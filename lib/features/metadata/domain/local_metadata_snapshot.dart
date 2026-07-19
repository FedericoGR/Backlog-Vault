/// Minimal local values needed to build a metadata comparison.
class LocalMetadataSnapshot {
  const LocalMetadataSnapshot({
    required this.title,
    required this.type,
    this.releaseDate,
    this.platforms = const [],
    this.genres = const [],
  });

  final String title;
  final DateTime? releaseDate;
  final String type;
  final List<String> platforms;
  final List<String> genres;
}
