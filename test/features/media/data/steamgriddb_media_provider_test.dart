import 'package:backlog_vault/features/media/data/steamgriddb_media_provider.dart';
import 'package:backlog_vault/features/media/domain/media_exception.dart';
import 'package:backlog_vault/features/metadata/data/metadata_api_key_storage.dart';
import 'package:test/test.dart';

void main() {
  test('fails safely when SteamGridDB API key is missing', () async {
    final provider = SteamGridDbMediaProvider(
      apiKeyStorage: _FakeApiKeyStorage(),
    );

    await expectLater(
      provider.searchGames('Hades'),
      throwsA(
        isA<MediaException>().having(
          (error) => error.type,
          'type',
          MediaErrorType.missingApiKey,
        ),
      ),
    );
  });
}

class _FakeApiKeyStorage implements MetadataApiKeyStorage {
  @override
  Future<void> deleteIgdbAccessToken() async {}

  @override
  Future<void> deleteIgdbClientId() async {}

  @override
  Future<void> deleteIgdbClientSecret() async {}

  @override
  Future<void> deleteRawgApiKey() async {}

  @override
  Future<void> deleteSteamGridDbApiKey() async {}

  @override
  Future<void> deleteAllExternalApiKeys() async {}

  @override
  Future<IgdbCachedToken?> readIgdbAccessToken() async => null;

  @override
  Future<String?> readIgdbClientId() async => null;

  @override
  Future<String?> readIgdbClientSecret() async => null;

  @override
  Future<String?> readRawgApiKey() async => null;

  @override
  Future<String?> readSteamGridDbApiKey() async => null;

  @override
  Future<void> saveRawgApiKey(String apiKey) async {}

  @override
  Future<void> saveIgdbAccessToken(IgdbCachedToken token) async {}

  @override
  Future<void> saveIgdbClientId(String clientId) async {}

  @override
  Future<void> saveIgdbClientSecret(String clientSecret) async {}

  @override
  Future<void> saveSteamGridDbApiKey(String apiKey) async {}
}
