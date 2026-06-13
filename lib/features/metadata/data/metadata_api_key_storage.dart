import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final metadataApiKeyStorageProvider = Provider<MetadataApiKeyStorage>((ref) {
  return SecureMetadataApiKeyStorage();
});

abstract class MetadataApiKeyStorage {
  Future<String?> readRawgApiKey();

  Future<void> saveRawgApiKey(String apiKey);

  Future<void> deleteRawgApiKey();

  Future<String?> readIgdbClientId();

  Future<void> saveIgdbClientId(String clientId);

  Future<void> deleteIgdbClientId();

  Future<String?> readIgdbClientSecret();

  Future<void> saveIgdbClientSecret(String clientSecret);

  Future<void> deleteIgdbClientSecret();

  Future<IgdbCachedToken?> readIgdbAccessToken();

  Future<void> saveIgdbAccessToken(IgdbCachedToken token);

  Future<void> deleteIgdbAccessToken();

  Future<String?> readSteamGridDbApiKey();

  Future<void> saveSteamGridDbApiKey(String apiKey);

  Future<void> deleteSteamGridDbApiKey();

  Future<void> deleteAllExternalApiKeys();
}

class SecureMetadataApiKeyStorage implements MetadataApiKeyStorage {
  SecureMetadataApiKeyStorage({SecureKeyValueStore? storage})
    : _storage = storage ?? FlutterSecureKeyValueStore();

  static const _rawgApiKey = 'metadata.rawg.api_key';
  static const _igdbClientId = 'metadata.igdb.client_id';
  static const _igdbClientSecret = 'metadata.igdb.client_secret';
  static const _igdbAccessToken = 'metadata.igdb.access_token';
  static const _igdbAccessTokenExpiresAt =
      'metadata.igdb.access_token_expires_at';
  static const _steamGridDbApiKey = 'media.steamgriddb.api_key';

  final SecureKeyValueStore _storage;

  @override
  Future<String?> readRawgApiKey() async {
    final value = await _storage.read(key: _rawgApiKey);
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  @override
  Future<void> saveRawgApiKey(String apiKey) {
    return _storage.write(key: _rawgApiKey, value: apiKey.trim());
  }

  @override
  Future<void> deleteRawgApiKey() {
    return _storage.delete(key: _rawgApiKey);
  }

  @override
  Future<String?> readIgdbClientId() async {
    final value = await _storage.read(key: _igdbClientId);
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  @override
  Future<void> saveIgdbClientId(String clientId) {
    return _storage.write(key: _igdbClientId, value: clientId.trim());
  }

  @override
  Future<void> deleteIgdbClientId() {
    return _storage.delete(key: _igdbClientId);
  }

  @override
  Future<String?> readIgdbClientSecret() async {
    final value = await _storage.read(key: _igdbClientSecret);
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  @override
  Future<void> saveIgdbClientSecret(String clientSecret) {
    return _storage.write(key: _igdbClientSecret, value: clientSecret.trim());
  }

  @override
  Future<void> deleteIgdbClientSecret() {
    return _storage.delete(key: _igdbClientSecret);
  }

  @override
  Future<IgdbCachedToken?> readIgdbAccessToken() async {
    final token = await _storage.read(key: _igdbAccessToken);
    final expiresAtValue = await _storage.read(key: _igdbAccessTokenExpiresAt);
    final trimmedToken = token?.trim();
    final expiresAt =
        expiresAtValue == null ? null : DateTime.tryParse(expiresAtValue);
    if (trimmedToken == null || trimmedToken.isEmpty || expiresAt == null) {
      return null;
    }
    return IgdbCachedToken(accessToken: trimmedToken, expiresAt: expiresAt);
  }

  @override
  Future<void> saveIgdbAccessToken(IgdbCachedToken token) async {
    await _storage.write(
      key: _igdbAccessToken,
      value: token.accessToken.trim(),
    );
    await _storage.write(
      key: _igdbAccessTokenExpiresAt,
      value: token.expiresAt.toIso8601String(),
    );
  }

  @override
  Future<void> deleteIgdbAccessToken() async {
    await Future.wait([
      _storage.delete(key: _igdbAccessToken),
      _storage.delete(key: _igdbAccessTokenExpiresAt),
    ]);
  }

  @override
  Future<String?> readSteamGridDbApiKey() async {
    final value = await _storage.read(key: _steamGridDbApiKey);
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  @override
  Future<void> saveSteamGridDbApiKey(String apiKey) {
    return _storage.write(key: _steamGridDbApiKey, value: apiKey.trim());
  }

  @override
  Future<void> deleteSteamGridDbApiKey() {
    return _storage.delete(key: _steamGridDbApiKey);
  }

  @override
  Future<void> deleteAllExternalApiKeys() async {
    await Future.wait([
      deleteRawgApiKey(),
      deleteIgdbClientId(),
      deleteIgdbClientSecret(),
      deleteIgdbAccessToken(),
      deleteSteamGridDbApiKey(),
    ]);
  }
}

class IgdbCachedToken {
  const IgdbCachedToken({required this.accessToken, required this.expiresAt});

  final String accessToken;
  final DateTime expiresAt;

  bool isValidAt(
    DateTime value, {
    Duration margin = const Duration(minutes: 1),
  }) {
    return accessToken.trim().isNotEmpty &&
        expiresAt.isAfter(value.add(margin));
  }
}

abstract class SecureKeyValueStore {
  Future<String?> read({required String key});

  Future<void> write({required String key, required String value});

  Future<void> delete({required String key});
}

class FlutterSecureKeyValueStore implements SecureKeyValueStore {
  FlutterSecureKeyValueStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read({required String key}) {
    return _storage.read(key: key);
  }

  @override
  Future<void> write({required String key, required String value}) {
    return _storage.write(key: key, value: value);
  }

  @override
  Future<void> delete({required String key}) {
    return _storage.delete(key: key);
  }
}
