import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/formatting/date_formatters.dart';
import '../../../core/time/clock.dart';
import '../../library/data/library_query_repository.dart';
import '../../library/domain/game_status.dart';
import '../domain/backup_models.dart';

final exportRepositoryProvider = Provider<ExportRepository>((ref) {
  return ExportRepository(ref.watch(appDatabaseProvider));
});

class ExportRepository {
  const ExportRepository(this._db, {Clock clock = systemClock})
    : _clock = clock;

  final AppDatabase _db;
  final Clock _clock;

  Future<LogicalLibraryExport> exportLogical({
    bool includeSoftDeleted = true,
  }) async {
    return LogicalLibraryExport(
      formatVersion: 1,
      schemaVersion: _db.schemaVersion,
      exportedAt: _clock.now(),
      games: await _games(includeSoftDeleted),
      libraryEntries: await _libraryEntries(includeSoftDeleted),
      platforms: await _platforms(includeSoftDeleted),
      libraryEntryPlatforms: await _libraryEntryPlatforms(includeSoftDeleted),
      genres: await _genres(includeSoftDeleted),
      gameGenres: await _gameGenres(includeSoftDeleted),
      playthroughs: await _playthroughs(includeSoftDeleted),
      savedViews: await _savedViews(includeSoftDeleted),
      externalGameIds: await _externalGameIds(includeSoftDeleted),
      mediaAssets: await _mediaAssets(includeSoftDeleted),
    );
  }

  Future<List<int>> exportLogicalJsonBytes() async {
    final export = await exportLogical();
    return utf8.encode(_prettyJson(export.toJson()));
  }

  Future<List<int>> exportActiveLibraryCsvBytes() async {
    final rows = await LibraryQueryRepository(_db).watchRows().first;
    final table = <List<Object?>>[
      [
        'Titulo',
        'Estado',
        'Fecha salida',
        'Fecha completado',
        'Horas',
        'Puntaje',
        'Plataformas',
        'Generos',
        'Notas',
        'Tipo',
      ],
      for (final row in rows)
        [
          row.title,
          row.status.label,
          row.releaseDate == null ? '' : formatVisibleDate(row.releaseDate),
          row.completedAt == null ? '' : formatVisibleDate(row.completedAt),
          row.hoursPlayed?.toStringAsFixed(1) ?? '',
          row.personalRating?.toString() ?? '',
          row.platforms.map((platform) => platform.name).join('; '),
          row.genres.map((genre) => genre.name).join('; '),
          row.personalNotes ?? '',
          row.type,
        ],
    ];
    final csv = const CsvEncoder().convert(table);
    return [0xEF, 0xBB, 0xBF, ...utf8.encode(csv)];
  }

  Future<void> restoreLogical(LogicalLibraryExport export) {
    if (export.schemaVersion > _db.schemaVersion) {
      throw const BackupException(
        'El backup usa un schema más nuevo que esta versión de la app.',
      );
    }

    return _db.transaction(() async {
      final now = _clock.now();
      await _upsertGames(export.games);
      await _upsertPlatforms(export.platforms);
      await _upsertGenres(export.genres);
      await _upsertLibraryEntries(export.libraryEntries);
      await _upsertLibraryEntryPlatforms(export.libraryEntryPlatforms);
      await _upsertGameGenres(export.gameGenres);
      await _upsertPlaythroughs(export.playthroughs);
      await _upsertSavedViews(export.savedViews);
      await _upsertExternalGameIds(export.externalGameIds);
      await _upsertMediaAssets(export.mediaAssets);

      await _softDeleteMissingGames(_ids(export.games), now);
      await _softDeleteMissingPlatforms(_ids(export.platforms), now);
      await _softDeleteMissingGenres(_ids(export.genres), now);
      await _softDeleteMissingLibraryEntries(_ids(export.libraryEntries), now);
      await _softDeleteMissingLibraryEntryPlatforms(
        _ids(export.libraryEntryPlatforms),
        now,
      );
      await _softDeleteMissingGameGenres(_ids(export.gameGenres), now);
      await _softDeleteMissingPlaythroughs(_ids(export.playthroughs), now);
      await _softDeleteMissingSavedViews(_ids(export.savedViews), now);
      await _softDeleteMissingExternalGameIds(
        _ids(export.externalGameIds),
        now,
      );
      await _softDeleteMissingMediaAssets(_ids(export.mediaAssets), now);
    });
  }

