import 'dart:convert';
import 'dart:math';

import 'package:backlog_vault/core/database/app_database.dart';
import 'package:backlog_vault/core/ids/id_generator.dart';
import 'package:backlog_vault/core/time/clock.dart';
import 'package:backlog_vault/features/sync/data/encrypted_pairing_codec.dart';
import 'package:backlog_vault/features/sync/data/encrypted_sync_package_codec.dart';
import 'package:backlog_vault/features/sync/data/sync_change_applier.dart';
import 'package:backlog_vault/features/sync/data/sync_change_tracking.dart';
import 'package:backlog_vault/features/sync/data/sync_conflict_detector.dart';
import 'package:backlog_vault/features/sync/data/sync_device_identity.dart';
import 'package:backlog_vault/features/sync/data/sync_group_management.dart';
import 'package:backlog_vault/features/sync/data/sync_package_builder.dart';
import 'package:backlog_vault/features/sync/data/sync_package_service.dart';
import 'package:backlog_vault/features/sync/data/sync_pairing_service.dart';
import 'package:backlog_vault/features/sync/domain/sync_models.dart';
import 'package:backlog_vault/features/sync/domain/sync_package_models.dart';
import 'package:backlog_vault/features/sync/domain/sync_pairing_models.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:test/test.dart';

const _deviceA = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
const _deviceB = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb';
const _deviceC = 'cccccccc-cccc-4ccc-8ccc-cccccccccccc';
const _wrongKeyId = 'dddddddd-dddd-4ddd-8ddd-dddddddddddd';
final _now = DateTime.utc(2026, 6, 22, 12);

