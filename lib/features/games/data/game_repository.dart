import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/ids/id_generator.dart';
import '../../../core/time/clock.dart';
import '../../catalogs/domain/catalog_item.dart';
import '../application/game_form_model.dart';
import '../application/library_game_details.dart';

final gameRepositoryProvider = Provider<GameRepository>((ref) {
  return GameRepository(ref.watch(appDatabaseProvider));
});

class GameRepository {
  GameRepository(this._db, {IdGenerator? ids, Clock clock = systemClock})
    : _ids = ids ?? defaultIdGenerator,
      _clock = clock;

  final AppDatabase _db;
  final IdGenerator _ids;
  final Clock _clock;

  Stream<List<LibraryGameDetails>> watchLibrary() {
    final query =
        _db.select(_db.libraryEntries)
          ..where((table) => table.deletedAt.isNull())
          ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)]);

    return query.watch().asyncMap(_loadDetailsForEntries);
  }

  Future<LibraryGameDetails?> getByEntryId(String entryId) async {
    final entry =
        await ((_db.select(_db.libraryEntries)
              ..where((table) => table.id.equals(entryId))
              ..where((table) => table.deletedAt.isNull()))
            .getSingleOrNull());
    if (entry == null) return null;
    final details = await _loadDetailsForEntries([entry]);
    return details.isEmpty ? null : details.single;
  }

  Future<String> save(GameFormModel model) async {
    model.validate();
    if (model.entryId == null || model.gameId == null) {
      return _create(model);
    }
    return _update(model);
  }

  Future<String> _create(GameFormModel model) {
    return _db.transaction(() async {
      final now = _clock.now();
      final gameId = _ids.newId();
      final entryId = _ids.newId();

      await _db
          .into(_db.games)
          .insert(
            GamesCompanion.insert(
              id: gameId,
              title: model.title.trim(),
              sortTitle: Value(_blankToNull(model.sortTitle)),
              releaseDate: Value(model.releaseDate),
              type: Value(model.type),
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
              status: model.isCompleted ? 'completed' : 'backlog',
              isCompleted: Value(model.isCompleted),
              completedAt: Value(model.completedAt),
              playedYear: Value(model.playedYear),
              hoursPlayed: Value(model.hoursPlayed),
              playedPlatformId: Value(model.playedPlatformId),
              personalRating: Value(model.personalRating),
              personalNotes: Value(_blankToNull(model.personalNotes)),
              createdAt: now,
              updatedAt: now,
            ),
          );

      await _replacePlatforms(entryId, model.platformIds, now);
      await _replaceGenres(gameId, model.genreIds, now);
      return entryId;
    });
  }

  Future<String> _update(GameFormModel model) {
    return _db.transaction(() async {
      final now = _clock.now();
      final entry =
          await ((_db.select(_db.libraryEntries)
                ..where((table) => table.id.equals(model.entryId!))
                ..where((table) => table.deletedAt.isNull()))
              .getSingleOrNull());
      if (entry == null) {
        throw const AppException('No se encontró el juego en la biblioteca.');
      }

      await (_db.update(_db.games)
        ..where((table) => table.id.equals(model.gameId!))).write(
        GamesCompanion(
          title: Value(model.title.trim()),
          sortTitle: Value(_blankToNull(model.sortTitle)),
          releaseDate: Value(model.releaseDate),
          type: Value(model.type),
          updatedAt: Value(now),
        ),
      );

      await (_db.update(_db.libraryEntries)
        ..where((table) => table.id.equals(model.entryId!))).write(
        LibraryEntriesCompanion(
          isCompleted: Value(model.isCompleted),
          completedAt: Value(model.completedAt),
          playedYear: Value(model.playedYear),
          hoursPlayed: Value(model.hoursPlayed),
          playedPlatformId: Value(model.playedPlatformId),
          personalRating: Value(model.personalRating),
          personalNotes: Value(_blankToNull(model.personalNotes)),
          updatedAt: Value(now),
        ),
      );

      await _replacePlatforms(model.entryId!, model.platformIds, now);
      await _replaceGenres(model.gameId!, model.genreIds, now);
      return model.entryId!;
    });
  }

  Future<void> softDelete(String entryId) {
    return _db.transaction(() async {
      final now = _clock.now();
      final entry =
          await ((_db.select(_db.libraryEntries)
                ..where((table) => table.id.equals(entryId))
                ..where((table) => table.deletedAt.isNull()))
              .getSingleOrNull());
      if (entry == null) return;

      await (_db.update(_db.libraryEntries)
        ..where((table) => table.id.equals(entryId))).write(
        LibraryEntriesCompanion(updatedAt: Value(now), deletedAt: Value(now)),
      );
      await (_db.update(_db.games)..where(
        (table) => table.id.equals(entry.gameId),
      )).write(GamesCompanion(updatedAt: Value(now), deletedAt: Value(now)));
    });
  }

  Future<void> softDeleteMany(Iterable<String> entryIds) {
    final ids = entryIds.toSet();
    if (ids.isEmpty) return Future.value();
    return _db.transaction(() async {
      final now = _clock.now();
      for (final entryId in ids) {
        final entry =
            await ((_db.select(_db.libraryEntries)
                  ..where((table) => table.id.equals(entryId))
                  ..where((table) => table.deletedAt.isNull()))
                .getSingleOrNull());
        if (entry == null) continue;

        await (_db.update(_db.libraryEntries)
          ..where((table) => table.id.equals(entryId))).write(
          LibraryEntriesCompanion(updatedAt: Value(now), deletedAt: Value(now)),
        );
        await (_db.update(_db.games)..where(
          (table) => table.id.equals(entry.gameId),
        )).write(GamesCompanion(updatedAt: Value(now), deletedAt: Value(now)));
      }
    });
  }

  Future<List<LibraryGameDetails>> _loadDetailsForEntries(
    List<LibraryEntry> entries,
  ) async {
    final details = <LibraryGameDetails>[];
    for (final entry in entries) {
      final game =
          await ((_db.select(_db.games)
                ..where((table) => table.id.equals(entry.gameId))
                ..where((table) => table.deletedAt.isNull()))
              .getSingleOrNull());
      if (game == null) continue;

      final platforms = await _platformsForEntry(entry.id);
      final genres = await _genresForGame(game.id);
      final playedPlatform =
          entry.playedPlatformId == null
              ? null
              : await (_db.select(_db.platforms)..where(
                (p) => p.id.equals(entry.playedPlatformId!),
              )).getSingleOrNull();
      final selectedCover =
          await ((_db.select(_db.mediaAssets)
                ..where((table) => table.gameId.equals(game.id))
                ..where((table) => table.kind.equals('cover'))
                ..where((table) => table.isSelected.equals(true))
                ..where((table) => table.deletedAt.isNull())
                ..limit(1))
              .getSingleOrNull());

      details.add(
        LibraryGameDetails(
          game: GameDetails(
            id: game.id,
            title: game.title,
            sortTitle: game.sortTitle,
            releaseDate: game.releaseDate,
            type: game.type,
            createdAt: game.createdAt,
            updatedAt: game.updatedAt,
          ),
          entry: LibraryEntryDetails(
            id: entry.id,
            gameId: entry.gameId,
            isCompleted: entry.isCompleted,
            completedAt: entry.completedAt,
            playedYear: entry.playedYear,
            hoursPlayed: entry.hoursPlayed,
            playedPlatformId: entry.playedPlatformId,
            personalRating: entry.personalRating,
            personalNotes: entry.personalNotes,
            createdAt: entry.createdAt,
            updatedAt: entry.updatedAt,
          ),
          platforms: [
            for (final platform in platforms)
              CatalogItem(
                id: platform.id,
                name: platform.name,
                shortName: platform.shortName,
              ),
          ],
          genres: [
            for (final genre in genres)
              CatalogItem(id: genre.id, name: genre.name),
          ],
          playedPlatform:
              playedPlatform == null
                  ? null
                  : CatalogItem(
                    id: playedPlatform.id,
                    name: playedPlatform.name,
                    deletedAt: playedPlatform.deletedAt,
                  ),
          selectedCover:
              selectedCover == null
                  ? null
                  : GameCoverDetails(
                    id: selectedCover.id,
                    localPath: selectedCover.localPath,
                    provider: selectedCover.provider,
                    source: selectedCover.source,
                  ),
        ),
      );
    }
    return details;
  }

  Future<List<Platform>> _platformsForEntry(String entryId) async {
    final links =
        await ((_db.select(_db.libraryEntryPlatforms)
              ..where((table) => table.libraryEntryId.equals(entryId))
              ..where((table) => table.deletedAt.isNull()))
            .get());
    final platforms = <Platform>[];
    for (final link in links) {
      final platform =
          await ((_db.select(_db.platforms)
                ..where((table) => table.id.equals(link.platformId))
                ..where((table) => table.deletedAt.isNull()))
              .getSingleOrNull());
      if (platform != null) platforms.add(platform);
    }
    platforms.sort((a, b) => a.name.compareTo(b.name));
    return platforms;
  }

  Future<List<Genre>> _genresForGame(String gameId) async {
    final links =
        await ((_db.select(_db.gameGenres)
              ..where((table) => table.gameId.equals(gameId))
              ..where((table) => table.deletedAt.isNull()))
            .get());
    final genres = <Genre>[];
    for (final link in links) {
      final genre =
          await ((_db.select(_db.genres)
                ..where((table) => table.id.equals(link.genreId))
                ..where((table) => table.deletedAt.isNull()))
              .getSingleOrNull());
      if (genre != null) genres.add(genre);
    }
    genres.sort((a, b) => a.name.compareTo(b.name));
    return genres;
  }

  Future<void> _replacePlatforms(
    String entryId,
    List<String> platformIds,
    DateTime now,
  ) async {
    final uniqueIds = platformIds.toSet().toList();
    await (_db.update(_db.libraryEntryPlatforms)
          ..where((table) => table.libraryEntryId.equals(entryId))
          ..where((table) => table.deletedAt.isNull()))
        .write(
          LibraryEntryPlatformsCompanion(
            updatedAt: Value(now),
            deletedAt: Value(now),
          ),
        );

    for (var index = 0; index < uniqueIds.length; index++) {
      await _db
          .into(_db.libraryEntryPlatforms)
          .insert(
            LibraryEntryPlatformsCompanion.insert(
              id: _ids.newId(),
              libraryEntryId: entryId,
              platformId: uniqueIds[index],
              isPrimary: Value(index == 0),
              createdAt: now,
              updatedAt: now,
            ),
          );
    }
  }

  Future<void> _replaceGenres(
    String gameId,
    List<String> genreIds,
    DateTime now,
  ) async {
    final uniqueIds = genreIds.toSet().toList();
    await (_db.update(_db.gameGenres)
          ..where((table) => table.gameId.equals(gameId))
          ..where((table) => table.deletedAt.isNull()))
        .write(
          GameGenresCompanion(updatedAt: Value(now), deletedAt: Value(now)),
        );

    for (final genreId in uniqueIds) {
      await _db
          .into(_db.gameGenres)
          .insert(
            GameGenresCompanion.insert(
              id: _ids.newId(),
              gameId: gameId,
              genreId: genreId,
              createdAt: now,
              updatedAt: now,
            ),
          );
    }
  }
}

String? _blankToNull(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}
