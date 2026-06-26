import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' hide Uint8List;

import '../../../core/database/app_database.dart';
import '../../../core/time/clock.dart';
import '../../media/data/media_file_storage.dart';
import '../domain/lan_sync_models.dart';
import '../domain/sync_package_models.dart';
import 'canonical_json.dart';
import 'sync_conflict_detector.dart';

class LanMediaTransferService {
  const LanMediaTransferService({
    required AppDatabase database,
    required MediaFileStorage storage,
    required SyncConflictDetector conflictDetector,
    Clock clock = systemClock,
    CanonicalJson serializer = canonicalJson,
    int maxFileBytes = defaultMaxFileBytes,
    int maxSessionBytes = defaultMaxSessionBytes,
    int maxFilesPerSession = defaultMaxFilesPerSession,
  }) : _db = database,
       _storage = storage,
       _conflictDetector = conflictDetector,
       _clock = clock,
       _serializer = serializer,
       _maxFileBytes = maxFileBytes,
       _maxSessionBytes = maxSessionBytes,
       _maxFilesPerSession = maxFilesPerSession;

  static const defaultMaxFileBytes = 8 * 1024 * 1024;
  static const defaultMaxSessionBytes = 16 * 1024 * 1024;
  static const defaultMaxFilesPerSession = 100;

  final AppDatabase _db;
  final MediaFileStorage _storage;
  final SyncConflictDetector _conflictDetector;
  final Clock _clock;
  final CanonicalJson _serializer;
  final int _maxFileBytes;
  final int _maxSessionBytes;
  final int _maxFilesPerSession;

  Future<LanMediaPrepareResult> prepareIncomingMedia(
    SyncPackageDocument document,
  ) async {
    final pending = await _pendingMediaChanges(document);
    if (pending.isEmpty) {
      return const LanMediaPrepareResult(
        requests: [],
        skipped: 0,
        failed: 0,
        pendingAfterLocalResolution: 0,
      );
    }
    final manifest = _manifestById(document);
    final requests = <LanMediaRequest>[];
    final existingFiles = <String, _ResolvedMediaFile>{};
    var failed = 0;
    for (final change in pending.values) {
      if (_isDelete(change)) continue;
      final entry = manifest[change.entityId];
      if (entry == null || !_isRequestable(entry, change)) {
        failed++;
        continue;
      }
      final existing = await _findUsableExistingFile(entry);
      if (existing != null) {
        existingFiles[entry.mediaAssetId] = existing;
        continue;
      }
      if (requests.length >= _maxFilesPerSession) {
        failed++;
        continue;
      }
      requests.add(
        LanMediaRequest(
          mediaAssetId: entry.mediaAssetId,
          gameId: entry.gameId,
          hash: entry.hash!,
        ),
      );
    }
    final existingApply =
        existingFiles.isEmpty
            ? const LanMediaReceiveResult(
              received: 0,
              skipped: 0,
              failed: 0,
              bytesTransferred: 0,
              pendingAfterReceive: 0,
            )
            : await _applyResolvedMedia(document, existingFiles);
    final pendingAfter = await _pendingMediaCount(document);
    return LanMediaPrepareResult(
      requests: requests,
      skipped: existingApply.received + existingApply.skipped,
      failed: failed + existingApply.failed,
      pendingAfterLocalResolution: pendingAfter,
    );
  }

