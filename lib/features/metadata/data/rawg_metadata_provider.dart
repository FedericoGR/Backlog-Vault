import 'package:http/http.dart' as http;

import '../domain/external_game_details.dart';
import '../domain/metadata_exception.dart';
import '../domain/metadata_provider.dart';
import '../domain/metadata_search_candidate.dart';
import 'metadata_api_key_storage.dart';
import 'rawg_api_client.dart';

class RawgMetadataProvider implements MetadataProvider {
  RawgMetadataProvider({
    required MetadataApiKeyStorage apiKeyStorage,
    http.Client? httpClient,
  }) : _apiKeyStorage = apiKeyStorage,
       _httpClient = httpClient;

  final MetadataApiKeyStorage _apiKeyStorage;
  final http.Client? _httpClient;

  @override
  String get providerId => RawgApiClient.providerId;

  @override
  String get displayName => RawgApiClient.providerName;

  @override
  bool get requiresApiKey => true;

  @override
  Future<List<MetadataSearchCandidate>> searchGames(String query) async {
    return _client().then((client) => client.searchGames(query));
  }

  @override
  Future<ExternalGameDetails> getGameDetails(String externalId) async {
    return _client().then((client) => client.getGameDetails(externalId));
  }

  Future<RawgApiClient> _client() async {
    final apiKey = await _apiKeyStorage.readRawgApiKey();
    if (apiKey == null) {
      throw const MetadataException(
        'Configurá una API key de RAWG antes de buscar metadata.',
        type: MetadataErrorType.missingApiKey,
      );
    }
    return RawgApiClient(apiKey: apiKey, httpClient: _httpClient);
  }
}
