import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../metadata/application/metadata_providers.dart';
import '../../metadata/data/metadata_api_key_storage.dart';
import '../data/media_repository.dart';
import '../data/steamgriddb_media_provider.dart';
import '../domain/media_provider.dart';
import 'media_use_cases.dart';

final steamGridDbMediaProvider = Provider<MediaProvider>((ref) {
  return SteamGridDbMediaProvider(
    apiKeyStorage: ref.watch(metadataApiKeyStorageProvider),
    httpClient: ref.watch(metadataHttpClientProvider),
  );
});

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
