import 'dart:convert';

import '../../../core/database/app_database.dart';
import '../domain/sync_models.dart';
import '../domain/sync_package_models.dart';
import 'canonical_json.dart';
import 'sync_change_tracking.dart';
import 'sync_payload_sanitizer.dart';

class SyncConflictDetector {
  const SyncConflictDetector({
    required AppDatabase database,
    required LogicalLibrarySnapshotReader snapshotReader,
    CanonicalJson serializer = canonicalJson,
    SyncPayloadSanitizer sanitizer = syncPayloadSanitizer,
  }) : _db = database,
       _snapshotReader = snapshotReader,
       _serializer = serializer,
       _sanitizer = sanitizer;

  final AppDatabase _db;
  final LogicalLibrarySnapshotReader _snapshotReader;
  final CanonicalJson _serializer;
  final SyncPayloadSanitizer _sanitizer;

  Future<SyncImportPreview> preview(SyncPackageDocument document) async {
    final knownChanges = {
      for (final row in await _db.select(_db.syncChanges).get())
        row.changeId: row,
    };
    final knownOrigins = {
      for (final row in knownChanges.values)
        '${row.originDeviceId}:${row.originCounter}': row.changeId,
    };
    final projections = await _snapshotReader.capture();
    final versions = <SyncEntityKey, Map<String, String>>{};
    for (final row in await _db.select(_db.syncEntityStates).get()) {
      versions[SyncEntityKey(row.entityType, row.entityId)] = _stringMap(
        row.fieldVersionsJson,
      );
    }
    final localState =
        await (_db.select(_db.syncStates)
          ..where((row) => row.id.equals('local'))).getSingleOrNull();
    final processedVector =
        localState == null
            ? <String, int>{}
            : _intMap(localState.seenVectorJson);
    final packageIds = <String>{};
    final items = <SyncImportItem>[];

    for (final change in _causalOrder(document.changes, processedVector)) {
      final key = SyncEntityKey(change.entityType, change.entityId);
      SyncImportItem item;
      if (!packageIds.add(change.changeId)) {
        item = _item(change, SyncImportDisposition.invalid, 'duplicate_change');
      } else if (!_isIntegrityValid(change)) {
        item = _item(change, SyncImportDisposition.invalid, 'invalid_change');
      } else if (knownChanges.containsKey(change.changeId)) {
        item = _item(
          change,
          SyncImportDisposition.alreadyApplied,
          'already_applied',
        );
      } else if (knownOrigins['${change.originDeviceId}:${change.originCounter}'] !=
          null) {
        item = _item(
          change,
          SyncImportDisposition.invalid,
          'origin_counter_collision',
        );
      } else if (change.entityType == 'media_asset') {
        item = _item(
          change,
          SyncImportDisposition.pendingMedia,
          'media_bytes_not_included',
        );
      } else if (!_isSupported(change)) {
        item = _item(
          change,
          SyncImportDisposition.unsupported,
          'unsupported_change',
        );
      } else {
        item = _classify(change, projections[key], versions[key] ?? const {});
      }
      items.add(item);
      if (item.disposition == SyncImportDisposition.applicable) {
        final result = item.resultingSnapshot!;
        projections[key] = SyncEntitySnapshot(
          key: key,
          values: result,
          isDeleted: result['deletedAt'] != null,
        );
        final fieldVersions = Map<String, String>.from(
          versions[key] ?? const {},
        );
        for (final field in change.changedFields) {
          fieldVersions[field] = change.changeId;
        }
        versions[key] = fieldVersions;
      }
      final current = processedVector[change.originDeviceId] ?? 0;
      if (change.originCounter > current) {
        processedVector[change.originDeviceId] = change.originCounter;
      }
    }
    return SyncImportPreview(document: document, items: items);
  }

  SyncImportItem _classify(
    SyncPackageChange change,
    SyncEntitySnapshot? current,
    Map<String, String> fieldVersions,
  ) {
    final isCreate =
        change.operation == 'created' || change.operation == 'linked';
    final isDelete =
        change.operation == 'deleted' || change.operation == 'unlinked';
    if (isCreate) {
      if (!_hasRequiredSnapshot(change.entityType, change.snapshot)) {
        return _item(change, SyncImportDisposition.invalid, 'invalid_snapshot');
      }
      if (current != null &&
          !_sameSemanticState(current.values, change.snapshot)) {
        return _item(change, SyncImportDisposition.conflict, 'entity_exists');
      }
      return _item(
        change,
        SyncImportDisposition.applicable,
        'safe_create',
        resultingSnapshot:
            current == null
                ? Map<String, Object?>.from(change.snapshot)
                : Map<String, Object?>.from(current.values),
      );
    }
    if (current == null) {
      return _item(change, SyncImportDisposition.conflict, 'entity_missing');
    }
    if (!isDelete && current.isDeleted) {
      return _item(change, SyncImportDisposition.conflict, 'local_deleted');
    }
    if (isDelete) {
      if (!current.isDeleted &&
          fieldVersions.values.any(
            (version) => !_isDominated(version, change.causalContext),
          )) {
        return _item(
          change,
          SyncImportDisposition.conflict,
          'delete_vs_local_update',
        );
      }
      final result = Map<String, Object?>.from(current.values)
        ..addAll(change.payload);
      result['deletedAt'] ??= change.snapshot['deletedAt'] ?? change.createdAt;
      return _item(
        change,
        SyncImportDisposition.applicable,
        'safe_delete',
        resultingSnapshot: result,
      );
    }
    if (change.changedFields.isEmpty ||
        change.changedFields.any(
          (field) => !change.payload.containsKey(field),
        )) {
      return _item(change, SyncImportDisposition.invalid, 'invalid_patch');
    }
    for (final field in change.changedFields) {
      if (_sameValue(current.values[field], change.payload[field])) continue;
      final version = fieldVersions[field];
      if (version == null || !_isDominated(version, change.causalContext)) {
        return _item(
          change,
          SyncImportDisposition.conflict,
          'field_changed_locally',
        );
      }
    }
    final result = Map<String, Object?>.from(current.values)
      ..addAll(change.payload);
    return _item(
      change,
      SyncImportDisposition.applicable,
      'safe_patch',
      resultingSnapshot: result,
    );
  }