  Future<LanMediaSendResult> buildPayloads({
    required SyncPackageDocument document,
    required List<LanMediaRequest> requests,
  }) async {
    if (requests.length > _maxFilesPerSession) {
      return LanMediaSendResult(
        payloads: const [],
        sent: 0,
        skipped: 0,
        failed: requests.length,
        bytesTransferred: 0,
      );
    }
    final manifest = _manifestById(document);
    final payloads = <LanMediaPayload>[];
    var failed = 0;
    var skipped = 0;
    var totalBytes = 0;
    for (final request in requests) {
      final entry = manifest[request.mediaAssetId];
      if (entry == null ||
          entry.gameId != request.gameId ||
          entry.hash != request.hash ||
          !_isValidHash(request.hash)) {
        failed++;
        continue;
      }
      final row =
          await (_db.select(_db.mediaAssets)
                ..where((table) => table.id.equals(request.mediaAssetId))
                ..where((table) => table.deletedAt.isNull())
                ..limit(1))
              .getSingleOrNull();
      if (row == null ||
          row.gameId != request.gameId ||
          row.hash != request.hash ||
          !_isSafeMediaPath(row.localPath)) {
        failed++;
        continue;
      }
      try {
        final file = await _storage.resolveFile(row.localPath);
        if (!await file.exists()) {
          skipped++;
          continue;
        }
        final length = await file.length();
        if (length <= 0 || length > _maxFileBytes) {
          failed++;
          continue;
        }
        if (totalBytes + length > _maxSessionBytes) {
          failed++;
          continue;
        }
        final bytes = await file.readAsBytes();
        if (bytes.length != length) {
          failed++;
          continue;
        }
        final hash = sha256.convert(bytes).toString();
        final mimeType = _detectSupportedMimeType(bytes);
        if (hash != request.hash ||
            mimeType == null ||
            !_mimeMatches(entry.mimeType, mimeType)) {
          failed++;
          continue;
        }
        totalBytes += bytes.length;
        payloads.add(
          LanMediaPayload(
            mediaAssetId: request.mediaAssetId,
            gameId: request.gameId,
            hash: request.hash,
            mimeType: mimeType,
            byteLength: bytes.length,
            bytesBase64: base64Encode(bytes),
          ),
        );
      } on FileSystemException {
        failed++;
      }
    }
    return LanMediaSendResult(
      payloads: payloads,
      sent: payloads.length,
      skipped: skipped,
      failed: failed,
      bytesTransferred: totalBytes,
    );
  }

  Future<LanMediaReceiveResult> receivePayloads({
    required SyncPackageDocument document,
    required List<LanMediaPayload> payloads,
  }) async {
    if (payloads.length > _maxFilesPerSession) {
      return LanMediaReceiveResult(
        received: 0,
        skipped: 0,
        failed: payloads.length,
        bytesTransferred: 0,
        pendingAfterReceive: await _pendingMediaCount(document),
      );
    }
    final pending = await _pendingMediaChanges(document);
    final manifest = _manifestById(document);
    final resolved = <String, _ResolvedMediaFile>{};
    var failed = 0;
    var skipped = 0;
    var totalBytes = 0;
    for (final payload in payloads) {
      final change = pending[payload.mediaAssetId];
      final entry = manifest[payload.mediaAssetId];
      if (change == null ||
          entry == null ||
          entry.gameId != payload.gameId ||
          entry.hash != payload.hash ||
          payload.byteLength <= 0 ||
          payload.byteLength > _maxFileBytes ||
          !_isRequestable(entry, change)) {
        failed++;
        continue;
      }
      final existing = await _findUsableExistingFile(entry);
      if (existing != null) {
        resolved[payload.mediaAssetId] = existing;
        skipped++;
        continue;
      }
      Uint8List bytes;
      try {
        bytes = Uint8List.fromList(base64Decode(payload.bytesBase64));
      } on FormatException {
        failed++;
        continue;
      }
      if (bytes.length != payload.byteLength ||
          totalBytes + bytes.length > _maxSessionBytes) {
        failed++;
        continue;
      }
      final hash = sha256.convert(bytes).toString();
      final mimeType = _detectSupportedMimeType(bytes);
      if (hash != payload.hash ||
          mimeType == null ||
          !_mimeMatches(payload.mimeType, mimeType) ||
          !_mimeMatches(entry.mimeType, mimeType)) {
        failed++;
        continue;
      }
      try {
        final stored = await _storage.saveBytes(
          gameId: payload.gameId,
          assetId: payload.mediaAssetId,
          bytes: bytes,
        );
        if (stored.hash != payload.hash ||
            !_mimeMatches(payload.mimeType, stored.mimeType)) {
          failed++;
          continue;
        }
        totalBytes += bytes.length;
        resolved[payload.mediaAssetId] = _ResolvedMediaFile(
          localPath: stored.localPath,
          fileName: stored.fileName,
          mimeType: stored.mimeType,
          hash: stored.hash,
          byteLength: bytes.length,
        );
      } on Object {
        failed++;
      }
    }
    final applied =
        resolved.isEmpty
            ? const LanMediaReceiveResult(
              received: 0,
              skipped: 0,
              failed: 0,
              bytesTransferred: 0,
              pendingAfterReceive: 0,
            )
            : await _applyResolvedMedia(document, resolved);
    final pendingAfter = await _pendingMediaCount(document);
    return LanMediaReceiveResult(
      received: applied.received,
      skipped: skipped + applied.skipped,
      failed: failed + applied.failed,
      bytesTransferred: totalBytes,
      pendingAfterReceive: pendingAfter,
    );
  }

