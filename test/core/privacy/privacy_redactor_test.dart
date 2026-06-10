import 'package:backlog_vault/core/privacy/privacy_redactor.dart';
import 'package:test/test.dart';

void main() {
  const redactor = PrivacyRedactor();

  test('redacts sensitive query parameters', () {
    final text =
        'https://api.rawg.io/api/games?search=Hades&key=rawg-secret '
        'https://example.com/?api_key=abc&apikey=def&token=ghi&access_token=jkl';

    final redacted = redactor.redact(text);

    expect(redacted, contains('key=[REDACTED]'));
    expect(redacted, contains('api_key=[REDACTED]'));
    expect(redacted, contains('apikey=[REDACTED]'));
    expect(redacted, contains('token=[REDACTED]'));
    expect(redacted, contains('access_token=[REDACTED]'));
    expect(redacted, isNot(contains('rawg-secret')));
    expect(redacted, isNot(contains('abc')));
    expect(redacted, isNot(contains('def')));
    expect(redacted, isNot(contains('ghi')));
    expect(redacted, isNot(contains('jkl')));
  });

  test('redacts bearer tokens and authorization headers', () {
    final text =
        'Authorization: Bearer steam-secret\n'
        'Request failed with Bearer another-secret';

    final redacted = redactor.redact(text);

    expect(redacted, contains('Authorization: Bearer [REDACTED]'));
    expect(redacted, contains('Bearer [REDACTED]'));
    expect(redacted, isNot(contains('steam-secret')));
    expect(redacted, isNot(contains('another-secret')));
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
}
