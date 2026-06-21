import 'dart:convert';
import 'dart:math';

import 'package:backlog_vault/core/database/app_database.dart';
import 'package:backlog_vault/core/ids/id_generator.dart';
import 'package:backlog_vault/core/time/clock.dart';
import 'package:backlog_vault/features/sync/data/canonical_json.dart';
import 'package:backlog_vault/features/sync/data/encrypted_sync_package_codec.dart';
import 'package:backlog_vault/features/sync/data/sync_change_applier.dart';
import 'package:backlog_vault/features/sync/data/sync_change_tracking.dart';
import 'package:backlog_vault/features/sync/data/sync_conflict_detector.dart';
import 'package:backlog_vault/features/sync/data/sync_device_identity.dart';
import 'package:backlog_vault/features/sync/data/sync_package_builder.dart';
import 'package:backlog_vault/features/sync/data/sync_package_service.dart';
import 'package:backlog_vault/features/sync/domain/sync_models.dart';
import 'package:backlog_vault/features/sync/domain/sync_package_models.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:test/test.dart';

const _deviceA = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
const _deviceB = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb';
final _now = DateTime.utc(2026, 6, 21, 12);

void main() {
  test(
    'cross-device package applies all supported entities idempotently',
    () async {
      final a = await _SyncHarness.create(_deviceA, seed: 1);
      final b = await _SyncHarness.create(_deviceB, seed: 2);
      addTearDown(a.close);
      addTearDown(b.close);
      await _insertCompleteGraph(a);

      final exported = await a.service.export(password: 'test sync password');
      final encryptedText = String.fromCharCodes(exported.bytes);
      expect(exported.fileName, endsWith('.vaultsync'));
      expect(exported.changeCount, 9);
      expect(encryptedText, isNot(contains('Cross-device game')));

      final preview = await b.service.preview(
        exported.bytes,
        password: 'test sync password',
      );
      expect(preview.count(SyncImportDisposition.applicable), 9);
      expect(preview.count(SyncImportDisposition.conflict), 0);

      final result = await b.service.applySafeChanges(
        exported.bytes,
        password: 'test sync password',
      );
      expect(result.applied, 9);
      expect(await b.db.select(b.db.games).get(), hasLength(1));
      expect(await b.db.select(b.db.libraryEntries).get(), hasLength(1));
      expect(await b.db.select(b.db.platforms).get(), hasLength(1));
      expect(await b.db.select(b.db.genres).get(), hasLength(1));
      expect(await b.db.select(b.db.playthroughs).get(), hasLength(1));
      expect(await b.db.select(b.db.savedViews).get(), hasLength(1));
      expect(await b.db.select(b.db.externalGameIds).get(), hasLength(1));

      final repeated = await b.service.preview(
        exported.bytes,
        password: 'test sync password',
      );
      expect(repeated.count(SyncImportDisposition.alreadyApplied), 9);
      expect(
        (await b.service.applySafeChanges(
          exported.bytes,
          password: 'test sync password',
        )).applied,
        0,
      );
      expect(await b.db.select(b.db.syncChanges).get(), hasLength(9));
      expect((await b.localState()).nextLocalCounter, 1);
    },
  );

  test(
    'same-field local edit is a conflict and is never overwritten',
    () async {
      final a = await _SyncHarness.create(_deviceA, seed: 3);
      final b = await _SyncHarness.create(_deviceB, seed: 4);
      addTearDown(a.close);
      addTearDown(b.close);
      await _insertCompleteGraph(a);
      final initial = await a.service.export(password: 'test password');
      await b.service.applySafeChanges(
        initial.bytes,
        password: 'test password',
      );

      await b.runner.run(
        source: SyncChangeSource.manual,
        action:
            (_) =>
                (b.db.update(b.db.games)
                  ..where((row) => row.id.equals('game-1'))).write(
                  GamesCompanion(
                    title: const Value('Local B title'),
                    updatedAt: Value(_now.add(const Duration(minutes: 1))),
                  ),
                ),
      );
      await a.runner.run(
        source: SyncChangeSource.manual,
        action:
            (_) =>
                (a.db.update(a.db.games)
                  ..where((row) => row.id.equals('game-1'))).write(
                  GamesCompanion(
                    title: const Value('Remote A title'),
                    updatedAt: Value(_now.add(const Duration(minutes: 2))),
                  ),
                ),
      );
      final update = await a.service.export(password: 'test password');

      final preview = await b.service.preview(
        update.bytes,
        password: 'test password',
      );
      expect(preview.count(SyncImportDisposition.conflict), 1);
      final result = await b.service.applySafeChanges(
        update.bytes,
        password: 'test password',
      );
      expect(result.applied, 0);
      expect(
        (await b.db.select(b.db.games).getSingle()).title,
        'Local B title',
      );
    },
  );

  test('different-field edits merge without last-write-wins', () async {
    final a = await _SyncHarness.create(_deviceA, seed: 5);
    final b = await _SyncHarness.create(_deviceB, seed: 6);
    addTearDown(a.close);
    addTearDown(b.close);
    await _insertCompleteGraph(a);
    final initial = await a.service.export(password: 'test password');
    await b.service.applySafeChanges(initial.bytes, password: 'test password');

    await b.runner.run(
      source: SyncChangeSource.manual,
      action:
          (_) =>
              (b.db.update(b.db.games)
                ..where((row) => row.id.equals('game-1'))).write(
                GamesCompanion(
                  sortTitle: const Value('Local sort title'),
                  updatedAt: Value(_now.add(const Duration(minutes: 1))),
                ),
              ),
    );
    await a.runner.run(
      source: SyncChangeSource.manual,
      action:
          (_) =>
              (a.db.update(a.db.games)
                ..where((row) => row.id.equals('game-1'))).write(
                GamesCompanion(
                  title: const Value('Remote title'),
                  updatedAt: Value(_now.add(const Duration(minutes: 2))),
                ),
              ),
    );
    final update = await a.service.export(password: 'test password');

    final preview = await b.service.preview(
      update.bytes,
      password: 'test password',
    );
    expect(preview.count(SyncImportDisposition.applicable), 1);
    await b.service.applySafeChanges(update.bytes, password: 'test password');
    final game = await b.db.select(b.db.games).getSingle();
    expect(game.title, 'Remote title');
    expect(game.sortTitle, 'Local sort title');
  });

  test('remote soft delete creates tombstones without hard delete', () async {
    final a = await _SyncHarness.create(_deviceA, seed: 7);
    final b = await _SyncHarness.create(_deviceB, seed: 8);
    addTearDown(a.close);
    addTearDown(b.close);
    await _insertCompleteGraph(a);
    final initial = await a.service.export(password: 'test password');
    await b.service.applySafeChanges(initial.bytes, password: 'test password');

    await a.runner.run(
      source: SyncChangeSource.manual,
      action: (_) async {
        final deletedAt = _now.add(const Duration(minutes: 3));
        await (a.db.update(a.db.libraryEntries)
          ..where((row) => row.id.equals('entry-1'))).write(
          LibraryEntriesCompanion(
            updatedAt: Value(deletedAt),
            deletedAt: Value(deletedAt),
          ),
        );
        await (a.db.update(a.db.games)
          ..where((row) => row.id.equals('game-1'))).write(
          GamesCompanion(
            updatedAt: Value(deletedAt),
            deletedAt: Value(deletedAt),
          ),
        );
      },
    );
    final deletion = await a.service.export(password: 'test password');
    final result = await b.service.applySafeChanges(
      deletion.bytes,
      password: 'test password',
    );

    expect(result.applied, 2);
    expect((await b.db.select(b.db.games).getSingle()).deletedAt, isNotNull);
    expect(
      (await b.db.select(b.db.libraryEntries).getSingle()).deletedAt,
      isNotNull,
    );
    expect(await b.db.select(b.db.syncTombstones).get(), hasLength(2));
    expect(await b.db.select(b.db.games).get(), hasLength(1));
  });

  test('media changes stay pending and never create a broken cover', () async {
    final a = await _SyncHarness.create(_deviceA, seed: 9);
    final b = await _SyncHarness.create(_deviceB, seed: 10);
    addTearDown(a.close);
    addTearDown(b.close);
    await b.runner.run(
      source: SyncChangeSource.manual,
      action: (_) async {
        await b.db
            .into(b.db.games)
            .insert(
              GamesCompanion.insert(
                id: 'local-game',
                title: 'Local media game',
                createdAt: _now,
                updatedAt: _now,
              ),
            );
        await b.db
            .into(b.db.mediaAssets)
            .insert(
              MediaAssetsCompanion.insert(
                id: 'local-media',
                gameId: 'local-game',
                kind: 'cover',
                source: 'local',
                localPath: 'covers/local-cover.png',
                fileName: 'local-cover.png',
                hash: const Value('sha256-local'),
                isSelected: const Value(true),
                createdAt: _now,
                updatedAt: _now,
              ),
            );
      },
    );
    await a.runner.run(
      source: SyncChangeSource.manual,
      action: (_) async {
        await a.db
            .into(a.db.games)
            .insert(
              GamesCompanion.insert(
                id: 'game-media',
                title: 'Media game',
                createdAt: _now,
                updatedAt: _now,
              ),
            );
        await a.db
            .into(a.db.mediaAssets)
            .insert(
              MediaAssetsCompanion.insert(
                id: 'media-1',
                gameId: 'game-media',
                kind: 'cover',
                source: 'local',
                localPath: r'C:\device-a\cover.png',
                fileName: 'cover.png',
                hash: const Value('sha256-test'),
                isSelected: const Value(true),
                createdAt: _now,
                updatedAt: _now,
              ),
            );
      },
    );
    final exported = await a.service.export(password: 'test password');

    final preview = await b.service.preview(
      exported.bytes,
      password: 'test password',
    );
    expect(preview.count(SyncImportDisposition.applicable), 1);
    expect(preview.count(SyncImportDisposition.pendingMedia), 1);
    final result = await b.service.applySafeChanges(
      exported.bytes,
      password: 'test password',
    );
    expect(result.applied, 1);
    final media = await b.db.select(b.db.mediaAssets).get();
    expect(media, hasLength(1));
    expect(media.single.id, 'local-media');
    expect(media.single.localPath, 'covers/local-cover.png');
    expect(media.single.isSelected, isTrue);
    expect(
      (await (b.db.select(b.db.games)
            ..where((row) => row.id.equals('game-media'))).getSingle())
          .title,
      'Media game',
    );
  });

  test('safe batch rolls back business rows and oplog on failure', () async {
    final a = await _SyncHarness.create(_deviceA, seed: 11);
    final b = await _SyncHarness.create(_deviceB, seed: 12);
    addTearDown(a.close);
    addTearDown(b.close);
    await a.runner.run(
      source: SyncChangeSource.manual,
      action: (_) async {
        for (final id in ['game-1', 'game-2']) {
          await a.db
              .into(a.db.games)
              .insert(
                GamesCompanion.insert(
                  id: id,
                  title: id,
                  createdAt: _now,
                  updatedAt: _now,
                ),
              );
        }
      },
    );
    final exported = await a.service.export(password: 'test password');
    await b.db.customStatement(
      'CREATE TRIGGER test_fail_second_game BEFORE INSERT ON games '
      'WHEN NEW.id = \'game-2\' BEGIN SELECT RAISE(ABORT, \'test\'); END',
    );

    await expectLater(
      b.service.applySafeChanges(exported.bytes, password: 'test password'),
      throwsA(anything),
    );
    expect(await b.db.select(b.db.games).get(), isEmpty);
    expect(await b.db.select(b.db.syncChanges).get(), isEmpty);
    expect((await b.localState()).lastImportedPackageId, isNull);
  });

  test(
    'preview reports unsupported and invalid changes conservatively',
    () async {
      final a = await _SyncHarness.create(_deviceA, seed: 13);
      final b = await _SyncHarness.create(_deviceB, seed: 16);
      addTearDown(a.close);
      addTearDown(b.close);
      await a.runner.run(
        source: SyncChangeSource.manual,
        action:
            (_) => a.db
                .into(a.db.games)
                .insert(
                  GamesCompanion.insert(
                    id: 'game-1',
                    title: 'Game',
                    createdAt: _now,
                    updatedAt: _now,
                  ),
                ),
      );
      final document = await a.builder.build();
      final original = document.changes.single;
      final unsupported = _changeWith(
        original,
        entityType: 'future_entity',
        contentHash: null,
      );
      final invalid = _changeWith(original, contentHash: 'invalid-hash');

      expect(
        (await b.detector.preview(
          _documentWith(document, [unsupported]),
        )).count(SyncImportDisposition.unsupported),
        1,
      );
      expect(
        (await b.detector.preview(
          _documentWith(document, [invalid]),
        )).count(SyncImportDisposition.invalid),
        1,
      );
    },
  );

  test(
    'export is canonical apart from package identity and encryption randomness',
    () async {
      final a = await _SyncHarness.create(_deviceA, seed: 14);
      addTearDown(a.close);
      await a.runner.run(
        source: SyncChangeSource.manual,
        action:
            (_) => a.db
                .into(a.db.games)
                .insert(
                  GamesCompanion.insert(
                    id: 'game-secret',
                    title:
                        r'client_secret=test_client_secret C:\Users\example\game.txt',
                    createdAt: _now,
                    updatedAt: _now,
                  ),
                ),
      );

      final first = (await a.builder.build()).toJson()..remove('packageId');
      final second = (await a.builder.build()).toJson()..remove('packageId');
      expect(canonicalJson.encode(first), canonicalJson.encode(second));

      final exported = await a.service.export(password: 'test password');
      final clear = utf8.decode(
        await a.codec.decrypt(exported.bytes, 'test password'),
      );
      expect(clear, isNot(contains('test_client_secret')));
      expect(clear, isNot(contains(r'C:\Users\example')));
      expect(clear, isNot(contains('sync.local.device_id')));
      expect(clear, isNot(contains('api_key')));
    },
  );

  test('service preview rejects wrong passwords and invalid files', () async {
    final a = await _SyncHarness.create(_deviceA, seed: 15);
    addTearDown(a.close);
    final exported = await a.service.export(password: 'test password');

    await expectLater(
      a.service.preview(exported.bytes, password: 'wrong test password'),
      throwsA(isA<SyncPackageException>()),
    );
    await expectLater(
      a.service.preview([1, 2, 3], password: 'test password'),
      throwsA(isA<SyncPackageException>()),
    );
  });
}

