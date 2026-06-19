import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/ids/id_generator.dart';
import '../../../core/time/clock.dart';
import '../domain/sync_models.dart';
import 'canonical_json.dart';
import 'sync_device_identity.dart';
import 'sync_payload_sanitizer.dart';

const _localSyncStateId = 'local';

class LogicalLibrarySnapshotReader {
  const LogicalLibrarySnapshotReader(this._db);

  final AppDatabase _db;

  /// Captures all logical library tables.
  ///
  /// E19 deliberately favors a complete transactional view over repository-
  /// specific capture rules. This is bounded by a moderate-library smoke test;
  /// E20 should introduce scoped snapshots before transport increases volume.
  Future<Map<SyncEntityKey, SyncEntitySnapshot>> capture() async {
    final result = <SyncEntityKey, SyncEntitySnapshot>{};

    for (final row
        in await (_db.select(_db.games)
          ..orderBy([(table) => OrderingTerm.asc(table.id)])).get()) {
      _add(result, 'game', row.id, {
        'id': row.id,
        'title': row.title,
        'sortTitle': row.sortTitle,
        'releaseDate': row.releaseDate,
        'type': row.type,
        'createdAt': row.createdAt,
        'updatedAt': row.updatedAt,
        'deletedAt': row.deletedAt,
      }, row.deletedAt != null);
    }
    for (final row
        in await (_db.select(_db.libraryEntries)
          ..orderBy([(table) => OrderingTerm.asc(table.id)])).get()) {
      _add(result, 'library_entry', row.id, {
        'id': row.id,
        'gameId': row.gameId,
        'status': row.status,
        'personalRating': row.personalRating,
        'personalNotes': row.personalNotes,
        'createdAt': row.createdAt,
        'updatedAt': row.updatedAt,
        'deletedAt': row.deletedAt,
      }, row.deletedAt != null);
    }
    for (final row
        in await (_db.select(_db.platforms)
          ..orderBy([(table) => OrderingTerm.asc(table.id)])).get()) {
      _add(result, 'platform', row.id, {
        'id': row.id,
        'name': row.name,
        'shortName': row.shortName,
        'createdAt': row.createdAt,
        'updatedAt': row.updatedAt,
        'deletedAt': row.deletedAt,
      }, row.deletedAt != null);
    }
    for (final row
        in await (_db.select(_db.libraryEntryPlatforms)
          ..orderBy([(table) => OrderingTerm.asc(table.id)])).get()) {
      _add(result, 'library_entry_platform', row.id, {
        'id': row.id,
        'libraryEntryId': row.libraryEntryId,
        'platformId': row.platformId,
        'isPrimary': row.isPrimary,
        'createdAt': row.createdAt,
        'updatedAt': row.updatedAt,
        'deletedAt': row.deletedAt,
      }, row.deletedAt != null);
    }
    for (final row
        in await (_db.select(_db.genres)
          ..orderBy([(table) => OrderingTerm.asc(table.id)])).get()) {
      _add(result, 'genre', row.id, {
        'id': row.id,
        'name': row.name,
        'createdAt': row.createdAt,
        'updatedAt': row.updatedAt,
        'deletedAt': row.deletedAt,
      }, row.deletedAt != null);
    }
    for (final row
        in await (_db.select(_db.gameGenres)
          ..orderBy([(table) => OrderingTerm.asc(table.id)])).get()) {
      _add(result, 'game_genre', row.id, {
        'id': row.id,
        'gameId': row.gameId,
        'genreId': row.genreId,
        'createdAt': row.createdAt,
        'updatedAt': row.updatedAt,
        'deletedAt': row.deletedAt,
      }, row.deletedAt != null);
    }
    for (final row
        in await (_db.select(_db.playthroughs)
          ..orderBy([(table) => OrderingTerm.asc(table.id)])).get()) {
      _add(result, 'playthrough', row.id, {
        'id': row.id,
        'libraryEntryId': row.libraryEntryId,
        'platformId': row.platformId,
        'status': row.status,
        'startedAt': row.startedAt,
        'completedAt': row.completedAt,
        'hoursPlayed': row.hoursPlayed,
        'rating': row.rating,
        'notes': row.notes,
        'createdAt': row.createdAt,
        'updatedAt': row.updatedAt,
        'deletedAt': row.deletedAt,
      }, row.deletedAt != null);
    }
    for (final row
        in await (_db.select(_db.savedViews)
          ..orderBy([(table) => OrderingTerm.asc(table.id)])).get()) {
      _add(result, 'saved_view', row.id, {
        'id': row.id,
        'name': row.name,
        'filterJson': _canonicalStoredJson(row.filterJson),
        'sortJson': _canonicalStoredJson(row.sortJson),
        'columnConfigJson': _canonicalStoredJson(row.columnConfigJson),
        'createdAt': row.createdAt,
        'updatedAt': row.updatedAt,
        'deletedAt': row.deletedAt,
      }, row.deletedAt != null);
    }
    for (final row
        in await (_db.select(_db.externalGameIds)
          ..orderBy([(table) => OrderingTerm.asc(table.id)])).get()) {
      _add(result, 'external_game_id', row.id, {
        'id': row.id,
        'gameId': row.gameId,
        'provider': row.provider,
        'externalId': row.externalId,
        'externalSlug': row.externalSlug,
        'matchedTitle': row.matchedTitle,
        'createdAt': row.createdAt,
        'updatedAt': row.updatedAt,
        'deletedAt': row.deletedAt,
      }, row.deletedAt != null);
    }
    for (final row
        in await (_db.select(_db.mediaAssets)
          ..orderBy([(table) => OrderingTerm.asc(table.id)])).get()) {
      // Device-local paths and download URLs are deliberately excluded. Sync
      // will address media bytes by hash in a later deliverable.
      _add(result, 'media_asset', row.id, {
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
        'createdAt': row.createdAt,
        'updatedAt': row.updatedAt,
        'deletedAt': row.deletedAt,
      }, row.deletedAt != null);
    }
    return result;
  }

