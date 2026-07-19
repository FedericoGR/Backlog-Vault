import '../../metadata/domain/external_game_details.dart';
import 'media_asset_models.dart';

/// Maps IGDB metadata cover data into the shared media asset contract.
ExternalMediaAsset? externalGameCoverToMediaAsset(ExternalGameCover? cover) {
  if (cover == null) return null;
  return ExternalMediaAsset(
    providerId: 'igdb',
    providerName: 'IGDB',
    externalId: cover.externalId,
    kind: MediaAssetKind.cover,
    remoteUrl: cover.remoteUrl,
    thumbnailUrl: cover.thumbnailUrl,
    mimeType: 'image/jpeg',
    width: cover.width,
    height: cover.height,
    attribution: 'IGDB',
  );
}
