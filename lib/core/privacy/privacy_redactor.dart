class PrivacyRedactor {
  const PrivacyRedactor();

  static final _sensitiveQueryParam = RegExp(
    r'([?&](?:key|api_key|apikey|token|access_token)=)([^&#\s]+)',
    caseSensitive: false,
  );
  static final _authorizationHeader = RegExp(
    r'(Authorization\s*:\s*Bearer\s+)([^\s,;]+)',
    caseSensitive: false,
  );
  static final _bearerToken = RegExp(
    r'\bBearer\s+[A-Za-z0-9._~+/=-]+',
    caseSensitive: false,
  );
  static final _windowsAbsolutePath = RegExp(
    r'\b[A-Za-z]:\\(?:[^\\/:*?"<>|\r\n]+\\)*[^\\/:*?"<>|\r\n]*',
  );
  static final _unixAbsolutePath = RegExp(
    r'''(?<![\w])/(?:home|Users|tmp|var|private|data|storage)/[^\s'"]+''',
  );

  String redact(String input) {
    var output = input;
    output = output.replaceAllMapped(
      _sensitiveQueryParam,
      (match) => '${match.group(1)}[REDACTED]',
    );
    output = output.replaceAllMapped(
      _authorizationHeader,
      (match) => '${match.group(1)}[REDACTED]',
    );
    output = output.replaceAll(_bearerToken, 'Bearer [REDACTED]');
    output = output.replaceAll(_windowsAbsolutePath, '[ruta local]');
    output = output.replaceAll(_unixAbsolutePath, '[ruta local]');
    return output;
  }
}

const privacyRedactor = PrivacyRedactor();