void main() {
  test(
    'BVP1 pairing codec authenticates and hides the entire payload',
    () async {
      final codec = EncryptedPairingCodec(iterations: 1, random: Random(1));
      final clear = utf8.encode(
        '{"groupKey":"test_group_key_material","displayName":"My devices"}',
      );

      final encrypted = await codec.encrypt(clear, 'test pairing passphrase');
      final second = await codec.encrypt(clear, 'test pairing passphrase');
      final decrypted = await codec.decrypt(
        encrypted,
        'test pairing passphrase',
      );

      expect(encrypted.take(4), [0x42, 0x56, 0x50, 0x31]);
      expect(String.fromCharCodes(encrypted), isNot(contains('My devices')));
      expect(
        String.fromCharCodes(encrypted),
        isNot(contains('test_group_key_material')),
      );
      expect(second, isNot(equals(encrypted)));
      expect(decrypted, clear);

      await expectLater(
        codec.decrypt(encrypted, 'wrong test passphrase'),
        throwsA(isA<SyncPairingException>()),
      );
      final tampered = [...encrypted]..[encrypted.length - 1] ^= 0x40;
      await expectLater(
        codec.decrypt(tampered, 'test pairing passphrase'),
        throwsA(isA<SyncPairingException>()),
      );
      final invalidMagic = [...encrypted]..[0] = 0;
      await expectLater(
        codec.decrypt(invalidMagic, 'test pairing passphrase'),
        throwsA(isA<SyncPairingException>()),
      );
    },
  );

  test('create group stores only public metadata in SQLite', () async {
    final a = await _PairingHarness.create(_deviceA, seed: 2);
    addTearDown(a.close);

    final identityBefore = await a.identity.ensureIdentity();
    final group = await a.pairing.createGroup('My devices');
    final state = await a.manager.state();
    final row = await a.db.select(a.db.syncGroups).getSingle();
    final storedKey = await a.keys.read(group.keyId);

    expect(state.group?.id, group.id);
    expect(state.hasGroupKey, isTrue);
    expect(storedKey, hasLength(32));
    expect(row.keyId, group.keyId);
    expect(row.status, SyncGroupManager.activeStatus);
    expect(jsonEncode(row.toJson()), isNot(contains(base64Encode(storedKey!))));
    expect((await a.identity.ensureIdentity()).id, identityBefore.id);
    expect(
      (await a.db.select(a.db.syncStates).getSingle()).syncGroupId,
      group.id,
    );
  });

  test(
    'encrypted invitation pairs another device and expires safely',
    () async {
      final a = await _PairingHarness.create(_deviceA, seed: 3);
      final b = await _PairingHarness.create(_deviceB, seed: 4);
      addTearDown(a.close);
      addTearDown(b.close);
      final group = await a.pairing.createGroup('A and B');

      final exported = await a.pairing.exportInvitation(
        passphrase: 'test temporary passphrase',
      );
      expect(exported.fileName, endsWith('.vaultpair'));
      final encryptedText = String.fromCharCodes(exported.bytes);
      expect(encryptedText, isNot(contains(group.id)));
      expect(encryptedText, isNot(contains('A and B')));

      await b.pairing.importInvitation(
        exported.bytes,
        passphrase: 'test temporary passphrase',
      );
      final bState = await b.manager.state();
      expect(bState.group?.id, group.id);
      expect(bState.group?.keyId, group.keyId);
      expect(bState.pairedDeviceCount, 1);
      expect(bState.hasGroupKey, isTrue);
      expect(await b.keys.read(group.keyId), await a.keys.read(group.keyId));

      await expectLater(
        b.pairing.previewInvitation(
          exported.bytes,
          passphrase: 'wrong test passphrase',
        ),
        throwsA(isA<SyncPairingException>()),
      );
      final expired = await a.pairing.exportInvitation(
        passphrase: 'test temporary passphrase',
        validity: Duration.zero,
      );
      await expectLater(
        b.pairing.previewInvitation(
          expired.bytes,
          passphrase: 'test temporary passphrase',
        ),
        throwsA(
          isA<SyncPairingException>().having(
            (error) => error.failure,
            'failure',
            SyncPairingFailure.invitationExpired,
          ),
        ),
      );
    },
  );

  test('different active group blocks invitation import', () async {
    final a = await _PairingHarness.create(_deviceA, seed: 5);
    final b = await _PairingHarness.create(_deviceB, seed: 6);
    addTearDown(a.close);
    addTearDown(b.close);
    await a.pairing.createGroup('Group A');
    await b.pairing.createGroup('Group B');
    final invitation = await a.pairing.exportInvitation(
      passphrase: 'test passphrase',
    );

    await expectLater(
      b.pairing.importInvitation(
        invitation.bytes,
        passphrase: 'test passphrase',
      ),
      throwsA(
        isA<SyncPairingException>().having(
          (error) => error.failure,
          'failure',
          SyncPairingFailure.existingGroup,
        ),
      ),
    );
  });

  test('same key id never replaces divergent local key material', () async {
    final a = await _PairingHarness.create(_deviceA, seed: 13);
    final b = await _PairingHarness.create(_deviceB, seed: 14);
    addTearDown(a.close);
    addTearDown(b.close);
    final group = await a.pairing.createGroup('Shared group');
    final exported = await a.pairing.exportInvitation(
      passphrase: 'test passphrase',
    );
    final invitation = await a.pairing.previewInvitation(
      exported.bytes,
      passphrase: 'test passphrase',
    );
    await b.manager.importInvitation(invitation);
    final originalKey = await b.keys.read(group.keyId);
    final divergent = PairingInvitation(
      formatVersion: invitation.formatVersion,
      syncProtocolVersion: invitation.syncProtocolVersion,
      createdAt: invitation.createdAt,
      expiresAt: invitation.expiresAt,
      group: PairingInvitationGroup(
        groupId: invitation.group.groupId,
        displayName: invitation.group.displayName,
        keyId: invitation.group.keyId,
        groupKey: List<int>.filled(32, 0x7f),
      ),
      inviterDevice: invitation.inviterDevice,
    );

    await expectLater(
      b.manager.importInvitation(divergent),
      throwsA(
        isA<SyncPairingException>().having(
          (error) => error.failure,
          'failure',
          SyncPairingFailure.keyIdMismatch,
        ),
      ),
    );
    expect(await b.keys.read(group.keyId), originalKey);
  });

  test(
    'leave removes key but preserves identity, library and changelog',
    () async {
      final a = await _PairingHarness.create(_deviceA, seed: 7);
      addTearDown(a.close);
      await a.runner.run(
        source: SyncChangeSource.manual,
        action:
            (_) => a.db
                .into(a.db.games)
                .insert(
                  GamesCompanion.insert(
                    id: 'game-1',
                    title: 'Keep me',
                    createdAt: _now,
                    updatedAt: _now,
                  ),
                ),
      );
      final group = await a.pairing.createGroup('Disposable group');
      final oldKey = await a.keys.read(group.keyId);
      final identity = await a.identity.ensureIdentity();

      await a.manager.leaveGroup();

      expect(await a.keys.read(group.keyId), isNull);
      expect(await a.db.select(a.db.games).get(), hasLength(1));
      expect(await a.db.select(a.db.syncChanges).get(), hasLength(1));
      expect((await a.identity.ensureIdentity()).id, identity.id);
      expect((await a.manager.state()).group, isNull);
      await expectLater(
        a.syncPackages.exportWithGroupKey(),
        throwsA(isA<SyncPairingException>()),
      );

      final replacement = await a.pairing.createGroup('Replacement group');
      expect(replacement.id, isNot(group.id));
      expect(replacement.keyId, isNot(group.keyId));
      expect(await a.keys.read(replacement.keyId), isNot(equals(oldKey)));
    },
  );

  test(
    'paired group packages roundtrip while password mode remains valid',
    () async {
      final a = await _PairingHarness.create(_deviceA, seed: 8);
      final b = await _PairingHarness.create(_deviceB, seed: 9);
      addTearDown(a.close);
      addTearDown(b.close);
      await a.pairing.createGroup('Shared group');
      final invitation = await a.pairing.exportInvitation(
        passphrase: 'test pairing passphrase',
      );
      await b.pairing.importInvitation(
        invitation.bytes,
        passphrase: 'test pairing passphrase',
      );
      await a.runner.run(
        source: SyncChangeSource.manual,
        action:
            (_) => a.db
                .into(a.db.games)
                .insert(
                  GamesCompanion.insert(
                    id: 'paired-game',
                    title: 'Paired secret game',
                    createdAt: _now,
                    updatedAt: _now,
                  ),
                ),
      );

      final groupPackage = await a.syncPackages.exportWithGroupKey();
      final header = a.syncCodec.inspect(groupPackage.bytes);
      expect(header.keyMode, SyncPackageKeyMode.group);
      expect(
        String.fromCharCodes(groupPackage.bytes),
        isNot(contains('Paired secret game')),
      );
      final preview = await b.syncPackages.previewWithGroupKey(
        groupPackage.bytes,
      );
      expect(preview.count(SyncImportDisposition.applicable), 1);
      expect(
        (await b.syncPackages.applySafeChangesWithGroupKey(
          groupPackage.bytes,
        )).applied,
        1,
      );
      expect(
        (await b.syncPackages.applySafeChangesWithGroupKey(
          groupPackage.bytes,
        )).applied,
        0,
      );
      expect(
        (await b.db.select(b.db.games).getSingle()).title,
        'Paired secret game',
      );

      final passwordPackage = await a.syncPackages.export(
        password: 'test manual password',
      );
      expect(
        a.syncCodec.inspect(passwordPackage.bytes).keyMode,
        SyncPackageKeyMode.password,
      );
      expect(
        (await b.syncPackages.preview(
          passwordPackage.bytes,
          password: 'test manual password',
        )).count(SyncImportDisposition.alreadyApplied),
        1,
      );
    },
  );

  test(
    'group package rejects missing key, other group and wrong key id',
    () async {
      final a = await _PairingHarness.create(_deviceA, seed: 10);
      final b = await _PairingHarness.create(_deviceB, seed: 11);
      final c = await _PairingHarness.create(_deviceC, seed: 12);
      addTearDown(a.close);
      addTearDown(b.close);
      addTearDown(c.close);
      final group = await a.pairing.createGroup('Shared group');
      final invitation = await a.pairing.exportInvitation(
        passphrase: 'test passphrase',
      );
      await b.pairing.importInvitation(
        invitation.bytes,
        passphrase: 'test passphrase',
      );
      await c.pairing.createGroup('Other group');
      final package = await a.syncPackages.exportWithGroupKey();

      await b.keys.delete(group.keyId);
      await expectLater(
        b.syncPackages.previewWithGroupKey(package.bytes),
        throwsA(
          isA<SyncPairingException>().having(
            (error) => error.failure,
            'failure',
            SyncPairingFailure.keyMissing,
          ),
        ),
      );
      await expectLater(
        c.syncPackages.previewWithGroupKey(package.bytes),
        throwsA(
          isA<SyncPairingException>().having(
            (error) => error.failure,
            'failure',
            SyncPairingFailure.groupMismatch,
          ),
        ),
      );

      await b.keys.save(_wrongKeyId, List<int>.filled(32, 7));
      await (b.db.update(b.db.syncGroups)..where(
        (row) => row.id.equals(group.id),
      )).write(const SyncGroupsCompanion(keyId: Value(_wrongKeyId)));
      await expectLater(
        b.syncPackages.previewWithGroupKey(package.bytes),
        throwsA(
          isA<SyncPairingException>().having(
            (error) => error.failure,
            'failure',
            SyncPairingFailure.keyIdMismatch,
          ),
        ),
      );
    },
  );
}

