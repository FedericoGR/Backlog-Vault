import 'dart:io';

import 'package:backlog_vault/features/media/data/igdb_media_provider.dart';
import 'package:backlog_vault/features/media/domain/media_exception.dart';
import 'package:backlog_vault/features/metadata/data/metadata_api_key_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  test('searchGames maps IGDB candidates into media candidates', () async {
    final provider = IgdbMediaProvider(
      apiKeyStorage: _FakeMetadataApiKeyStorage(),
      httpClient: MockClient((request) async {
        expect(request.headers['Client-ID'], 'test_client_id');
        expect(request.headers['Authorization'], 'Bearer test_access_token');
        return http.Response(
          File('test/fixtures/igdb_search.json').readAsStringSync(),
          200,
        );
      }),
    );

    final candidates = await provider.searchGames('Hades');

    expect(candidates, hasLength(2));
    expect(candidates.first.providerId, 'igdb');
    expect(candidates.first.providerName, 'IGDB');
    expect(candidates.first.externalId, '123');
    expect(candidates.first.title, 'Hades');
  });

  test('searchCoverAssets maps IGDB cover into external media asset', () async {
    final provider = IgdbMediaProvider(
      apiKeyStorage: _FakeMetadataApiKeyStorage(),
      httpClient: MockClient((request) async {
        expect(request.body, contains('where id = 123;'));
        return http.Response(
          File('test/fixtures/igdb_details_with_cover.json').readAsStringSync(),
          200,
        );
      }),
    );

    final assets = await provider.searchCoverAssets('123');

    expect(assets, hasLength(1));
    expect(assets.single.providerId, 'igdb');
    expect(assets.single.providerName, 'IGDB');
    expect(assets.single.externalId, '456');
    expect(
      assets.single.remoteUrl,
      'https://images.igdb.com/igdb/image/upload/t_cover_big/cofixture.jpg',
    );
    expect(assets.single.width, 600);
    expect(assets.single.height, 800);
    expect(assets.single.attribution, 'IGDB');
  });

  test('searchCoverAssets returns empty list when IGDB has no cover', () async {
    final provider = IgdbMediaProvider(
      apiKeyStorage: _FakeMetadataApiKeyStorage(),
      httpClient: MockClient((request) async {
        return http.Response(
          File(
            'test/fixtures/igdb_details_without_cover.json',
          ).readAsStringSync(),
          200,
        );
      }),
    );

    final assets = await provider.searchCoverAssets('123');

    expect(assets, isEmpty);
  });

  test(
    'missing IGDB credentials fail safely without leaking secrets',
    () async {
      final provider = IgdbMediaProvider(
        apiKeyStorage: _FakeMetadataApiKeyStorage(
          clientId: null,
          clientSecret: null,
        ),
        httpClient: MockClient((request) async => http.Response('[]', 200)),
      );

      await expectLater(
        provider.searchGames('Hades'),
        throwsA(
          isA<MediaException>()
              .having(
                (error) => error.type,
                'type',
                MediaErrorType.missingApiKey,
              )
              .having(
                (error) => error.message,
                'message',
                isNot(contains('test_client_secret')),
              ),
        ),
      );
    },
  );
}

class _FakeMetadataApiKeyStorage implements MetadataApiKeyStorage {
  _FakeMetadataApiKeyStorage({
    this.clientId = 'test_client_id',
    this.clientSecret = 'test_client_secret',
  });

  final String? clientId;
  final String? clientSecret;
  IgdbCachedToken? token = IgdbCachedToken(
    accessToken: 'test_access_token',
    expiresAt: DateTime(2099),
  );

  @override
  Future<void> deleteAllExternalApiKeys() async {}

  @override
  Future<void> deleteIgdbAccessToken() async => token = null;

  @override
  Future<void> deleteIgdbClientId() async {}

  @override
  Future<void> deleteIgdbClientSecret() async {}

  @override
  Future<void> deleteRawgApiKey() async {}

  @override
  Future<void> deleteSteamGridDbApiKey() async {}

  @override
  Future<IgdbCachedToken?> readIgdbAccessToken() async => token;

  @override
  Future<String?> readIgdbClientId() async => clientId;

  @override
  Future<String?> readIgdbClientSecret() async => clientSecret;

  @override
  Future<String?> readRawgApiKey() async => null;

  @override
  Future<String?> readSteamGridDbApiKey() async => null;

  @override
  Future<void> saveIgdbAccessToken(IgdbCachedToken token) async {
    this.token = token;
  }

  @override
  Future<void> saveIgdbClientId(String clientId) async {}

  @override
  Future<void> saveIgdbClientSecret(String clientSecret) async {}

  @override
  Future<void> saveRawgApiKey(String apiKey) async {}

  @override
  Future<void> saveSteamGridDbApiKey(String apiKey) async {}
}
