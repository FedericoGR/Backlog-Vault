import 'package:http/http.dart' as http;

import '../../metadata/data/metadata_api_key_storage.dart';
import '../domain/media_asset_models.dart';
import '../domain/media_exception.dart';
import '../domain/media_provider.dart';
import 'steamgriddb_api_client.dart';

class SteamGridDbMediaProvider implements MediaProvider {
  SteamGridDbMediaProvider({
    required MetadataApiKeyStorage apiKeyStorage,
    http.Client? httpClient,
  }) : _apiKeyStorage = apiKeyStorage,
       _httpClient = httpClient;

  final MetadataApiKeyStorage _apiKeyStorage;
  final http.Client? _httpClient;

  @override
  String get providerId => SteamGridDbApiClient.providerId;

  @override
  String get displayName => SteamGridDbApiClient.providerName;

  @override
  bool get requiresApiKey => true;

  @override
  MediaProviderCapabilities get capabilities =>
      const MediaProviderCapabilities(supportsCovers: true);

  @override
  Future<List<MediaSearchCandidate>> searchGames(String query) async {
    return _client().then((client) => client.searchGames(query));
  }

  @override
  Future<List<ExternalMediaAsset>> searchCoverAssets(String externalGameId) {
    return _client().then((client) => client.searchCoverAssets(externalGameId));
  }

  Future<SteamGridDbApiClient> _client() async {
    final apiKey = await _apiKeyStorage.readSteamGridDbApiKey();
    if (apiKey == null) {
      throw const MediaException(
        'Configurá una API key de SteamGridDB antes de buscar portadas.',
        type: MediaErrorType.missingApiKey,
      );
    }
    return SteamGridDbApiClient(apiKey: apiKey, httpClient: _httpClient);
  }
}
