import 'dart:io';

import 'package:backlog_vault/features/metadata/data/igdb_auth_client.dart';
import 'package:backlog_vault/features/metadata/domain/metadata_exception.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  test('obtains an access token using OAuth client credentials', () async {
    final client = IgdbAuthClient(
      httpClient: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.host, 'id.twitch.tv');
        expect(request.url.path, '/oauth2/token');
        expect(request.url.queryParameters['client_id'], 'test_client_id');
        expect(
          request.url.queryParameters['client_secret'],
          'test_client_secret',
        );
        expect(request.url.queryParameters['grant_type'], 'client_credentials');
        return http.Response(
          File('test/fixtures/igdb_token.json').readAsStringSync(),
          200,
        );
      }),
    );

    final token = await client.requestAccessToken(
      clientId: 'test_client_id',
      clientSecret: 'test_client_secret',
    );

    expect(token.accessToken, 'test_access_token');
    expect(token.expiresIn, const Duration(seconds: 5184000));
  });

  test('missing credentials fail before making a request', () async {
    var called = false;
    final client = IgdbAuthClient(
      httpClient: MockClient((request) async {
        called = true;
        return http.Response('{}', 200);
      }),
    );

    await expectLater(
      client.requestAccessToken(clientId: '', clientSecret: 'test'),
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

  test('invalid credentials fail without leaking client secret', () async {
    final client = IgdbAuthClient(
      httpClient: MockClient((request) async => http.Response('{}', 401)),
    );

    await expectLater(
      client.requestAccessToken(
        clientId: 'test_client_id',
        clientSecret: 'test_client_secret',
      ),
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
              isNot(contains('test_client_secret')),
            ),
      ),
    );
  });
}
