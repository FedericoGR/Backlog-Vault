import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../metadata/data/metadata_api_key_storage.dart';

final externalCredentialsProvider = AsyncNotifierProvider<
  ExternalCredentialsViewModel,
  ExternalCredentialsState
>(ExternalCredentialsViewModel.new);

/// Exposes only credential presence; secret values never enter UI state.
class ExternalCredentialsViewModel
    extends AsyncNotifier<ExternalCredentialsState> {
  MetadataApiKeyStorage get _storage => ref.read(metadataApiKeyStorageProvider);

  @override
  Future<ExternalCredentialsState> build() async {
    final values = await Future.wait([
      _storage.readRawgApiKey(),
      _storage.readIgdbClientId(),
      _storage.readIgdbClientSecret(),
      _storage.readSteamGridDbApiKey(),
    ]);
    return ExternalCredentialsState(
      rawgConfigured: values[0] != null,
      igdbConfigured: values[1] != null && values[2] != null,
      steamGridDbConfigured: values[3] != null,
    );
  }

  Future<void> saveRawg(String value) => _mutate(() async {
    await _storage.saveRawgApiKey(value);
  }, rawg: true);

  Future<void> deleteRawg() => _mutate(() async {
    await _storage.deleteRawgApiKey();
  }, rawg: false);

  Future<void> saveIgdb(String clientId, String clientSecret) =>
      _mutate(() async {
        await _storage.saveIgdbClientId(clientId);
        await _storage.saveIgdbClientSecret(clientSecret);
        await _storage.deleteIgdbAccessToken();
      }, igdb: true);

  Future<void> deleteIgdb() => _mutate(() async {
    await _storage.deleteIgdbClientId();
    await _storage.deleteIgdbClientSecret();
    await _storage.deleteIgdbAccessToken();
  }, igdb: false);

  Future<void> saveSteamGridDb(String value) => _mutate(() async {
    await _storage.saveSteamGridDbApiKey(value);
  }, steamGridDb: true);

  Future<void> deleteSteamGridDb() => _mutate(() async {
    await _storage.deleteSteamGridDbApiKey();
  }, steamGridDb: false);

  Future<void> deleteAll() => _mutate(
    () async {
      await _storage.deleteAllExternalApiKeys();
    },
    rawg: false,
    igdb: false,
    steamGridDb: false,
  );

  Future<void> _mutate(
    Future<void> Function() operation, {
    bool? rawg,
    bool? igdb,
    bool? steamGridDb,
  }) async {
    final previous = state.value ?? const ExternalCredentialsState();
    state = const AsyncLoading();
    try {
      await operation();
      state = AsyncData(
        previous.copyWith(
          rawgConfigured: rawg,
          igdbConfigured: igdb,
          steamGridDbConfigured: steamGridDb,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

class ExternalCredentialsState {
  const ExternalCredentialsState({
    this.rawgConfigured = false,
    this.igdbConfigured = false,
    this.steamGridDbConfigured = false,
  });

  final bool rawgConfigured;
  final bool igdbConfigured;
  final bool steamGridDbConfigured;

  ExternalCredentialsState copyWith({
    bool? rawgConfigured,
    bool? igdbConfigured,
    bool? steamGridDbConfigured,
  }) {
    return ExternalCredentialsState(
      rawgConfigured: rawgConfigured ?? this.rawgConfigured,
      igdbConfigured: igdbConfigured ?? this.igdbConfigured,
      steamGridDbConfigured:
          steamGridDbConfigured ?? this.steamGridDbConfigured,
    );
  }
}