  void _add(
    Map<SyncEntityKey, SyncEntitySnapshot> result,
    String type,
    String id,
    Map<String, Object?> values,
    bool isDeleted,
  ) {
    final key = SyncEntityKey(type, id);
    result[key] = SyncEntitySnapshot(
      key: key,
      values: values,
      isDeleted: isDeleted,
    );
  }

  Object? _canonicalStoredJson(String source) {
    try {
      return jsonDecode(source);
    } on FormatException {
      return source;
    }
  }
}

class SyncSnapshotDiffer {
  const SyncSnapshotDiffer({CanonicalJson serializer = canonicalJson})
    : _serializer = serializer;

  final CanonicalJson _serializer;

  List<PendingSyncChange> diff(
    Map<SyncEntityKey, SyncEntitySnapshot> before,
    Map<SyncEntityKey, SyncEntitySnapshot> after,
  ) {
    final keys = {...before.keys, ...after.keys}.toList()..sort();
    final changes = <PendingSyncChange>[];
    for (final key in keys) {
      final oldValue = before[key];
      final newValue = after[key];
      if (oldValue == null && newValue != null) {
        changes.add(_created(newValue));
        continue;
      }
      if (oldValue != null && newValue == null) {
        changes.add(_removedWithoutHardDeleteSupport(oldValue));
        continue;
      }
      if (oldValue == null || newValue == null) continue;
      final fields = _changedSemanticFields(oldValue.values, newValue.values);
      if (fields.isEmpty) continue;
      changes.add(
        PendingSyncChange(
          entityType: key.entityType,
          entityId: key.entityId,
          operation: _updatedOperation(oldValue, newValue, fields),
          changedFields: fields,
          payload: {for (final field in fields) field: newValue.values[field]},
          snapshot: newValue.values,
          isDeleted: newValue.isDeleted,
        ),
      );
    }
    return changes;
  }

  List<PendingSyncChange> baseline(
    Map<SyncEntityKey, SyncEntitySnapshot> snapshots,
  ) {
    final values =
        snapshots.values.toList()..sort((a, b) => a.key.compareTo(b.key));
    return values.map(_created).toList(growable: false);
  }