  Future<List<Map<String, Object?>>> _games(bool includeSoftDeleted) async {
    final query = _db.select(_db.games)
      ..orderBy([(table) => OrderingTerm.asc(table.id)]);
    if (!includeSoftDeleted) query.where((table) => table.deletedAt.isNull());
    final rows = await query.get();
    return rows
        .map(
          (row) => {
            'id': row.id,
            'title': row.title,
            'sortTitle': row.sortTitle,
            'releaseDate': _date(row.releaseDate),
            'type': row.type,
            'createdAt': _date(row.createdAt),
            'updatedAt': _date(row.updatedAt),
            'deletedAt': _date(row.deletedAt),
          },
        )
        .toList();
  }

  Future<List<Map<String, Object?>>> _libraryEntries(
    bool includeSoftDeleted,
  ) async {
    final query = _db.select(_db.libraryEntries)
      ..orderBy([(table) => OrderingTerm.asc(table.id)]);
    if (!includeSoftDeleted) query.where((table) => table.deletedAt.isNull());
    final rows = await query.get();
    return rows
        .map(
          (row) => {
            'id': row.id,
            'gameId': row.gameId,
            'status': row.status,
            'personalRating': row.personalRating,
            'personalNotes': row.personalNotes,
            'createdAt': _date(row.createdAt),
            'updatedAt': _date(row.updatedAt),
            'deletedAt': _date(row.deletedAt),
          },
        )
        .toList();
  }

  Future<List<Map<String, Object?>>> _platforms(bool includeSoftDeleted) async {
    final query = _db.select(_db.platforms)
      ..orderBy([(table) => OrderingTerm.asc(table.id)]);
    if (!includeSoftDeleted) query.where((table) => table.deletedAt.isNull());
    final rows = await query.get();
    return rows
        .map(
          (row) => {
            'id': row.id,
            'name': row.name,
            'shortName': row.shortName,
            'createdAt': _date(row.createdAt),
            'updatedAt': _date(row.updatedAt),
            'deletedAt': _date(row.deletedAt),
          },
        )
        .toList();
  }

  Future<List<Map<String, Object?>>> _libraryEntryPlatforms(
    bool includeSoftDeleted,
  ) async {
    final query = _db.select(_db.libraryEntryPlatforms)
      ..orderBy([(table) => OrderingTerm.asc(table.id)]);
    if (!includeSoftDeleted) query.where((table) => table.deletedAt.isNull());
    final rows = await query.get();
    return rows
        .map(
          (row) => {
            'id': row.id,
            'libraryEntryId': row.libraryEntryId,
            'platformId': row.platformId,
            'isPrimary': row.isPrimary,
            'createdAt': _date(row.createdAt),
            'updatedAt': _date(row.updatedAt),
            'deletedAt': _date(row.deletedAt),
          },
        )
        .toList();
  }

  Future<List<Map<String, Object?>>> _genres(bool includeSoftDeleted) async {
    final query = _db.select(_db.genres)
      ..orderBy([(table) => OrderingTerm.asc(table.id)]);
    if (!includeSoftDeleted) query.where((table) => table.deletedAt.isNull());
    final rows = await query.get();
    return rows
        .map(
          (row) => {
            'id': row.id,
            'name': row.name,
            'createdAt': _date(row.createdAt),
            'updatedAt': _date(row.updatedAt),
            'deletedAt': _date(row.deletedAt),
          },
        )
        .toList();
  }

  Future<List<Map<String, Object?>>> _gameGenres(
    bool includeSoftDeleted,
  ) async {
    final query = _db.select(_db.gameGenres)
      ..orderBy([(table) => OrderingTerm.asc(table.id)]);
    if (!includeSoftDeleted) query.where((table) => table.deletedAt.isNull());
    final rows = await query.get();
    return rows
        .map(
          (row) => {
            'id': row.id,
            'gameId': row.gameId,
            'genreId': row.genreId,
            'createdAt': _date(row.createdAt),
            'updatedAt': _date(row.updatedAt),
            'deletedAt': _date(row.deletedAt),
          },
        )
        .toList();
  }

