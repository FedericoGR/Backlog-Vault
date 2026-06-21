import '../../../core/version/app_versions.dart' as app_versions;

const syncPackageFormatVersion = 1;
const syncPackageExtension = 'vaultsync';

class SyncPackageException implements Exception {
  const SyncPackageException(this.message);

  final String message;

  @override
  String toString() => message;
}

class SyncPackageDevice {
  const SyncPackageDevice({
    required this.deviceId,
    required this.displayName,
    required this.platform,
  });

  final String deviceId;
  final String displayName;
  final String platform;

  Map<String, Object?> toJson() => {
    'deviceId': deviceId,
    'displayName': displayName,
    'platform': platform,
  };

  factory SyncPackageDevice.fromJson(Map<String, Object?> json) {
    return SyncPackageDevice(
      deviceId: _string(json, 'deviceId'),
      displayName: _string(json, 'displayName'),
      platform: _string(json, 'platform'),
    );
  }
}

class SyncPackageChange {
  const SyncPackageChange({
    required this.changeId,
    required this.originDeviceId,
    required this.originCounter,
    required this.mutationId,
    required this.mutationSequence,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.changedFields,
    required this.payload,
    required this.snapshot,
    required this.causalContext,
    required this.source,
    required this.contentHash,
    required this.createdAt,
  });

  final String changeId;
  final String originDeviceId;
  final int originCounter;
  final String mutationId;
  final int mutationSequence;
  final String entityType;
  final String entityId;
  final String operation;
  final List<String> changedFields;
  final Map<String, Object?> payload;
  final Map<String, Object?> snapshot;
  final Map<String, int> causalContext;
  final String source;
  final String contentHash;
  final DateTime createdAt;

  Map<String, Object?> toJson() => {
    'changeId': changeId,
    'originDeviceId': originDeviceId,
    'originCounter': originCounter,
    'mutationId': mutationId,
    'mutationSequence': mutationSequence,
    'entityType': entityType,
    'entityId': entityId,
    'operation': operation,
    'changedFields': changedFields,
    'payload': payload,
    'snapshot': snapshot,
    'causalContext': causalContext,
    'source': source,
    'contentHash': contentHash,
    'createdAt': createdAt.toUtc().toIso8601String(),
  };

  factory SyncPackageChange.fromJson(Map<String, Object?> json) {
    return SyncPackageChange(
      changeId: _string(json, 'changeId'),
      originDeviceId: _string(json, 'originDeviceId'),
      originCounter: _integer(json, 'originCounter'),
      mutationId: _string(json, 'mutationId'),
      mutationSequence: _integer(json, 'mutationSequence'),
      entityType: _string(json, 'entityType'),
      entityId: _string(json, 'entityId'),
      operation: _string(json, 'operation'),
      changedFields: _stringList(json, 'changedFields'),
      payload: _map(json['payload']),
      snapshot: _map(json['snapshot']),
      causalContext: _intMap(json['causalContext']),
      source: _string(json, 'source'),
      contentHash: _string(json, 'contentHash'),
      createdAt: DateTime.parse(_string(json, 'createdAt')).toUtc(),
    );
  }
}

class SyncPackageTombstone {
  const SyncPackageTombstone({
    required this.entityType,
    required this.entityId,
    required this.deleteChangeId,
    required this.originDeviceId,
    required this.originCounter,
    required this.causalContext,
    required this.lastContentHash,
    required this.deletedAt,
    required this.retainUntil,
  });

  final String entityType;
  final String entityId;
  final String deleteChangeId;
  final String originDeviceId;
  final int originCounter;
  final Map<String, int> causalContext;
  final String? lastContentHash;
  final DateTime deletedAt;
  final DateTime? retainUntil;

  Map<String, Object?> toJson() => {
    'entityType': entityType,
    'entityId': entityId,
    'deleteChangeId': deleteChangeId,
    'originDeviceId': originDeviceId,
    'originCounter': originCounter,
    'causalContext': causalContext,
    'lastContentHash': lastContentHash,
    'deletedAt': deletedAt.toUtc().toIso8601String(),
    'retainUntil': retainUntil?.toUtc().toIso8601String(),
  };

