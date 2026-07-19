import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../metadata/application/metadata_providers.dart';
import '../../metadata/data/metadata_api_key_storage.dart';
import '../data/igdb_media_provider.dart';
import '../data/local_cover_picker_service.dart';
import '../data/media_repository.dart';
import '../data/steamgriddb_media_provider.dart';
import '../domain/media_asset_models.dart';
import '../domain/media_provider.dart';
import 'media_use_cases.dart';

final steamGridDbMediaProvider = Provider<MediaProvider>((ref) {
  return SteamGridDbMediaProvider(
    apiKeyStorage: ref.watch(metadataApiKeyStorageProvider),
    httpClient: ref.watch(metadataHttpClientProvider),
  );
});

final igdbMediaProvider = Provider<MediaProvider>((ref) {
  return IgdbMediaProvider(
    apiKeyStorage: ref.watch(metadataApiKeyStorageProvider),
    httpClient: ref.watch(metadataHttpClientProvider),
  );
});

final mediaProviderListProvider = Provider<List<MediaProvider>>((ref) {
  return [ref.watch(steamGridDbMediaProvider), ref.watch(igdbMediaProvider)];
});

final localCoverPickerProvider = Provider<LocalCoverPickerService>((ref) {
  return const LocalCoverPickerService();
});

final localMediaBytesProvider = FutureProvider.autoDispose
    .family<Uint8List?, String>((ref, localPath) async {
      try {
        return await ref
            .watch(mediaRepositoryProvider)
            .readLocalFileBytes(localPath);
      } on Exception {
        return null;
      }
    });

final mediaSearchViewModelProvider = Provider<MediaSearchViewModel>((ref) {
  return MediaSearchViewModel(
    saveRemote:
        ({required gameId, required asset}) => ref
            .read(saveSelectedMediaAssetUseCaseProvider)
            .fromRemoteCover(gameId: gameId, asset: asset),
    pickAndSaveLocal: (gameId) async {
      final path = await ref.read(localCoverPickerProvider).pickImagePath();
      if (path == null) return false;
      await ref
          .read(saveSelectedMediaAssetUseCaseProvider)
          .fromLocalFile(gameId: gameId, sourcePath: path);
      return true;
    },
  );
});

/// Coordinates provider search and local/remote cover selection.
class MediaSearchViewModel {
  const MediaSearchViewModel({
    required MediaRemoteSaver saveRemote,
    required MediaLocalPickerAndSaver pickAndSaveLocal,
  }) : _saveRemote = saveRemote,
       _pickAndSaveLocal = pickAndSaveLocal;

  final MediaRemoteSaver _saveRemote;
  final MediaLocalPickerAndSaver _pickAndSaveLocal;

  Future<List<MediaSearchCandidate>> searchGames(
    MediaProvider provider,
    String query,
  ) => SearchMediaGamesUseCase(provider).call(query);

  Future<List<ExternalMediaAsset>> searchCovers(
    MediaProvider provider,
    String externalGameId,
  ) => SearchCoverAssetsUseCase(provider).call(externalGameId);

  Future<void> saveRemote({
    required String gameId,
    required ExternalMediaAsset asset,
  }) => _saveRemote(gameId: gameId, asset: asset);

  Future<bool> pickAndSaveLocal(String gameId) => _pickAndSaveLocal(gameId);
}

typedef MediaRemoteSaver =
    Future<void> Function({
      required String gameId,
      required ExternalMediaAsset asset,
    });

typedef MediaLocalPickerAndSaver = Future<bool> Function(String gameId);

final searchMediaGamesUseCaseProvider = Provider<SearchMediaGamesUseCase>((
  ref,
) {
  return SearchMediaGamesUseCase(ref.watch(steamGridDbMediaProvider));
});

final searchCoverAssetsUseCaseProvider = Provider<SearchCoverAssetsUseCase>((
  ref,
) {
  return SearchCoverAssetsUseCase(ref.watch(steamGridDbMediaProvider));
});

final saveSelectedMediaAssetUseCaseProvider =
    Provider<SaveSelectedMediaAssetUseCase>((ref) {
      return SaveSelectedMediaAssetUseCase(ref.watch(mediaRepositoryProvider));
    });

final deleteMediaAssetUseCaseProvider = Provider<DeleteMediaAssetUseCase>((
  ref,
) {
  return DeleteMediaAssetUseCase(ref.watch(mediaRepositoryProvider));
});