  Future<List<Map<String, Object?>>> _playthroughs(
    bool includeSoftDeleted,
  ) async {
    final query = _db.select(_db.playthroughs)
      ..orderBy([(table) => OrderingTerm.asc(table.id)]);
    if (!includeSoftDeleted) query.where((table) => table.deletedAt.isNull());
    final rows = await query.get();
    return rows
        .map(
          (row) => {
            'id': row.id,
            'libraryEntryId': row.libraryEntryId,
            'platformId': row.platformId,
            'status': row.status,
            'startedAt': _date(row.startedAt),
            'completedAt': _date(row.completedAt),
            'hoursPlayed': row.hoursPlayed,
            'rating': row.rating,
            'notes': row.notes,
            'createdAt': _date(row.createdAt),
            'updatedAt': _date(row.updatedAt),
            'deletedAt': _date(row.deletedAt),
          },
        )
        .toList();
  }

  Future<List<Map<String, Object?>>> _savedViews(
    bool includeSoftDeleted,
  ) async {
    final query = _db.select(_db.savedViews)
      ..orderBy([(table) => OrderingTerm.asc(table.id)]);
    if (!includeSoftDeleted) query.where((table) => table.deletedAt.isNull());
    final rows = await query.get();
    return rows
        .map(
          (row) => {
            'id': row.id,
            'name': row.name,
            'filterJson': row.filterJson,
            'sortJson': row.sortJson,
            'columnConfigJson': row.columnConfigJson,
            'createdAt': _date(row.createdAt),
            'updatedAt': _date(row.updatedAt),
            'deletedAt': _date(row.deletedAt),
          },
        )
        .toList();
  }

  Future<List<Map<String, Object?>>> _externalGameIds(
    bool includeSoftDeleted,
  ) async {
    final query = _db.select(_db.externalGameIds)
      ..orderBy([(table) => OrderingTerm.asc(table.id)]);
    if (!includeSoftDeleted) query.where((table) => table.deletedAt.isNull());
    final rows = await query.get();
    return rows
        .map(
          (row) => {
            'id': row.id,
            'gameId': row.gameId,
            'provider': row.provider,
            'externalId': row.externalId,
            'externalSlug': row.externalSlug,
            'externalUrl': row.externalUrl,
            'matchedTitle': row.matchedTitle,
            'createdAt': _date(row.createdAt),
            'updatedAt': _date(row.updatedAt),
            'deletedAt': _date(row.deletedAt),
          },
        )
        .toList();
  }

  Future<List<Map<String, Object?>>> _mediaAssets(
    bool includeSoftDeleted,
  ) async {
    final query = _db.select(_db.mediaAssets)
      ..orderBy([(table) => OrderingTerm.asc(table.id)]);
    if (!includeSoftDeleted) query.where((table) => table.deletedAt.isNull());
    final rows = await query.get();
    return rows
        .map(
          (row) => {
            'id': row.id,
            'gameId': row.gameId,
            'kind': row.kind,
            'source': row.source,
            'provider': row.provider,
            'externalId': row.externalId,
            'remoteUrl': row.remoteUrl,
            'localPath': row.localPath,
            'fileName': row.fileName,
            'mimeType': row.mimeType,
            'width': row.width,
            'height': row.height,
            'hash': row.hash,
            'isSelected': row.isSelected,
            'attribution': row.attribution,
            'createdAt': _date(row.createdAt),
            'updatedAt': _date(row.updatedAt),
            'deletedAt': _date(row.deletedAt),
          },
        )
        .toList();
  }

  Future<void> _upsertGames(List<Map<String, Object?>> rows) async {
    for (final row in rows) {
      final id = _string(row, 'id');
      final companion = GamesCompanion(
        id: Value(id),
        title: Value(_string(row, 'title')),
        sortTitle: Value(_nullableString(row, 'sortTitle')),
        releaseDate: Value(_nullableDate(row, 'releaseDate')),
        type: Value(_string(row, 'type', fallback: 'game')),
        createdAt: Value(_requiredDate(row, 'createdAt')),
        updatedAt: Value(_requiredDate(row, 'updatedAt')),
        deletedAt: Value(_nullableDate(row, 'deletedAt')),
      );
      await _upsert(_db.games, id, companion);
    }
  }

