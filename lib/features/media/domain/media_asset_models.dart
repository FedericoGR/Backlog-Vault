enum MediaAssetKind {
  cover;

  String get label => switch (this) {
    MediaAssetKind.cover => 'Portada',
  };
}

MediaAssetKind parseMediaAssetKind(String value) {
  return MediaAssetKind.values.firstWhere(
    (kind) => kind.name == value,
    orElse: () => MediaAssetKind.cover,
  );
}

enum MediaAssetSource {
  steamgriddb,
  local;

  String get label => switch (this) {
    MediaAssetSource.steamgriddb => 'SteamGridDB',
    MediaAssetSource.local => 'Archivo local',
  };
}

MediaAssetSource parseMediaAssetSource(String value) {
  return MediaAssetSource.values.firstWhere(
    (source) => source.name == value,
    orElse: () => MediaAssetSource.local,
  );
}

class MediaSearchCandidate {
  const MediaSearchCandidate({
    required this.providerId,
    required this.providerName,
    required this.externalId,
    required this.title,
    this.externalUrl,
  });

  final String providerId;
  final String providerName;
  final String externalId;
  final String title;
  final String? externalUrl;
}

class ExternalMediaAsset {
  const ExternalMediaAsset({
    required this.providerId,
    required this.providerName,
    required this.externalId,
    required this.kind,
    required this.remoteUrl,
    this.thumbnailUrl,
    this.mimeType,
    this.width,
    this.height,
    this.attribution,
  });

  final String providerId;
  final String providerName;
  final String externalId;
  final MediaAssetKind kind;
  final String remoteUrl;
  final String? thumbnailUrl;
  final String? mimeType;
  final int? width;
  final int? height;
  final String? attribution;
}

class MediaProviderCapabilities {
  const MediaProviderCapabilities({required this.supportsCovers});

  final bool supportsCovers;
}

class SavedMediaAsset {
  const SavedMediaAsset({
    required this.id,
    required this.gameId,
    required this.kind,
    required this.source,
    required this.localPath,
    required this.fileName,
    required this.isSelected,
    this.provider,
    this.externalId,
    this.remoteUrl,
    this.mimeType,
    this.width,
    this.height,
    this.hash,
    this.attribution,
  });

  final String id;
  final String gameId;
  final MediaAssetKind kind;
  final MediaAssetSource source;
  final String localPath;
  final String fileName;
  final bool isSelected;
  final String? provider;
  final String? externalId;
  final String? remoteUrl;
  final String? mimeType;
  final int? width;
  final int? height;
  final String? hash;
  final String? attribution;
}
