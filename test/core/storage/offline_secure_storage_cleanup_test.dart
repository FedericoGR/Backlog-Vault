import 'package:backlog_vault/core/storage/offline_secure_storage_cleanup.dart';
import 'package:test/test.dart';

void main() {
  test('removes only the explicit legacy Sync key allowlist', () async {
    final store = _MemoryStore({
      OfflineSecureStorageCleanup.legacyDeviceIdentityKey: 'fake-device',
      '${OfflineSecureStorageCleanup.legacyGroupKeyPrefix}fake-group-a':
          'fake-group-key-a',
      '${OfflineSecureStorageCleanup.legacyGroupKeyPrefix}fake-group-b':
          'fake-group-key-b',
      'metadata.rawg.api_key': 'fake-rawg',
      'metadata.igdb.client_id': 'fake-igdb-id',
      'metadata.igdb.client_secret': 'fake-igdb-secret',
      'metadata.igdb.access_token': 'fake-igdb-token',
      'media.steamgriddb.api_key': 'fake-steamgriddb',
      'unknown.key': 'must-stay',
    });

    final removed = await OfflineSecureStorageCleanup(store).run();

    expect(removed, 3);
    expect(store.values, {
      'metadata.rawg.api_key': 'fake-rawg',
      'metadata.igdb.client_id': 'fake-igdb-id',
      'metadata.igdb.client_secret': 'fake-igdb-secret',
      'metadata.igdb.access_token': 'fake-igdb-token',
      'media.steamgriddb.api_key': 'fake-steamgriddb',
      'unknown.key': 'must-stay',
    });
  });

  test('is idempotent when legacy keys no longer exist', () async {
    final store = _MemoryStore({'unknown.key': 'must-stay'});
    final cleanup = OfflineSecureStorageCleanup(store);

    expect(await cleanup.run(), 0);
    expect(await cleanup.run(), 0);
    expect(store.values, {'unknown.key': 'must-stay'});
  });

  test('reports storage failures without including stored values', () async {
    final cleanup = OfflineSecureStorageCleanup(_FailingStore());

    await expectLater(
      cleanup.run(),
      throwsA(
        isA<OfflineSecureStorageCleanupException>().having(
          (error) => error.toString(),
          'message',
          isNot(contains('sensitive-test-value')),
        ),
      ),
    );
  });
}

class _MemoryStore implements OfflineSecureKeyValueStore {
  _MemoryStore(Map<String, String> values) : values = Map.of(values);

  final Map<String, String> values;

  @override
  Future<void> delete(String key) async {
    values.remove(key);
  }

  @override
  Future<Map<String, String>> readAll() async => Map.of(values);
}

class _FailingStore implements OfflineSecureKeyValueStore {
  @override
  Future<void> delete(String key) async {
    throw StateError('sensitive-test-value');
  }

  @override
  Future<Map<String, String>> readAll() async {
    throw StateError('sensitive-test-value');
  }
}
