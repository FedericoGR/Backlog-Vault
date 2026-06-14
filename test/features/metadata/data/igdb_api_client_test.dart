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
    expect(details.cover, isNull);
  });

  test('parses IGDB detail cover fixture', () async {
    final client = IgdbApiClient(
      clientId: 'test_client_id',
      accessToken: 'test_access_token',
      httpClient: MockClient((request) async {
        expect(request.body, contains('cover.image_id'));
        return http.Response(
          File('test/fixtures/igdb_details_with_cover.json').readAsStringSync(),
          200,
        );
      }),
    );

    final details = await client.getGameDetails('123');

    expect(details.imageUrl, contains('t_720p/cofixture.jpg'));
    expect(details.cover, isNotNull);
    expect(details.cover!.externalId, '456');
    expect(details.cover!.imageId, 'cofixture');
    expect(
      details.cover!.remoteUrl,
      'https://images.igdb.com/igdb/image/upload/t_720p/cofixture.jpg',
    );
    expect(
      details.cover!.thumbnailUrl,
      'https://images.igdb.com/igdb/image/upload/t_cover_big/cofixture.jpg',
    );
    expect(details.cover!.width, 600);
    expect(details.cover!.height, 800);
  });

  test('IGDB detail without cover does not fail', () async {
    final client = IgdbApiClient(
      clientId: 'test_client_id',
      accessToken: 'test_access_token',
      httpClient: MockClient((request) async {
        return http.Response(
          File(
            'test/fixtures/igdb_details_without_cover.json',
          ).readAsStringSync(),
          200,
        );
      }),
    );

    final details = await client.getGameDetails('123');

    expect(details.cover, isNull);
    expect(details.imageUrl, isNull);
  });

  test('uses protocol-relative cover url when image id is missing', () async {
    final client = IgdbApiClient(
      clientId: 'test_client_id',
      accessToken: 'test_access_token',
      httpClient: MockClient((request) async {
        return http.Response('''
[
  {
    "id": 123,
    "name": "Hades",
    "cover": {
      "id": 456,
      "url": "//images.igdb.com/igdb/image/upload/t_thumb/cofallback.jpg",
      "width": 300,
      "height": 400
    }
  }
]
''', 200);
      }),
    );

    final details = await client.getGameDetails('123');

    expect(details.cover, isNotNull);
    expect(details.cover!.externalId, '456');
    expect(details.cover!.imageId, isNull);
    expect(
      details.cover!.remoteUrl,
      'https://images.igdb.com/igdb/image/upload/t_720p/cofallback.jpg',
    );
    expect(
      details.cover!.thumbnailUrl,
      'https://images.igdb.com/igdb/image/upload/t_cover_big/cofallback.jpg',
    );
  });

  test('ignores invalid cover url without failing detail parsing', () async {
    final client = IgdbApiClient(
      clientId: 'test_client_id',
      accessToken: 'test_access_token',
      httpClient: MockClient((request) async {
        return http.Response('''
[
  {
    "id": 123,
    "name": "Hades",
    "cover": {
      "id": 456,
      "url": "not-a-valid-absolute-url"
    }
  }
]
''', 200);
      }),
    );

    final details = await client.getGameDetails('123');

    expect(details.cover, isNull);
    expect(details.imageUrl, isNull);
  });

  test('parses cover with optional width and height missing', () async {
    final client = IgdbApiClient(
      clientId: 'test_client_id',
      accessToken: 'test_access_token',
      httpClient: MockClient((request) async {
        return http.Response('''
[
  {
    "id": 123,
    "name": "Hades",
    "cover": {
      "id": 456,
      "image_id": "cofixture"
    }
  }
]
''', 200);
      }),
    );

    final details = await client.getGameDetails('123');

    expect(details.cover, isNotNull);
    expect(details.cover!.width, isNull);
    expect(details.cover!.height, isNull);
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