Future<void> _insertCompleteGraph(_SyncHarness harness) {
  return harness.runner.run(
    source: SyncChangeSource.manual,
    action: (_) async {
      await harness.db
          .into(harness.db.platforms)
          .insert(
            PlatformsCompanion.insert(
              id: 'platform-1',
              name: 'PC',
              createdAt: _now,
              updatedAt: _now,
            ),
          );
      await harness.db
          .into(harness.db.genres)
          .insert(
            GenresCompanion.insert(
              id: 'genre-1',
              name: 'RPG',
              createdAt: _now,
              updatedAt: _now,
            ),
          );
      await harness.db
          .into(harness.db.games)
          .insert(
            GamesCompanion.insert(
              id: 'game-1',
              title: 'Cross-device game',
              createdAt: _now,
              updatedAt: _now,
            ),
          );
      await harness.db
          .into(harness.db.libraryEntries)
          .insert(
            LibraryEntriesCompanion.insert(
              id: 'entry-1',
              gameId: 'game-1',
              status: 'backlog',
              createdAt: _now,
              updatedAt: _now,
            ),
          );
      await harness.db
          .into(harness.db.libraryEntryPlatforms)
          .insert(
            LibraryEntryPlatformsCompanion.insert(
              id: 'platform-link-1',
              libraryEntryId: 'entry-1',
              platformId: 'platform-1',
              isPrimary: const Value(true),
              createdAt: _now,
              updatedAt: _now,
            ),
          );
      await harness.db
          .into(harness.db.gameGenres)
          .insert(
            GameGenresCompanion.insert(
              id: 'genre-link-1',
              gameId: 'game-1',
              genreId: 'genre-1',
              createdAt: _now,
              updatedAt: _now,
            ),
          );
      await harness.db
          .into(harness.db.playthroughs)
          .insert(
            PlaythroughsCompanion.insert(
              id: 'playthrough-1',
              libraryEntryId: 'entry-1',
              platformId: const Value('platform-1'),
              status: 'planned',
              createdAt: _now,
              updatedAt: _now,
            ),
          );
      await harness.db
          .into(harness.db.savedViews)
          .insert(
            SavedViewsCompanion.insert(
              id: 'view-1',
              name: 'View',
              filterJson: '{}',
              sortJson: '{}',
              columnConfigJson: '{}',
              createdAt: _now,
              updatedAt: _now,
            ),
          );
      await harness.db
          .into(harness.db.externalGameIds)
          .insert(
            ExternalGameIdsCompanion.insert(
              id: 'external-1',
              gameId: 'game-1',
              provider: 'rawg',
              externalId: 'rawg-1',
              createdAt: _now,
              updatedAt: _now,
            ),
          );
    },
  );
}

