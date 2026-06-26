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
    this.mediaRequested = 0,
    this.mediaSent = 0,
    this.mediaReceived = 0,
    this.mediaSkipped = 0,
    this.mediaFailed = 0,
    this.mediaBytesTransferred = 0,
  });

  final int changesSent;
  final int changesReceived;
  final int applied;
  final int alreadyApplied;
  final int conflicts;
  final int unsupported;
  final int invalid;
  final int pendingMedia;
  final int mediaRequested;
  final int mediaSent;
  final int mediaReceived;
  final int mediaSkipped;
  final int mediaFailed;
  final int mediaBytesTransferred;

  Map<String, Object?> toJson() => {
    'changesSent': changesSent,
    'changesReceived': changesReceived,
    'applied': applied,
    'alreadyApplied': alreadyApplied,
    'conflicts': conflicts,
    'unsupported': unsupported,
    'invalid': invalid,
    'pendingMedia': pendingMedia,
    'mediaRequested': mediaRequested,
    'mediaSent': mediaSent,
    'mediaReceived': mediaReceived,
    'mediaSkipped': mediaSkipped,
    'mediaFailed': mediaFailed,
    'mediaBytesTransferred': mediaBytesTransferred,
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
      mediaRequested: _optionalInteger(json, 'mediaRequested'),
      mediaSent: _optionalInteger(json, 'mediaSent'),
      mediaReceived: _optionalInteger(json, 'mediaReceived'),
      mediaSkipped: _optionalInteger(json, 'mediaSkipped'),
      mediaFailed: _optionalInteger(json, 'mediaFailed'),
      mediaBytesTransferred: _optionalInteger(json, 'mediaBytesTransferred'),
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

  LanSyncSummary withMedia({
    int? mediaRequested,
    int? mediaSent,
    int? mediaReceived,
    int? mediaSkipped,
    int? mediaFailed,
    int? mediaBytesTransferred,
    int? pendingMedia,
  }) {
    return LanSyncSummary(
      changesSent: changesSent,
      changesReceived: changesReceived,
      applied: applied,
      alreadyApplied: alreadyApplied,
      conflicts: conflicts,
      unsupported: unsupported,
      invalid: invalid,
      pendingMedia: pendingMedia ?? this.pendingMedia,
      mediaRequested: mediaRequested ?? this.mediaRequested,
      mediaSent: mediaSent ?? this.mediaSent,
      mediaReceived: mediaReceived ?? this.mediaReceived,
      mediaSkipped: mediaSkipped ?? this.mediaSkipped,
      mediaFailed: mediaFailed ?? this.mediaFailed,
      mediaBytesTransferred:
          mediaBytesTransferred ?? this.mediaBytesTransferred,
    );
  }
}

class LanMediaRequest {
  const LanMediaRequest({
    required this.mediaAssetId,
    required this.gameId,
    required this.hash,
  });

  final String mediaAssetId;
  final String gameId;
  final String hash;

  Map<String, Object?> toJson() => {
    'mediaAssetId': mediaAssetId,
    'gameId': gameId,
    'hash': hash,
  };

  factory LanMediaRequest.fromJson(Map<String, Object?> json) {
    return LanMediaRequest(
      mediaAssetId: _string(json, 'mediaAssetId'),
      gameId: _string(json, 'gameId'),
      hash: _string(json, 'hash'),
    );
  }
}

class LanMediaPayload {
  const LanMediaPayload({
    required this.mediaAssetId,
    required this.gameId,
    required this.hash,
    required this.mimeType,
    required this.byteLength,
    required this.bytesBase64,
  });

  final String mediaAssetId;
  final String gameId;
  final String hash;
  final String mimeType;
  final int byteLength;
  final String bytesBase64;

  Map<String, Object?> toJson() => {
    'mediaAssetId': mediaAssetId,
    'gameId': gameId,
    'hash': hash,
    'mimeType': mimeType,
    'byteLength': byteLength,
    'bytesBase64': bytesBase64,
  };

  factory LanMediaPayload.fromJson(Map<String, Object?> json) {
    return LanMediaPayload(
      mediaAssetId: _string(json, 'mediaAssetId'),
      gameId: _string(json, 'gameId'),
      hash: _string(json, 'hash'),
      mimeType: _string(json, 'mimeType'),
      byteLength: _integer(json, 'byteLength'),
      bytesBase64: _string(json, 'bytesBase64'),
    );
  }
}

class LanMediaPrepareResult {
  const LanMediaPrepareResult({
    required this.requests,
    required this.skipped,
    required this.failed,
    required this.pendingAfterLocalResolution,
  });

  final List<LanMediaRequest> requests;
  final int skipped;
  final int failed;
  final int pendingAfterLocalResolution;
}

class LanMediaReceiveResult {
  const LanMediaReceiveResult({
    required this.received,
    required this.skipped,
    required this.failed,
    required this.bytesTransferred,
    required this.pendingAfterReceive,
  });

  final int received;
  final int skipped;
  final int failed;
  final int bytesTransferred;
  final int pendingAfterReceive;
}

class LanMediaSendResult {
  const LanMediaSendResult({
    required this.payloads,
    required this.sent,
    required this.skipped,
    required this.failed,
    required this.bytesTransferred,
  });

  final List<LanMediaPayload> payloads;
  final int sent;
  final int skipped;
  final int failed;
  final int bytesTransferred;
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

int _optionalInteger(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  throw const LanSyncException(LanSyncFailure.invalidRequest);
}

String _string(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is String && value.isNotEmpty) return value;
  throw const LanSyncException(LanSyncFailure.invalidRequest);
}