  PendingSyncChange _created(SyncEntitySnapshot snapshot) {
    final fields = _semanticKeys(snapshot.values);
    return PendingSyncChange(
      entityType: snapshot.key.entityType,
      entityId: snapshot.key.entityId,
      operation:
          snapshot.isDeleted
              ? _deletedOperation(snapshot.key.entityType)
              : _createdOperation(snapshot.key.entityType),
      changedFields: fields,
      payload: {for (final field in fields) field: snapshot.values[field]},
      snapshot: snapshot.values,
      isDeleted: snapshot.isDeleted,
    );
  }

  PendingSyncChange _removedWithoutHardDeleteSupport(SyncEntitySnapshot old) {
    return PendingSyncChange(
      entityType: old.key.entityType,
      entityId: old.key.entityId,
      operation: _deletedOperation(old.key.entityType),
      changedFields: const ['deletedAt'],
      payload: const {'deletedAt': null},
      snapshot: old.values,
      isDeleted: true,
    );
  }

  List<String> _changedSemanticFields(
    Map<String, Object?> before,
    Map<String, Object?> after,
  ) {
    final fields =
        {...before.keys, ...after.keys}
            .where((field) => field != 'createdAt' && field != 'updatedAt')
            .where(
              (field) =>
                  _serializer.encode(before[field]) !=
                  _serializer.encode(after[field]),
            )
            .toList()
          ..sort();
    return fields;
  }

  List<String> _semanticKeys(Map<String, Object?> values) =>
      values.keys
          .where((field) => field != 'createdAt' && field != 'updatedAt')
          .toList()
        ..sort();

  String _createdOperation(String entityType) {
    if (_isRelation(entityType) || entityType == 'external_game_id') {
      return 'linked';
    }
    if (entityType == 'media_asset') return 'added';
    return 'created';
  }

  String _deletedOperation(String entityType) =>
      _isRelation(entityType) || entityType == 'external_game_id'
          ? 'unlinked'
          : 'deleted';

  String _updatedOperation(
    SyncEntitySnapshot before,
    SyncEntitySnapshot after,
    List<String> fields,
  ) {
    if (!before.isDeleted && after.isDeleted) {
      return _deletedOperation(after.key.entityType);
    }
    if (before.isDeleted && !after.isDeleted) {
      return _createdOperation(after.key.entityType);
    }
    if (after.key.entityType == 'media_asset' &&
        fields.length == 1 &&
        fields.single == 'isSelected' &&
        after.values['isSelected'] == true) {
      return 'selected';
    }
    return 'updated';
  }

  bool _isRelation(String entityType) =>
      entityType == 'library_entry_platform' || entityType == 'game_genre';
}

class SyncChangeRecorder {
  const SyncChangeRecorder(
    this._db, {
    CanonicalJson serializer = canonicalJson,
    SyncPayloadSanitizer sanitizer = syncPayloadSanitizer,
    Clock clock = systemClock,
  }) : _serializer = serializer,
       _sanitizer = sanitizer,
       _clock = clock;

  final AppDatabase _db;
  final CanonicalJson _serializer;
  final SyncPayloadSanitizer _sanitizer;
  final Clock _clock;

  Future<SyncState> ensureState(LocalDeviceInfo device) async {
    final existing =
        await (_db.select(_db.syncStates)
          ..where((row) => row.id.equals(_localSyncStateId))).getSingleOrNull();
    if (existing != null && existing.localDeviceId == device.id) {
      return existing;
    }
    final now = _clock.now();
    if (existing != null) {
      await (_db.update(_db.syncStates)
        ..where((row) => row.id.equals(_localSyncStateId))).write(
        SyncStatesCompanion(
          localDeviceId: Value(device.id),
          nextLocalCounter: const Value(1),
          seenVectorJson: const Value('{}'),
          peerAckVectorJson: const Value('{}'),
          lastExportedVectorJson: const Value('{}'),
          lastImportedPackageId: const Value(null),
          replicaEpoch: Value(existing.replicaEpoch + 1),
          baselineCreated: const Value(false),
          requiresReconciliation: const Value(true),
          updatedAt: Value(now),
        ),
      );
      return (_db.select(_db.syncStates)
        ..where((row) => row.id.equals(_localSyncStateId))).getSingle();
    }
    await _db
        .into(_db.syncStates)
        .insert(
          SyncStatesCompanion.insert(
            id: _localSyncStateId,
            localDeviceId: device.id,
            updatedAt: now,
          ),
        );
    return (_db.select(_db.syncStates)
      ..where((row) => row.id.equals(_localSyncStateId))).getSingle();
  }

