import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final offlineSecureStorageCleanupProvider =
    Provider<OfflineSecureStorageCleanup>((ref) {
      return OfflineSecureStorageCleanup(FlutterOfflineSecureKeyValueStore());
    });

abstract interface class OfflineSecureKeyValueStore {
  Future<Map<String, String>> readAll();

  Future<void> delete(String key);
}

class FlutterOfflineSecureKeyValueStore implements OfflineSecureKeyValueStore {
  FlutterOfflineSecureKeyValueStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<Map<String, String>> readAll() => _storage.readAll();

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

class OfflineSecureStorageCleanup {
  const OfflineSecureStorageCleanup(this._storage);

  static const legacyDeviceIdentityKey = 'sync.local.device_id';
  static const legacyGroupKeyPrefix = 'sync.group.key.';

  final OfflineSecureKeyValueStore _storage;

  /// Removes only the two legacy Sync key namespaces used before schema 6.
  ///
  /// Running this more than once is safe. Metadata credentials and unknown
  /// keys are deliberately outside this exact allowlist.
  Future<int> run() async {
    try {
      final values = await _storage.readAll();
      final keys = values.keys
          .where(
            (key) =>
                key == legacyDeviceIdentityKey ||
                key.startsWith(legacyGroupKeyPrefix),
          )
          .toList(growable: false);
      for (final key in keys) {
        await _storage.delete(key);
      }
      return keys.length;
    } on Object {
      throw const OfflineSecureStorageCleanupException();
    }
  }
}

class OfflineSecureStorageCleanupException implements Exception {
  const OfflineSecureStorageCleanupException();

  @override
  String toString() =>
      'OfflineSecureStorageCleanupException: legacy secure storage cleanup failed';
}
