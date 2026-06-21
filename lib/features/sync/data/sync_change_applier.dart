import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/time/clock.dart';
import '../domain/sync_models.dart';
import '../domain/sync_package_models.dart';
import 'canonical_json.dart';
import 'sync_change_tracking.dart';
import 'sync_conflict_detector.dart';

class SyncChangeApplier {
  const SyncChangeApplier({
    required AppDatabase database,
    required SyncAwareTransaction transaction,
    required SyncConflictDetector conflictDetector,
    CanonicalJson serializer = canonicalJson,
    Clock clock = systemClock,
  }) : _db = database,
       _transaction = transaction,
       _conflictDetector = conflictDetector,
       _serializer = serializer,
       _clock = clock;

  final AppDatabase _db;
  final SyncAwareTransaction _transaction;
  final SyncConflictDetector _conflictDetector;
  final CanonicalJson _serializer;
  final Clock _clock;

  Future<SyncImportResult> apply(SyncPackageDocument document) {
    return _transaction.run(
      source: SyncChangeSource.remote,
      mode: SyncMutationMode.remote,
      action: (_) async {
        final preview = await _conflictDetector.preview(document);
        final applicable =
            preview.items
                .where(
                  (item) =>
                      item.disposition == SyncImportDisposition.applicable,
                )
                .toList();
        final ordered = _applyOrder(applicable);
        final tombstones = {
          for (final row in document.tombstones) row.deleteChangeId: row,
        };
        for (final item in ordered) {
          await _upsertEntity(item.change.entityType, item.resultingSnapshot!);
          await _insertChange(item.change);
          await _upsertEntityState(item);
          if (item.change.operation == 'deleted' ||
              item.change.operation == 'unlinked') {
            await _upsertTombstone(item, tombstones[item.change.changeId]);
          }
        }
        await _updateSyncState(document.packageId, applicable);
        return SyncImportResult(preview: preview, applied: applicable.length);
      },
    );
  }

  List<SyncImportItem> _applyOrder(List<SyncImportItem> items) {
    final indexed = items.indexed.toList();
    indexed.sort((first, second) {
      final firstDelete = _isDelete(first.$2.change) ? 1 : 0;
      final secondDelete = _isDelete(second.$2.change) ? 1 : 0;
      final deleteOrder = firstDelete.compareTo(secondDelete);
      if (deleteOrder != 0) return deleteOrder;
      final priority = _priority(
        first.$2.change.entityType,
      ).compareTo(_priority(second.$2.change.entityType));
      if (priority != 0) return priority;
      return first.$1.compareTo(second.$1);
    });
    return indexed.map((entry) => entry.$2).toList(growable: false);
  }

  bool _isDelete(SyncPackageChange change) =>
      change.operation == 'deleted' || change.operation == 'unlinked';

