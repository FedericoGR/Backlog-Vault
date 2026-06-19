import '../../../core/privacy/privacy_redactor.dart';

/// Removes device-local paths and credential-shaped values before data enters
/// the durable sync oplog.
///
/// Logical entities may contain user-authored text. That text is preserved
/// unless it looks like an explicit credential or absolute local path. The
/// sanitizer is recursive and deterministic so it can run before canonical
/// JSON encoding and hashing.
class SyncPayloadSanitizer {
  const SyncPayloadSanitizer({PrivacyRedactor redactor = privacyRedactor})
    : _redactor = redactor;

  final PrivacyRedactor _redactor;

  Object? sanitize(Object? value, {String? fieldName}) {
    if (fieldName != null && _isSensitiveField(fieldName)) {
      return '[REDACTED]';
    }
    if (value is String) {
      return _redactor
          .redact(value)
          .replaceAll('[ruta local]', '[LOCAL_PATH_REDACTED]');
    }
    if (value is Map) {
      return <String, Object?>{
        for (final entry in value.entries)
          entry.key.toString(): sanitize(
            entry.value,
            fieldName: entry.key.toString(),
          ),
      };
    }
    if (value is Iterable) {
      return value.map<Object?>(sanitize).toList(growable: false);
    }
    return value;
  }

  Map<String, Object?> sanitizeMap(Map<String, Object?> value) {
    return sanitize(value)! as Map<String, Object?>;
  }

  bool _isSensitiveField(String fieldName) {
    final normalized = fieldName.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]'),
      '',
    );
    return const {
      'apikey',
      'rawgapikey',
      'steamgriddbapikey',
      'clientsecret',
      'accesstoken',
      'refreshtoken',
      'authorization',
      'synckey',
      'groupkey',
      'privatekey',
      'sessionkey',
      'pairingsecret',
    }.contains(normalized);
  }
}

const syncPayloadSanitizer = SyncPayloadSanitizer();
