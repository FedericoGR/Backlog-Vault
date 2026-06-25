import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:backlog_vault/core/database/app_database.dart';
import 'package:backlog_vault/core/ids/id_generator.dart';
import 'package:backlog_vault/core/time/clock.dart';
import 'package:backlog_vault/features/sync/data/canonical_json.dart';
import 'package:backlog_vault/features/sync/data/encrypted_sync_package_codec.dart';
import 'package:backlog_vault/features/sync/data/lan_sync_service.dart';
import 'package:backlog_vault/features/sync/data/sync_change_applier.dart';
import 'package:backlog_vault/features/sync/data/sync_change_tracking.dart';
import 'package:backlog_vault/features/sync/data/sync_conflict_detector.dart';
import 'package:backlog_vault/features/sync/data/sync_device_identity.dart';
import 'package:backlog_vault/features/sync/data/sync_group_management.dart';
import 'package:backlog_vault/features/sync/data/sync_package_builder.dart';
import 'package:backlog_vault/features/sync/data/sync_package_service.dart';
import 'package:backlog_vault/features/sync/domain/lan_sync_models.dart';
import 'package:backlog_vault/features/sync/domain/sync_models.dart';
import 'package:backlog_vault/features/sync/domain/sync_pairing_models.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:test/test.dart';

const _deviceA = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
const _deviceB = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb';
const _deviceC = 'cccccccc-cccc-4ccc-8ccc-cccccccccccc';
final _now = DateTime.utc(2026, 6, 23, 12);

