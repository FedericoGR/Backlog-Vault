class MetadataSearchCandidate {
  const MetadataSearchCandidate({
    required this.providerId,
    required this.providerName,
    required this.externalId,
    this.externalSlug,
    this.externalUrl,
    required this.title,
    this.releaseDate,
    this.platforms = const [],
    this.genres = const [],
    this.thumbnailUrl,
  });

  final String providerId;
  final String providerName;
  final String externalId;
  final String? externalSlug;
  final String? externalUrl;
  final String title;
  final DateTime? releaseDate;
  final List<String> platforms;
  final List<String> genres;
  final String? thumbnailUrl;
}
