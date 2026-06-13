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
    this.cover,
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
  final ExternalGameCover? cover;
}

class ExternalGameCover {
  const ExternalGameCover({
    required this.externalId,
    this.imageId,
    required this.remoteUrl,
    this.thumbnailUrl,
    this.width,
    this.height,
  });

  final String externalId;
  final String? imageId;
  final String remoteUrl;
  final String? thumbnailUrl;
  final int? width;
  final int? height;
}
