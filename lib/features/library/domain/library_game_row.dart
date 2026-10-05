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
    required this.isCompleted,
    required this.type,
    required this.platforms,
    required this.genres,
    required this.updatedAt,
    this.sortTitle,
    this.selectedCoverLocalPath,
    this.selectedCoverProvider,
    this.hasExternalMetadata = false,
    this.releaseDate,
    this.completedAt,
    this.playedYear,
    this.hoursPlayed,
    this.playedPlatformId,
    this.playedPlatformName,
    this.personalRating,
    this.personalNotes,
  });

  final String gameId;
  final String libraryEntryId;
  final String title;
  final String? sortTitle;
  final String? selectedCoverLocalPath;
  final String? selectedCoverProvider;
  final bool hasExternalMetadata;
  final bool isCompleted;
  GameStatus get status =>
      isCompleted ? GameStatus.completed : GameStatus.pending;
  final String? playedPlatformName;
  LibraryCatalogItem? get playedPlatform =>
      playedPlatformId == null
          ? null
          : LibraryCatalogItem(
            id: playedPlatformId!,
            name: playedPlatformName ?? playedPlatformId!,
          );
  final String? playedPlatformId;
  final DateTime? releaseDate;
  final DateTime? completedAt;
  final int? playedYear;
  final double? hoursPlayed;
  final int? personalRating;
  final String? personalNotes;
  final String type;
  final List<LibraryCatalogItem> platforms;
  final List<LibraryCatalogItem> genres;
  final DateTime updatedAt;
}
