import 'dart:io';

import 'package:backlog_vault/features/metadata/data/rawg_api_client.dart';
import 'package:backlog_vault/features/metadata/domain/metadata_exception.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  test('parses RAWG search fixture into candidates', () async {
    final client = RawgApiClient(
      apiKey: 'test-key',
      httpClient: MockClient((request) async {
        expect(request.url.path, '/api/games');
        expect(request.url.queryParameters['search'], 'grand theft auto');
        return http.Response(
          File('test/fixtures/rawg_search.json').readAsStringSync(),
          200,
        );
      }),
    );

    final candidates = await client.searchGames('grand theft auto');

    expect(candidates, hasLength(2));
    expect(candidates.first.externalId, '3498');
    expect(candidates.first.title, 'Grand Theft Auto V');
    expect(candidates.first.releaseDate, DateTime(2013, 9, 17));
    expect(candidates.first.platforms, containsAll(['PC', 'PlayStation 4']));
    expect(candidates.first.genres, containsAll(['Action', 'Adventure']));
  });

  test('parses RAWG details fixture', () async {
    final client = RawgApiClient(
      apiKey: 'test-key',
      httpClient: MockClient((request) async {
        expect(request.url.path, '/api/games/3498');
        return http.Response(
          File('test/fixtures/rawg_details.json').readAsStringSync(),
          200,
        );
      }),
    );

    final details = await client.getGameDetails('3498');

    expect(details.externalId, '3498');
    expect(details.externalSlug, 'grand-theft-auto-v');
    expect(details.externalUrl, 'https://rawg.io/games/grand-theft-auto-v');
    expect(details.releaseDate, DateTime(2013, 9, 17));
    expect(details.platforms, containsAll(['PC', 'PlayStation 4', 'Xbox One']));
    expect(details.genres, containsAll(['Action', 'Adventure']));
  });

  test('maps auth and rate limit errors without leaking API key', () async {
    final client = RawgApiClient(
      apiKey: 'secret-test-key',
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
              isNot(contains('secret-test-key')),
            ),
      ),
    );
  });

  test('empty API key fails before making a request', () async {
    var called = false;
    final client = RawgApiClient(
      apiKey: '',
      httpClient: MockClient((request) async {
        called = true;
        return http.Response('{}', 200);
      }),
    );

    await expectLater(
      client.searchGames('Hades'),
      throwsA(
        isA<MetadataException>().having(
          (error) => error.type,
          'type',
          MetadataErrorType.missingApiKey,
        ),
      ),
    );
    expect(called, isFalse);
  });
}