  Future<void> record({
    required LocalDeviceInfo device,
    required String mutationId,
    required SyncChangeSource source,
    required List<PendingSyncChange> changes,
    bool requiresReconciliation = false,
  }) async {
    var state = await ensureState(device);
    if (state.localDeviceId != device.id) {
      throw StateError('Local sync identity does not match sync state.');
    }
    var counter = state.nextLocalCounter;
    final vector = _decodeIntMap(state.seenVectorJson);
    final sequenceStart = await _nextMutationSequence(mutationId);

    for (var index = 0; index < changes.length; index++) {
      final pending = changes[index];
      final changeId = '${device.id}:$counter';
      final causalContext = Map<String, int>.from(vector);
      final changedFields = pending.changedFields.toList()..sort();
      final safePayload = _sanitizer.sanitizeMap(pending.payload);
      final safeSnapshot = _sanitizer.sanitizeMap(pending.snapshot);
      final content = <String, Object?>{
        'causalContext': causalContext,
        'changedFields': changedFields,
        'entityId': pending.entityId,
        'entityType': pending.entityType,
        'operation': pending.operation,
        'originCounter': counter,
        'originDeviceId': device.id,
        'payload': safePayload,
        'snapshot': safeSnapshot,
        'source': source.name,
      };
      final contentHash = _serializer.sha256Hex(content);
      final snapshotHash = _serializer.sha256Hex(safeSnapshot);
      final createdAt = _clock.now();
      await _db
          .into(_db.syncChanges)
          .insert(
            SyncChangesCompanion.insert(
              changeId: changeId,
              originDeviceId: device.id,
              originCounter: counter,
              mutationId: mutationId,
              mutationSequence: sequenceStart + index,
              entityType: pending.entityType,
              entityId: pending.entityId,
              operation: pending.operation,
              changedFieldsJson: _serializer.encode(changedFields),
              payloadJson: _serializer.encode(safePayload),
              snapshotJson: _serializer.encode(safeSnapshot),
              causalContextJson: _serializer.encode(causalContext),
              source: source.name,
              contentHash: contentHash,
              createdAt: createdAt,
            ),
          );

      vector[device.id] = counter;
      await _upsertEntityState(
        pending: pending,
        changeId: changeId,
        contentHash: snapshotHash,
        vector: vector,
        updatedAt: createdAt,
      );
      if (pending.isDeleted || pending.operation == 'unlinked') {
        await _upsertTombstone(
          pending: pending,
          changeId: changeId,
          device: device,
          counter: counter,
          causalContext: causalContext,
          contentHash: snapshotHash,
          deletedAt:
              pending.snapshot['deletedAt'] is DateTime
                  ? pending.snapshot['deletedAt']! as DateTime
                  : createdAt,
        );
      }
      counter++;
    }

    await (_db.update(_db.syncStates)
      ..where((row) => row.id.equals(_localSyncStateId))).write(
      SyncStatesCompanion(
        nextLocalCounter: Value(counter),
        seenVectorJson: Value(_serializer.encode(vector)),
        requiresReconciliation:
            requiresReconciliation ? const Value(true) : const Value.absent(),
        updatedAt: Value(_clock.now()),
      ),
    );
  }

  Future<int> _nextMutationSequence(String mutationId) async {
    final row =
        await _db
            .customSelect(
              'SELECT MAX(mutation_sequence) AS max_sequence FROM sync_changes '
              'WHERE mutation_id = ?',
              variables: [Variable<String>(mutationId)],
            )
            .getSingle();
    return (row.readNullable<int>('max_sequence') ?? -1) + 1;
  }

