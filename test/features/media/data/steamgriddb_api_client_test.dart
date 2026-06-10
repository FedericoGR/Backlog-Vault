import 'dart:io';

import 'package:backlog_vault/features/media/data/steamgriddb_api_client.dart';
import 'package:backlog_vault/features/media/domain/media_exception.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  test('parses SteamGridDB search candidates', () async {
    final client = SteamGridDbApiClient(
      apiKey: 'test-key',
      httpClient: MockClient((request) async {
        expect(request.headers['Authorization'], 'Bearer test-key');
        return http.Response(
          await _fixture('steamgriddb_search_hades.json'),
          200,
        );
      }),
    );

    final candidates = await client.searchGames('Hades');

    expect(candidates, hasLength(2));
    expect(candidates.first.externalId, '123');
    expect(candidates.first.title, 'Hades');
    expect(candidates.first.providerId, SteamGridDbApiClient.providerId);
  });

  test('parses and filters SteamGridDB cover assets', () async {
    final client = SteamGridDbApiClient(
      apiKey: 'test-key',
      httpClient: MockClient((request) async {
        return http.Response(
          await _fixture('steamgriddb_grids_hades.json'),
          200,
        );
      }),
    );

    final assets = await client.searchCoverAssets('123');

    expect(assets, hasLength(1));
    expect(assets.single.externalId, '9001');
    expect(assets.single.remoteUrl, contains('hades-cover.png'));
    expect(assets.single.attribution, 'Fixture Artist');
  });

  test('does not expose API key in auth errors', () async {
    const secret = 'super-secret-key';
    final client = SteamGridDbApiClient(
      apiKey: secret,
      httpClient: MockClient((request) async {
        return http.Response(
          await _fixture('steamgriddb_auth_error.json'),
          401,
        );
      }),
    );

    await expectLater(
      client.searchGames('Hades'),
      throwsA(
        isA<MediaException>()
            .having((error) => error.type, 'type', MediaErrorType.invalidApiKey)
            .having(
              (error) => error.message,
              'message',
              isNot(contains(secret)),
            ),
      ),
    );
  });
}

Future<String> _fixture(String name) {
  return File('test/features/media/fixtures/$name').readAsString();
}