void main() {
  test('host session starts with short code and stops cleanly', () async {
    final a = await _LanHarness.create(_deviceA, seed: 1);
    addTearDown(a.close);
    await a.manager.createGroup('LAN group');

    final session = await a.lan.startHost(
      bindAddress: InternetAddress.loopbackIPv4,
      displayAddress: InternetAddress.loopbackIPv4.address,
    );
    expect(session.host, InternetAddress.loopbackIPv4.address);
    expect(session.port, greaterThan(0));
    expect(session.sessionCode, matches(RegExp(r'^\d{6}$')));

    await session.stop();
    await expectLater(
      session.completed,
      throwsA(
        isA<LanSyncException>().having(
          (error) => error.failure,
          'failure',
          LanSyncFailure.stopped,
        ),
      ),
    );
  });

  test('paired devices exchange LAN packages idempotently', () async {
    final a = await _LanHarness.create(_deviceA, seed: 2);
    final b = await _LanHarness.create(_deviceB, seed: 3);
    addTearDown(a.close);
    addTearDown(b.close);
    await _pair(a, b);
    await _insertGame(a, 'game-a', 'Game from A');
    await _insertGame(b, 'game-b', 'Game from B');

    final session = await a.lan.startHost(
      bindAddress: InternetAddress.loopbackIPv4,
      displayAddress: InternetAddress.loopbackIPv4.address,
    );
    final clientResult = await b.lan.connectAndSync(
      host: session.host,
      port: session.port,
      sessionCode: session.sessionCode,
    );
    final hostResult = await session.completed;

    expect(clientResult.local.applied, greaterThan(0));
    expect(hostResult.local.applied, greaterThan(0));
    expect(await _gameTitles(a), containsAll(['Game from A', 'Game from B']));
    expect(await _gameTitles(b), containsAll(['Game from A', 'Game from B']));

    final repeat = await a.lan.startHost(
      bindAddress: InternetAddress.loopbackIPv4,
      displayAddress: InternetAddress.loopbackIPv4.address,
    );
    final repeatClient = await b.lan.connectAndSync(
      host: repeat.host,
      port: repeat.port,
      sessionCode: repeat.sessionCode,
    );
    final repeatHost = await repeat.completed;

    expect(repeatClient.local.applied, 0);
    expect(repeatHost.local.applied, 0);
    expect(await a.db.select(a.db.games).get(), hasLength(2));
    expect(await b.db.select(b.db.games).get(), hasLength(2));
  });

  test('same-field conflict is reported and never overwritten', () async {
    final a = await _LanHarness.create(_deviceA, seed: 4);
    final b = await _LanHarness.create(_deviceB, seed: 5);
    addTearDown(a.close);
    addTearDown(b.close);
    await _pair(a, b);
    await _insertGame(a, 'game-1', 'Shared game');

    final initial = await a.lan.startHost(
      bindAddress: InternetAddress.loopbackIPv4,
      displayAddress: InternetAddress.loopbackIPv4.address,
    );
    await b.lan.connectAndSync(
      host: initial.host,
      port: initial.port,
      sessionCode: initial.sessionCode,
    );
    await initial.completed;

    await _renameGame(a, 'game-1', 'Title from A', minutes: 1);
    await _renameGame(b, 'game-1', 'Title from B', minutes: 2);

    final conflict = await a.lan.startHost(
      bindAddress: InternetAddress.loopbackIPv4,
      displayAddress: InternetAddress.loopbackIPv4.address,
    );
    final client = await b.lan.connectAndSync(
      host: conflict.host,
      port: conflict.port,
      sessionCode: conflict.sessionCode,
    );
    final host = await conflict.completed;

    expect(client.local.conflicts, greaterThanOrEqualTo(1));
    expect(host.local.conflicts, greaterThanOrEqualTo(1));
    expect((await a.db.select(a.db.games).getSingle()).title, 'Title from A');
    expect((await b.db.select(b.db.games).getSingle()).title, 'Title from B');
  });

  test('invalid session code and wrong group are rejected', () async {
    final a = await _LanHarness.create(_deviceA, seed: 6);
    final b = await _LanHarness.create(_deviceB, seed: 7);
    final c = await _LanHarness.create(_deviceC, seed: 8);
    addTearDown(a.close);
    addTearDown(b.close);
    addTearDown(c.close);
    await _pair(a, b);
    await c.manager.createGroup('Other group');

    final wrongCode = await a.lan.startHost(
      bindAddress: InternetAddress.loopbackIPv4,
      displayAddress: InternetAddress.loopbackIPv4.address,
    );
    await expectLater(
      b.lan.connectAndSync(
        host: wrongCode.host,
        port: wrongCode.port,
        sessionCode: '000000',
      ),
      throwsA(
        isA<LanSyncException>().having(
          (error) => error.failure,
          'failure',
          LanSyncFailure.invalidSessionCode,
        ),
      ),
    );
    unawaited(wrongCode.completed.then<void>((_) {}, onError: (_) {}));
    await wrongCode.stop();

    final wrongGroup = await a.lan.startHost(
      bindAddress: InternetAddress.loopbackIPv4,
      displayAddress: InternetAddress.loopbackIPv4.address,
    );
    await expectLater(
      c.lan.connectAndSync(
        host: wrongGroup.host,
        port: wrongGroup.port,
        sessionCode: wrongGroup.sessionCode,
      ),
      throwsA(
        isA<LanSyncException>().having(
          (error) => error.failure,
          'failure',
          LanSyncFailure.groupMismatch,
        ),
      ),
    );
    unawaited(wrongGroup.completed.then<void>((_) {}, onError: (_) {}));
    await wrongGroup.stop();
  });

  test('host rejects oversized requests and corrupt packages', () async {
    final a = await _LanHarness.create(_deviceA, seed: 9);
    final b = await _LanHarness.create(_deviceB, seed: 10);
    final small = await _LanHarness.create(
      _deviceC,
      seed: 11,
      maxRequestBytes: 128,
    );
    addTearDown(a.close);
    addTearDown(b.close);
    addTearDown(small.close);
    await _pair(a, b);
    await small.manager.createGroup('Small request group');
    await _insertGame(b, 'game-b', 'Corrupt me not');

    final tooLarge = await small.lan.startHost(
      bindAddress: InternetAddress.loopbackIPv4,
      displayAddress: InternetAddress.loopbackIPv4.address,
    );
    final largeResponse = await _rawPost(
      port: tooLarge.port,
      path: '/sync/hello',
      body: {'padding': List.filled(256, 'x').join()},
    );
    expect(largeResponse.statusCode, HttpStatus.requestEntityTooLarge);
    unawaited(tooLarge.completed.then<void>((_) {}, onError: (_) {}));
    await tooLarge.stop();

    final corrupt = await a.lan.startHost(
      bindAddress: InternetAddress.loopbackIPv4,
      displayAddress: InternetAddress.loopbackIPv4.address,
    );
    final key = await b.manager.requireActiveGroupKey();
    final state = await b.manager.state();
    final clientNonce = 'test-client-nonce';
    final hello = await _rawPost(
      port: corrupt.port,
      path: '/sync/hello',
      body: {
        'formatVersion': 1,
        'syncProtocolVersion': 1,
        'groupId': key.groupId,
        'keyId': key.keyId,
        'device': state.localDevice.toJson(),
        'clientNonce': clientNonce,
        'proof': _proof(key.bytes, {
          'type': 'hello',
          'groupId': key.groupId,
          'keyId': key.keyId,
          'deviceId': state.localDevice.deviceId,
          'clientNonce': clientNonce,
          'sessionCode': corrupt.sessionCode,
        }),
      },
    );
    expect(hello.statusCode, HttpStatus.ok);
    final helloJson = hello.json;
    final package = await b.service.exportWithGroupKey();
    final tampered = [...package.bytes]..[package.bytes.length - 1] ^= 0x20;
    final exchange = await _rawPost(
      port: corrupt.port,
      path: '/sync/exchange',
      body: {
        'formatVersion': 1,
        'syncProtocolVersion': 1,
        'sessionId': helloJson['sessionId'],
        'groupId': key.groupId,
        'keyId': key.keyId,
        'device': state.localDevice.toJson(),
        'clientNonce': clientNonce,
        'package': base64Encode(tampered),
        'proof': _proof(key.bytes, {
          'type': 'exchange',
          'sessionId': helloJson['sessionId'],
          'groupId': key.groupId,
          'keyId': key.keyId,
          'clientNonce': clientNonce,
          'hostNonce': helloJson['hostNonce'],
          'deviceId': state.localDevice.deviceId,
          'packageHash': _sha256Base64(tampered),
          'sessionCode': corrupt.sessionCode,
        }),
      },
    );
    expect(exchange.statusCode, HttpStatus.badRequest);
    expect(exchange.json['error'], LanSyncFailure.packageRejected.name);
    unawaited(corrupt.completed.then<void>((_) {}, onError: (_) {}));
    await corrupt.stop();
  });
}