  factory SyncPackageTombstone.fromJson(Map<String, Object?> json) {
    return SyncPackageTombstone(
      entityType: _string(json, 'entityType'),
      entityId: _string(json, 'entityId'),
      deleteChangeId: _string(json, 'deleteChangeId'),
      originDeviceId: _string(json, 'originDeviceId'),
      originCounter: _integer(json, 'originCounter'),
      causalContext: _intMap(json['causalContext']),
      lastContentHash: _nullableString(json['lastContentHash']),
      deletedAt: DateTime.parse(_string(json, 'deletedAt')).toUtc(),
      retainUntil: _nullableDate(json['retainUntil']),
    );
  }
}

class SyncPackageEntityState {
  const SyncPackageEntityState({
    required this.entityType,
    required this.entityId,
    required this.fieldVersions,
    required this.entityVector,
    required this.lastChangeId,
    required this.contentHash,
    required this.isDeleted,
  });

  final String entityType;
  final String entityId;
  final Map<String, String> fieldVersions;
  final Map<String, int> entityVector;
  final String lastChangeId;
  final String contentHash;
  final bool isDeleted;

  Map<String, Object?> toJson() => {
    'entityType': entityType,
    'entityId': entityId,
    'fieldVersions': fieldVersions,
    'entityVector': entityVector,
    'lastChangeId': lastChangeId,
    'contentHash': contentHash,
    'isDeleted': isDeleted,
  };

  factory SyncPackageEntityState.fromJson(Map<String, Object?> json) {
    return SyncPackageEntityState(
      entityType: _string(json, 'entityType'),
      entityId: _string(json, 'entityId'),
      fieldVersions: _stringMap(json['fieldVersions']),
      entityVector: _intMap(json['entityVector']),
      lastChangeId: _string(json, 'lastChangeId'),
      contentHash: _string(json, 'contentHash'),
      isDeleted: json['isDeleted'] == true,
    );
  }
}

class SyncMediaManifestEntry {
  const SyncMediaManifestEntry({
    required this.mediaAssetId,
    required this.gameId,
    required this.hash,
    required this.kind,
    required this.provider,
    required this.externalId,
    required this.fileName,
    required this.mimeType,
    required this.width,
    required this.height,
  });

  final String mediaAssetId;
  final String gameId;
  final String? hash;
  final String kind;
  final String? provider;
  final String? externalId;
  final String fileName;
  final String? mimeType;
  final int? width;
  final int? height;

  Map<String, Object?> toJson() => {
    'mediaAssetId': mediaAssetId,
    'gameId': gameId,
    'hash': hash,
    'kind': kind,
    'provider': provider,
    'externalId': externalId,
    'fileName': fileName,
    'mimeType': mimeType,
    'width': width,
    'height': height,
  };

  factory SyncMediaManifestEntry.fromJson(Map<String, Object?> json) {
    return SyncMediaManifestEntry(
      mediaAssetId: _string(json, 'mediaAssetId'),
      gameId: _string(json, 'gameId'),
      hash: _nullableString(json['hash']),
      kind: _string(json, 'kind'),
      provider: _nullableString(json['provider']),
      externalId: _nullableString(json['externalId']),
      fileName: _string(json, 'fileName'),
      mimeType: _nullableString(json['mimeType']),
      width: _nullableInt(json['width']),
      height: _nullableInt(json['height']),
    );
  }
}

class SyncPackageDocument {
  const SyncPackageDocument({
    required this.packageId,
    required this.formatVersion,
    required this.syncProtocolVersion,
    required this.createdAt,
    required this.fromDevice,
    required this.exportedVector,
    required this.changes,
    required this.tombstones,
    required this.entityStates,
    required this.mediaManifest,
    required this.warnings,
  });

  final String packageId;
  final int formatVersion;
  final int syncProtocolVersion;
  final DateTime createdAt;
  final SyncPackageDevice fromDevice;
  final Map<String, int> exportedVector;
  final List<SyncPackageChange> changes;
  final List<SyncPackageTombstone> tombstones;
  final List<SyncPackageEntityState> entityStates;
  final List<SyncMediaManifestEntry> mediaManifest;
  final List<String> warnings;

  Map<String, Object?> toJson() => {
    'packageId': packageId,
    'formatVersion': formatVersion,
    'syncProtocolVersion': syncProtocolVersion,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'fromDevice': fromDevice.toJson(),
    'exportedVector': exportedVector,
    'changes': changes.map((change) => change.toJson()).toList(),
    'tombstones': tombstones.map((row) => row.toJson()).toList(),
    'entityStates': entityStates.map((row) => row.toJson()).toList(),
    'mediaManifest': mediaManifest.map((row) => row.toJson()).toList(),
    'warnings': warnings,
  };

