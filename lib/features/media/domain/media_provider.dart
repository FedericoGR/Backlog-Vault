import 'media_asset_models.dart';

abstract class MediaProvider {
  String get providerId;
  String get displayName;
  bool get requiresApiKey;
  MediaProviderCapabilities get capabilities;

  Future<List<MediaSearchCandidate>> searchGames(String query);

  Future<List<ExternalMediaAsset>> searchCoverAssets(String externalGameId);
}
