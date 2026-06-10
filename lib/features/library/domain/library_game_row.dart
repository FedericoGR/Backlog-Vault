import 'game_status.dart';

class LibraryCatalogItem {
  const LibraryCatalogItem({required this.id, required this.name});

  final String id;
  final String name;
}

class LibraryGameRow {
  const LibraryGameRow({
    required this.gameId,
    required this.libraryEntryId,
    required this.title,
    required this.status,
    required this.type,
    required this.platforms,
    required this.genres,
    required this.playthroughCount,
    required this.updatedAt,
    this.sortTitle,
    this.releaseDate,
    this.completedAt,
    this.hoursPlayed,
    this.personalRating,
    this.personalNotes,
  });

  final String gameId;
  final String libraryEntryId;
  final String title;
  final String? sortTitle;
  final GameStatus status;
  final DateTime? releaseDate;
  final DateTime? completedAt;
  final double? hoursPlayed;
  final int? personalRating;
  final String? personalNotes;
  final String type;
  final List<LibraryCatalogItem> platforms;
  final List<LibraryCatalogItem> genres;
  final int playthroughCount;
  final DateTime updatedAt;
}