  Future<Map<String, SyncPackageChange>> _pendingMediaChanges(
    SyncPackageDocument document,
  ) async {
    final preview = await _conflictDetector.preview(document);
    return {
      for (final item in preview.items)
        if (item.disposition == SyncImportDisposition.pendingMedia &&
            item.change.entityType == 'media_asset')
          item.change.entityId: item.change,
    };
  }

  Future<int> _pendingMediaCount(SyncPackageDocument document) async {
    final preview = await _conflictDetector.preview(document);
    return preview.count(SyncImportDisposition.pendingMedia);
  }

  Future<LanMediaReceiveResult> _applyResolvedMedia(
    SyncPackageDocument document,
    Map<String, _ResolvedMediaFile> files,
  ) async {
    final pending = await _pendingMediaChanges(document);
    final applied = <SyncPackageChange>[];
    var failed = 0;
    var skipped = 0;
    var bytes = 0;
    await _db.transaction(() async {
      final tombstones = {
        for (final row in document.tombstones) row.deleteChangeId: row,
      };
      for (final entry in files.entries) {
        final change = pending[entry.key];
        if (change == null) {
          skipped++;
          continue;
        }
        final snapshot = await _mediaSnapshotToApply(change, entry.value);
        if (snapshot == null) {
          failed++;
          continue;
        }
        await _upsertMediaAsset(snapshot);
        await _insertChange(change);
        await _upsertEntityState(change, snapshot);
        if (_isDelete(change)) {
          await _upsertTombstone(change, snapshot, tombstones[change.changeId]);
        }
        applied.add(change);
        bytes += entry.value.byteLength;
      }
      await _updateSyncState(document.packageId, applied);
    });
    return LanMediaReceiveResult(
      received: applied.length,
      skipped: skipped,
      failed: failed,
      bytesTransferred: bytes,
      pendingAfterReceive: await _pendingMediaCount(document),
    );
  }

  Future<Map<String, Object?>?> _mediaSnapshotToApply(
    SyncPackageChange change,
    _ResolvedMediaFile file,
  ) async {
    if (!_hasRequiredMediaSnapshot(change.snapshot)) return null;
    final current = await _mediaAssetMap(change.entityId);
    if (_isCreate(change)) {
      if (!await _activeGameExists(_string(change.snapshot, 'gameId'))) {
        return null;
      }
      if (current != null &&
          !_sameMediaState(current, change.snapshot, file.hash)) {
        return null;
      }
      return _withLocalFile(change.snapshot, file);
    }
    if (current == null) return null;
    if (!_isDelete(change) && current['deletedAt'] != null) return null;
    if (!await _fieldsSafe(change, current)) return null;
    final next = Map<String, Object?>.from(current)..addAll(change.payload);
    if (_isDelete(change)) {
      next['deletedAt'] ??= change.snapshot['deletedAt'] ?? change.createdAt;
      next['isSelected'] = false;
      return next;
    }
    return _withLocalFile(next, file);
  }

  Map<String, Object?> _withLocalFile(
    Map<String, Object?> source,
    _ResolvedMediaFile file,
  ) {
    return Map<String, Object?>.from(source)
      ..['localPath'] = file.localPath
      ..['fileName'] = file.fileName
      ..['mimeType'] = file.mimeType
      ..['hash'] = file.hash;
  }

  Future<bool> _fieldsSafe(
    SyncPackageChange change,
    Map<String, Object?> current,
  ) async {
    final stateId = 'local:${change.entityType}:${change.entityId}';
    final state =
        await (_db.select(_db.syncEntityStates)
              ..where((row) => row.id.equals(stateId))
              ..limit(1))
            .getSingleOrNull();
    final fieldVersions =
        state == null
            ? const <String, String>{}
            : _stringMap(state.fieldVersionsJson);
    for (final field in change.changedFields) {
      if (_sameValue(current[field], change.payload[field])) continue;
      final version = fieldVersions[field];
      if (version == null || !_isDominated(version, change.causalContext)) {
        return false;
      }
    }
    return true;
  }