SyncPackageDocument _documentWith(
  SyncPackageDocument source,
  List<SyncPackageChange> changes,
) {
  return SyncPackageDocument(
    packageId: source.packageId,
    formatVersion: source.formatVersion,
    syncProtocolVersion: source.syncProtocolVersion,
    createdAt: source.createdAt,
    fromDevice: source.fromDevice,
    exportedVector: source.exportedVector,
    changes: changes,
    tombstones: source.tombstones,
    entityStates: source.entityStates,
    mediaManifest: source.mediaManifest,
    warnings: source.warnings,
  );
}

SyncPackageChange _changeWith(
  SyncPackageChange source, {
  String? entityType,
  String? contentHash,
}) {
  final changed = SyncPackageChange(
    changeId: source.changeId,
    originDeviceId: source.originDeviceId,
    originCounter: source.originCounter,
    mutationId: source.mutationId,
    mutationSequence: source.mutationSequence,
    entityType: entityType ?? source.entityType,
    entityId: source.entityId,
    operation: source.operation,
    changedFields: source.changedFields,
    payload: source.payload,
    snapshot: source.snapshot,
    causalContext: source.causalContext,
    source: source.source,
    contentHash: contentHash ?? '',
    createdAt: source.createdAt,
  );
  if (contentHash != null) return changed;
  final content = <String, Object?>{
    'causalContext': changed.causalContext,
    'changedFields': [...changed.changedFields]..sort(),
    'entityId': changed.entityId,
    'entityType': changed.entityType,
    'operation': changed.operation,
    'originCounter': changed.originCounter,
    'originDeviceId': changed.originDeviceId,
    'payload': changed.payload,
    'snapshot': changed.snapshot,
    'source': changed.source,
  };
  return SyncPackageChange(
    changeId: changed.changeId,
    originDeviceId: changed.originDeviceId,
    originCounter: changed.originCounter,
    mutationId: changed.mutationId,
    mutationSequence: changed.mutationSequence,
    entityType: changed.entityType,
    entityId: changed.entityId,
    operation: changed.operation,
    changedFields: changed.changedFields,
    payload: changed.payload,
    snapshot: changed.snapshot,
    causalContext: changed.causalContext,
    source: changed.source,
    contentHash: canonicalJson.sha256Hex(content),
    createdAt: changed.createdAt,
  );
}