  int _priority(String entityType) => switch (entityType) {
    'platform' => 0,
    'genre' => 1,
    'game' => 2,
    'library_entry' => 3,
    'external_game_id' => 4,
    'library_entry_platform' => 5,
    'game_genre' => 6,
    'playthrough' => 7,
    'saved_view' => 8,
    _ => 99,
  };

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
        );
  }

  Future<void> _upsertEntityState(SyncImportItem item) async {
    final change = item.change;
    final id = 'local:${change.entityType}:${change.entityId}';
    final existing =
        await (_db.select(_db.syncEntityStates)
          ..where((row) => row.id.equals(id))).getSingleOrNull();
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
    final snapshot = item.resultingSnapshot!;
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
    SyncImportItem item,
    SyncPackageTombstone? incoming,
  ) {
    final change = item.change;
    final snapshot = item.resultingSnapshot!;
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
    List<SyncImportItem> applied,
  ) async {
    final state =
        await (_db.select(_db.syncStates)
          ..where((row) => row.id.equals('local'))).getSingle();
    final vector = _intMap(state.seenVectorJson);
    for (final item in applied) {
      final change = item.change;
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

  Future<void> _upsertEntity(
    String entityType,
    Map<String, Object?> row,
  ) async {
    switch (entityType) {
      case 'game':
        await _db
            .into(_db.games)
            .insertOnConflictUpdate(
              GamesCompanion.insert(
                id: _string(row, 'id'),
                title: _string(row, 'title'),
                sortTitle: Value(_nullableString(row['sortTitle'])),
                releaseDate: Value(_nullableDate(row['releaseDate'])),
                type: Value(_string(row, 'type')),
                createdAt: _date(row, 'createdAt'),
                updatedAt: _date(row, 'updatedAt'),
                deletedAt: Value(_nullableDate(row['deletedAt'])),
              ),
            );
      case 'library_entry':
        await _db
            .into(_db.libraryEntries)
            .insertOnConflictUpdate(
              LibraryEntriesCompanion.insert(
                id: _string(row, 'id'),
                gameId: _string(row, 'gameId'),
                status: _string(row, 'status'),
                personalRating: Value(_nullableInt(row['personalRating'])),
                personalNotes: Value(_nullableString(row['personalNotes'])),
                createdAt: _date(row, 'createdAt'),
                updatedAt: _date(row, 'updatedAt'),
                deletedAt: Value(_nullableDate(row['deletedAt'])),
              ),
            );
      case 'platform':
        await _db
            .into(_db.platforms)
            .insertOnConflictUpdate(
              PlatformsCompanion.insert(
                id: _string(row, 'id'),
                name: _string(row, 'name'),
                shortName: Value(_nullableString(row['shortName'])),
                createdAt: _date(row, 'createdAt'),
                updatedAt: _date(row, 'updatedAt'),
                deletedAt: Value(_nullableDate(row['deletedAt'])),
              ),
            );
      case 'library_entry_platform':
        await _db
            .into(_db.libraryEntryPlatforms)
            .insertOnConflictUpdate(
              LibraryEntryPlatformsCompanion.insert(
                id: _string(row, 'id'),
                libraryEntryId: _string(row, 'libraryEntryId'),
                platformId: _string(row, 'platformId'),
                isPrimary: Value(row['isPrimary'] == true),
                createdAt: _date(row, 'createdAt'),
                updatedAt: _date(row, 'updatedAt'),
                deletedAt: Value(_nullableDate(row['deletedAt'])),
              ),
            );
      case 'genre':
        await _db
            .into(_db.genres)
            .insertOnConflictUpdate(
              GenresCompanion.insert(
                id: _string(row, 'id'),
                name: _string(row, 'name'),
                createdAt: _date(row, 'createdAt'),
                updatedAt: _date(row, 'updatedAt'),
                deletedAt: Value(_nullableDate(row['deletedAt'])),
              ),
            );
      case 'game_genre':
        await _db
            .into(_db.gameGenres)
            .insertOnConflictUpdate(
              GameGenresCompanion.insert(
                id: _string(row, 'id'),
                gameId: _string(row, 'gameId'),
                genreId: _string(row, 'genreId'),
                createdAt: _date(row, 'createdAt'),
                updatedAt: _date(row, 'updatedAt'),
                deletedAt: Value(_nullableDate(row['deletedAt'])),
              ),
            );
      case 'playthrough':
        await _db
            .into(_db.playthroughs)
            .insertOnConflictUpdate(
              PlaythroughsCompanion.insert(
                id: _string(row, 'id'),
                libraryEntryId: _string(row, 'libraryEntryId'),
                platformId: Value(_nullableString(row['platformId'])),
                status: _string(row, 'status'),
                startedAt: Value(_nullableDate(row['startedAt'])),
                completedAt: Value(_nullableDate(row['completedAt'])),
                hoursPlayed: Value(_nullableDouble(row['hoursPlayed'])),
                rating: Value(_nullableInt(row['rating'])),
                notes: Value(_nullableString(row['notes'])),
                createdAt: _date(row, 'createdAt'),
                updatedAt: _date(row, 'updatedAt'),
                deletedAt: Value(_nullableDate(row['deletedAt'])),
              ),
            );
      case 'saved_view':
        await _db
            .into(_db.savedViews)
            .insertOnConflictUpdate(
              SavedViewsCompanion.insert(
                id: _string(row, 'id'),
                name: _string(row, 'name'),
                filterJson: _storedJson(row['filterJson']),
                sortJson: _storedJson(row['sortJson']),
                columnConfigJson: _storedJson(row['columnConfigJson']),
                createdAt: _date(row, 'createdAt'),
                updatedAt: _date(row, 'updatedAt'),
                deletedAt: Value(_nullableDate(row['deletedAt'])),
              ),
            );
      case 'external_game_id':
        final id = _string(row, 'id');
        final existing =
            await (_db.select(_db.externalGameIds)
              ..where((table) => table.id.equals(id))).getSingleOrNull();
        await _db
            .into(_db.externalGameIds)
            .insertOnConflictUpdate(
              ExternalGameIdsCompanion.insert(
                id: id,
                gameId: _string(row, 'gameId'),
                provider: _string(row, 'provider'),
                externalId: _string(row, 'externalId'),
                externalSlug: Value(_nullableString(row['externalSlug'])),
                externalUrl: Value(existing?.externalUrl),
                matchedTitle: Value(_nullableString(row['matchedTitle'])),
                createdAt: _date(row, 'createdAt'),
                updatedAt: _date(row, 'updatedAt'),
                deletedAt: Value(_nullableDate(row['deletedAt'])),
              ),
            );
      default:
        throw const SyncPackageException('Unsupported sync entity.');
    }
  }

  String _storedJson(Object? value) =>
      value is String ? value : _serializer.encode(value);

  String _string(Map<String, Object?> row, String key) {
    final value = row[key];
    if (value is String) return value;
    throw SyncPackageException('Invalid synced entity field: $key');
  }

  String? _nullableString(Object? value) {
    if (value == null) return null;
    if (value is String) return value;
    throw const SyncPackageException('Invalid synced entity string.');
  }

  int? _nullableInt(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    throw const SyncPackageException('Invalid synced entity integer.');
  }

  double? _nullableDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    throw const SyncPackageException('Invalid synced entity number.');
  }

  DateTime _date(Map<String, Object?> row, String key) {
    final value = _nullableDate(row[key]);
    if (value != null) return value;
    throw SyncPackageException('Invalid synced entity date: $key');
  }

  DateTime? _nullableDate(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value.toUtc();
    if (value is String) return DateTime.parse(value).toUtc();
    throw const SyncPackageException('Invalid synced entity date.');
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
