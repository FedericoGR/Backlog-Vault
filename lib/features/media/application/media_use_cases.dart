import '../../../core/database/app_database.dart';
import '../data/media_repository.dart';
import '../domain/media_asset_models.dart';
import '../domain/media_provider.dart';

class SearchMediaGamesUseCase {
  const SearchMediaGamesUseCase(this._provider);

  final MediaProvider _provider;

  Future<List<MediaSearchCandidate>> call(String query) {
    return _provider.searchGames(query);
  }
}

class SearchCoverAssetsUseCase {
  const SearchCoverAssetsUseCase(this._provider);

  final MediaProvider _provider;

  Future<List<ExternalMediaAsset>> call(String externalGameId) {
    return _provider.searchCoverAssets(externalGameId);
  }
}

class SaveSelectedMediaAssetUseCase {
  const SaveSelectedMediaAssetUseCase(this._repository);

  final MediaRepository _repository;

  Future<MediaAsset> fromRemoteCover({
    required String gameId,
    required ExternalMediaAsset asset,
  }) {
    return _repository.saveRemoteCover(gameId: gameId, asset: asset);
  }

  Future<MediaAsset> fromLocalFile({
    required String gameId,
    required String sourcePath,
  }) {
    return _repository.saveLocalCover(gameId: gameId, sourcePath: sourcePath);
  }
}

class DeleteMediaAssetUseCase {
  const DeleteMediaAssetUseCase(this._repository);

  final MediaRepository _repository;

  Future<void> call(String mediaAssetId) {
    return _repository.softDelete(mediaAssetId);
  }
}
