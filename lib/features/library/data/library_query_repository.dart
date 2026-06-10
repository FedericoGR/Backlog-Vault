import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../domain/game_status.dart';
import '../domain/library_game_row.dart';

final libraryQueryRepositoryProvider = Provider<LibraryQueryRepository>((ref) {
  return LibraryQueryRepository(ref.watch(appDatabaseProvider));
});

final libraryRowsProvider = StreamProvider.autoDispose<List<LibraryGameRow>>((
  ref,
) {
  return ref.watch(libraryQueryRepositoryProvider).watchRows();
});

class LibraryQueryRepository {
  const LibraryQueryRepository(this._db);

  final AppDatabase _db;

  Stream<List<LibraryGameRow>> watchRows() {
    final query =
        _db.select(_db.libraryEntries).join([
            innerJoin(
              _db.games,
              _db.games.id.equalsExp(_db.libraryEntries.gameId),
            ),
          ])
          ..where(_db.libraryEntries.deletedAt.isNull())
          ..where(_db.games.deletedAt.isNull());

    return query.watch().asyncMap(_buildRows);
  }

  Future<List<LibraryGameRow>> _buildRows(List<TypedResult> joinedRows) async {
    if (joinedRows.isEmpty) return const [];

    final entries = <LibraryEntry>[];
    final gamesById = <String, Game>{};
    for (final joinedRow in joinedRows) {
      final entry = joinedRow.readTable(_db.libraryEntries);
      final game = joinedRow.readTable(_db.games);
      entries.add(entry);
      gamesById[game.id] = game;
    }

    final entryIds = entries.map((entry) => entry.id).toList();
    final gameIds = gamesById.keys.toList();

    final platformsByEntryId = await _loadPlatformsByEntryId(entryIds);
    final genresByGameId = await _loadGenresByGameId(gameIds);
    final playthroughsByEntryId = await _loadPlaythroughsByEntryId(entryIds);
    final selectedCoverByGameId = await _loadSelectedCoverByGameId(gameIds);
    final gamesWithExternalMetadata = await _loadGamesWithExternalMetadata(
      gameIds,
    );

    return [
      for (final entry in entries)
        if (gamesById[entry.gameId] case final game?)
          _toRow(
            entry: entry,
            game: game,
            platforms: platformsByEntryId[entry.id] ?? const [],
            genres: genresByGameId[game.id] ?? const [],
            playthroughs: playthroughsByEntryId[entry.id] ?? const [],
            selectedCover: selectedCoverByGameId[game.id],
            hasExternalMetadata: gamesWithExternalMetadata.contains(game.id),
          ),
    ];
  }

  Future<Map<String, List<LibraryCatalogItem>>> _loadPlatformsByEntryId(
    List<String> entryIds,
  ) async {
    if (entryIds.isEmpty) return const {};
    final links =
        await ((_db.select(_db.libraryEntryPlatforms)
              ..where((table) => table.libraryEntryId.isIn(entryIds))
              ..where((table) => table.deletedAt.isNull()))
            .get());
    if (links.isEmpty) return const {};

    final platformIds = links.map((link) => link.platformId).toSet().toList();
    final platforms =
        await ((_db.select(_db.platforms)
              ..where((table) => table.id.isIn(platformIds))
              ..where((table) => table.deletedAt.isNull()))
            .get());
    final platformsById = {
      for (final platform in platforms)
        platform.id: LibraryCatalogItem(id: platform.id, name: platform.name),
    };

    final result = <String, List<LibraryCatalogItem>>{};
    for (final link in links) {
      final platform = platformsById[link.platformId];
      if (platform == null) continue;
      result.putIfAbsent(link.libraryEntryId, () => []).add(platform);
    }
    for (final platforms in result.values) {
      platforms.sort((a, b) => a.name.compareTo(b.name));
    }
    return result;
  }