  Future<void> _upsertLibraryEntries(List<Map<String, Object?>> rows) async {
    for (final row in rows) {
      final id = _string(row, 'id');
      final companion = LibraryEntriesCompanion(
        id: Value(id),
        gameId: Value(_string(row, 'gameId')),
        status: Value(_string(row, 'status')),
        personalRating: Value(_nullableInt(row, 'personalRating')),
        personalNotes: Value(_nullableString(row, 'personalNotes')),
        createdAt: Value(_requiredDate(row, 'createdAt')),
        updatedAt: Value(_requiredDate(row, 'updatedAt')),
        deletedAt: Value(_nullableDate(row, 'deletedAt')),
      );
      await _upsert(_db.libraryEntries, id, companion);
    }
  }

  Future<void> _upsertPlatforms(List<Map<String, Object?>> rows) async {
    for (final row in rows) {
      final id = _string(row, 'id');
      final companion = PlatformsCompanion(
        id: Value(id),
        name: Value(_string(row, 'name')),
        shortName: Value(_nullableString(row, 'shortName')),
        createdAt: Value(_requiredDate(row, 'createdAt')),
        updatedAt: Value(_requiredDate(row, 'updatedAt')),
        deletedAt: Value(_nullableDate(row, 'deletedAt')),
      );
      await _upsert(_db.platforms, id, companion);
    }
  }

  Future<void> _upsertLibraryEntryPlatforms(
    List<Map<String, Object?>> rows,
  ) async {
    for (final row in rows) {
      final id = _string(row, 'id');
      final companion = LibraryEntryPlatformsCompanion(
        id: Value(id),
        libraryEntryId: Value(_string(row, 'libraryEntryId')),
        platformId: Value(_string(row, 'platformId')),
        isPrimary: Value(row['isPrimary'] == true),
        createdAt: Value(_requiredDate(row, 'createdAt')),
        updatedAt: Value(_requiredDate(row, 'updatedAt')),
        deletedAt: Value(_nullableDate(row, 'deletedAt')),
      );
      await _upsert(_db.libraryEntryPlatforms, id, companion);
    }
  }

  Future<void> _upsertGenres(List<Map<String, Object?>> rows) async {
    for (final row in rows) {
      final id = _string(row, 'id');
      final companion = GenresCompanion(
        id: Value(id),
        name: Value(_string(row, 'name')),
        createdAt: Value(_requiredDate(row, 'createdAt')),
        updatedAt: Value(_requiredDate(row, 'updatedAt')),
        deletedAt: Value(_nullableDate(row, 'deletedAt')),
      );
      await _upsert(_db.genres, id, companion);
    }
  }

  Future<void> _upsertGameGenres(List<Map<String, Object?>> rows) async {
    for (final row in rows) {
      final id = _string(row, 'id');
      final companion = GameGenresCompanion(
        id: Value(id),
        gameId: Value(_string(row, 'gameId')),
        genreId: Value(_string(row, 'genreId')),
        createdAt: Value(_requiredDate(row, 'createdAt')),
        updatedAt: Value(_requiredDate(row, 'updatedAt')),
        deletedAt: Value(_nullableDate(row, 'deletedAt')),
      );
      await _upsert(_db.gameGenres, id, companion);
    }
  }

  Future<void> _upsertPlaythroughs(List<Map<String, Object?>> rows) async {
    for (final row in rows) {
      final id = _string(row, 'id');
      final companion = PlaythroughsCompanion(
        id: Value(id),
        libraryEntryId: Value(_string(row, 'libraryEntryId')),
        platformId: Value(_nullableString(row, 'platformId')),
        status: Value(_string(row, 'status')),
        startedAt: Value(_nullableDate(row, 'startedAt')),
        completedAt: Value(_nullableDate(row, 'completedAt')),
        hoursPlayed: Value(_nullableDouble(row, 'hoursPlayed')),
        rating: Value(_nullableInt(row, 'rating')),
        notes: Value(_nullableString(row, 'notes')),
        createdAt: Value(_requiredDate(row, 'createdAt')),
        updatedAt: Value(_requiredDate(row, 'updatedAt')),
        deletedAt: Value(_nullableDate(row, 'deletedAt')),
      );
      await _upsert(_db.playthroughs, id, companion);
    }
  }

  Future<void> _upsertSavedViews(List<Map<String, Object?>> rows) async {
    for (final row in rows) {
      final id = _string(row, 'id');
      final companion = SavedViewsCompanion(
        id: Value(id),
        name: Value(_string(row, 'name')),
        filterJson: Value(_string(row, 'filterJson')),
        sortJson: Value(_string(row, 'sortJson')),
        columnConfigJson: Value(_string(row, 'columnConfigJson')),
        createdAt: Value(_requiredDate(row, 'createdAt')),
        updatedAt: Value(_requiredDate(row, 'updatedAt')),
        deletedAt: Value(_nullableDate(row, 'deletedAt')),
      );
      await _upsert(_db.savedViews, id, companion);
    }
  }

