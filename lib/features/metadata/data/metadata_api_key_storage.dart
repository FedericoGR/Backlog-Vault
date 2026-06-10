import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final metadataApiKeyStorageProvider = Provider<MetadataApiKeyStorage>((ref) {
  return SecureMetadataApiKeyStorage();
});

abstract class MetadataApiKeyStorage {
  Future<String?> readRawgApiKey();

  Future<void> saveRawgApiKey(String apiKey);

  Future<void> deleteRawgApiKey();
}

class SecureMetadataApiKeyStorage implements MetadataApiKeyStorage {
  SecureMetadataApiKeyStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _rawgApiKey = 'metadata.rawg.api_key';

  final FlutterSecureStorage _storage;

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
}
