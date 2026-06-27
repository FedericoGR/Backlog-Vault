import 'dart:convert';

import '../../../core/version/app_versions.dart';

const syncQrFormatVersion = 1;
const syncQrMaxPayloadChars = 1800;

enum SyncQrFailure {
  invalidPayload,
  unsupportedType,
  incompatibleVersion,
  payloadTooLarge,
  groupMismatch,
  keyIdMismatch,
  invalidLanSession,
}

class SyncQrException implements Exception {
  const SyncQrException(this.failure);

  final SyncQrFailure failure;

  @override
  String toString() => 'Sync QR operation failed: ${failure.name}';
}

class PairingQrPayload {
  const PairingQrPayload({
    required this.formatVersion,
    required this.createdAt,
    required this.invitationBytes,
  });

  final int formatVersion;
  final DateTime createdAt;
  final List<int> invitationBytes;
}

class LanSessionQrPayload {
  const LanSessionQrPayload({
    required this.formatVersion,
    required this.syncProtocolVersion,
    required this.host,
    required this.port,
    required this.sessionCode,
    required this.syncGroupId,
    required this.keyId,
    required this.createdAt,
    this.expiresAt,
  });

  final int formatVersion;
  final int syncProtocolVersion;
  final String host;
  final int port;
  final String sessionCode;
  final String syncGroupId;
  final String keyId;
  final DateTime createdAt;
  final DateTime? expiresAt;
}

class SyncQrPayloadCodec {
  const SyncQrPayloadCodec({this.maxPayloadChars = syncQrMaxPayloadChars});

  final int maxPayloadChars;

  String encodePairingInvitation({
    required List<int> invitationBytes,
    required DateTime createdAt,
  }) {
    final payload = _encode({
      'type': _pairingType,
      'formatVersion': syncQrFormatVersion,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'payloadBase64': base64Encode(invitationBytes),
    });
    _checkSize(payload);
    return payload;
  }

  PairingQrPayload decodePairingInvitation(String encoded) {
    final json = _decode(encoded);
    _requireExactKeys(json, const {
      'type',
      'formatVersion',
      'createdAt',
      'payloadBase64',
    });
    _requireType(json, _pairingType);
    _requireQrVersion(json);
    try {
      final bytes = base64Decode(_string(json, 'payloadBase64'));
      if (bytes.isEmpty) {
        throw const SyncQrException(SyncQrFailure.invalidPayload);
      }
      return PairingQrPayload(
        formatVersion: syncQrFormatVersion,
        createdAt: _date(json, 'createdAt'),
        invitationBytes: bytes,
      );
    } on SyncQrException {
      rethrow;
    } on Object {
      throw const SyncQrException(SyncQrFailure.invalidPayload);
    }
  }

  String encodeLanSession({
    required String host,
    required int port,
    required String sessionCode,
    required String syncGroupId,
    required String keyId,
    required DateTime createdAt,
    DateTime? expiresAt,
  }) {
    final normalized = _normalizeLan(
      host: host,
      port: port,
      sessionCode: sessionCode,
      syncGroupId: syncGroupId,
      keyId: keyId,
      createdAt: createdAt,
      expiresAt: expiresAt,
    );
    final payload = _encode({
      'type': _lanType,
      'formatVersion': syncQrFormatVersion,
      'syncProtocolVersion': syncProtocolVersion,
      'host': normalized.host,
      'port': normalized.port,
      'sessionCode': normalized.sessionCode,
      'syncGroupId': normalized.syncGroupId,
      'keyId': normalized.keyId,
      'createdAt': normalized.createdAt.toUtc().toIso8601String(),
      'expiresAt': normalized.expiresAt?.toUtc().toIso8601String(),
    });
    _checkSize(payload);
    return payload;
  }

  LanSessionQrPayload decodeLanSession(
    String encoded, {
    String? expectedGroupId,
    String? expectedKeyId,
  }) {
    final json = _decode(encoded);
    _requireExactKeys(json, const {
      'type',
      'formatVersion',
      'syncProtocolVersion',
      'host',
      'port',
      'sessionCode',
      'syncGroupId',
      'keyId',
      'createdAt',
      'expiresAt',
    });
    _requireType(json, _lanType);
    _requireQrVersion(json);
    final protocol = _integer(json, 'syncProtocolVersion');
    if (protocol != syncProtocolVersion) {
      throw const SyncQrException(SyncQrFailure.incompatibleVersion);
    }
    final payload = _normalizeLan(
      host: _string(json, 'host'),
      port: _integer(json, 'port'),
      sessionCode: _string(json, 'sessionCode'),
      syncGroupId: _string(json, 'syncGroupId'),
      keyId: _string(json, 'keyId'),
      createdAt: _date(json, 'createdAt'),
      expiresAt: _nullableDate(json['expiresAt']),
    );
    if (expectedGroupId != null && payload.syncGroupId != expectedGroupId) {
      throw const SyncQrException(SyncQrFailure.groupMismatch);
    }
    if (expectedKeyId != null && payload.keyId != expectedKeyId) {
      throw const SyncQrException(SyncQrFailure.keyIdMismatch);
    }
    return payload;
  }

