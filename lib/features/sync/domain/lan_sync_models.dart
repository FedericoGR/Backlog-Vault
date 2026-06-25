import 'sync_package_models.dart';

enum LanSyncFailure {
  notPaired,
  keyMissing,
  invalidSessionCode,
  groupMismatch,
  keyIdMismatch,
  protocolMismatch,
  invalidRequest,
  requestTooLarge,
  packageRejected,
  networkUnavailable,
  connectionInterrupted,
  timeout,
  stopped,
}

class LanSyncException implements Exception {
  const LanSyncException(this.failure);

  final LanSyncFailure failure;

  @override
  String toString() => 'LAN sync failed: ${failure.name}';
}

class LanSyncSummary {
  const LanSyncSummary({
    required this.changesSent,
    required this.changesReceived,
    required this.applied,
    required this.alreadyApplied,
    required this.conflicts,
    required this.unsupported,
    required this.invalid,
    required this.pendingMedia,
  });

  final int changesSent;
  final int changesReceived;
  final int applied;
  final int alreadyApplied;
  final int conflicts;
  final int unsupported;
  final int invalid;
  final int pendingMedia;

  Map<String, Object?> toJson() => {
    'changesSent': changesSent,
    'changesReceived': changesReceived,
    'applied': applied,
    'alreadyApplied': alreadyApplied,
    'conflicts': conflicts,
    'unsupported': unsupported,
    'invalid': invalid,
    'pendingMedia': pendingMedia,
  };

  factory LanSyncSummary.fromJson(Map<String, Object?> json) {
    return LanSyncSummary(
      changesSent: _integer(json, 'changesSent'),
      changesReceived: _integer(json, 'changesReceived'),
      applied: _integer(json, 'applied'),
      alreadyApplied: _integer(json, 'alreadyApplied'),
      conflicts: _integer(json, 'conflicts'),
      unsupported: _integer(json, 'unsupported'),
      invalid: _integer(json, 'invalid'),
      pendingMedia: _integer(json, 'pendingMedia'),
    );
  }

  factory LanSyncSummary.fromImportResult({
    required int changesSent,
    required SyncImportResult result,
  }) {
    final preview = result.preview;
    return LanSyncSummary(
      changesSent: changesSent,
      changesReceived: preview.items.length,
      applied: result.applied,
      alreadyApplied: preview.count(SyncImportDisposition.alreadyApplied),
      conflicts: preview.count(SyncImportDisposition.conflict),
      unsupported: preview.count(SyncImportDisposition.unsupported),
      invalid: preview.count(SyncImportDisposition.invalid),
      pendingMedia: preview.count(SyncImportDisposition.pendingMedia),
    );
  }
}

class LanSyncResult {
  const LanSyncResult({
    required this.peerDevice,
    required this.local,
    this.peer,
  });

  final SyncPackageDevice peerDevice;
  final LanSyncSummary local;
  final LanSyncSummary? peer;
}

int _integer(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is int) return value;
  if (value is num) return value.toInt();
  throw const LanSyncException(LanSyncFailure.invalidRequest);
}
