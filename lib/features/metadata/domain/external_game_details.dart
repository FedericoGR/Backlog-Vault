class ExternalGameDetails {
  const ExternalGameDetails({
    required this.providerId,
    required this.providerName,
    required this.externalId,
    this.externalSlug,
    this.externalUrl,
    required this.title,
    this.releaseDate,
    this.type = 'game',
    this.genres = const [],
    this.platforms = const [],
    this.imageUrl,
  });

  final String providerId;
  final String providerName;
  final String externalId;
  final String? externalSlug;
  final String? externalUrl;
  final String title;
  final DateTime? releaseDate;
  final String type;
  final List<String> genres;
  final List<String> platforms;
  final String? imageUrl;
}