class _PairingHarness {
  _PairingHarness({
    required this.db,
    required this.identity,
    required this.keys,
    required this.manager,
    required this.pairing,
    required this.runner,
    required this.syncCodec,
    required this.syncPackages,
  });

  final AppDatabase db;
  final SyncDeviceIdentityService identity;
  final _MemoryGroupKeyStore keys;
  final SyncGroupManager manager;
  final SyncPairingService pairing;
  final SyncAwareTransaction runner;
  final EncryptedSyncPackageCodec syncCodec;
  final SyncPackageService syncPackages;

  static Future<_PairingHarness> create(
    String deviceId, {
    required int seed,
  }) async {
    final db = AppDatabase(NativeDatabase.memory());
    final identity = SyncDeviceIdentityService(
      store: _MemoryIdentityStore(deviceId),
      repository: SyncDeviceRepository(db),
      clock: _FixedClock(_now),
      platformLoader: () => deviceId == _deviceA ? 'windows' : 'android',
    );
    final reader = LogicalLibrarySnapshotReader(db);
    const differ = SyncSnapshotDiffer();
    final recorder = SyncChangeRecorder(db, clock: _FixedClock(_now));
    final initializer = SyncFoundationInitializer(
      database: db,
      snapshotReader: reader,
      differ: differ,
      recorder: recorder,
      clock: _FixedClock(_now),
    );
    final runner = SyncAwareTransaction(
      database: db,
      identityService: identity,
      initializer: initializer,
      snapshotReader: reader,
      differ: differ,
      recorder: recorder,
      ids: _UuidSequence(seed, start: 30),
    );
    await initializer.initialize(await identity.ensureIdentity());
    final keys = _MemoryGroupKeyStore();
    final manager = SyncGroupManager(
      database: db,
      keyStore: keys,
      identityService: identity,
      initializer: initializer,
      ids: _UuidSequence(seed, start: 1),
      clock: _FixedClock(_now),
      random: Random(seed),
    );
    final pairingCodec = EncryptedPairingCodec(
      iterations: 1,
      random: Random(seed),
    );
    final pairing = SyncPairingService(
      groupManager: manager,
      codec: pairingCodec,
      clock: _FixedClock(_now),
    );
    final builder = SyncPackageBuilder(
      database: db,
      identityService: identity,
      initializer: initializer,
      ids: _UuidSequence(seed, start: 60),
      clock: _FixedClock(_now),
    );
    final detector = SyncConflictDetector(database: db, snapshotReader: reader);
    final syncCodec = EncryptedSyncPackageCodec(
      iterations: 1,
      random: Random(seed + 100),
    );
    final applier = SyncChangeApplier(
      database: db,
      transaction: runner,
      conflictDetector: detector,
      clock: _FixedClock(_now),
    );
    final syncPackages = SyncPackageService(
      builder: builder,
      codec: syncCodec,
      conflictDetector: detector,
      changeApplier: applier,
      groupKeys: manager,
      clock: _FixedClock(_now),
    );
    return _PairingHarness(
      db: db,
      identity: identity,
      keys: keys,
      manager: manager,
      pairing: pairing,
      runner: runner,
      syncCodec: syncCodec,
      syncPackages: syncPackages,
    );
  }