  Future<void> _upsertExternalGameIds(List<Map<String, Object?>> rows) async {
    for (final row in rows) {
      final id = _string(row, 'id');
      final companion = ExternalGameIdsCompanion(
        id: Value(id),
        gameId: Value(_string(row, 'gameId')),
        provider: Value(_string(row, 'provider')),
        externalId: Value(_string(row, 'externalId')),
        externalSlug: Value(_nullableString(row, 'externalSlug')),
        externalUrl: Value(_nullableString(row, 'externalUrl')),
        matchedTitle: Value(_nullableString(row, 'matchedTitle')),
        createdAt: Value(_requiredDate(row, 'createdAt')),
        updatedAt: Value(_requiredDate(row, 'updatedAt')),
        deletedAt: Value(_nullableDate(row, 'deletedAt')),
      );
      await _upsert(_db.externalGameIds, id, companion);
    }
  }

  Future<void> _upsertMediaAssets(List<Map<String, Object?>> rows) async {
    for (final row in rows) {
      final id = _string(row, 'id');
      final companion = MediaAssetsCompanion(
        id: Value(id),
        gameId: Value(_string(row, 'gameId')),
        kind: Value(_string(row, 'kind')),
        source: Value(_string(row, 'source')),
        provider: Value(_nullableString(row, 'provider')),
        externalId: Value(_nullableString(row, 'externalId')),
        remoteUrl: Value(_nullableString(row, 'remoteUrl')),
        localPath: Value(_string(row, 'localPath')),
        fileName: Value(_string(row, 'fileName')),
        mimeType: Value(_nullableString(row, 'mimeType')),
        width: Value(_nullableInt(row, 'width')),
        height: Value(_nullableInt(row, 'height')),
        hash: Value(_nullableString(row, 'hash')),
        isSelected: Value(row['isSelected'] == true),
        attribution: Value(_nullableString(row, 'attribution')),
        createdAt: Value(_requiredDate(row, 'createdAt')),
        updatedAt: Value(_requiredDate(row, 'updatedAt')),
        deletedAt: Value(_nullableDate(row, 'deletedAt')),
      );
      await _upsert(_db.mediaAssets, id, companion);
    }
  }

  Future<void> _upsert<T extends Table, D extends DataClass>(
    TableInfo<T, D> table,
    String id,
    Insertable<D> companion,
  ) async {
    final exists =
        await (_db.select(table)..where(
          (row) => (row as dynamic).id.equals(id) as Expression<bool>,
        )).getSingleOrNull();
    if (exists == null) {
      await _db.into(table).insert(companion);
    } else {
      await (_db.update(table)..where(
        (row) => (row as dynamic).id.equals(id) as Expression<bool>,
      )).write(companion);
    }
  }

  Future<void> _softDeleteMissingGames(Set<String> ids, DateTime now) async {
    final update = _db.update(_db.games)
      ..where((table) => table.deletedAt.isNull());
    if (ids.isNotEmpty) update.where((table) => table.id.isNotIn(ids));
    await update.write(
      GamesCompanion(updatedAt: Value(now), deletedAt: Value(now)),
    );
  }

  Future<void> _softDeleteMissingLibraryEntries(
    Set<String> ids,
    DateTime now,
  ) async {
    final update = _db.update(_db.libraryEntries)
      ..where((table) => table.deletedAt.isNull());
    if (ids.isNotEmpty) update.where((table) => table.id.isNotIn(ids));
    await update.write(
      LibraryEntriesCompanion(updatedAt: Value(now), deletedAt: Value(now)),
    );
  }

  Future<void> _softDeleteMissingPlatforms(
    Set<String> ids,
    DateTime now,
  ) async {
    final update = _db.update(_db.platforms)
      ..where((table) => table.deletedAt.isNull());
    if (ids.isNotEmpty) update.where((table) => table.id.isNotIn(ids));
    await update.write(
      PlatformsCompanion(updatedAt: Value(now), deletedAt: Value(now)),
    );
  }

