import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_providers.dart';
import '../../../../core/ids/id_generator.dart';
import '../../../../core/time/clock.dart';
import '../../../playthroughs/domain/playthrough_status.dart';
import '../application/build_import_preview_use_case.dart';
import '../application/duplicate_detector.dart';
import '../domain/existing_game_summary.dart';
import '../domain/import_preview.dart';
import '../domain/import_result.dart';
import '../domain/normalized_import_row.dart';

final notionCsvImportRepositoryProvider = Provider<NotionCsvImportRepository>((
  ref,
) {
  return NotionCsvImportRepository(ref.watch(appDatabaseProvider));
});

class NotionCsvImportRepository {
  NotionCsvImportRepository(
    this._db, {
    IdGenerator? ids,
    Clock clock = systemClock,
  }) : _ids = ids ?? defaultIdGenerator,
       _clock = clock;

  final AppDatabase _db;
  final IdGenerator _ids;
  final Clock _clock;

  Future<List<ExistingGameSummary>> loadExistingGames() async {
    final entries =
        await ((_db.select(_db.libraryEntries)
          ..where((table) => table.deletedAt.isNull())).get());
    final result = <ExistingGameSummary>[];

    for (final entry in entries) {
      final game =
          await ((_db.select(_db.games)
                ..where((table) => table.id.equals(entry.gameId))
                ..where((table) => table.deletedAt.isNull()))
              .getSingleOrNull());
      if (game == null) continue;

      final platformLinks =
          await ((_db.select(_db.libraryEntryPlatforms)
                ..where((table) => table.libraryEntryId.equals(entry.id))
                ..where((table) => table.deletedAt.isNull()))
              .get());
      final platformNames = <String>[];
      for (final link in platformLinks) {
        final platform =
            await ((_db.select(_db.platforms)
                  ..where((table) => table.id.equals(link.platformId))
                  ..where((table) => table.deletedAt.isNull()))
                .getSingleOrNull());
        if (platform != null) {
          platformNames.add(platform.name);
        }
      }

      result.add(
        ExistingGameSummary(
          title: game.title,
          releaseYear: game.releaseDate?.year,
          platforms: platformNames,
        ),
      );
    }

    return result;
  }

