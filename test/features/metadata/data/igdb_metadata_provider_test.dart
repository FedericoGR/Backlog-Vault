import 'dart:io';

import 'package:backlog_vault/core/time/clock.dart';
import 'package:backlog_vault/features/metadata/data/igdb_metadata_provider.dart';
import 'package:backlog_vault/features/metadata/data/metadata_api_key_storage.dart';
import 'package:backlog_vault/features/metadata/domain/metadata_exception.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  test(
    'fails with controlled error when IGDB credentials are missing',
    () async {
      final provider = IgdbMetadataProvider(
        apiKeyStorage: _FakeApiKeyStorage(),
        httpClient: MockClient((request) async => http.Response('[]', 200)),
      );

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
    },
  );

  test('uses cached token while it is valid', () async {
    var tokenRequests = 0;
    var gameRequests = 0;
    final storage = _FakeApiKeyStorage(
      clientId: 'test_client_id',
      clientSecret: 'test_client_secret',
      cachedToken: IgdbCachedToken(
        accessToken: 'test_access_token',
        expiresAt: DateTime(2026, 6, 13, 12),
      ),
    );
    final provider = IgdbMetadataProvider(
      apiKeyStorage: storage,
      clock: _FixedClock(DateTime(2026, 6, 13, 10)),
      httpClient: MockClient((request) async {
        if (request.url.host == 'id.twitch.tv') {
          tokenRequests++;
          return http.Response(
            File('test/fixtures/igdb_token.json').readAsStringSync(),
            200,
          );
        }
        gameRequests++;
        return http.Response(
          File('test/fixtures/igdb_search.json').readAsStringSync(),
          200,
        );
      }),
    );

    final candidates = await provider.searchGames('Hades');

    expect(candidates.first.providerId, 'igdb');
    expect(tokenRequests, 0);
    expect(gameRequests, 1);
  });

  test('renews expired token and stores the replacement', () async {
    var tokenRequests = 0;
    final storage = _FakeApiKeyStorage(
      clientId: 'test_client_id',
      clientSecret: 'test_client_secret',
      cachedToken: IgdbCachedToken(
        accessToken: 'expired_access_token',
        expiresAt: DateTime(2026, 6, 13, 9),
      ),
    );
    final provider = IgdbMetadataProvider(
      apiKeyStorage: storage,
      clock: _FixedClock(DateTime(2026, 6, 13, 10)),
      httpClient: MockClient((request) async {
        if (request.url.host == 'id.twitch.tv') {
          tokenRequests++;
          return http.Response(
            File('test/fixtures/igdb_token.json').readAsStringSync(),
            200,
          );
        }
        expect(request.headers['Authorization'], 'Bearer test_access_token');
        return http.Response(
          File('test/fixtures/igdb_search.json').readAsStringSync(),
          200,
        );
      }),
    );

    await provider.searchGames('Hades');

    expect(tokenRequests, 1);
    expect(storage.cachedToken?.accessToken, 'test_access_token');
    expect(storage.cachedToken?.expiresAt, DateTime(2026, 8, 12, 10));
  });
}

class _FixedClock extends Clock {
  const _FixedClock(this.value);

  final DateTime value;

  @override
  DateTime now() => value;
}

class _FakeApiKeyStorage implements MetadataApiKeyStorage {
  _FakeApiKeyStorage({this.clientId, this.clientSecret, this.cachedToken});

  String? clientId;
  String? clientSecret;
  IgdbCachedToken? cachedToken;

  @override
  Future<void> deleteAllExternalApiKeys() async {
    clientId = null;
    clientSecret = null;
    cachedToken = null;
  }

  @override
  Future<void> deleteIgdbAccessToken() async {
    cachedToken = null;
  }

  @override
  Future<void> deleteIgdbClientId() async {
    clientId = null;
  }

  @override
  Future<void> deleteIgdbClientSecret() async {
    clientSecret = null;
  }

  @override
  Future<void> deleteRawgApiKey() async {}

  @override
  Future<void> deleteSteamGridDbApiKey() async {}

  @override
  Future<IgdbCachedToken?> readIgdbAccessToken() async => cachedToken;

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
    cachedToken = token;
  }

  @override
  Future<void> saveIgdbClientId(String clientId) async {
    this.clientId = clientId;
  }

  @override
  Future<void> saveIgdbClientSecret(String clientSecret) async {
    this.clientSecret = clientSecret;
  }

  @override
  Future<void> saveRawgApiKey(String apiKey) async {}

  @override
  Future<void> saveSteamGridDbApiKey(String apiKey) async {}
}
