import 'package:backlog_vault/features/metadata/data/metadata_api_key_storage.dart';
import 'package:test/test.dart';

void main() {
  test(
    'deleteAllExternalApiKeys deletes RAWG, IGDB and SteamGridDB keys',
    () async {
      final store = _FakeSecureKeyValueStore();
      final storage = SecureMetadataApiKeyStorage(storage: store);

      await storage.saveRawgApiKey(' rawg-secret ');
      await storage.saveIgdbClientId(' test_client_id ');
      await storage.saveIgdbClientSecret(' test_client_secret ');
      await storage.saveIgdbAccessToken(
        IgdbCachedToken(
          accessToken: ' test_access_token ',
          expiresAt: DateTime(2026, 6, 13),
        ),
      );
      await storage.saveSteamGridDbApiKey(' steam-secret ');

      expect(await storage.readRawgApiKey(), 'rawg-secret');
      expect(await storage.readIgdbClientId(), 'test_client_id');
      expect(await storage.readIgdbClientSecret(), 'test_client_secret');
      expect(
        (await storage.readIgdbAccessToken())?.accessToken,
        'test_access_token',
      );
      expect(await storage.readSteamGridDbApiKey(), 'steam-secret');

      await storage.deleteAllExternalApiKeys();

      expect(await storage.readRawgApiKey(), isNull);
      expect(await storage.readIgdbClientId(), isNull);
      expect(await storage.readIgdbClientSecret(), isNull);
      expect(await storage.readIgdbAccessToken(), isNull);
      expect(await storage.readSteamGridDbApiKey(), isNull);
      expect(store.values, isEmpty);
    },
  );
}

class _FakeSecureKeyValueStore implements SecureKeyValueStore {
  final values = <String, String>{};

  @override
  Future<void> delete({required String key}) async {
    values.remove(key);
  }

  @override
  Future<String?> read({required String key}) async {
    return values[key];
  }

  @override
  Future<void> write({required String key, required String value}) async {
    values[key] = value;
  }
}