Future<void> _pair(_LanHarness a, _LanHarness b) async {
  final group = await a.manager.createGroup('LAN group');
  final key = await a.keys.read(group.keyId);
  final state = await a.manager.state();
  await b.manager.importInvitation(
    PairingInvitation(
      formatVersion: pairingPackageFormatVersion,
      syncProtocolVersion: 1,
      createdAt: _now,
      expiresAt: _now.add(const Duration(hours: 1)),
      group: PairingInvitationGroup(
        groupId: group.id,
        displayName: group.displayName,
        keyId: group.keyId,
        groupKey: key!,
      ),
      inviterDevice: state.localDevice,
    ),
  );
}

Future<void> _insertGame(_LanHarness harness, String id, String title) {
  return harness.runner.run(
    source: SyncChangeSource.manual,
    action:
        (_) => harness.db
            .into(harness.db.games)
            .insert(
              GamesCompanion.insert(
                id: id,
                title: title,
                createdAt: _now,
                updatedAt: _now,
              ),
            ),
  );
}

Future<void> _renameGame(
  _LanHarness harness,
  String id,
  String title, {
  required int minutes,
}) {
  return harness.runner.run(
    source: SyncChangeSource.manual,
    action:
        (_) =>
            (harness.db.update(harness.db.games)
              ..where((row) => row.id.equals(id))).write(
              GamesCompanion(
                title: Value(title),
                updatedAt: Value(_now.add(Duration(minutes: minutes))),
              ),
            ),
  );
}

Future<List<String>> _gameTitles(_LanHarness harness) async =>
    (await harness.db.select(harness.db.games).get())
        .map((game) => game.title)
        .toList();

Future<_RawResponse> _rawPost({
  required int port,
  required String path,
  required Map<String, Object?> body,
}) async {
  final client = HttpClient();
  try {
    final request = await client.post(
      InternetAddress.loopbackIPv4.address,
      port,
      path,
    );
    request.headers.contentType = ContentType.json;
    final bytes = utf8.encode(jsonEncode(body));
    request.contentLength = bytes.length;
    request.add(bytes);
    final response = await request.close();
    final text = await utf8.decodeStream(response);
    return _RawResponse(
      statusCode: response.statusCode,
      json:
          text.isEmpty
              ? const <String, Object?>{}
              : Map<String, Object?>.from(jsonDecode(text) as Map),
    );
  } finally {
    client.close(force: true);
  }
}

String _proof(List<int> groupKey, Map<String, Object?> message) {
  final mac = Hmac(
    sha256,
    groupKey,
  ).convert(utf8.encode(canonicalJson.encode(message)));
  return base64UrlEncode(mac.bytes);
}

String _sha256Base64(List<int> bytes) =>
    base64UrlEncode(sha256.convert(bytes).bytes);

class _RawResponse {
  const _RawResponse({required this.statusCode, required this.json});

  final int statusCode;
  final Map<String, Object?> json;
}

class _LanHarness {
  _LanHarness({
    required this.db,
    required this.identity,
    required this.keys,
    required this.manager,
    required this.runner,
    required this.service,
    required this.lan,
  });

  final AppDatabase db;
  final SyncDeviceIdentityService identity;
  final _MemoryGroupKeyStore keys;
  final SyncGroupManager manager;
  final SyncAwareTransaction runner;
  final SyncPackageService service;
  final LanSyncService lan;

  static Future<_LanHarness> create(
    String deviceId, {
    required int seed,
    int maxRequestBytes = LanSyncService.defaultMaxRequestBytes,
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
    final builder = SyncPackageBuilder(
      database: db,
      identityService: identity,
      initializer: initializer,
      ids: _UuidSequence(seed, start: 60),
      clock: _FixedClock(_now),
    );
    final detector = SyncConflictDetector(database: db, snapshotReader: reader);
    final applier = SyncChangeApplier(
      database: db,
      transaction: runner,
      conflictDetector: detector,
      clock: _FixedClock(_now),
    );
    final service = SyncPackageService(
      builder: builder,
      codec: EncryptedSyncPackageCodec(iterations: 1, random: Random(seed)),
      conflictDetector: detector,
      changeApplier: applier,
      groupKeys: manager,
      clock: _FixedClock(_now),
    );
    final lan = LanSyncService(
      packageService: service,
      groupKeys: manager,
      pairingStateLoader: manager.state,
      ids: _UuidSequence(seed, start: 90),
      random: Random(seed + 1000),
      timeout: const Duration(seconds: 5),
      maxRequestBytes: maxRequestBytes,
    );
    return _LanHarness(
      db: db,
      identity: identity,
      keys: keys,
      manager: manager,
      runner: runner,
      service: service,
      lan: lan,
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
