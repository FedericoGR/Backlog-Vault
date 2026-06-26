import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:backlog_vault/core/database/app_database.dart';
import 'package:backlog_vault/core/ids/id_generator.dart';
import 'package:backlog_vault/core/time/clock.dart';
import 'package:backlog_vault/features/media/data/media_file_storage.dart';
import 'package:backlog_vault/features/sync/data/canonical_json.dart';
import 'package:backlog_vault/features/sync/data/encrypted_sync_package_codec.dart';
import 'package:backlog_vault/features/sync/data/lan_media_transfer_service.dart';
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
import 'package:backlog_vault/features/sync/domain/sync_package_models.dart';
import 'package:backlog_vault/features/sync/domain/sync_pairing_models.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' hide Uint8List, isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:test/test.dart';

const _deviceA = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
const _deviceB = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb';
const _deviceC = 'cccccccc-cccc-4ccc-8ccc-cccccccccccc';
final _now = DateTime.utc(2026, 6, 23, 12);
final _pngBytes = Uint8List.fromList([
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0,
  1,
  2,
  3,
]);

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
    final aLocalChangesBefore = await _localChangeCount(a);
    final bLocalChangesBefore = await _localChangeCount(b);

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
    expect(await _localChangeCount(a), aLocalChangesBefore);
    expect(await _localChangeCount(b), bLocalChangesBefore);

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
    final wrongCodeFailure = _expectSessionFailure(
      wrongCode,
      LanSyncFailure.invalidSessionCode,
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
    await wrongCodeFailure;

    final wrongGroup = await a.lan.startHost(
      bindAddress: InternetAddress.loopbackIPv4,
      displayAddress: InternetAddress.loopbackIPv4.address,
    );
    final wrongGroupFailure = _expectSessionFailure(
      wrongGroup,
      LanSyncFailure.groupMismatch,
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
    await wrongGroupFailure;
  });

  test('host rejects key id, protocol mismatch and invalid proof', () async {
    final a = await _LanHarness.create(_deviceA, seed: 12);
    final b = await _LanHarness.create(_deviceB, seed: 13);
    addTearDown(a.close);
    addTearDown(b.close);
    await _pair(a, b);
    await _insertGame(b, 'game-b', 'Should not apply');
    final key = await b.manager.requireActiveGroupKey();
    final state = await b.manager.state();

    final wrongKeyId = await a.lan.startHost(
      bindAddress: InternetAddress.loopbackIPv4,
      displayAddress: InternetAddress.loopbackIPv4.address,
    );
    final wrongKeyIdFailure = _expectSessionFailure(
      wrongKeyId,
      LanSyncFailure.keyIdMismatch,
    );
    final wrongKeyIdResponse = await _rawPost(
      port: wrongKeyId.port,
      path: '/sync/hello',
      body: _helloBody(
        key: key,
        device: state.localDevice,
        sessionCode: wrongKeyId.sessionCode,
        keyId: 'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
      ),
    );
    expect(wrongKeyIdResponse.statusCode, HttpStatus.forbidden);
    expect(wrongKeyIdResponse.json['error'], LanSyncFailure.keyIdMismatch.name);
    await wrongKeyIdFailure;

    final wrongProtocol = await a.lan.startHost(
      bindAddress: InternetAddress.loopbackIPv4,
      displayAddress: InternetAddress.loopbackIPv4.address,
    );
    final wrongProtocolFailure = _expectSessionFailure(
      wrongProtocol,
      LanSyncFailure.protocolMismatch,
    );
    final wrongProtocolResponse = await _rawPost(
      port: wrongProtocol.port,
      path: '/sync/hello',
      body: _helloBody(
        key: key,
        device: state.localDevice,
        sessionCode: wrongProtocol.sessionCode,
        syncProtocolVersion: 999,
      ),
    );
    expect(wrongProtocolResponse.statusCode, HttpStatus.preconditionFailed);
    expect(
      wrongProtocolResponse.json['error'],
      LanSyncFailure.protocolMismatch.name,
    );
    await wrongProtocolFailure;

    final invalidProof = await a.lan.startHost(
      bindAddress: InternetAddress.loopbackIPv4,
      displayAddress: InternetAddress.loopbackIPv4.address,
    );
    final invalidProofFailure = _expectSessionFailure(
      invalidProof,
      LanSyncFailure.invalidSessionCode,
    );
    final invalidProofResponse = await _rawPost(
      port: invalidProof.port,
      path: '/sync/hello',
      body: _helloBody(
        key: key,
        device: state.localDevice,
        sessionCode: invalidProof.sessionCode,
        proof: 'not-a-valid-proof',
      ),
    );
    expect(invalidProofResponse.statusCode, HttpStatus.forbidden);
    expect(
      invalidProofResponse.json['error'],
      LanSyncFailure.invalidSessionCode.name,
    );
    await invalidProofFailure;

    expect(await _gameTitles(a), isNot(contains('Should not apply')));
  });

  test(
    'replayed hello and invalid exchange proof do not apply changes',
    () async {
      final a = await _LanHarness.create(_deviceA, seed: 14);
      final b = await _LanHarness.create(_deviceB, seed: 15);
      addTearDown(a.close);
      addTearDown(b.close);
      await _pair(a, b);
      await _insertGame(b, 'game-b', 'Replay must not apply');
      final key = await b.manager.requireActiveGroupKey();
      final state = await b.manager.state();

      final replay = await a.lan.startHost(
        bindAddress: InternetAddress.loopbackIPv4,
        displayAddress: InternetAddress.loopbackIPv4.address,
      );
      final replayFailure = _expectSessionFailure(
        replay,
        LanSyncFailure.invalidRequest,
      );
      final helloBody = _helloBody(
        key: key,
        device: state.localDevice,
        sessionCode: replay.sessionCode,
      );
      final firstHello = await _rawPost(
        port: replay.port,
        path: '/sync/hello',
        body: helloBody,
      );
      expect(firstHello.statusCode, HttpStatus.ok);
      final secondHello = await _rawPost(
        port: replay.port,
        path: '/sync/hello',
        body: helloBody,
      );
      expect(secondHello.statusCode, HttpStatus.badRequest);
      expect(secondHello.json['error'], LanSyncFailure.invalidRequest.name);
      await replayFailure;
      expect(await _gameTitles(a), isNot(contains('Replay must not apply')));

      final invalidExchange = await a.lan.startHost(
        bindAddress: InternetAddress.loopbackIPv4,
        displayAddress: InternetAddress.loopbackIPv4.address,
      );
      final invalidExchangeFailure = _expectSessionFailure(
        invalidExchange,
        LanSyncFailure.invalidRequest,
      );
      final hello = await _openRawHello(client: b, session: invalidExchange);
      final package = await b.service.exportWithGroupKey();
      final exchange = await _rawPost(
        port: invalidExchange.port,
        path: '/sync/exchange',
        body: _exchangeBody(
          key: hello.key,
          device: hello.device,
          session: invalidExchange,
          clientNonce: hello.clientNonce,
          hostNonce: hello.hostNonce,
          packageBytes: package.bytes,
          proof: 'invalid-exchange-proof',
        ),
      );
      expect(exchange.statusCode, HttpStatus.badRequest);
      expect(exchange.json['error'], LanSyncFailure.invalidRequest.name);
      await invalidExchangeFailure;
      expect(await _gameTitles(a), isNot(contains('Replay must not apply')));
    },
  );

  test('host rejects oversized requests and corrupt packages', () async {
    final a = await _LanHarness.create(_deviceA, seed: 16);
    final b = await _LanHarness.create(_deviceB, seed: 17);
    final small = await _LanHarness.create(
      _deviceC,
      seed: 18,
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
    final tooLargeFailure = _expectSessionFailure(
      tooLarge,
      LanSyncFailure.requestTooLarge,
    );
    final largeResponse = await _rawPost(
      port: tooLarge.port,
      path: '/sync/hello',
      body: {'padding': List.filled(256, 'x').join()},
    );
    expect(largeResponse.statusCode, HttpStatus.requestEntityTooLarge);
    await tooLargeFailure;

    final corrupt = await a.lan.startHost(
      bindAddress: InternetAddress.loopbackIPv4,
      displayAddress: InternetAddress.loopbackIPv4.address,
    );
    final corruptFailure = _expectSessionFailure(
      corrupt,
      LanSyncFailure.packageRejected,
    );
    final hello = await _openRawHello(client: b, session: corrupt);
    final package = await b.service.exportWithGroupKey();
    final tampered = [...package.bytes]..[package.bytes.length - 1] ^= 0x20;
    final exchange = await _rawPost(
      port: corrupt.port,
      path: '/sync/exchange',
      body: _exchangeBody(
        key: hello.key,
        device: hello.device,
        session: corrupt,
        clientNonce: hello.clientNonce,
        hostNonce: hello.hostNonce,
        packageBytes: tampered,
      ),
    );
    expect(exchange.statusCode, HttpStatus.badRequest);
    expect(exchange.json['error'], LanSyncFailure.packageRejected.name);
    await corruptFailure;
    expect(await _gameTitles(a), isNot(contains('Corrupt me not')));
  });

  test('truncated payload does not apply changes', () async {
    final a = await _LanHarness.create(_deviceA, seed: 19);
    final b = await _LanHarness.create(_deviceB, seed: 20);
    addTearDown(a.close);
    addTearDown(b.close);
    await _pair(a, b);
    await _insertGame(b, 'game-b', 'Truncated must not apply');

    final session = await a.lan.startHost(
      bindAddress: InternetAddress.loopbackIPv4,
      displayAddress: InternetAddress.loopbackIPv4.address,
    );
    final sessionFailure = _expectSessionFailure(
      session,
      LanSyncFailure.packageRejected,
    );
    final hello = await _openRawHello(client: b, session: session);
    final package = await b.service.exportWithGroupKey();
    final truncated = package.bytes.sublist(0, package.bytes.length ~/ 2);
    final exchange = await _rawPost(
      port: session.port,
      path: '/sync/exchange',
      body: _exchangeBody(
        key: hello.key,
        device: hello.device,
        session: session,
        clientNonce: hello.clientNonce,
        hostNonce: hello.hostNonce,
        packageBytes: truncated,
      ),
    );
    expect(exchange.statusCode, HttpStatus.badRequest);
    expect(exchange.json['error'], LanSyncFailure.packageRejected.name);
    await sessionFailure;
    expect(await _gameTitles(a), isNot(contains('Truncated must not apply')));
  });

  test('host and client timeouts are reported safely', () async {
    final a = await _LanHarness.create(
      _deviceA,
      seed: 21,
      sessionTimeout: const Duration(milliseconds: 30),
    );
    final b = await _LanHarness.create(
      _deviceB,
      seed: 22,
      timeout: const Duration(milliseconds: 30),
    );
    addTearDown(a.close);
    addTearDown(b.close);
    await _pair(a, b);

    final idle = await a.lan.startHost(
      bindAddress: InternetAddress.loopbackIPv4,
      displayAddress: InternetAddress.loopbackIPv4.address,
    );
    await _expectSessionFailure(idle, LanSyncFailure.timeout);
    await expectLater(
      b.lan.connectAndSync(
        host: idle.host,
        port: idle.port,
        sessionCode: idle.sessionCode,
      ),
      throwsA(isA<LanSyncException>()),
    );

    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    server.listen((request) {
      unawaited(Future<void>.delayed(const Duration(seconds: 5)));
    });
    await expectLater(
      b.lan.connectAndSync(
        host: InternetAddress.loopbackIPv4.address,
        port: server.port,
        sessionCode: '123456',
      ),
      throwsA(
        isA<LanSyncException>().having(
          (error) => error.failure,
          'failure',
          LanSyncFailure.timeout,
        ),
      ),
    );
  });

  test('client reports interrupted connection without applying', () async {
    final client = await _LanHarness.create(_deviceB, seed: 23);
    addTearDown(client.close);
    await client.manager.createGroup('Interrupted group');
    await _insertGame(client, 'game-b', 'Interrupted outbound');
    final key = await client.manager.requireActiveGroupKey();
    const sessionCode = '123456';
    const sessionId = '99999999-0000-4000-8000-000000000999';
    const hostNonce = 'host-nonce';
    final hostDevice = SyncPackageDevice(
      deviceId: _deviceA,
      displayName: 'Host',
      platform: 'windows',
    );
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    server.listen((request) async {
      if (request.uri.path == '/sync/hello') {
        final body = Map<String, Object?>.from(
          jsonDecode(await utf8.decodeStream(request)) as Map,
        );
        final clientNonce = body['clientNonce']! as String;
        request.response.headers.contentType = ContentType.json;
        request.response.write(
          jsonEncode({
            'formatVersion': 1,
            'syncProtocolVersion': 1,
            'sessionId': sessionId,
            'groupId': key.groupId,
            'keyId': key.keyId,
            'hostDevice': hostDevice.toJson(),
            'hostNonce': hostNonce,
            'proof': _proof(key.bytes, {
              'type': 'helloResponse',
              'sessionId': sessionId,
              'groupId': key.groupId,
              'keyId': key.keyId,
              'clientNonce': clientNonce,
              'hostNonce': hostNonce,
              'deviceId': hostDevice.deviceId,
              'sessionCode': sessionCode,
            }),
          }),
        );
        await request.response.close();
        return;
      }
      final socket = await request.response.detachSocket();
      socket.destroy();
    });

    await expectLater(
      client.lan.connectAndSync(
        host: InternetAddress.loopbackIPv4.address,
        port: server.port,
        sessionCode: sessionCode,
      ),
      throwsA(
        isA<LanSyncException>().having(
          (error) => error.failure,
          'failure',
          anyOf(
            LanSyncFailure.connectionInterrupted,
            LanSyncFailure.networkUnavailable,
          ),
        ),
      ),
    );
    expect(await _gameTitles(client), contains('Interrupted outbound'));
  });

  test('LAN media changes remain pending without broken cover files', () async {
    final a = await _LanHarness.create(_deviceA, seed: 24);
    final b = await _LanHarness.create(_deviceB, seed: 25);
    addTearDown(a.close);
    addTearDown(b.close);
    await _pair(a, b);
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
                localPath: 'covers/device-a-cover.png',
                fileName: 'cover.png',
                hash: const Value('sha256-test'),
                isSelected: const Value(true),
                createdAt: _now,
                updatedAt: _now,
              ),
            );
      },
    );

    final session = await a.lan.startHost(
      bindAddress: InternetAddress.loopbackIPv4,
      displayAddress: InternetAddress.loopbackIPv4.address,
    );
    final clientResult = await b.lan.connectAndSync(
      host: session.host,
      port: session.port,
      sessionCode: session.sessionCode,
    );
    await session.completed;

    expect(clientResult.local.pendingMedia, 1);
    final media = await b.db.select(b.db.mediaAssets).get();
    expect(media, hasLength(1));
    expect(media.single.id, 'local-media');
    expect(media.single.localPath, 'covers/local-cover.png');
    expect(media.single.isSelected, isTrue);
  });

  test('media manifest is hash-based and never exposes local paths', () async {
    final a = await _LanHarness.create(_deviceA, seed: 26);
    addTearDown(a.close);
    await a.manager.createGroup('Manifest group');
    final stored = await _insertGameWithCover(
      a,
      gameId: 'game-media',
      title: 'Media game',
      mediaId: 'media-1',
      bytes: _pngBytes,
    );

    final package = await a.service.exportWithGroupKey();
    expect(package.document.mediaManifest, hasLength(1));
    final entry = package.document.mediaManifest.single;
    expect(entry.mediaAssetId, 'media-1');
    expect(entry.gameId, 'game-media');
    expect(entry.hash, stored.hash);
    expect(entry.source, 'local');
    expect(entry.isSelected, isTrue);
    final manifestJson = jsonEncode(entry.toJson());
    expect(manifestJson, isNot(contains('localPath')));
    expect(manifestJson, isNot(contains(a.mediaDir.path)));
    expect(manifestJson, isNot(contains(r'C:\')));
  });

  test('LAN sync transfers missing cover files by hash', () async {
    final a = await _LanHarness.create(_deviceA, seed: 27);
    final b = await _LanHarness.create(_deviceB, seed: 28);
    addTearDown(a.close);
    addTearDown(b.close);
    await _pair(a, b);
    final stored = await _insertGameWithCover(
      a,
      gameId: 'game-media',
      title: 'Media game',
      mediaId: 'media-1',
      bytes: _pngBytes,
    );

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

    expect(clientResult.local.mediaRequested, 1);
    expect(clientResult.local.mediaReceived, 1);
    expect(clientResult.local.pendingMedia, 0);
    expect(hostResult.local.mediaSent, 1);
    expect(hostResult.local.mediaBytesTransferred, greaterThan(0));
    final media =
        await (b.db.select(b.db.mediaAssets)
          ..where((table) => table.id.equals('media-1'))).getSingle();
    expect(media.hash, stored.hash);
    expect(media.isSelected, isTrue);
    expect(media.localPath, startsWith('media/games/game-media/'));
    final file = await b.storage.resolveFile(media.localPath);
    expect(await file.exists(), isTrue);
    expect(sha256.convert(await file.readAsBytes()).toString(), stored.hash);

    final repeat = await a.lan.startHost(
      bindAddress: InternetAddress.loopbackIPv4,
      displayAddress: InternetAddress.loopbackIPv4.address,
    );
    final repeatClient = await b.lan.connectAndSync(
      host: repeat.host,
      port: repeat.port,
      sessionCode: repeat.sessionCode,
    );
    await repeat.completed;
    expect(repeatClient.local.mediaReceived, 0);
    expect(await b.db.select(b.db.mediaAssets).get(), hasLength(1));
  });

  test('receiver reuses an existing local file with the same hash', () async {
    final a = await _LanHarness.create(_deviceA, seed: 29);
    final b = await _LanHarness.create(_deviceB, seed: 30);
    addTearDown(a.close);
    addTearDown(b.close);
    await _pair(a, b);
    final source = await _insertGameWithCover(
      a,
      gameId: 'game-media',
      title: 'Media game',
      mediaId: 'media-1',
      bytes: _pngBytes,
    );
    final local = await _insertGameWithCover(
      b,
      gameId: 'local-game',
      title: 'Local game',
      mediaId: 'local-media',
      bytes: _pngBytes,
    );
    expect(local.hash, source.hash);

    final session = await a.lan.startHost(
      bindAddress: InternetAddress.loopbackIPv4,
      displayAddress: InternetAddress.loopbackIPv4.address,
    );
    final clientResult = await b.lan.connectAndSync(
      host: session.host,
      port: session.port,
      sessionCode: session.sessionCode,
    );
    await session.completed;

    expect(clientResult.local.mediaRequested, 0);
    expect(clientResult.local.mediaReceived, 0);
    expect(clientResult.local.mediaSkipped, greaterThanOrEqualTo(1));
    final imported =
        await (b.db.select(b.db.mediaAssets)
          ..where((table) => table.id.equals('media-1'))).getSingle();
    expect(imported.hash, source.hash);
    expect(imported.localPath, local.localPath);
    expect(await b.db.select(b.db.mediaAssets).get(), hasLength(2));
  });

  test(
    'media with mismatched hash stays pending and is not inserted',
    () async {
      final a = await _LanHarness.create(_deviceA, seed: 31);
      final b = await _LanHarness.create(_deviceB, seed: 32);
      addTearDown(a.close);
      addTearDown(b.close);
      await _pair(a, b);
      await _insertGameWithCover(
        b,
        gameId: 'game-media',
        title: 'Media game',
        mediaId: 'media-1',
        bytes: _pngBytes,
        hashOverride: '0' * 64,
      );

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

      expect(clientResult.local.mediaSent, 0);
      expect(clientResult.local.mediaFailed, greaterThanOrEqualTo(1));
      expect(hostResult.local.mediaRequested, 1);
      expect(hostResult.local.mediaReceived, 0);
      expect(hostResult.local.pendingMedia, 1);
      final media = await a.db.select(a.db.mediaAssets).get();
      expect(media, isEmpty);
    },
  );

  test('invalid magic bytes and oversized media are rejected safely', () async {
    final invalidHost = await _LanHarness.create(_deviceA, seed: 33);
    final invalidClient = await _LanHarness.create(_deviceB, seed: 34);
    addTearDown(invalidHost.close);
    addTearDown(invalidClient.close);
    await _pair(invalidHost, invalidClient);
    await _insertGameWithCover(
      invalidClient,
      gameId: 'game-invalid',
      title: 'Invalid media',
      mediaId: 'media-invalid',
      bytes: Uint8List.fromList([1, 2, 3, 4, 5, 6]),
      bypassStorageValidation: true,
    );

    final invalidSession = await invalidHost.lan.startHost(
      bindAddress: InternetAddress.loopbackIPv4,
      displayAddress: InternetAddress.loopbackIPv4.address,
    );
    final invalidResult = await invalidClient.lan.connectAndSync(
      host: invalidSession.host,
      port: invalidSession.port,
      sessionCode: invalidSession.sessionCode,
    );
    final invalidHostResult = await invalidSession.completed;
    expect(invalidResult.local.mediaFailed, greaterThanOrEqualTo(1));
    expect(invalidHostResult.local.mediaReceived, 0);
    expect(
      await invalidHost.db.select(invalidHost.db.mediaAssets).get(),
      isEmpty,
    );

    final smallHost = await _LanHarness.create(
      _deviceA,
      seed: 35,
      maxMediaFileBytes: 12,
    );
    final smallClient = await _LanHarness.create(
      _deviceB,
      seed: 36,
      maxMediaFileBytes: 12,
    );
    addTearDown(smallHost.close);
    addTearDown(smallClient.close);
    await _pair(smallHost, smallClient);
    await _insertGameWithCover(
      smallClient,
      gameId: 'game-large',
      title: 'Large media',
      mediaId: 'media-large',
      bytes: Uint8List.fromList([..._pngBytes, ...List<int>.filled(32, 0)]),
    );

    final smallSession = await smallHost.lan.startHost(
      bindAddress: InternetAddress.loopbackIPv4,
      displayAddress: InternetAddress.loopbackIPv4.address,
    );
    final smallResult = await smallClient.lan.connectAndSync(
      host: smallSession.host,
      port: smallSession.port,
      sessionCode: smallSession.sessionCode,
    );
    final smallHostResult = await smallSession.completed;
    expect(smallResult.local.mediaFailed, greaterThanOrEqualTo(1));
    expect(smallHostResult.local.mediaReceived, 0);
    expect(await smallHost.db.select(smallHost.db.mediaAssets).get(), isEmpty);
  });

  test('unsafe media paths are rejected without activating covers', () async {
    final host = await _LanHarness.create(_deviceA, seed: 37);
    final client = await _LanHarness.create(_deviceB, seed: 38);
    addTearDown(host.close);
    addTearDown(client.close);
    await _pair(host, client);
    await _insertGameWithCover(
      client,
      gameId: 'game-unsafe-path',
      title: 'Unsafe path',
      mediaId: 'media-unsafe-path',
      bytes: _pngBytes,
      localPathOverride: r'media/games/game-unsafe-path\..\secret.png',
    );

    final session = await host.lan.startHost(
      bindAddress: InternetAddress.loopbackIPv4,
      displayAddress: InternetAddress.loopbackIPv4.address,
    );
    final clientResult = await client.lan.connectAndSync(
      host: session.host,
      port: session.port,
      sessionCode: session.sessionCode,
    );
    final hostResult = await session.completed;

    expect(clientResult.local.mediaSent, 0);
    expect(clientResult.local.mediaFailed, greaterThanOrEqualTo(1));
    expect(hostResult.local.mediaRequested, 1);
    expect(hostResult.local.mediaReceived, 0);
    expect(hostResult.local.pendingMedia, 1);
    expect(await host.db.select(host.db.mediaAssets).get(), isEmpty);
  });

  test('suspicious remote filenames keep media pending', () async {
    final host = await _LanHarness.create(_deviceA, seed: 39);
    final client = await _LanHarness.create(_deviceB, seed: 40);
    addTearDown(host.close);
    addTearDown(client.close);
    await _pair(host, client);
    await _insertGameWithCover(
      client,
      gameId: 'game-unsafe-name',
      title: 'Unsafe name',
      mediaId: 'media-unsafe-name',
      bytes: _pngBytes,
      fileNameOverride: r'..\evil.png',
    );

    final session = await host.lan.startHost(
      bindAddress: InternetAddress.loopbackIPv4,
      displayAddress: InternetAddress.loopbackIPv4.address,
    );
    final clientResult = await client.lan.connectAndSync(
      host: session.host,
      port: session.port,
      sessionCode: session.sessionCode,
    );
    final hostResult = await session.completed;

    expect(clientResult.local.mediaSent, 0);
    expect(hostResult.local.mediaRequested, 0);
    expect(hostResult.local.mediaReceived, 0);
    expect(hostResult.local.pendingMedia, 1);
    expect(await host.db.select(host.db.mediaAssets).get(), isEmpty);
  });

  test('remote filename extension is ignored after byte validation', () async {
    final host = await _LanHarness.create(_deviceA, seed: 41);
    final client = await _LanHarness.create(_deviceB, seed: 42);
    addTearDown(host.close);
    addTearDown(client.close);
    await _pair(host, client);
    await _insertGameWithCover(
      client,
      gameId: 'game-extension',
      title: 'Extension mismatch',
      mediaId: 'media-extension',
      bytes: _pngBytes,
      fileNameOverride: 'media-extension.jpg',
    );

    final session = await host.lan.startHost(
      bindAddress: InternetAddress.loopbackIPv4,
      displayAddress: InternetAddress.loopbackIPv4.address,
    );
    final hostResultFuture = session.completed;
    await client.lan.connectAndSync(
      host: session.host,
      port: session.port,
      sessionCode: session.sessionCode,
    );
    await hostResultFuture;

    final media =
        await (host.db.select(host.db.mediaAssets)
          ..where((table) => table.id.equals('media-extension'))).getSingle();
    expect(media.mimeType, 'image/png');
    expect(media.fileName, 'media-extension.png');
    expect(media.localPath, endsWith('/media-extension.png'));
  });

  test('unknown and soft-deleted media requests are rejected', () async {
    final harness = await _LanHarness.create(_deviceA, seed: 43);
    addTearDown(harness.close);
    await harness.manager.createGroup('Direct media group');
    final stored = await _insertGameWithCover(
      harness,
      gameId: 'game-direct',
      title: 'Direct media',
      mediaId: 'media-direct',
      bytes: _pngBytes,
    );
    final package = await harness.service.exportWithGroupKey();

    final unknown = await harness.mediaTransfer.buildPayloads(
      document: package.document,
      requests: [
        LanMediaRequest(
          mediaAssetId: 'media-missing',
          gameId: 'game-direct',
          hash: stored.hash,
        ),
      ],
    );
    expect(unknown.sent, 0);
    expect(unknown.failed, 1);

    await (harness.db.update(harness.db.mediaAssets)
      ..where((row) => row.id.equals('media-direct'))).write(
      MediaAssetsCompanion(
        isSelected: const Value(false),
        deletedAt: Value(_now.add(const Duration(minutes: 1))),
      ),
    );
    final deleted = await harness.mediaTransfer.buildPayloads(
      document: package.document,
      requests: [
        LanMediaRequest(
          mediaAssetId: 'media-direct',
          gameId: 'game-direct',
          hash: stored.hash,
        ),
      ],
    );
    expect(deleted.sent, 0);
    expect(deleted.failed, 1);
  });

  test('media transfer enforces total session byte limit', () async {
    final host = await _LanHarness.create(
      _deviceA,
      seed: 44,
      maxMediaSessionBytes: 20,
    );
    final client = await _LanHarness.create(
      _deviceB,
      seed: 45,
      maxMediaSessionBytes: 20,
    );
    addTearDown(host.close);
    addTearDown(client.close);
    await _pair(host, client);
    final largerPng = Uint8List.fromList([
      ..._pngBytes,
      0x01,
      0x02,
      0x03,
      0x04,
    ]);
    await _insertGameWithCover(
      client,
      gameId: 'game-total-a',
      title: 'Total media A',
      mediaId: 'media-total-a',
      bytes: largerPng,
    );
    await _insertGameWithCover(
      client,
      gameId: 'game-total-b',
      title: 'Total media B',
      mediaId: 'media-total-b',
      bytes: Uint8List.fromList([...largerPng, 0x05]),
    );

    final session = await host.lan.startHost(
      bindAddress: InternetAddress.loopbackIPv4,
      displayAddress: InternetAddress.loopbackIPv4.address,
    );
    final clientResult = await client.lan.connectAndSync(
      host: session.host,
      port: session.port,
      sessionCode: session.sessionCode,
    );
    final hostResult = await session.completed;

    expect(clientResult.local.mediaSent, 1);
    expect(clientResult.local.mediaFailed, greaterThanOrEqualTo(1));
    expect(hostResult.local.mediaReceived, 1);
    expect(hostResult.local.pendingMedia, 1);
    expect(await host.db.select(host.db.mediaAssets).get(), hasLength(1));
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

Future<StoredMediaFile> _insertGameWithCover(
  _LanHarness harness, {
  required String gameId,
  required String title,
  required String mediaId,
  required Uint8List bytes,
  String? hashOverride,
  String? localPathOverride,
  String? fileNameOverride,
  bool bypassStorageValidation = false,
}) async {
  final stored =
      bypassStorageValidation
          ? await _writeRawMedia(
            harness,
            gameId: gameId,
            mediaId: mediaId,
            bytes: bytes,
          )
          : await harness.storage.saveBytes(
            gameId: gameId,
            assetId: mediaId,
            bytes: bytes,
          );
  await harness.runner.run(
    source: SyncChangeSource.manual,
    action: (_) async {
      await harness.db
          .into(harness.db.games)
          .insert(
            GamesCompanion.insert(
              id: gameId,
              title: title,
              createdAt: _now,
              updatedAt: _now,
            ),
          );
      await harness.db
          .into(harness.db.mediaAssets)
          .insert(
            MediaAssetsCompanion.insert(
              id: mediaId,
              gameId: gameId,
              kind: 'cover',
              source: 'local',
              localPath: localPathOverride ?? stored.localPath,
              fileName: fileNameOverride ?? stored.fileName,
              mimeType: Value(stored.mimeType),
              hash: Value(hashOverride ?? stored.hash),
              isSelected: const Value(true),
              createdAt: _now,
              updatedAt: _now,
            ),
          );
    },
  );
  return StoredMediaFile(
    localPath: localPathOverride ?? stored.localPath,
    fileName: fileNameOverride ?? stored.fileName,
    mimeType: stored.mimeType,
    hash: hashOverride ?? stored.hash,
  );
}

Future<StoredMediaFile> _writeRawMedia(
  _LanHarness harness, {
  required String gameId,
  required String mediaId,
  required Uint8List bytes,
}) async {
  final localPath = 'media/games/$gameId/$mediaId.png';
  final file = await harness.storage.resolveFile(localPath);
  await file.parent.create(recursive: true);
  await file.writeAsBytes(bytes, flush: true);
  return StoredMediaFile(
    localPath: localPath,
    fileName: '$mediaId.png',
    mimeType: 'image/png',
    hash: sha256.convert(bytes).toString(),
  );
}

Future<List<String>> _gameTitles(_LanHarness harness) async =>
    (await harness.db.select(harness.db.games).get())
        .map((game) => game.title)
        .toList();

Future<int> _localChangeCount(_LanHarness harness) async {
  final device = await harness.identity.ensureIdentity();
  final rows =
      await (harness.db.select(harness.db.syncChanges)
        ..where((row) => row.originDeviceId.equals(device.id))).get();
  return rows.length;
}

Future<void> _expectSessionFailure(
  LanSyncHostSession session,
  LanSyncFailure failure,
) {
  return expectLater(
    session.completed,
    throwsA(
      isA<LanSyncException>().having(
        (error) => error.failure,
        'failure',
        failure,
      ),
    ),
  );
}

Map<String, Object?> _helloBody({
  required SyncGroupKeyMaterial key,
  required SyncPackageDevice device,
  required String sessionCode,
  String clientNonce = 'test-client-nonce',
  String? groupId,
  String? keyId,
  int formatVersion = 1,
  int syncProtocolVersion = 1,
  String? proof,
}) {
  final effectiveGroupId = groupId ?? key.groupId;
  final effectiveKeyId = keyId ?? key.keyId;
  return {
    'formatVersion': formatVersion,
    'syncProtocolVersion': syncProtocolVersion,
    'groupId': effectiveGroupId,
    'keyId': effectiveKeyId,
    'device': device.toJson(),
    'clientNonce': clientNonce,
    'proof':
        proof ??
        _proof(key.bytes, {
          'type': 'hello',
          'groupId': effectiveGroupId,
          'keyId': effectiveKeyId,
          'deviceId': device.deviceId,
          'clientNonce': clientNonce,
          'sessionCode': sessionCode,
        }),
  };
}

Map<String, Object?> _exchangeBody({
  required SyncGroupKeyMaterial key,
  required SyncPackageDevice device,
  required LanSyncHostSession session,
  required String clientNonce,
  required String hostNonce,
  required List<int> packageBytes,
  String? proof,
}) {
  return {
    'formatVersion': 1,
    'syncProtocolVersion': 1,
    'sessionId': session.sessionId,
    'groupId': key.groupId,
    'keyId': key.keyId,
    'device': device.toJson(),
    'clientNonce': clientNonce,
    'package': base64Encode(packageBytes),
    'proof':
        proof ??
        _proof(key.bytes, {
          'type': 'exchange',
          'sessionId': session.sessionId,
          'groupId': key.groupId,
          'keyId': key.keyId,
          'clientNonce': clientNonce,
          'hostNonce': hostNonce,
          'deviceId': device.deviceId,
          'packageHash': _sha256Base64(packageBytes),
          'sessionCode': session.sessionCode,
        }),
  };
}

Future<_RawHello> _openRawHello({
  required _LanHarness client,
  required LanSyncHostSession session,
}) async {
  final key = await client.manager.requireActiveGroupKey();
  final state = await client.manager.state();
  const clientNonce = 'test-client-nonce';
  final response = await _rawPost(
    port: session.port,
    path: '/sync/hello',
    body: _helloBody(
      key: key,
      device: state.localDevice,
      sessionCode: session.sessionCode,
      clientNonce: clientNonce,
    ),
  );
  expect(response.statusCode, HttpStatus.ok);
  expect(response.json['sessionId'], session.sessionId);
  return _RawHello(
    key: key,
    device: state.localDevice,
    clientNonce: clientNonce,
    hostNonce: response.json['hostNonce']! as String,
  );
}

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

class _RawHello {
  const _RawHello({
    required this.key,
    required this.device,
    required this.clientNonce,
    required this.hostNonce,
  });

  final SyncGroupKeyMaterial key;
  final SyncPackageDevice device;
  final String clientNonce;
  final String hostNonce;
}

class _LanHarness {
  _LanHarness({
    required this.db,
    required this.identity,
    required this.keys,
    required this.manager,
    required this.runner,
    required this.service,
    required this.storage,
    required this.mediaDir,
    required this.mediaTransfer,
    required this.lan,
  });

  final AppDatabase db;
  final SyncDeviceIdentityService identity;
  final _MemoryGroupKeyStore keys;
  final SyncGroupManager manager;
  final SyncAwareTransaction runner;
  final SyncPackageService service;
  final MediaFileStorage storage;
  final Directory mediaDir;
  final LanMediaTransferService mediaTransfer;
  final LanSyncService lan;

  static Future<_LanHarness> create(
    String deviceId, {
    required int seed,
    Duration timeout = const Duration(seconds: 5),
    Duration sessionTimeout = const Duration(minutes: 5),
    int maxRequestBytes = LanSyncService.defaultMaxRequestBytes,
    int maxMediaFileBytes = LanMediaTransferService.defaultMaxFileBytes,
    int maxMediaSessionBytes = LanMediaTransferService.defaultMaxSessionBytes,
  }) async {
    final db = AppDatabase(NativeDatabase.memory());
    final mediaDir = await Directory.systemTemp.createTemp(
      'backlog-vault-lan-media-$seed-',
    );
    final storage = MediaFileStorage(baseDirectoryLoader: () async => mediaDir);
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
    final mediaTransfer = LanMediaTransferService(
      database: db,
      storage: storage,
      conflictDetector: detector,
      clock: _FixedClock(_now),
      maxFileBytes: maxMediaFileBytes,
      maxSessionBytes: maxMediaSessionBytes,
    );
    final lan = LanSyncService(
      packageService: service,
      mediaTransfer: mediaTransfer,
      groupKeys: manager,
      pairingStateLoader: manager.state,
      ids: _UuidSequence(seed, start: 90),
      random: Random(seed + 1000),
      timeout: timeout,
      sessionTimeout: sessionTimeout,
      maxRequestBytes: maxRequestBytes,
    );
    return _LanHarness(
      db: db,
      identity: identity,
      keys: keys,
      manager: manager,
      runner: runner,
      service: service,
      storage: storage,
      mediaDir: mediaDir,
      mediaTransfer: mediaTransfer,
      lan: lan,
    );
  }

  Future<void> close() async {
    await db.close();
    if (await mediaDir.exists()) {
      await mediaDir.delete(recursive: true);
    }
  }
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