  bool _isIntegrityValid(SyncPackageChange change) {
    if (change.changeId != '${change.originDeviceId}:${change.originCounter}') {
      return false;
    }
    if (change.originCounter <= 0 || change.mutationSequence < 0) return false;
    final safePayload = _sanitizer.sanitizeMap(change.payload);
    final safeSnapshot = _sanitizer.sanitizeMap(change.snapshot);
    if (_serializer.encode(safePayload) != _serializer.encode(change.payload) ||
        _serializer.encode(safeSnapshot) !=
            _serializer.encode(change.snapshot)) {
      return false;
    }
    final content = <String, Object?>{
      'causalContext': change.causalContext,
      'changedFields': [...change.changedFields]..sort(),
      'entityId': change.entityId,
      'entityType': change.entityType,
      'operation': change.operation,
      'originCounter': change.originCounter,
      'originDeviceId': change.originDeviceId,
      'payload': change.payload,
      'snapshot': change.snapshot,
      'source': change.source,
    };
    return _serializer.sha256Hex(content) == change.contentHash;
  }

  bool _isSupported(SyncPackageChange change) {
    const supportedTypes = {
      'game',
      'library_entry',
      'platform',
      'library_entry_platform',
      'genre',
      'game_genre',
      'playthrough',
      'saved_view',
      'external_game_id',
    };
    if (!supportedTypes.contains(change.entityType)) return false;
    const operations = {'created', 'updated', 'deleted', 'linked', 'unlinked'};
    return operations.contains(change.operation);
  }

  bool _hasRequiredSnapshot(String type, Map<String, Object?> snapshot) {
    final required = switch (type) {
      'game' => const {'id', 'title', 'type', 'createdAt', 'updatedAt'},
      'library_entry' => const {
        'id',
        'gameId',
        'status',
        'createdAt',
        'updatedAt',
      },
      'platform' => const {'id', 'name', 'createdAt', 'updatedAt'},
      'library_entry_platform' => const {
        'id',
        'libraryEntryId',
        'platformId',
        'createdAt',
        'updatedAt',
      },
      'genre' => const {'id', 'name', 'createdAt', 'updatedAt'},
      'game_genre' => const {
        'id',
        'gameId',
        'genreId',
        'createdAt',
        'updatedAt',
      },
      'playthrough' => const {
        'id',
        'libraryEntryId',
        'status',
        'createdAt',
        'updatedAt',
      },
      'saved_view' => const {
        'id',
        'name',
        'filterJson',
        'sortJson',
        'columnConfigJson',
        'createdAt',
        'updatedAt',
      },
      'external_game_id' => const {
        'id',
        'gameId',
        'provider',
        'externalId',
        'createdAt',
        'updatedAt',
      },
      _ => const <String>{},
    };
    return required.isNotEmpty && required.every(snapshot.containsKey);
  }

  bool _sameSemanticState(
    Map<String, Object?> first,
    Map<String, Object?> second,
  ) {
    final fields = {
      ...first.keys,
      ...second.keys,
    }.where((field) => field != 'createdAt' && field != 'updatedAt');
    return fields.every((field) => _sameValue(first[field], second[field]));
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

  List<SyncPackageChange> _causalOrder(
    List<SyncPackageChange> changes,
    Map<String, int> initialVector,
  ) {
    final remaining = [...changes];
    final ordered = <SyncPackageChange>[];
    final vector = Map<String, int>.from(initialVector);
    while (remaining.isNotEmpty) {
      final ready =
          remaining
              .where(
                (change) => change.causalContext.entries.every(
                  (entry) => (vector[entry.key] ?? 0) >= entry.value,
                ),
              )
              .toList()
            ..sort(_compareChanges);
      final next =
          ready.isEmpty
              ? (remaining..sort(_compareChanges)).first
              : ready.first;
      remaining.remove(next);
      ordered.add(next);
      final current = vector[next.originDeviceId] ?? 0;
      if (next.originCounter > current) {
        vector[next.originDeviceId] = next.originCounter;
      }
    }
    return ordered;
  }

  int _compareChanges(SyncPackageChange first, SyncPackageChange second) {
    final date = first.createdAt.compareTo(second.createdAt);
    if (date != 0) return date;
    final origin = first.originDeviceId.compareTo(second.originDeviceId);
    if (origin != 0) return origin;
    final counter = first.originCounter.compareTo(second.originCounter);
    if (counter != 0) return counter;
    return first.changeId.compareTo(second.changeId);
  }

  SyncImportItem _item(
    SyncPackageChange change,
    SyncImportDisposition disposition,
    String reason, {
    Map<String, Object?>? resultingSnapshot,
  }) {
    return SyncImportItem(
      change: change,
      disposition: disposition,
      reason: reason,
      resultingSnapshot: resultingSnapshot,
    );
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
