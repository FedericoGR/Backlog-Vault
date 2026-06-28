import 'dart:convert';

import 'package:backlog_vault/features/sync/data/sync_qr_payload_codec.dart';
import 'package:test/test.dart';

const _groupId = '11111111-1111-4111-8111-111111111111';
const _keyId = '22222222-2222-4222-8222-222222222222';
final _now = DateTime.utc(2026, 6, 27, 12);

void main() {
  test('pairing QR payload is versioned and hides encrypted bytes only', () {
    const codec = SyncQrPayloadCodec();
    final invitationBytes = utf8.encode('BVP1 encrypted invitation bytes');

    final encoded = codec.encodePairingInvitation(
      invitationBytes: invitationBytes,
      createdAt: _now,
    );

    expect(encoded, contains('backlogVault.pairingInvitation'));
    expect(encoded, contains('"formatVersion":1'));
    expect(encoded, isNot(contains('sync_group_key_plaintext')));
    _expectNoSensitiveMarkers(encoded);

    final decoded = codec.decodePairingInvitation(encoded);
    expect(decoded.formatVersion, syncQrFormatVersion);
    expect(decoded.createdAt, _now);
    expect(decoded.invitationBytes, invitationBytes);
  });

  test(
    'pairing QR rejects wrong type, incompatible version and truncation',
    () {
      const codec = SyncQrPayloadCodec();
      final valid = codec.encodePairingInvitation(
        invitationBytes: [1, 2, 3, 4],
        createdAt: _now,
      );
      final wrongType = valid.replaceFirst(
        'backlogVault.pairingInvitation',
        'backlogVault.lanSession',
      );
      expect(
        () => codec.decodePairingInvitation(wrongType),
        throwsA(
          isA<SyncQrException>().having(
            (error) => error.failure,
            'failure',
            SyncQrFailure.unsupportedType,
          ),
        ),
      );

      final incompatible = valid.replaceFirst(
        '"formatVersion":1',
        '"formatVersion":999',
      );
      expect(
        () => codec.decodePairingInvitation(incompatible),
        throwsA(
          isA<SyncQrException>().having(
            (error) => error.failure,
            'failure',
            SyncQrFailure.incompatibleVersion,
          ),
        ),
      );

      expect(
        () => codec.decodePairingInvitation(
          valid.substring(0, valid.length ~/ 2),
        ),
        throwsA(isA<SyncQrException>()),
      );

      final unexpectedField = valid.replaceFirst(
        '"payloadBase64"',
        '"unexpected":"value","payloadBase64"',
      );
      expect(
        () => codec.decodePairingInvitation(unexpectedField),
        throwsA(
          isA<SyncQrException>().having(
            (error) => error.failure,
            'failure',
            SyncQrFailure.invalidPayload,
          ),
        ),
      );

      expect(
        () => codec.decodePairingInvitation('{not-json'),
        throwsA(
          isA<SyncQrException>().having(
            (error) => error.toString(),
            'message',
            isNot(contains('{not-json')),
          ),
        ),
      );
    },
  );

  test('pairing QR reports payloads that are too large for QR UX', () {
    const codec = SyncQrPayloadCodec(maxPayloadChars: 120);

    expect(
      () => codec.encodePairingInvitation(
        invitationBytes: List<int>.filled(256, 7),
        createdAt: _now,
      ),
      throwsA(
        isA<SyncQrException>().having(
          (error) => error.failure,
          'failure',
          SyncQrFailure.payloadTooLarge,
        ),
      ),
    );
  });

  test('LAN QR payload parses and validates the expected group', () {
    const codec = SyncQrPayloadCodec();

    final encoded = codec.encodeLanSession(
      host: '192.168.1.20',
      port: 47777,
      sessionCode: '123456',
      syncGroupId: _groupId,
      keyId: _keyId,
      createdAt: _now,
      expiresAt: _now.add(const Duration(minutes: 5)),
    );

    expect(encoded, contains('backlogVault.lanSession'));
    expect(encoded, contains('192.168.1.20'));
    expect(encoded, contains('123456'));
    expect(encoded, isNot(contains('group_key_plaintext')));
    expect(encoded, isNot(contains('Game from A')));
    _expectNoSensitiveMarkers(encoded);

    final decoded = codec.decodeLanSession(
      encoded,
      expectedGroupId: _groupId,
      expectedKeyId: _keyId,
    );
    expect(decoded.host, '192.168.1.20');
    expect(decoded.port, 47777);
    expect(decoded.sessionCode, '123456');
    expect(decoded.syncGroupId, _groupId);
    expect(decoded.keyId, _keyId);
  });

  test('LAN QR rejects invalid host, port, group, key and protocol', () {
    const codec = SyncQrPayloadCodec();

    expect(
      () => codec.encodeLanSession(
        host: '../bad-host',
        port: 47777,
        sessionCode: '123456',
        syncGroupId: _groupId,
        keyId: _keyId,
        createdAt: _now,
      ),
      throwsA(isA<SyncQrException>()),
    );

    expect(
      () => codec.encodeLanSession(
        host: '192.168.1.20',
        port: 0,
        sessionCode: '123456',
        syncGroupId: _groupId,
        keyId: _keyId,
        createdAt: _now,
      ),
      throwsA(isA<SyncQrException>()),
    );

    expect(
      () => codec.encodeLanSession(
        host: '192.168.1.20',
        port: 70000,
        sessionCode: '123456',
        syncGroupId: _groupId,
        keyId: _keyId,
        createdAt: _now,
      ),
      throwsA(isA<SyncQrException>()),
    );

    expect(
      () => codec.encodeLanSession(
        host: '192.168.1.20',
        port: 47777,
        sessionCode: '',
        syncGroupId: _groupId,
        keyId: _keyId,
        createdAt: _now,
      ),
      throwsA(isA<SyncQrException>()),
    );

    expect(
      () => codec.encodeLanSession(
        host: '192.168.1.20',
        port: 47777,
        sessionCode: '123456',
        syncGroupId: '',
        keyId: _keyId,
        createdAt: _now,
      ),
      throwsA(isA<SyncQrException>()),
    );

    expect(
      () => codec.encodeLanSession(
        host: '192.168.1.20',
        port: 47777,
        sessionCode: '123456',
        syncGroupId: _groupId,
        keyId: '',
        createdAt: _now,
      ),
      throwsA(isA<SyncQrException>()),
    );

    final encoded = codec.encodeLanSession(
      host: '192.168.1.20',
      port: 47777,
      sessionCode: '123456',
      syncGroupId: _groupId,
      keyId: _keyId,
      createdAt: _now,
    );

    expect(
      () => codec.decodeLanSession(
        encoded,
        expectedGroupId: '33333333-3333-4333-8333-333333333333',
        expectedKeyId: _keyId,
      ),
      throwsA(
        isA<SyncQrException>().having(
          (error) => error.failure,
          'failure',
          SyncQrFailure.groupMismatch,
        ),
      ),
    );

    expect(
      () => codec.decodeLanSession(
        encoded,
        expectedGroupId: _groupId,
        expectedKeyId: '44444444-4444-4444-8444-444444444444',
      ),
      throwsA(
        isA<SyncQrException>().having(
          (error) => error.failure,
          'failure',
          SyncQrFailure.keyIdMismatch,
        ),
      ),
    );

    final incompatible = encoded.replaceFirst(
      '"syncProtocolVersion":1',
      '"syncProtocolVersion":999',
    );
    expect(
      () => codec.decodeLanSession(incompatible),
      throwsA(
        isA<SyncQrException>().having(
          (error) => error.failure,
          'failure',
          SyncQrFailure.incompatibleVersion,
        ),
      ),
    );

    final wrongType = encoded.replaceFirst(
      'backlogVault.lanSession',
      'backlogVault.pairingInvitation',
    );
    expect(
      () => codec.decodeLanSession(wrongType),
      throwsA(
        isA<SyncQrException>().having(
          (error) => error.failure,
          'failure',
          SyncQrFailure.unsupportedType,
        ),
      ),
    );

    final portAsString = encoded.replaceFirst('"port":47777', '"port":"47777"');
    expect(
      () => codec.decodeLanSession(portAsString),
      throwsA(
        isA<SyncQrException>().having(
          (error) => error.failure,
          'failure',
          SyncQrFailure.invalidPayload,
        ),
      ),
    );

    final unexpectedField = encoded.replaceFirst(
      '"host"',
      '"unexpected":"value","host"',
    );
    expect(
      () => codec.decodeLanSession(unexpectedField),
      throwsA(
        isA<SyncQrException>().having(
          (error) => error.failure,
          'failure',
          SyncQrFailure.invalidPayload,
        ),
      ),
    );

    expect(
      () => codec.decodeLanSession(encoded.substring(0, encoded.length ~/ 2)),
      throwsA(isA<SyncQrException>()),
    );

    expect(
      () => codec.decodeLanSession('{not-json'),
      throwsA(
        isA<SyncQrException>().having(
          (error) => error.toString(),
          'message',
          isNot(contains('{not-json')),
        ),
      ),
    );
  });

  test('QR payload size limits are enforced while decoding', () {
    const codec = SyncQrPayloadCodec(maxPayloadChars: 16);
    final oversized = List.filled(32, 'x').join();

    expect(
      () => codec.decodePairingInvitation(oversized),
      throwsA(
        isA<SyncQrException>().having(
          (error) => error.failure,
          'failure',
          SyncQrFailure.payloadTooLarge,
        ),
      ),
    );

    expect(
      () => codec.decodeLanSession(oversized),
      throwsA(
        isA<SyncQrException>().having(
          (error) => error.failure,
          'failure',
          SyncQrFailure.payloadTooLarge,
        ),
      ),
    );
  });
}

void _expectNoSensitiveMarkers(String encoded) {
  for (final marker in [
    'syncGroupKey',
    'group_key',
    'private_key',
    'access_token',
    'client_secret',
    'Bearer',
    r'C:\',
    '/Users/',
    '.vaultsync',
  ]) {
    expect(encoded, isNot(contains(marker)));
  }
}
