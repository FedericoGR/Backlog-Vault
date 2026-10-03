import '../../catalogs/domain/catalog_item.dart';

class LibraryGameDetails {
  const LibraryGameDetails({
    required this.game,
    required this.entry,
    required this.platforms,
    required this.genres,
    this.playedPlatform,
    this.selectedCover,
  });

  final GameDetails game;
  final LibraryEntryDetails entry;
  final List<CatalogItem> platforms;
  final List<CatalogItem> genres;

  /// Personal platform, distinct from the catalog platforms above.
  final CatalogItem? playedPlatform;
  final GameCoverDetails? selectedCover;
}

/// Read model for work-level game data used by presentation flows.
class GameDetails {
  const GameDetails({
    required this.id,
    required this.title,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.sortTitle,
    this.releaseDate,
    this.deletedAt,
  });

  final String id;
  final String title;
  final String? sortTitle;
  final DateTime? releaseDate;
  final String type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
}

/// Read model for the user's relationship with a game.
class LibraryEntryDetails {
  const LibraryEntryDetails({
    required this.id,
    required this.gameId,
    required this.createdAt,
    required this.updatedAt,
    this.isCompleted = false,
    this.completedAt,
    this.hoursPlayed,
    this.playedPlatformId,
    this.personalRating,
    this.personalNotes,
    this.deletedAt,
  });

  final String id;
  final String gameId;
  final bool isCompleted;
  final DateTime? completedAt;
  final double? hoursPlayed;
  final String? playedPlatformId;
  final int? personalRating;
  final String? personalNotes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
}

class GameCoverDetails {
  const GameCoverDetails({
    required this.id,
    required this.localPath,
    this.provider,
    this.source,
  });

  final String id;
  final String localPath;
  final String? provider;
  final String? source;
}