  Future<Map<String, List<LibraryCatalogItem>>> _loadGenresByGameId(
    List<String> gameIds,
  ) async {
    if (gameIds.isEmpty) return const {};
    final links =
        await ((_db.select(_db.gameGenres)
              ..where((table) => table.gameId.isIn(gameIds))
              ..where((table) => table.deletedAt.isNull()))
            .get());
    if (links.isEmpty) return const {};

    final genreIds = links.map((link) => link.genreId).toSet().toList();
    final genres =
        await ((_db.select(_db.genres)
              ..where((table) => table.id.isIn(genreIds))
              ..where((table) => table.deletedAt.isNull()))
            .get());
    final genresById = {
      for (final genre in genres)
        genre.id: LibraryCatalogItem(id: genre.id, name: genre.name),
    };

    final result = <String, List<LibraryCatalogItem>>{};
    for (final link in links) {
      final genre = genresById[link.genreId];
      if (genre == null) continue;
      result.putIfAbsent(link.gameId, () => []).add(genre);
    }
    for (final genres in result.values) {
      genres.sort((a, b) => a.name.compareTo(b.name));
    }
    return result;
  }

  Future<Map<String, List<Playthrough>>> _loadPlaythroughsByEntryId(
    List<String> entryIds,
  ) async {
    if (entryIds.isEmpty) return const {};
    final playthroughs =
        await ((_db.select(_db.playthroughs)
              ..where((table) => table.libraryEntryId.isIn(entryIds))
              ..where((table) => table.deletedAt.isNull()))
            .get());

    final result = <String, List<Playthrough>>{};
    for (final playthrough in playthroughs) {
      result.putIfAbsent(playthrough.libraryEntryId, () => []).add(playthrough);
    }
    return result;
  }

  Future<Map<String, MediaAsset>> _loadSelectedCoverByGameId(
    List<String> gameIds,
  ) async {
    if (gameIds.isEmpty) return const {};
    final assets =
        await ((_db.select(_db.mediaAssets)
              ..where((table) => table.gameId.isIn(gameIds))
              ..where((table) => table.kind.equals('cover'))
              ..where((table) => table.isSelected.equals(true))
              ..where((table) => table.deletedAt.isNull()))
            .get());
    return {for (final asset in assets) asset.gameId: asset};
  }

  Future<Set<String>> _loadGamesWithExternalMetadata(
    List<String> gameIds,
  ) async {
    if (gameIds.isEmpty) return const {};
    final externalIds =
        await ((_db.select(_db.externalGameIds)
              ..where((table) => table.gameId.isIn(gameIds))
              ..where((table) => table.deletedAt.isNull()))
            .get());
    return {for (final externalId in externalIds) externalId.gameId};
  }

  LibraryGameRow _toRow({
    required LibraryEntry entry,
    required Game game,
    required List<LibraryCatalogItem> platforms,
    required List<LibraryCatalogItem> genres,
    required List<Playthrough> playthroughs,
    required MediaAsset? selectedCover,
    required bool hasExternalMetadata,
  }) {
    DateTime? completedAt;
    var hoursPlayed = 0.0;
    var hasHours = false;

    for (final playthrough in playthroughs) {
      final candidateCompletedAt = playthrough.completedAt;
      if (candidateCompletedAt != null &&
          (completedAt == null || candidateCompletedAt.isAfter(completedAt))) {
        completedAt = candidateCompletedAt;
      }
      final hours = playthrough.hoursPlayed;
      if (hours != null) {
        hoursPlayed += hours;
        hasHours = true;
      }
    }

    return LibraryGameRow(
      gameId: game.id,
      libraryEntryId: entry.id,
      title: game.title,
      sortTitle: game.sortTitle,
      selectedCoverLocalPath: selectedCover?.localPath,
      hasExternalMetadata: hasExternalMetadata,
      status: parseGameStatus(entry.status),
      releaseDate: game.releaseDate,
      completedAt: completedAt,
      hoursPlayed: hasHours ? hoursPlayed : null,
      personalRating: entry.personalRating,
      personalNotes: entry.personalNotes,
      type: game.type,
      platforms: platforms,
      genres: genres,
      playthroughCount: playthroughs.length,
      updatedAt: entry.updatedAt,
    );
  }
}
