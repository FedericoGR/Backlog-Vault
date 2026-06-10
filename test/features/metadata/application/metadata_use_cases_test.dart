import 'package:backlog_vault/features/metadata/application/search_metadata_use_case.dart';
import 'package:backlog_vault/features/metadata/data/metadata_api_key_storage.dart';
import 'package:backlog_vault/features/metadata/data/rawg_metadata_provider.dart';
import 'package:backlog_vault/features/metadata/domain/external_game_details.dart';
import 'package:backlog_vault/features/metadata/domain/metadata_exception.dart';
import 'package:backlog_vault/features/metadata/domain/metadata_provider.dart';
import 'package:backlog_vault/features/metadata/domain/metadata_search_candidate.dart';
import 'package:test/test.dart';

void main() {
  test('fake provider returns candidates through search use case', () async {
    final result = await SearchMetadataUseCase(_FakeProvider())('Hades');

    expect(result.single.title, 'Hades');
    expect(result.single.providerId, 'fake');
  });

  test('search use case rejects empty query', () async {
    expect(
      () => SearchMetadataUseCase(_FakeProvider())('  '),
      throwsA(
        isA<MetadataException>().having(
          (error) => error.type,
          'type',
          MetadataErrorType.unexpectedResponse,
        ),
      ),
    );
  });

  test('RAWG provider without API key fails with controlled error', () async {
    final provider = RawgMetadataProvider(apiKeyStorage: _FakeApiKeyStorage());

    await expectLater(
      provider.searchGames('Hades'),
      throwsA(
        isA<MetadataException>().having(
          (error) => error.type,
          'type',
          MetadataErrorType.missingApiKey,
        ),
      ),
    );
  });
}

class _FakeProvider implements MetadataProvider {
  @override
  String get displayName => 'Fake';

  @override
  String get providerId => 'fake';

  @override
  bool get requiresApiKey => false;

  @override
  Future<ExternalGameDetails> getGameDetails(String externalId) async {
    return ExternalGameDetails(
      providerId: providerId,
      providerName: displayName,
      externalId: externalId,
      title: 'Hades',
    );
  }

  @override
  Future<List<MetadataSearchCandidate>> searchGames(String query) async {
    return [
      MetadataSearchCandidate(
        providerId: providerId,
        providerName: displayName,
        externalId: '1',
        title: query,
      ),
    ];
  }
}

class _FakeApiKeyStorage implements MetadataApiKeyStorage {
  @override
  Future<void> deleteRawgApiKey() async {}

  @override
  Future<void> deleteSteamGridDbApiKey() async {}

  @override
  Future<void> deleteAllExternalApiKeys() async {}

  @override
  Future<String?> readRawgApiKey() async => null;

  @override
  Future<String?> readSteamGridDbApiKey() async => null;

  @override
  Future<void> saveRawgApiKey(String apiKey) async {}

  @override
  Future<void> saveSteamGridDbApiKey(String apiKey) async {}
}
