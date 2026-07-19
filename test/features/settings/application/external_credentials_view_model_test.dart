import 'package:backlog_vault/features/metadata/data/metadata_api_key_storage.dart';
import 'package:backlog_vault/features/settings/application/external_credentials_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/test.dart';

void main() {
  test('state exposes presence but never credential values', () async {
    final storage = _MemoryCredentialStorage(rawg: 'secret', steam: 'secret');
    final container = ProviderContainer(
      overrides: [metadataApiKeyStorageProvider.overrideWithValue(storage)],
    );
    addTearDown(container.dispose);

    final state = await container.read(externalCredentialsProvider.future);

    expect(state.rawgConfigured, isTrue);
    expect(state.igdbConfigured, isFalse);
    expect(state.steamGridDbConfigured, isTrue);
    expect(state.toString(), isNot(contains('secret')));
  });

  test('actions update immutable configuration state', () async {
    final storage = _MemoryCredentialStorage();
    final container = ProviderContainer(
      overrides: [metadataApiKeyStorageProvider.overrideWithValue(storage)],
    );
    addTearDown(container.dispose);
    await container.read(externalCredentialsProvider.future);

    await container
        .read(externalCredentialsProvider.notifier)
        .saveIgdb('client', 'secret');
    expect(
      container.read(externalCredentialsProvider).requireValue.igdbConfigured,
      isTrue,
    );

    await container.read(externalCredentialsProvider.notifier).deleteAll();
    final state = container.read(externalCredentialsProvider).requireValue;
    expect(state.rawgConfigured, isFalse);
    expect(state.igdbConfigured, isFalse);
    expect(state.steamGridDbConfigured, isFalse);
  });
}

class _MemoryCredentialStorage implements MetadataApiKeyStorage {
  _MemoryCredentialStorage({this.rawg, this.steam});

  String? rawg;
  String? steam;
  String? clientId;
  String? clientSecret;
  IgdbCachedToken? token;

  @override
  Future<void> deleteAllExternalApiKeys() async {
    rawg = steam = clientId = clientSecret = null;
    token = null;
  }

  @override
  Future<void> deleteIgdbAccessToken() async => token = null;
  @override
  Future<void> deleteIgdbClientId() async => clientId = null;
  @override
  Future<void> deleteIgdbClientSecret() async => clientSecret = null;
  @override
  Future<void> deleteRawgApiKey() async => rawg = null;
  @override
  Future<void> deleteSteamGridDbApiKey() async => steam = null;
  @override
  Future<IgdbCachedToken?> readIgdbAccessToken() async => token;
  @override
  Future<String?> readIgdbClientId() async => clientId;
  @override
  Future<String?> readIgdbClientSecret() async => clientSecret;
  @override
  Future<String?> readRawgApiKey() async => rawg;
  @override
  Future<String?> readSteamGridDbApiKey() async => steam;
  @override
  Future<void> saveIgdbAccessToken(IgdbCachedToken value) async =>
      token = value;
  @override
  Future<void> saveIgdbClientId(String value) async => clientId = value;
  @override
  Future<void> saveIgdbClientSecret(String value) async => clientSecret = value;
  @override
  Future<void> saveRawgApiKey(String value) async => rawg = value;
  @override
  Future<void> saveSteamGridDbApiKey(String value) async => steam = value;
}
