import 'dart:io';

import 'package:backlog_vault/features/metadata/data/igdb_api_client.dart';
import 'package:backlog_vault/features/metadata/domain/metadata_exception.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  test('parses IGDB search fixture into candidates', () async {
    final client = IgdbApiClient(
      clientId: 'test_client_id',
      accessToken: 'test_access_token',
      httpClient: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.host, 'api.igdb.com');
        expect(request.url.path, '/v4/games');
        expect(request.headers['Client-ID'], 'test_client_id');
        expect(request.headers['Authorization'], 'Bearer test_access_token');
        expect(request.body, contains('search "Hades"'));
        return http.Response(
          File('test/fixtures/igdb_search.json').readAsStringSync(),
          200,
        );
      }),
    );

    final candidates = await client.searchGames('Hades');

    expect(candidates, hasLength(2));
    expect(candidates.first.providerId, 'igdb');
    expect(candidates.first.providerName, 'IGDB');
    expect(candidates.first.externalId, '123');
    expect(candidates.first.externalSlug, 'hades');
    expect(candidates.first.externalUrl, 'https://www.igdb.com/games/hades');
    expect(candidates.first.title, 'Hades');
    expect(candidates.first.releaseDate, DateTime(2020, 9, 30));
    expect(
      candidates.first.platforms,
      containsAll(['PC (Microsoft Windows)', 'Nintendo Switch']),
    );
    expect(
      candidates.first.genres,
      containsAll(['Role-playing (RPG)', 'Hack and slash/Beat \'em up']),
    );
  });

  test('parses IGDB detail fixture', () async {
    final client = IgdbApiClient(
      clientId: 'test_client_id',
      accessToken: 'test_access_token',
      httpClient: MockClient((request) async {
        expect(request.body, contains('where id = 123;'));
        return http.Response(
          File('test/fixtures/igdb_details.json').readAsStringSync(),
          200,
        );
      }),
    );

    final details = await client.getGameDetails('123');

    expect(details.providerId, 'igdb');
    expect(details.externalId, '123');
    expect(details.externalSlug, 'hades');
    expect(details.releaseDate, DateTime(2020, 9, 30));
    expect(details.type, 'game');
    expect(
      details.platforms,
      containsAll([
        'PC (Microsoft Windows)',
        'PlayStation 4',
        'Nintendo Switch',
      ]),
    );
    expect(
      details.genres,
      containsAll(['Role-playing (RPG)', 'Hack and slash/Beat \'em up']),
    );
  });

  test('maps auth errors without leaking bearer token', () async {
    final client = IgdbApiClient(
      clientId: 'test_client_id',
      accessToken: 'test_access_token',
      httpClient: MockClient((request) async => http.Response('{}', 401)),
    );

    await expectLater(
      client.searchGames('Hades'),
      throwsA(
        isA<MetadataException>()
            .having(
              (error) => error.type,
              'type',
              MetadataErrorType.invalidApiKey,
            )
            .having(
              (error) => error.toString(),
              'message',
              isNot(contains('test_access_token')),
            ),
      ),
    );
  });

  test('unexpected JSON fails with controlled error', () async {
    final client = IgdbApiClient(
      clientId: 'test_client_id',
      accessToken: 'test_access_token',
      httpClient: MockClient((request) async => http.Response('{}', 200)),
    );

    await expectLater(
      client.searchGames('Hades'),
      throwsA(
        isA<MetadataException>().having(
          (error) => error.type,
          'type',
          MetadataErrorType.unexpectedResponse,
        ),
      ),
    );
  });
}