  void _checkSize(String payload) {
    if (payload.length > maxPayloadChars) {
      throw const SyncQrException(SyncQrFailure.payloadTooLarge);
    }
  }

  String _encode(Map<String, Object?> json) => jsonEncode(json);

  Map<String, Object?> _decode(String encoded) {
    if (encoded.trim().length > maxPayloadChars) {
      throw const SyncQrException(SyncQrFailure.payloadTooLarge);
    }
    try {
      final decoded = jsonDecode(encoded.trim());
      if (decoded is Map) {
        return Map<String, Object?>.from(decoded);
      }
      throw const SyncQrException(SyncQrFailure.invalidPayload);
    } on SyncQrException {
      rethrow;
    } on Object {
      throw const SyncQrException(SyncQrFailure.invalidPayload);
    }
  }

  void _requireType(Map<String, Object?> json, String type) {
    final actual = _string(json, 'type');
    if (actual != type) {
      throw const SyncQrException(SyncQrFailure.unsupportedType);
    }
  }

  void _requireQrVersion(Map<String, Object?> json) {
    if (_integer(json, 'formatVersion') != syncQrFormatVersion) {
      throw const SyncQrException(SyncQrFailure.incompatibleVersion);
    }
  }

  LanSessionQrPayload _normalizeLan({
    required String host,
    required int port,
    required String sessionCode,
    required String syncGroupId,
    required String keyId,
    required DateTime createdAt,
    required DateTime? expiresAt,
  }) {
    final trimmedHost = host.trim();
    final trimmedCode = sessionCode.trim();
    if (!_hostPattern.hasMatch(trimmedHost) ||
        port <= 0 ||
        port > 65535 ||
        !_sessionCodePattern.hasMatch(trimmedCode) ||
        !_uuidV4.hasMatch(syncGroupId) ||
        !_uuidV4.hasMatch(keyId)) {
      throw const SyncQrException(SyncQrFailure.invalidLanSession);
    }
    return LanSessionQrPayload(
      formatVersion: syncQrFormatVersion,
      syncProtocolVersion: syncProtocolVersion,
      host: trimmedHost,
      port: port,
      sessionCode: trimmedCode,
      syncGroupId: syncGroupId,
      keyId: keyId,
      createdAt: createdAt.toUtc(),
      expiresAt: expiresAt?.toUtc(),
    );
  }
}

const _pairingType = 'backlogVault.pairingInvitation';
const _lanType = 'backlogVault.lanSession';

void _requireExactKeys(Map<String, Object?> json, Set<String> keys) {
  if (json.keys.toSet().difference(keys).isNotEmpty ||
      keys.difference(json.keys.toSet()).isNotEmpty) {
    throw const SyncQrException(SyncQrFailure.invalidPayload);
  }
}

String _string(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is String && value.trim().isNotEmpty) return value.trim();
  throw const SyncQrException(SyncQrFailure.invalidPayload);
}

int _integer(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is int) return value;
  throw const SyncQrException(SyncQrFailure.invalidPayload);
}

DateTime _date(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! String) {
    throw const SyncQrException(SyncQrFailure.invalidPayload);
  }
  try {
    return DateTime.parse(value).toUtc();
  } on Object {
    throw const SyncQrException(SyncQrFailure.invalidPayload);
  }
}

DateTime? _nullableDate(Object? value) {
  if (value == null) return null;
  if (value is! String) {
    throw const SyncQrException(SyncQrFailure.invalidPayload);
  }
  try {
    return DateTime.parse(value).toUtc();
  } on Object {
    throw const SyncQrException(SyncQrFailure.invalidPayload);
  }
}

final _uuidV4 = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  caseSensitive: false,
);

final _hostPattern = RegExp(r'^[a-zA-Z0-9.\-:\[\]]{1,253}$');
final _sessionCodePattern = RegExp(r'^[A-Za-z0-9\-]{4,32}$');