  Future<void> close() => db.close();
}

class _MemoryIdentityStore implements SyncIdentityStore {
  _MemoryIdentityStore(this.value);

  String? value;

  @override
  Future<String?> readDeviceId() async => value;

  @override
  Future<void> writeDeviceId(String deviceId) async => value = deviceId;
}

class _MemoryGroupKeyStore implements SyncGroupKeyStore {
  final values = <String, List<int>>{};

  @override
  Future<void> save(String keyId, List<int> keyBytes) async {
    values[keyId] = List<int>.from(keyBytes);
  }

  @override
  Future<List<int>?> read(String keyId) async {
    final value = values[keyId];
    return value == null ? null : List<int>.from(value);
  }

  @override
  Future<void> delete(String keyId) async => values.remove(keyId);
}

class _UuidSequence extends IdGenerator {
  _UuidSequence(this.seed, {required this.start});

  final int seed;
  final int start;
  var offset = 0;

  @override
  String newId() {
    final value = start + offset++;
    final suffix = (seed * 1000 + value).toString().padLeft(12, '0');
    return '${value.toRadixString(16).padLeft(8, '0')}-0000-4000-8000-$suffix';
  }
}

class _FixedClock extends Clock {
  const _FixedClock(this.value);

  final DateTime value;

  @override
  DateTime now() => value;
}