  factory SyncPackageDocument.fromJson(Map<String, Object?> json) {
    final formatVersion = _integer(json, 'formatVersion');
    final protocolVersion = _integer(json, 'syncProtocolVersion');
    if (formatVersion != syncPackageFormatVersion ||
        protocolVersion != app_versions.syncProtocolVersion) {
      throw const SyncPackageException(
        'The sync package version is not supported.',
      );
    }
    return SyncPackageDocument(
      packageId: _string(json, 'packageId'),
      formatVersion: formatVersion,
      syncProtocolVersion: protocolVersion,
      createdAt: DateTime.parse(_string(json, 'createdAt')).toUtc(),
      fromDevice: SyncPackageDevice.fromJson(_map(json['fromDevice'])),
      exportedVector: _intMap(json['exportedVector']),
      changes:
          _mapList(json['changes']).map(SyncPackageChange.fromJson).toList(),
      tombstones:
          _mapList(
            json['tombstones'],
          ).map(SyncPackageTombstone.fromJson).toList(),
      entityStates:
          _mapList(
            json['entityStates'],
          ).map(SyncPackageEntityState.fromJson).toList(),
      mediaManifest:
          _mapList(
            json['mediaManifest'],
          ).map(SyncMediaManifestEntry.fromJson).toList(),
      warnings: _stringList(json, 'warnings'),
    );
  }
}

enum SyncImportDisposition {
  alreadyApplied,
  applicable,
  conflict,
  unsupported,
  invalid,
  pendingMedia,
}

class SyncImportItem {
  const SyncImportItem({
    required this.change,
    required this.disposition,
    required this.reason,
    this.resultingSnapshot,
  });

  final SyncPackageChange change;
  final SyncImportDisposition disposition;
  final String reason;
  final Map<String, Object?>? resultingSnapshot;
}

class SyncImportPreview {
  const SyncImportPreview({required this.document, required this.items});

  final SyncPackageDocument document;
  final List<SyncImportItem> items;

  int count(SyncImportDisposition disposition) =>
      items.where((item) => item.disposition == disposition).length;
}

class SyncImportResult {
  const SyncImportResult({required this.preview, required this.applied});

  final SyncImportPreview preview;
  final int applied;
}

class SyncPackageExportResult {
  const SyncPackageExportResult({
    required this.fileName,
    required this.bytes,
    required this.changeCount,
  });

  final String fileName;
  final List<int> bytes;
  final int changeCount;
}

String _string(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is String && value.isNotEmpty) return value;
  throw FormatException('Invalid sync package field: $key');
}

int _integer(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is int) return value;
  if (value is num) return value.toInt();
  throw FormatException('Invalid sync package field: $key');
}

String? _nullableString(Object? value) {
  if (value == null) return null;
  if (value is String) return value;
  throw const FormatException('Invalid optional sync package string.');
}

int? _nullableInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  throw const FormatException('Invalid optional sync package integer.');
}

DateTime? _nullableDate(Object? value) {
  if (value == null) return null;
  if (value is String) return DateTime.parse(value).toUtc();
  throw const FormatException('Invalid optional sync package date.');
}

Map<String, Object?> _map(Object? value) {
  if (value is Map<String, Object?>) return value;
  if (value is Map) return Map<String, Object?>.from(value);
  throw const FormatException('Invalid sync package object.');
}

List<Map<String, Object?>> _mapList(Object? value) {
  if (value is! List) throw const FormatException('Invalid sync package list.');
  return value.map(_map).toList();
}

List<String> _stringList(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! List) throw FormatException('Invalid sync package field: $key');
  return value.map((item) {
    if (item is String) return item;
    throw FormatException('Invalid sync package field: $key');
  }).toList();
}

Map<String, int> _intMap(Object? value) {
  final map = _map(value);
  return map.map((key, item) {
    if (item is num) return MapEntry(key, item.toInt());
    throw const FormatException('Invalid sync vector.');
  });
}

Map<String, String> _stringMap(Object? value) {
  final map = _map(value);
  return map.map((key, item) {
    if (item is String) return MapEntry(key, item);
    throw const FormatException('Invalid sync field version.');
  });
}
