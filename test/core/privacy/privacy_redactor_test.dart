import 'package:backlog_vault/core/privacy/privacy_redactor.dart';
import 'package:test/test.dart';

void main() {
  const redactor = PrivacyRedactor();

  test('redacts sensitive query parameters', () {
    final text =
        'https://api.rawg.io/api/games?search=Hades&key=rawg-secret '
        'https://example.com/?api_key=abc&apikey=def&token=ghi&access_token=jkl'
        '&client_id=mno&client_secret=pqr&refresh_token=stu';

    final redacted = redactor.redact(text);

    expect(redacted, contains('key=[REDACTED]'));
    expect(redacted, contains('api_key=[REDACTED]'));
    expect(redacted, contains('apikey=[REDACTED]'));
    expect(redacted, contains('token=[REDACTED]'));
    expect(redacted, contains('access_token=[REDACTED]'));
    expect(redacted, contains('client_id=[REDACTED]'));
    expect(redacted, contains('client_secret=[REDACTED]'));
    expect(redacted, contains('refresh_token=[REDACTED]'));
    expect(redacted, isNot(contains('rawg-secret')));
    expect(redacted, isNot(contains('abc')));
    expect(redacted, isNot(contains('def')));
    expect(redacted, isNot(contains('ghi')));
    expect(redacted, isNot(contains('jkl')));
    expect(redacted, isNot(contains('mno')));
    expect(redacted, isNot(contains('pqr')));
    expect(redacted, isNot(contains('stu')));
  });

  test('redacts bearer tokens and authorization headers', () {
    final text =
        'Authorization: Bearer steam-secret\n'
        'Request failed with Bearer another-secret\n'
        'Client-ID: test_client_id';

    final redacted = redactor.redact(text);

    expect(redacted, contains('Authorization: Bearer [REDACTED]'));
    expect(redacted, contains('Bearer [REDACTED]'));
    expect(redacted, contains('Client-ID: [REDACTED]'));
    expect(redacted, isNot(contains('steam-secret')));
    expect(redacted, isNot(contains('another-secret')));
    expect(redacted, isNot(contains('test_client_id')));
  });

  test('redacts loose sensitive key value pairs', () {
    const text =
        'client_id=test_client_id client_secret=test_client_secret '
        'access_token=test_access_token refresh_token=test_refresh_token';

    final redacted = redactor.redact(text);

    expect(redacted, contains('client_id=[REDACTED]'));
    expect(redacted, contains('client_secret=[REDACTED]'));
    expect(redacted, contains('access_token=[REDACTED]'));
    expect(redacted, contains('refresh_token=[REDACTED]'));
    expect(redacted, isNot(contains('test_client_id')));
    expect(redacted, isNot(contains('test_client_secret')));
    expect(redacted, isNot(contains('test_access_token')));
    expect(redacted, isNot(contains('test_refresh_token')));
  });

  test('redacts absolute paths but keeps relative media paths', () {
    final text =
        r'C:\Users\Feder\Documents\Backlog Vault\backup.vaultbackup '
        '/home/feder/backlog/backup.vaultbackup '
        'media/games/game-1/cover.png';

    final redacted = redactor.redact(text);

    expect(redacted, contains('[ruta local]'));
    expect(redacted, isNot(contains(r'C:\Users\Feder')));
    expect(redacted, isNot(contains('/home/feder')));
    expect(redacted, contains('media/games/game-1/cover.png'));
  });

  test('redacts future sync key labels without exposing dummy values', () {
    final redacted = privacyRedactor.redact(
      'sync_key=test_sync_value group_key=test_group_value '
      'private_key=test_private_value session_key=test_session_value '
      'pairing_secret=test_pairing_value',
    );

    expect(redacted, contains('sync_key=[REDACTED]'));
    expect(redacted, contains('group_key=[REDACTED]'));
    expect(redacted, isNot(contains('test_sync_value')));
    expect(redacted, isNot(contains('test_private_value')));
  });
}
