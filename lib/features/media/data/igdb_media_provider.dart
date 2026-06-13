import 'package:http/http.dart' as http;

import '../../../core/time/clock.dart';
import '../../metadata/data/igdb_api_client.dart';
import '../../metadata/data/igdb_auth_client.dart';
import '../../metadata/data/metadata_api_key_storage.dart';
import '../../metadata/domain/external_game_details.dart';
import '../../metadata/domain/metadata_exception.dart';
import '../domain/media_asset_models.dart';
import '../domain/media_exception.dart';
import '../domain/media_provider.dart';

class IgdbMediaProvider implements MediaProvider {
  IgdbMediaProvider({
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
  MediaProviderCapabilities get capabilities =>
      const MediaProviderCapabilities(supportsCovers: true);

  @override
  Future<List<MediaSearchCandidate>> searchGames(String query) async {
    try {
      final candidates = await _client().then(
        (client) => client.searchGames(query),
      );
      return [
        for (final candidate in candidates)
          MediaSearchCandidate(
            providerId: providerId,
            providerName: displayName,
            externalId: candidate.externalId,
            title: candidate.title,
            externalUrl: candidate.externalUrl,
          ),
      ];
    } on MetadataException catch (error) {
      throw _mediaException(error);
    }
  }

  @override
  Future<List<ExternalMediaAsset>> searchCoverAssets(
    String externalGameId,
  ) async {
    try {
      final details = await _client().then(
        (client) => client.getGameDetails(externalGameId),
      );
      final asset = externalGameCoverToMediaAsset(details.cover);
      return asset == null ? const [] : [asset];
    } on MetadataException catch (error) {
      throw _mediaException(error);
    }
  }

  Future<IgdbApiClient> _client() async {
    final clientId = await _apiKeyStorage.readIgdbClientId();
    final clientSecret = await _apiKeyStorage.readIgdbClientSecret();
    if (clientId == null || clientSecret == null) {
      throw const MetadataException(
        'Configurá Client ID y Client Secret de IGDB antes de buscar portadas.',
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

  MediaException _mediaException(MetadataException error) {
    return MediaException(
      error.message,
      type: switch (error.type) {
        MetadataErrorType.missingApiKey => MediaErrorType.missingApiKey,
        MetadataErrorType.invalidApiKey => MediaErrorType.invalidApiKey,
        MetadataErrorType.rateLimited => MediaErrorType.rateLimited,
        MetadataErrorType.network => MediaErrorType.network,
        MetadataErrorType.timeout => MediaErrorType.timeout,
        MetadataErrorType.notFound => MediaErrorType.notFound,
        MetadataErrorType.conflict => MediaErrorType.conflict,
        MetadataErrorType.unexpectedResponse =>
          MediaErrorType.unexpectedResponse,
        MetadataErrorType.providerUnavailable =>
          MediaErrorType.providerUnavailable,
      },
    );
  }
}

ExternalMediaAsset? externalGameCoverToMediaAsset(ExternalGameCover? cover) {
  if (cover == null) return null;
  return ExternalMediaAsset(
    providerId: IgdbApiClient.providerId,
    providerName: IgdbApiClient.providerName,
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
