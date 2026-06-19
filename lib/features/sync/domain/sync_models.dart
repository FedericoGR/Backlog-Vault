enum SyncDeviceStatus { local, paired, revoked, identityLost, identityMismatch }

class LocalDeviceInfo {
  const LocalDeviceInfo({
    required this.id,
    required this.displayName,
    required this.platform,
    required this.createdAt,
    required this.status,
  });

  final String id;
  final String displayName;
  final String platform;
  final DateTime createdAt;
  final SyncDeviceStatus status;
}

enum SyncChangeSource {
  manual,
  metadata,
  bulk,
  import,
  restore,
  normalization,
  remote,
  baseline,
}

enum SyncMutationMode { local, remote, suppressed }

class SyncMutationContext {
  const SyncMutationContext({
    required this.mutationId,
    required this.source,
    required this.mode,
  });

  final String mutationId;
  final SyncChangeSource source;
  final SyncMutationMode mode;
}

class SyncEntityKey implements Comparable<SyncEntityKey> {
  const SyncEntityKey(this.entityType, this.entityId);

  final String entityType;
  final String entityId;

  @override
  int compareTo(SyncEntityKey other) {
    final typeComparison = entityType.compareTo(other.entityType);
    return typeComparison != 0
        ? typeComparison
        : entityId.compareTo(other.entityId);
  }

  @override
  bool operator ==(Object other) =>
      other is SyncEntityKey &&
      entityType == other.entityType &&
      entityId == other.entityId;

  @override
  int get hashCode => Object.hash(entityType, entityId);
}

class SyncEntitySnapshot {
  const SyncEntitySnapshot({
    required this.key,
    required this.values,
    required this.isDeleted,
  });

  final SyncEntityKey key;
  final Map<String, Object?> values;
  final bool isDeleted;
}

class PendingSyncChange {
  const PendingSyncChange({
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.changedFields,
    required this.payload,
    required this.snapshot,
    required this.isDeleted,
  });

  final String entityType;
  final String entityId;
  final String operation;
  final List<String> changedFields;
  final Map<String, Object?> payload;
  final Map<String, Object?> snapshot;
  final bool isDeleted;
}