  Future<void> _softDeleteMissingLibraryEntryPlatforms(
    Set<String> ids,
    DateTime now,
  ) async {
    final update = _db.update(_db.libraryEntryPlatforms)
      ..where((table) => table.deletedAt.isNull());
    if (ids.isNotEmpty) update.where((table) => table.id.isNotIn(ids));
    await update.write(
      LibraryEntryPlatformsCompanion(
        updatedAt: Value(now),
        deletedAt: Value(now),
      ),
    );
  }

  Future<void> _softDeleteMissingGenres(Set<String> ids, DateTime now) async {
    final update = _db.update(_db.genres)
      ..where((table) => table.deletedAt.isNull());
    if (ids.isNotEmpty) update.where((table) => table.id.isNotIn(ids));
    await update.write(
      GenresCompanion(updatedAt: Value(now), deletedAt: Value(now)),
    );
  }

  Future<void> _softDeleteMissingGameGenres(
    Set<String> ids,
    DateTime now,
  ) async {
    final update = _db.update(_db.gameGenres)
      ..where((table) => table.deletedAt.isNull());
    if (ids.isNotEmpty) update.where((table) => table.id.isNotIn(ids));
    await update.write(
      GameGenresCompanion(updatedAt: Value(now), deletedAt: Value(now)),
    );
  }

  Future<void> _softDeleteMissingPlaythroughs(
    Set<String> ids,
    DateTime now,
  ) async {
    final update = _db.update(_db.playthroughs)
      ..where((table) => table.deletedAt.isNull());
    if (ids.isNotEmpty) update.where((table) => table.id.isNotIn(ids));
    await update.write(
      PlaythroughsCompanion(updatedAt: Value(now), deletedAt: Value(now)),
    );
  }

  Future<void> _softDeleteMissingSavedViews(
    Set<String> ids,
    DateTime now,
  ) async {
    final update = _db.update(_db.savedViews)
      ..where((table) => table.deletedAt.isNull());
    if (ids.isNotEmpty) update.where((table) => table.id.isNotIn(ids));
    await update.write(
      SavedViewsCompanion(updatedAt: Value(now), deletedAt: Value(now)),
    );
  }

  Future<void> _softDeleteMissingExternalGameIds(
    Set<String> ids,
    DateTime now,
  ) async {
    final update = _db.update(_db.externalGameIds)
      ..where((table) => table.deletedAt.isNull());
    if (ids.isNotEmpty) update.where((table) => table.id.isNotIn(ids));
    await update.write(
      ExternalGameIdsCompanion(updatedAt: Value(now), deletedAt: Value(now)),
    );
  }

  Future<void> _softDeleteMissingMediaAssets(
    Set<String> ids,
    DateTime now,
  ) async {
    final update = _db.update(_db.mediaAssets)
      ..where((table) => table.deletedAt.isNull());
    if (ids.isNotEmpty) update.where((table) => table.id.isNotIn(ids));
    await update.write(
      MediaAssetsCompanion(updatedAt: Value(now), deletedAt: Value(now)),
    );
  }
}

String _prettyJson(Map<String, Object?> json) {
  return const JsonEncoder.withIndent('  ').convert(json);
}

String? _date(DateTime? value) => value?.toIso8601String();

Set<String> _ids(List<Map<String, Object?>> rows) {
  return rows.map((row) => _string(row, 'id')).toSet();
}

String _string(Map<String, Object?> row, String key, {String? fallback}) {
  final value = row[key];
  if (value is String) return value;
  if (fallback != null) return fallback;
  throw FormatException('Missing string field: $key');
}

String? _nullableString(Map<String, Object?> row, String key) {
  final value = row[key];
  if (value == null) return null;
  if (value is String) return value;
  throw FormatException('Invalid string field: $key');
}

int? _nullableInt(Map<String, Object?> row, String key) {
  final value = row[key];
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  throw FormatException('Invalid integer field: $key');
}

double? _nullableDouble(Map<String, Object?> row, String key) {
  final value = row[key];
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  throw FormatException('Invalid double field: $key');
}

DateTime _requiredDate(Map<String, Object?> row, String key) {
  final value = _nullableDate(row, key);
  if (value == null) throw FormatException('Missing date field: $key');
  return value;
}

DateTime? _nullableDate(Map<String, Object?> row, String key) {
  final value = row[key];
  if (value == null) return null;
  if (value is String && value.isNotEmpty) return DateTime.parse(value);
  throw FormatException('Invalid date field: $key');
}