class _SyncHarness {
  _SyncHarness({
    required this.db,
    required this.runner,
    required this.builder,
    required this.detector,
    required this.codec,
    required this.service,
  });

  final AppDatabase db;
  final SyncAwareTransaction runner;
  final SyncPackageBuilder builder;
  final SyncConflictDetector detector;
  final EncryptedSyncPackageCodec codec;
  final SyncPackageService service;

  static Future<_SyncHarness> create(
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
      ids: _SequenceIds(
        List.generate(50, (index) => 'mutation-$seed-${index + 1}'),
      ),
    );
    await initializer.initialize(await identity.ensureIdentity());
    final builder = SyncPackageBuilder(
      database: db,
      identityService: identity,
      initializer: initializer,
      ids: _SequenceIds(
        List.generate(
          20,
          (index) =>
              '${seed.toString().padLeft(8, '0')}-0000-4000-8000-'
              '${(index + 1).toString().padLeft(12, '0')}',
        ),
      ),
      clock: _FixedClock(_now),
    );
    final detector = SyncConflictDetector(database: db, snapshotReader: reader);
    final codec = EncryptedSyncPackageCodec(
      iterations: 1,
      random: Random(seed),
    );
    final applier = SyncChangeApplier(
      database: db,
      transaction: runner,
      conflictDetector: detector,
      clock: _FixedClock(_now),
    );
    final service = SyncPackageService(
      builder: builder,
      codec: codec,
      conflictDetector: detector,
      changeApplier: applier,
      clock: _FixedClock(_now),
    );
    return _SyncHarness(
      db: db,
      runner: runner,
      builder: builder,
      detector: detector,
      codec: codec,
      service: service,
    );
  }

  Future<SyncState> localState() =>
      (db.select(db.syncStates)
        ..where((row) => row.id.equals('local'))).getSingle();

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

class _SequenceIds extends IdGenerator {
  _SequenceIds(this.values);

  final List<String> values;
  var index = 0;

  @override
  String newId() {
    if (index >= values.length) throw StateError('No test ID available.');
    return values[index++];
  }
}

class _FixedClock extends Clock {
  const _FixedClock(this.value);

  final DateTime value;

  @override
  DateTime now() => value;
}