  Future<ImportResult> importPreview(ImportPreview preview) {
    return _db.transaction(() async {
      final now = _clock.now();
      var importedGames = 0;
      var platformsCreated = 0;
      var genresCreated = 0;
      var playthroughsCreated = 0;

      for (final row in preview.rows.where((row) => row.canImport)) {
        final gameId = _ids.newId();
        final entryId = _ids.newId();

        await _db
            .into(_db.games)
            .insert(
              GamesCompanion.insert(
                id: gameId,
                title: row.title.trim(),
                sortTitle: Value(_sortTitle(row.title)),
                releaseDate: Value(row.releaseDate),
                type: Value(row.type),
                createdAt: now,
                updatedAt: now,
              ),
            );

        await _db
            .into(_db.libraryEntries)
            .insert(
              LibraryEntriesCompanion.insert(
                id: entryId,
                gameId: gameId,
                status: row.status.name,
                personalRating: Value(row.personalRating),
                personalNotes: Value(_blankToNull(row.personalNotes)),
                createdAt: now,
                updatedAt: now,
              ),
            );

        final platformIds = <String>[];
        for (final platformName in row.platforms) {
          final resolved = await _getOrCreatePlatform(platformName, now);
          if (resolved.created) {
            platformsCreated++;
          }
          platformIds.add(resolved.id);
        }
        for (var index = 0; index < platformIds.length; index++) {
          await _db
              .into(_db.libraryEntryPlatforms)
              .insert(
                LibraryEntryPlatformsCompanion.insert(
                  id: _ids.newId(),
                  libraryEntryId: entryId,
                  platformId: platformIds[index],
                  isPrimary: Value(index == 0),
                  createdAt: now,
                  updatedAt: now,
                ),
              );
        }

        for (final genreName in row.genres) {
          final resolved = await _getOrCreateGenre(genreName, now);
          if (resolved.created) {
            genresCreated++;
          }
          await _db
              .into(_db.gameGenres)
              .insert(
                GameGenresCompanion.insert(
                  id: _ids.newId(),
                  gameId: gameId,
                  genreId: resolved.id,
                  createdAt: now,
                  updatedAt: now,
                ),
              );
        }

        if (shouldCreatePlaythroughForImport(row)) {
          await _db
              .into(_db.playthroughs)
              .insert(
                PlaythroughsCompanion.insert(
                  id: _ids.newId(),
                  libraryEntryId: entryId,
                  platformId: Value(
                    platformIds.isEmpty ? null : platformIds.first,
                  ),
                  status: playthroughStatusForImport(row).name,
                  startedAt: Value(_startedAtFor(row)),
                  completedAt: Value(row.completedAt),
                  hoursPlayed: Value(row.hoursPlayed),
                  rating: Value(row.personalRating),
                  notes: Value(_blankToNull(row.personalNotes)),
                  createdAt: now,
                  updatedAt: now,
                ),
              );
          playthroughsCreated++;
        }

        importedGames++;
      }

      final skippedRows = preview.rows.length - importedGames;
      final duplicatesSkipped =
          preview.rows
              .where((row) => row.hasDuplicates && !row.forceCreateDuplicate)
              .length;
      return ImportResult(
        importedGames: importedGames,
        skippedRows: skippedRows,
        duplicatesSkipped: duplicatesSkipped,
        platformsCreated: platformsCreated,
        genresCreated: genresCreated,
        playthroughsCreated: playthroughsCreated,
      );
    });
  }

  Future<_ResolvedCatalog> _getOrCreatePlatform(
    String name,
    DateTime now,
  ) async {
    final normalized = normalizeTitle(name);
    final existing = _firstOrNull(
      (await ((_db.select(_db.platforms)
            ..where((table) => table.deletedAt.isNull())).get()))
          .where((platform) => normalizeTitle(platform.name) == normalized),
    );
    if (existing != null) {
      return _ResolvedCatalog(id: existing.id, created: false);
    }

    final id = _ids.newId();
    await _db
        .into(_db.platforms)
        .insert(
          PlatformsCompanion.insert(
            id: id,
            name: name.trim(),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return _ResolvedCatalog(id: id, created: true);
  }

  Future<_ResolvedCatalog> _getOrCreateGenre(String name, DateTime now) async {
    final normalized = normalizeTitle(name);
    final existing = _firstOrNull(
      (await ((_db.select(_db.genres)
            ..where((table) => table.deletedAt.isNull())).get()))
          .where((genre) => normalizeTitle(genre.name) == normalized),
    );
    if (existing != null) {
      return _ResolvedCatalog(id: existing.id, created: false);
    }

    final id = _ids.newId();
    await _db
        .into(_db.genres)
        .insert(
          GenresCompanion.insert(
            id: id,
            name: name.trim(),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return _ResolvedCatalog(id: id, created: true);
  }
}

class _ResolvedCatalog {
  const _ResolvedCatalog({required this.id, required this.created});

  final String id;
  final bool created;
}

String? _blankToNull(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}

String? _sortTitle(String title) {
  final trimmed = title.trim();
  return trimmed.isEmpty ? null : trimmed.toLowerCase();
}

DateTime? _startedAtFor(NormalizedImportRow row) {
  final status = playthroughStatusForImport(row);
  if (status == PlaythroughStatus.active ||
      status == PlaythroughStatus.paused) {
    return null;
  }
  return null;
}

T? _firstOrNull<T>(Iterable<T> values) {
  final iterator = values.iterator;
  if (!iterator.moveNext()) return null;
  return iterator.current;
}
