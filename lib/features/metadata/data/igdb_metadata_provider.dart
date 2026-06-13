import 'package:http/http.dart' as http;

import '../../../core/time/clock.dart';
import '../domain/external_game_details.dart';
import '../domain/metadata_exception.dart';
import '../domain/metadata_provider.dart';
import '../domain/metadata_search_candidate.dart';
import 'igdb_api_client.dart';
import 'igdb_auth_client.dart';
import 'metadata_api_key_storage.dart';

class IgdbMetadataProvider implements MetadataProvider {
  IgdbMetadataProvider({
    required MetadataApiKeyStorage apiKeyStorage,
    http.Client? httpClient,
    Clock clock = systemClock,
  }) : _apiKeyStorage = apiKeyStorage,
       _httpClient = httpClient,
       _clock = clock;

  final MetadataApiKeyStorage _apiKeyStorage;
  final http.Client? _httpClient;
  final Clock _clock;

  @override
  String get providerId => IgdbApiClient.providerId;

  @override
  String get displayName => IgdbApiClient.providerName;

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

  Future<IgdbApiClient> _client() async {
    final clientId = await _apiKeyStorage.readIgdbClientId();
    final clientSecret = await _apiKeyStorage.readIgdbClientSecret();
    if (clientId == null || clientSecret == null) {
      throw const MetadataException(
        'Configurá Client ID y Client Secret de IGDB antes de buscar metadata.',
        type: MetadataErrorType.missingApiKey,
      );
    }
    final accessToken = await _accessToken(
      clientId: clientId,
      clientSecret: clientSecret,
    );
    return IgdbApiClient(
      clientId: clientId,
      accessToken: accessToken,
      httpClient: _httpClient,
    );
  }

  Future<String> _accessToken({
    required String clientId,
    required String clientSecret,
  }) async {
    final now = _clock.now();
    final cached = await _apiKeyStorage.readIgdbAccessToken();
    if (cached != null && cached.isValidAt(now)) return cached.accessToken;

    final token = await IgdbAuthClient(
      httpClient: _httpClient,
    ).requestAccessToken(clientId: clientId, clientSecret: clientSecret);
    final cachedToken = IgdbCachedToken(
      accessToken: token.accessToken,
      expiresAt: now.add(token.expiresIn),
    );
    await _apiKeyStorage.saveIgdbAccessToken(cachedToken);
    return cachedToken.accessToken;
  }
}
