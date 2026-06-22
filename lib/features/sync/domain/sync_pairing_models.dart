import 'dart:convert';

import '../../../core/version/app_versions.dart' as app_versions;
import 'sync_package_models.dart';

const pairingPackageFormatVersion = 1;
const pairingPackageExtension = 'vaultpair';

enum SyncPairingFailure {
  noGroup,
  keyMissing,
  groupMismatch,
  keyIdMismatch,
  existingGroup,
  invitationExpired,
  wrongPassphraseOrTampered,
  invalidInvitation,
}

class SyncPairingException implements Exception {
  const SyncPairingException(this.failure);

  final SyncPairingFailure failure;

  @override
  String toString() => 'Sync pairing operation failed: ${failure.name}';
}

class SyncGroupInfo {
  const SyncGroupInfo({
    required this.id,
    required this.displayName,
    required this.keyId,
    required this.protocolVersion,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String displayName;
  final String keyId;
  final int protocolVersion;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class SyncGroupKeyMaterial {
  const SyncGroupKeyMaterial({
    required this.groupId,
    required this.keyId,
    required this.bytes,
  });

  final String groupId;
  final String keyId;
  final List<int> bytes;
}

class SyncPairingState {
  const SyncPairingState({
    required this.localDevice,
    required this.group,
    required this.pairedDeviceCount,
    required this.hasGroupKey,
  });

  final SyncPackageDevice localDevice;
  final SyncGroupInfo? group;
  final int pairedDeviceCount;
  final bool hasGroupKey;

  bool get isConfigured => group != null;
}

class PairingInvitation {
  const PairingInvitation({
    required this.formatVersion,
    required this.syncProtocolVersion,
    required this.createdAt,
    required this.expiresAt,
    required this.group,
    required this.inviterDevice,
  });

  final int formatVersion;
  final int syncProtocolVersion;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final PairingInvitationGroup group;
  final SyncPackageDevice inviterDevice;

  bool isExpiredAt(DateTime value) =>
      expiresAt != null && !value.toUtc().isBefore(expiresAt!.toUtc());

  Map<String, Object?> toJson() => {
    'formatVersion': formatVersion,
    'syncProtocolVersion': syncProtocolVersion,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'expiresAt': expiresAt?.toUtc().toIso8601String(),
    'syncGroup': group.toJson(),
    'inviterDevice': inviterDevice.toJson(),
  };

  factory PairingInvitation.fromJson(Map<String, Object?> json) {
    _requireExactKeys(json, const {
      'formatVersion',
      'syncProtocolVersion',
      'createdAt',
      'expiresAt',
      'syncGroup',
      'inviterDevice',
    });
    final formatVersion = _integer(json, 'formatVersion');
    final protocolVersion = _integer(json, 'syncProtocolVersion');
    if (formatVersion != pairingPackageFormatVersion ||
        protocolVersion != app_versions.syncProtocolVersion) {
      throw const SyncPairingException(SyncPairingFailure.invalidInvitation);
    }
    return PairingInvitation(
      formatVersion: formatVersion,
      syncProtocolVersion: protocolVersion,
      createdAt: _date(json, 'createdAt'),
      expiresAt: _nullableDate(json['expiresAt']),
      group: PairingInvitationGroup.fromJson(_map(json['syncGroup'])),
      inviterDevice: _device(_map(json['inviterDevice'])),
    );
  }
}

class PairingInvitationGroup {
  const PairingInvitationGroup({
    required this.groupId,
    required this.displayName,
    required this.keyId,
    required this.groupKey,
  });

  final String groupId;
  final String displayName;
  final String keyId;
  final List<int> groupKey;

  Map<String, Object?> toJson() => {
    'groupId': groupId,
    'displayName': displayName,
    'keyId': keyId,
    'groupKey': base64Encode(groupKey),
  };

  factory PairingInvitationGroup.fromJson(Map<String, Object?> json) {
    _requireExactKeys(json, const {
      'groupId',
      'displayName',
      'keyId',
      'groupKey',
    });
    final groupId = _uuid(json, 'groupId');
    final keyId = _uuid(json, 'keyId');
    final displayName = _string(json, 'displayName');
    if (displayName.length > 100) {
      throw const SyncPairingException(SyncPairingFailure.invalidInvitation);
    }
    try {
      final groupKey = base64Decode(_string(json, 'groupKey'));
      if (groupKey.length != 32) {
        throw const SyncPairingException(SyncPairingFailure.invalidInvitation);
      }
      return PairingInvitationGroup(
        groupId: groupId,
        displayName: displayName,
        keyId: keyId,
        groupKey: groupKey,
      );
    } on SyncPairingException {
      rethrow;
    } on Object {
      throw const SyncPairingException(SyncPairingFailure.invalidInvitation);
    }
  }
}

class PairingExportResult {
  const PairingExportResult({required this.fileName, required this.bytes});

  final String fileName;
  final List<int> bytes;
}

SyncPackageDevice _device(Map<String, Object?> json) {
  _requireExactKeys(json, const {'deviceId', 'displayName', 'platform'});
  final deviceId = _uuid(json, 'deviceId');
  final displayName = _string(json, 'displayName');
  final platform = _string(json, 'platform');
  if (displayName.length > 100 || platform.length > 32) {
    throw const SyncPairingException(SyncPairingFailure.invalidInvitation);
  }
  return SyncPackageDevice(
    deviceId: deviceId,
    displayName: displayName,
    platform: platform,
  );
}

void _requireExactKeys(Map<String, Object?> json, Set<String> keys) {
  if (json.keys.toSet().difference(keys).isNotEmpty ||
      keys.difference(json.keys.toSet()).isNotEmpty) {
    throw const SyncPairingException(SyncPairingFailure.invalidInvitation);
  }
}

Map<String, Object?> _map(Object? value) {
  if (value is Map<String, Object?>) return value;
  if (value is Map) return Map<String, Object?>.from(value);
  throw const SyncPairingException(SyncPairingFailure.invalidInvitation);
}

String _string(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is String && value.trim().isNotEmpty) return value.trim();
  throw const SyncPairingException(SyncPairingFailure.invalidInvitation);
}

String _uuid(Map<String, Object?> json, String key) {
  final value = _string(json, key);
  if (!_uuidV4.hasMatch(value)) {
    throw const SyncPairingException(SyncPairingFailure.invalidInvitation);
  }
  return value;
}

int _integer(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is int) return value;
  throw const SyncPairingException(SyncPairingFailure.invalidInvitation);
}

DateTime _date(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! String) {
    throw const SyncPairingException(SyncPairingFailure.invalidInvitation);
  }
  try {
    return DateTime.parse(value).toUtc();
  } on Object {
    throw const SyncPairingException(SyncPairingFailure.invalidInvitation);
  }
}

DateTime? _nullableDate(Object? value) {
  if (value == null) return null;
  if (value is! String) {
    throw const SyncPairingException(SyncPairingFailure.invalidInvitation);
  }
  try {
    return DateTime.parse(value).toUtc();
  } on Object {
    throw const SyncPairingException(SyncPairingFailure.invalidInvitation);
  }
}

final _uuidV4 = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  caseSensitive: false,
);
