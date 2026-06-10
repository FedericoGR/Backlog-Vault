import '../../../core/database/app_database.dart';

class LibraryGameDetails {
  const LibraryGameDetails({
    required this.game,
    required this.entry,
    required this.platforms,
    required this.genres,
    required this.playthroughs,
    this.selectedCover,
  });

  final Game game;
  final LibraryEntry entry;
  final List<Platform> platforms;
  final List<Genre> genres;
  final List<Playthrough> playthroughs;
  final MediaAsset? selectedCover;
}