  Future<void> _upsertMediaAsset(Map<String, Object?> row) async {
    final isSelected = row['isSelected'] == true && row['deletedAt'] == null;
    final gameId = _string(row, 'gameId');
    final kind = _string(row, 'kind');
    if (isSelected) {
      await (_db.update(_db.mediaAssets)
            ..where((table) => table.gameId.equals(gameId))
            ..where((table) => table.kind.equals(kind))
            ..where((table) => table.deletedAt.isNull()))
          .write(
            MediaAssetsCompanion(
              isSelected: const Value(false),
              updatedAt: Value(_clock.now()),
            ),
          );
    }
    await _db
        .into(_db.mediaAssets)
        .insertOnConflictUpdate(
          MediaAssetsCompanion.insert(
            id: _string(row, 'id'),
            gameId: gameId,
            kind: kind,
            source: _string(row, 'source'),
            provider: Value(_nullableString(row['provider'])),
            externalId: Value(_nullableString(row['externalId'])),
            remoteUrl: const Value(null),
            localPath: _string(row, 'localPath'),
            fileName: _string(row, 'fileName'),
            mimeType: Value(_nullableString(row['mimeType'])),
            width: Value(_nullableInt(row['width'])),
            height: Value(_nullableInt(row['height'])),
            hash: Value(_nullableString(row['hash'])),
            isSelected: Value(isSelected),
            attribution: Value(_nullableString(row['attribution'])),
            createdAt: _date(row, 'createdAt'),
            updatedAt: _date(row, 'updatedAt'),
            deletedAt: Value(_nullableDate(row['deletedAt'])),
          ),
        );
  }