  Future<void> _upsertEntityState({
    required PendingSyncChange pending,
    required String changeId,
    required String contentHash,
    required Map<String, int> vector,
    required DateTime updatedAt,
  }) async {
    final id = 'local:${pending.entityType}:${pending.entityId}';
    final existing =
        await (_db.select(_db.syncEntityStates)
          ..where((row) => row.id.equals(id))).getSingleOrNull();
    final fieldVersions =
        existing == null
            ? <String, String>{}
            : _decodeStringMap(existing.fieldVersionsJson);
    for (final field in pending.changedFields) {
      fieldVersions[field] = changeId;
    }
    final companion = SyncEntityStatesCompanion(
      id: Value(id),
      entityType: Value(pending.entityType),
      entityId: Value(pending.entityId),
      fieldVersionsJson: Value(_serializer.encode(fieldVersions)),
      entityVectorJson: Value(_serializer.encode(vector)),
      lastChangeId: Value(changeId),
      contentHash: Value(contentHash),
      isDeleted: Value(pending.isDeleted),
      updatedAt: Value(updatedAt),
    );
    if (existing == null) {
      await _db.into(_db.syncEntityStates).insert(companion);
    } else {
      await (_db.update(_db.syncEntityStates)
        ..where((row) => row.id.equals(id))).write(companion);
    }
  }

  Future<void> _upsertTombstone({
    required PendingSyncChange pending,
    required String changeId,
    required LocalDeviceInfo device,
    required int counter,
    required Map<String, int> causalContext,
    required String contentHash,
    required DateTime deletedAt,
  }) async {
    final id = 'local:${pending.entityType}:${pending.entityId}';
    final existing =
        await (_db.select(_db.syncTombstones)
          ..where((row) => row.tombstoneId.equals(id))).getSingleOrNull();
    final companion = SyncTombstonesCompanion(
      tombstoneId: Value(id),
      entityType: Value(pending.entityType),
      entityId: Value(pending.entityId),
      deleteChangeId: Value(changeId),
      originDeviceId: Value(device.id),
      originCounter: Value(counter),
      causalContextJson: Value(_serializer.encode(causalContext)),
      lastContentHash: Value(contentHash),
      deletedAt: Value(deletedAt),
    );
    if (existing == null) {
      await _db.into(_db.syncTombstones).insert(companion);
    } else {
      await (_db.update(_db.syncTombstones)
        ..where((row) => row.tombstoneId.equals(id))).write(companion);
    }
  }

  Map<String, int> _decodeIntMap(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map) return <String, int>{};
    return decoded.map(
      (key, value) => MapEntry(key.toString(), (value as num).toInt()),
    );
  }

  Map<String, String> _decodeStringMap(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map) return <String, String>{};
    return decoded.map(
      (key, value) => MapEntry(key.toString(), value.toString()),
    );
  }
}

class SyncFoundationInitializer {
  SyncFoundationInitializer({
    required AppDatabase database,
    required LogicalLibrarySnapshotReader snapshotReader,
    required SyncSnapshotDiffer differ,
    required SyncChangeRecorder recorder,
    Clock clock = systemClock,
  }) : _db = database,
       _snapshotReader = snapshotReader,
       _differ = differ,
       _recorder = recorder,
       _clock = clock;

  final AppDatabase _db;
  final LogicalLibrarySnapshotReader _snapshotReader;
  final SyncSnapshotDiffer _differ;
  final SyncChangeRecorder _recorder;
  final Clock _clock;
  Future<void>? _initialization;

  Future<void> initialize(LocalDeviceInfo device) async {
    final current = _initialization;
    if (current != null) return current;
    final future = _initialize(device);
    _initialization = future;
    try {
      await future;
    } on Object {
      if (identical(_initialization, future)) _initialization = null;
      rethrow;
    }
  }

