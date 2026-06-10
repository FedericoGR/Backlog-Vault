import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/ids/id_generator.dart';
import '../../../core/time/clock.dart';
import '../../library/domain/game_status.dart';
import '../../playthroughs/application/completion_form_model.dart';
import '../../playthroughs/application/playthrough_form_model.dart';
import '../../playthroughs/domain/playthrough_status.dart';
import '../application/game_form_model.dart';
import '../application/library_game_details.dart';

final gameRepositoryProvider = Provider<GameRepository>((ref) {
  return GameRepository(ref.watch(appDatabaseProvider));
});

final libraryGamesProvider =
    StreamProvider.autoDispose<List<LibraryGameDetails>>((ref) {
      return ref.watch(gameRepositoryProvider).watchLibrary();
    });

final libraryGameProvider = FutureProvider.autoDispose
    .family<LibraryGameDetails?, String>(
      (ref, entryId) => ref.watch(gameRepositoryProvider).getByEntryId(entryId),
    );

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
              status: model.status.name,
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

      final currentStatus = parseGameStatus(entry.status);
      if (!canTransitionGameStatus(currentStatus, model.status)) {
        throw AppException(
          'No se puede pasar de ${currentStatus.label} a ${model.status.label}.',
        );
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
          status: Value(model.status.name),
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

  Future<void> registerPlaythrough(PlaythroughFormModel model) {
    return savePlaythrough(model);
  }

  Future<void> savePlaythrough(PlaythroughFormModel model) {
    model.validate();
    if (model.playthroughId == null) {
      return _createPlaythrough(model);
    }
    return _updatePlaythrough(model);
  }

  Future<void> _createPlaythrough(PlaythroughFormModel model) {
    return _db.transaction(() async {
      final now = _clock.now();
      await _requireEntry(model.libraryEntryId);
      await _db
          .into(_db.playthroughs)
          .insert(
            PlaythroughsCompanion.insert(
              id: _ids.newId(),
              libraryEntryId: model.libraryEntryId,
              platformId: Value(model.platformId),
              status: model.status.name,
              startedAt: Value(model.startedAt),
              completedAt: Value(model.completedAt),
              hoursPlayed: Value(model.hoursPlayed),
              rating: Value(model.rating),
              notes: Value(_blankToNull(model.notes)),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _touchEntry(model.libraryEntryId, now);
    });
  }

  Future<void> _updatePlaythrough(PlaythroughFormModel model) {
    return _db.transaction(() async {
      final now = _clock.now();
      await _requireEntry(model.libraryEntryId);
      final existing =
          await ((_db.select(_db.playthroughs)
                ..where((table) => table.id.equals(model.playthroughId!))
                ..where(
                  (table) => table.libraryEntryId.equals(model.libraryEntryId),
                )
                ..where((table) => table.deletedAt.isNull()))
              .getSingleOrNull());
      if (existing == null) {
        throw const AppException('No se encontró la partida.');
      }

      await (_db.update(_db.playthroughs)
        ..where((table) => table.id.equals(existing.id))).write(
        PlaythroughsCompanion(
          platformId: Value(model.platformId),
          status: Value(model.status.name),
          startedAt: Value(model.startedAt),
          completedAt: Value(model.completedAt),
          hoursPlayed: Value(model.hoursPlayed),
          rating: Value(model.rating),
          notes: Value(_blankToNull(model.notes)),
          updatedAt: Value(now),
        ),
      );
      await _touchEntry(model.libraryEntryId, now);
    });
  }

  Future<void> softDeletePlaythrough(String playthroughId) {
    return _db.transaction(() async {
      final now = _clock.now();
      final playthrough =
          await ((_db.select(_db.playthroughs)
                ..where((table) => table.id.equals(playthroughId))
                ..where((table) => table.deletedAt.isNull()))
              .getSingleOrNull());
      if (playthrough == null) return;

      await (_db.update(_db.playthroughs)
        ..where((table) => table.id.equals(playthroughId))).write(
        PlaythroughsCompanion(updatedAt: Value(now), deletedAt: Value(now)),
      );
      await _touchEntry(playthrough.libraryEntryId, now);
    });
  }

  Future<void> markPlaying(String entryId) {
    return _db.transaction(() async {
      final now = _clock.now();
      await _updateEntryStatus(entryId, GameStatus.playing, now);
      final active = await _activeOrPausedPlaythrough(entryId);
      if (active == null) {
        await _db
            .into(_db.playthroughs)
            .insert(
              PlaythroughsCompanion.insert(
                id: _ids.newId(),
                libraryEntryId: entryId,
                platformId: Value(await _defaultPlatformId(entryId)),
                status: PlaythroughStatus.active.name,
                startedAt: Value(now),
                createdAt: now,
                updatedAt: now,
              ),
            );
        return;
      }
      if (parsePlaythroughStatus(active.status) == PlaythroughStatus.paused) {
        await (_db.update(_db.playthroughs)
          ..where((table) => table.id.equals(active.id))).write(
          PlaythroughsCompanion(
            status: Value(PlaythroughStatus.active.name),
            updatedAt: Value(now),
          ),
        );
      }
    });
  }

  Future<void> markPaused(String entryId) {
    return _db.transaction(() async {
      final now = _clock.now();
      await _updateEntryStatus(entryId, GameStatus.paused, now);
      final active = await _activeOrPausedPlaythrough(entryId);
      if (active == null) {
        await _db
            .into(_db.playthroughs)
            .insert(
              PlaythroughsCompanion.insert(
                id: _ids.newId(),
                libraryEntryId: entryId,
                platformId: Value(await _defaultPlatformId(entryId)),
                status: PlaythroughStatus.paused.name,
                startedAt: Value(now),
                createdAt: now,
                updatedAt: now,
              ),
            );
        return;
      }
      if (parsePlaythroughStatus(active.status) == PlaythroughStatus.active) {
        await (_db.update(_db.playthroughs)
          ..where((table) => table.id.equals(active.id))).write(
          PlaythroughsCompanion(
            status: Value(PlaythroughStatus.paused.name),
            updatedAt: Value(now),
          ),
        );
      }
    });
  }

  Future<void> markDropped(String entryId) {
    return _db.transaction(() async {
      final now = _clock.now();
      await _updateEntryStatus(entryId, GameStatus.dropped, now);
      final active = await _activeOrPausedPlaythrough(entryId);
      if (active == null) return;
      await (_db.update(_db.playthroughs)
        ..where((table) => table.id.equals(active.id))).write(
        PlaythroughsCompanion(
          status: Value(PlaythroughStatus.dropped.name),
          updatedAt: Value(now),
        ),
      );
    });
  }

  Future<void> markBacklog(String entryId) {
    return _db.transaction(() async {
      final now = _clock.now();
      await _updateEntryStatus(entryId, GameStatus.backlog, now);
    });
  }

  Future<void> completeGame(CompletionFormModel model) {
    model.validate();
    return _db.transaction(() async {
      final now = _clock.now();
      final entry =
          await ((_db.select(_db.libraryEntries)
                ..where((table) => table.id.equals(model.libraryEntryId))
                ..where((table) => table.deletedAt.isNull()))
              .getSingleOrNull());
      if (entry == null) {
        throw const AppException('No se encontró el juego en la biblioteca.');
      }

      final currentStatus = parseGameStatus(entry.status);
      if (!canTransitionGameStatus(currentStatus, GameStatus.completed)) {
        throw AppException(
          'No se puede pasar de ${currentStatus.label} a Completado.',
        );
      }

      final activePlaythrough =
          await ((_db.select(_db.playthroughs)
                ..where(
                  (table) => table.libraryEntryId.equals(model.libraryEntryId),
                )
                ..where((table) => table.deletedAt.isNull())
                ..where(
                  (table) =>
                      table.status.equals(PlaythroughStatus.active.name) |
                      table.status.equals(PlaythroughStatus.paused.name),
                )
                ..limit(1))
              .getSingleOrNull());

      if (activePlaythrough == null) {
        await _db
            .into(_db.playthroughs)
            .insert(
              PlaythroughsCompanion.insert(
                id: _ids.newId(),
                libraryEntryId: model.libraryEntryId,
                platformId: Value(model.platformId),
                status: PlaythroughStatus.completed.name,
                completedAt: Value(model.completedAt),
                hoursPlayed: Value(model.hoursPlayed),
                rating: Value(model.rating),
                notes: Value(_blankToNull(model.notes)),
                createdAt: now,
                updatedAt: now,
              ),
            );
      } else {
        await (_db.update(_db.playthroughs)
          ..where((table) => table.id.equals(activePlaythrough.id))).write(
          PlaythroughsCompanion(
            platformId: Value(model.platformId ?? activePlaythrough.platformId),
            status: Value(PlaythroughStatus.completed.name),
            completedAt: Value(model.completedAt),
            hoursPlayed: Value(model.hoursPlayed),
            rating: Value(model.rating),
            notes: Value(_blankToNull(model.notes) ?? activePlaythrough.notes),
            updatedAt: Value(now),
          ),
        );
      }

      await (_db.update(_db.libraryEntries)
        ..where((table) => table.id.equals(model.libraryEntryId))).write(
        LibraryEntriesCompanion(
          status: Value(GameStatus.completed.name),
          personalRating:
              model.rating == null
                  ? const Value<int?>.absent()
                  : Value(model.rating),
          updatedAt: Value(now),
        ),
      );
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
      final playthroughs =
          await ((_db.select(_db.playthroughs)
                ..where((table) => table.libraryEntryId.equals(entry.id))
                ..where((table) => table.deletedAt.isNull())
                ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)]))
              .get());

      details.add(
        LibraryGameDetails(
          game: game,
          entry: entry,
          platforms: platforms,
          genres: genres,
          playthroughs: playthroughs,
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

  Future<void> _touchEntry(String entryId, DateTime now) async {
    await (_db.update(_db.libraryEntries)..where(
      (table) => table.id.equals(entryId),
    )).write(LibraryEntriesCompanion(updatedAt: Value(now)));
  }

  Future<LibraryEntry> _requireEntry(String entryId) async {
    final entry =
        await ((_db.select(_db.libraryEntries)
              ..where((table) => table.id.equals(entryId))
              ..where((table) => table.deletedAt.isNull()))
            .getSingleOrNull());
    if (entry == null) {
      throw const AppException('No se encontró el juego en la biblioteca.');
    }
    return entry;
  }

  Future<void> _updateEntryStatus(
    String entryId,
    GameStatus targetStatus,
    DateTime now,
  ) async {
    final entry = await _requireEntry(entryId);
    final currentStatus = parseGameStatus(entry.status);
    if (!canTransitionGameStatus(currentStatus, targetStatus)) {
      throw AppException(
        'No se puede pasar de ${currentStatus.label} a ${targetStatus.label}.',
      );
    }
    await (_db.update(_db.libraryEntries)
      ..where((table) => table.id.equals(entryId))).write(
      LibraryEntriesCompanion(
        status: Value(targetStatus.name),
        updatedAt: Value(now),
      ),
    );
  }

  Future<Playthrough?> _activeOrPausedPlaythrough(String entryId) {
    return ((_db.select(_db.playthroughs)
          ..where((table) => table.libraryEntryId.equals(entryId))
          ..where((table) => table.deletedAt.isNull())
          ..where(
            (table) =>
                table.status.equals(PlaythroughStatus.active.name) |
                table.status.equals(PlaythroughStatus.paused.name),
          )
          ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)])
          ..limit(1))
        .getSingleOrNull());
  }

  Future<String?> _defaultPlatformId(String entryId) async {
    final primary =
        await ((_db.select(_db.libraryEntryPlatforms)
              ..where((table) => table.libraryEntryId.equals(entryId))
              ..where((table) => table.deletedAt.isNull())
              ..where((table) => table.isPrimary.equals(true))
              ..limit(1))
            .getSingleOrNull());
    if (primary != null) return primary.platformId;

    final first =
        await ((_db.select(_db.libraryEntryPlatforms)
              ..where((table) => table.libraryEntryId.equals(entryId))
              ..where((table) => table.deletedAt.isNull())
              ..limit(1))
            .getSingleOrNull());
    return first?.platformId;
  }
}

String? _blankToNull(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}