  Future<void> _insertChange(SyncPackageChange change) {
    return _db
        .into(_db.syncChanges)
        .insert(
          SyncChangesCompanion.insert(
            changeId: change.changeId,
            originDeviceId: change.originDeviceId,
            originCounter: change.originCounter,
            mutationId: change.mutationId,
            mutationSequence: change.mutationSequence,
            entityType: change.entityType,
            entityId: change.entityId,
            operation: change.operation,
            changedFieldsJson: _serializer.encode(change.changedFields),
            payloadJson: _serializer.encode(change.payload),
            snapshotJson: _serializer.encode(change.snapshot),
            causalContextJson: _serializer.encode(change.causalContext),
            source: change.source,
            contentHash: change.contentHash,
            createdAt: change.createdAt,
            appliedAt: Value(_clock.now()),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> _upsertEntityState(
    SyncPackageChange change,
    Map<String, Object?> snapshot,
  ) async {
    final id = 'local:${change.entityType}:${change.entityId}';
    final existing =
        await (_db.select(_db.syncEntityStates)
              ..where((row) => row.id.equals(id))
              ..limit(1))
            .getSingleOrNull();
    final fieldVersions =
        existing == null
            ? <String, String>{}
            : _stringMap(existing.fieldVersionsJson);
    for (final field in change.changedFields) {
      fieldVersions[field] = change.changeId;
    }
    final vector =
        existing == null ? <String, int>{} : _intMap(existing.entityVectorJson);
    for (final entry in change.causalContext.entries) {
      if ((vector[entry.key] ?? 0) < entry.value) {
        vector[entry.key] = entry.value;
      }
    }
    vector[change.originDeviceId] = change.originCounter;
    await _db
        .into(_db.syncEntityStates)
        .insertOnConflictUpdate(
          SyncEntityStatesCompanion.insert(
            id: id,
            entityType: change.entityType,
            entityId: change.entityId,
            fieldVersionsJson: _serializer.encode(fieldVersions),
            entityVectorJson: _serializer.encode(vector),
            lastChangeId: change.changeId,
            contentHash: _serializer.sha256Hex(snapshot),
            isDeleted: Value(snapshot['deletedAt'] != null),
            updatedAt: _clock.now(),
          ),
        );
  }

  Future<void> _upsertTombstone(
    SyncPackageChange change,
    Map<String, Object?> snapshot,
    SyncPackageTombstone? incoming,
  ) {
    final deletedAt =
        incoming?.deletedAt ??
        _nullableDate(snapshot['deletedAt']) ??
        change.createdAt;
    return _db
        .into(_db.syncTombstones)
        .insertOnConflictUpdate(
          SyncTombstonesCompanion.insert(
            tombstoneId: 'local:${change.entityType}:${change.entityId}',
            entityType: change.entityType,
            entityId: change.entityId,
            deleteChangeId: change.changeId,
            originDeviceId: change.originDeviceId,
            originCounter: change.originCounter,
            causalContextJson: _serializer.encode(change.causalContext),
            lastContentHash: Value(
              incoming?.lastContentHash ?? _serializer.sha256Hex(snapshot),
            ),
            deletedAt: deletedAt,
            retainUntil: Value(incoming?.retainUntil),
          ),
        );
  }

  Future<void> _updateSyncState(
    String packageId,
    List<SyncPackageChange> applied,
  ) async {
    if (applied.isEmpty) return;
    final state =
        await (_db.select(_db.syncStates)
          ..where((row) => row.id.equals('local'))).getSingle();
    final vector = _intMap(state.seenVectorJson);
    for (final change in applied) {
      final current = vector[change.originDeviceId] ?? 0;
      if (change.originCounter > current) {
        vector[change.originDeviceId] = change.originCounter;
      }
    }
    await (_db.update(_db.syncStates)
      ..where((row) => row.id.equals('local'))).write(
      SyncStatesCompanion(
        seenVectorJson: Value(_serializer.encode(vector)),
        lastImportedPackageId: Value(packageId),
        updatedAt: Value(_clock.now()),
      ),
    );
  }

  Future<_ResolvedMediaFile?> _findUsableExistingFile(
    SyncMediaManifestEntry entry,
  ) async {
    final hash = entry.hash;
    if (!_isValidHash(hash)) return null;
    final mediaHash = hash!;
    final rows =
        await (_db.select(_db.mediaAssets)
              ..where((table) => table.hash.equals(mediaHash))
              ..where((table) => table.deletedAt.isNull())
              ..orderBy([(table) => OrderingTerm.asc(table.id)]))
            .get();
    for (final row in rows) {
      if (!_isSafeMediaPath(row.localPath)) continue;
      try {
        final file = await _storage.resolveFile(row.localPath);
        if (!await file.exists()) continue;
        final length = await file.length();
        if (length <= 0 || length > _maxFileBytes) continue;
        final bytes = await file.readAsBytes();
        if (sha256.convert(bytes).toString() != mediaHash) continue;
        final mimeType = _detectSupportedMimeType(bytes);
        if (mimeType == null || !_mimeMatches(entry.mimeType, mimeType)) {
          continue;
        }
        return _ResolvedMediaFile(
          localPath: row.localPath,
          fileName: row.fileName,
          mimeType: mimeType,
          hash: mediaHash,
          byteLength: bytes.length,
        );
      } on Object {
        continue;
      }
    }
    return null;
  }

  Future<Map<String, Object?>?> _mediaAssetMap(String id) async {
    final row =
        await (_db.select(_db.mediaAssets)
              ..where((table) => table.id.equals(id))
              ..limit(1))
            .getSingleOrNull();
    if (row == null) return null;
    return {
      'id': row.id,
      'gameId': row.gameId,
      'kind': row.kind,
      'source': row.source,
      'provider': row.provider,
      'externalId': row.externalId,
      'fileName': row.fileName,
      'mimeType': row.mimeType,
      'width': row.width,
      'height': row.height,
      'hash': row.hash,
      'isSelected': row.isSelected,
      'attribution': row.attribution,
      'localPath': row.localPath,
      'createdAt': row.createdAt,
      'updatedAt': row.updatedAt,
      'deletedAt': row.deletedAt,
    };
  }

  Future<bool> _activeGameExists(String gameId) async {
    final game =
        await (_db.select(_db.games)
              ..where((table) => table.id.equals(gameId))
              ..where((table) => table.deletedAt.isNull())
              ..limit(1))
            .getSingleOrNull();
    return game != null;
  }

  Map<String, SyncMediaManifestEntry> _manifestById(
    SyncPackageDocument document,
  ) {
    final result = <String, SyncMediaManifestEntry>{};
    for (final entry in document.mediaManifest) {
      result.putIfAbsent(entry.mediaAssetId, () => entry);
    }
    return result;
  }

  bool _isRequestable(SyncMediaManifestEntry entry, SyncPackageChange change) {
    return change.entityType == 'media_asset' &&
        !_isDelete(change) &&
        change.entityId == entry.mediaAssetId &&
        change.snapshot['gameId'] == entry.gameId &&
        change.snapshot['hash'] == entry.hash &&
        _isValidHash(entry.hash) &&
        _isSafeRemoteFileName(entry.fileName) &&
        _isSupportedKind(entry.kind) &&
        _isSupportedMimeType(entry.mimeType);
  }

  bool _hasRequiredMediaSnapshot(Map<String, Object?> row) {
    const required = {
      'id',
      'gameId',
      'kind',
      'source',
      'fileName',
      'createdAt',
      'updatedAt',
    };
    final fileName = row['fileName'];
    return required.every(row.containsKey) &&
        fileName is String &&
        _isSafeRemoteFileName(fileName);
  }

  bool _sameMediaState(
    Map<String, Object?> current,
    Map<String, Object?> incoming,
    String hash,
  ) {
    final fields = {
      'id',
      'gameId',
      'kind',
      'source',
      'provider',
      'externalId',
      'width',
      'height',
      'hash',
      'isSelected',
      'attribution',
      'deletedAt',
    };
    return fields.every((field) {
      if (field == 'hash') return incoming[field] == hash;
      return _sameValue(current[field], incoming[field]);
    });
  }

  bool _isDelete(SyncPackageChange change) =>
      change.operation == 'deleted' || change.operation == 'unlinked';

  bool _isCreate(SyncPackageChange change) =>
      change.operation == 'created' ||
      change.operation == 'linked' ||
      change.operation == 'added';

  bool _isSupportedKind(String kind) => kind == 'cover';

  bool _isValidHash(String? hash) =>
      hash != null && RegExp(r'^[0-9a-f]{64}$').hasMatch(hash);

  bool _isSafeMediaPath(String localPath) {
    final trimmed = localPath.trim();
    if (!trimmed.startsWith('media/')) return false;
    if (trimmed.startsWith('/') || trimmed.startsWith(r'\')) return false;
    if (trimmed.contains(':')) return false;
    if (trimmed.contains(r'\')) return false;
    return !trimmed.split('/').any((part) => part == '..');
  }

  bool _isSafeRemoteFileName(String fileName) {
    final trimmed = fileName.trim();
    if (trimmed.isEmpty) return false;
    if (trimmed.startsWith('/') || trimmed.startsWith(r'\')) return false;
    if (trimmed.contains('/') || trimmed.contains(r'\')) return false;
    if (trimmed.contains(':')) return false;
    if (trimmed == '.' || trimmed == '..') return false;
    return !trimmed.runes.any((rune) => rune < 0x20 || rune == 0x7F);
  }

  bool _isSupportedMimeType(String? mimeType) =>
      mimeType == null ||
      mimeType == 'image/jpeg' ||
      mimeType == 'image/png' ||
      mimeType == 'image/webp';

  bool _mimeMatches(String? expected, String actual) =>
      expected == null || expected == actual;

  String? _detectSupportedMimeType(List<int> bytes) {
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return 'image/jpeg';
    }
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A) {
      return 'image/png';
    }
    if (bytes.length >= 12 &&
        ascii.decode(bytes.sublist(0, 4), allowInvalid: true) == 'RIFF' &&
        ascii.decode(bytes.sublist(8, 12), allowInvalid: true) == 'WEBP') {
      return 'image/webp';
    }
    return null;
  }

  bool _sameValue(Object? first, Object? second) =>
      _serializer.encode(first) == _serializer.encode(second);

  bool _isDominated(String changeId, Map<String, int> causalContext) {
    final separator = changeId.lastIndexOf(':');
    if (separator <= 0 || separator == changeId.length - 1) return false;
    final origin = changeId.substring(0, separator);
    final counter = int.tryParse(changeId.substring(separator + 1));
    return counter != null && (causalContext[origin] ?? 0) >= counter;
  }

  String _string(Map<String, Object?> row, String key) {
    final value = row[key];
    if (value is String) return value;
    throw SyncPackageException('Invalid synced media field: $key');
  }

  String? _nullableString(Object? value) {
    if (value == null) return null;
    if (value is String) return value;
    throw const SyncPackageException('Invalid synced media string.');
  }

  int? _nullableInt(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    throw const SyncPackageException('Invalid synced media integer.');
  }

  DateTime _date(Map<String, Object?> row, String key) {
    final value = _nullableDate(row[key]);
    if (value != null) return value;
    throw SyncPackageException('Invalid synced media date: $key');
  }

  DateTime? _nullableDate(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value.toUtc();
    if (value is String) return DateTime.parse(value).toUtc();
    throw const SyncPackageException('Invalid synced media date.');
  }

  Map<String, String> _stringMap(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map) return <String, String>{};
    return decoded.map(
      (key, value) => MapEntry(key.toString(), value.toString()),
    );
  }

  Map<String, int> _intMap(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map) return <String, int>{};
    return decoded.map(
      (key, value) => MapEntry(key.toString(), (value as num).toInt()),
    );
  }
}

class _ResolvedMediaFile {
  const _ResolvedMediaFile({
    required this.localPath,
    required this.fileName,
    required this.mimeType,
    required this.hash,
    required this.byteLength,
  });

  final String localPath;
  final String fileName;
  final String mimeType;
  final String hash;
  final int byteLength;
}