  Future<void> _initialize(LocalDeviceInfo device) {
    return _db.transaction(() async {
      var state = await _recorder.ensureState(device);
      if (state.baselineCreated) return;
      final snapshots = await _snapshotReader.capture();
      final changes = _differ.baseline(snapshots);
      await _recorder.record(
        device: device,
        mutationId: 'baseline:${device.id}:1',
        source: SyncChangeSource.baseline,
        changes: changes,
      );
      await (_db.update(_db.syncStates)
        ..where((row) => row.id.equals(_localSyncStateId))).write(
        SyncStatesCompanion(
          baselineCreated: const Value(true),
          updatedAt: Value(_clock.now()),
        ),
      );
      state =
          await (_db.select(_db.syncStates)
            ..where((row) => row.id.equals(_localSyncStateId))).getSingle();
      if (!state.baselineCreated) {
        throw StateError('Sync baseline initialization did not complete.');
      }
    });
  }
}

class SyncMutationScopeData {
  const SyncMutationScopeData({
    required this.mutationId,
    required this.source,
    required this.mode,
  });

  final String mutationId;
  final SyncChangeSource source;
  final SyncMutationMode mode;
}

class SyncMutationScope {
  static final _zoneKey = Object();

  static SyncMutationScopeData? get current =>
      Zone.current[_zoneKey] as SyncMutationScopeData?;

  static Future<T> run<T>({
    required String mutationId,
    required SyncChangeSource source,
    SyncMutationMode mode = SyncMutationMode.local,
    required Future<T> Function() action,
  }) {
    return runZoned(
      action,
      zoneValues: {
        _zoneKey: SyncMutationScopeData(
          mutationId: mutationId,
          source: source,
          mode: mode,
        ),
      },
    );
  }
}

class SyncAwareTransaction {
  SyncAwareTransaction({
    required AppDatabase database,
    required SyncDeviceIdentityService identityService,
    required SyncFoundationInitializer initializer,
    required LogicalLibrarySnapshotReader snapshotReader,
    required SyncSnapshotDiffer differ,
    required SyncChangeRecorder recorder,
    IdGenerator? ids,
  }) : _db = database,
       _identityService = identityService,
       _initializer = initializer,
       _snapshotReader = snapshotReader,
       _differ = differ,
       _recorder = recorder,
       _ids = ids ?? defaultIdGenerator,
       _enabled = true;

  SyncAwareTransaction.disabled(AppDatabase database)
    : _db = database,
      _identityService = null,
      _initializer = null,
      _snapshotReader = null,
      _differ = null,
      _recorder = null,
      _ids = defaultIdGenerator,
      _enabled = false;

  final AppDatabase _db;
  final SyncDeviceIdentityService? _identityService;
  final SyncFoundationInitializer? _initializer;
  final LogicalLibrarySnapshotReader? _snapshotReader;
  final SyncSnapshotDiffer? _differ;
  final SyncChangeRecorder? _recorder;
  final IdGenerator _ids;
  final bool _enabled;

  Future<T> run<T>({
    required SyncChangeSource source,
    SyncMutationMode mode = SyncMutationMode.local,
    required Future<T> Function(SyncMutationContext context) action,
  }) async {
    final scope = SyncMutationScope.current;
    final effectiveSource = scope?.source ?? source;
    final effectiveMode = scope?.mode ?? mode;
    final mutationId = scope?.mutationId ?? _ids.newId();
    final context = SyncMutationContext(
      mutationId: mutationId,
      source: effectiveSource,
      mode: effectiveMode,
    );

    if (!_enabled) return _db.transaction(() => action(context));

    final device = await _identityService!.ensureIdentity();
    await _initializer!.initialize(device);
    return _db.transaction(() async {
      if (effectiveMode != SyncMutationMode.local ||
          effectiveSource == SyncChangeSource.restore) {
        final result = await action(context);
        if (effectiveSource == SyncChangeSource.restore) {
          await _recorder!.record(
            device: device,
            mutationId: mutationId,
            source: effectiveSource,
            changes: const [],
            requiresReconciliation: true,
          );
        }
        return result;
      }

      final before = await _snapshotReader!.capture();
      final result = await action(context);
      final after = await _snapshotReader.capture();
      final changes = _differ!.diff(before, after);
      await _recorder!.record(
        device: device,
        mutationId: mutationId,
        source: effectiveSource,
        changes: changes,
      );
      return result;
    });
  }
}
