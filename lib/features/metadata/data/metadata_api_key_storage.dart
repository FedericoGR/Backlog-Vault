import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final metadataApiKeyStorageProvider = Provider<MetadataApiKeyStorage>((ref) {
  return SecureMetadataApiKeyStorage();
});

abstract class MetadataApiKeyStorage {
  Future<String?> readRawgApiKey();

  Future<void> saveRawgApiKey(String apiKey);

  Future<void> deleteRawgApiKey();

  Future<String?> readSteamGridDbApiKey();

  Future<void> saveSteamGridDbApiKey(String apiKey);

  Future<void> deleteSteamGridDbApiKey();

  Future<void> deleteAllExternalApiKeys();
}

class SecureMetadataApiKeyStorage implements MetadataApiKeyStorage {
  SecureMetadataApiKeyStorage({SecureKeyValueStore? storage})
    : _storage = storage ?? FlutterSecureKeyValueStore();

  static const _rawgApiKey = 'metadata.rawg.api_key';
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
    await Future.wait([deleteRawgApiKey(), deleteSteamGridDbApiKey()]);
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
