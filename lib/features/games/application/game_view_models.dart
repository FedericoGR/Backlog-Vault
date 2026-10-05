import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../catalogs/application/catalog_controller.dart';
import '../../media/application/media_providers.dart';
import '../../media/application/media_use_cases.dart';
import '../../media/domain/media_asset_models.dart';
import '../data/game_repository.dart';
import 'game_form_model.dart';
import 'library_game_details.dart';

final libraryGamesProvider =
    StreamProvider.autoDispose<List<LibraryGameDetails>>(
      (ref) => ref.watch(gameRepositoryProvider).watchLibrary(),
    );

final libraryGameProvider = FutureProvider.autoDispose
    .family<LibraryGameDetails?, String>(
      (ref, entryId) => ref.watch(gameRepositoryProvider).getByEntryId(entryId),
    );

final gameFormViewModelProvider = Provider<GameFormViewModel>((ref) {
  return GameFormViewModel(
    games: ref.watch(gameRepositoryProvider),
    catalogs: ref.watch(catalogControllerProvider),
    media: ref.watch(saveSelectedMediaAssetUseCaseProvider),
  );
});

final gameDetailViewModelProvider = Provider<GameDetailViewModel>((ref) {
  return GameDetailViewModel(games: ref.watch(gameRepositoryProvider));
});

/// Coordinates catalog resolution, persistence, completion and cover storage.
class GameFormViewModel {
  const GameFormViewModel({
    required GameRepository games,
    required CatalogController catalogs,
    required SaveSelectedMediaAssetUseCase media,
  }) : _games = games,
       _catalogs = catalogs,
       _media = media;

  final GameRepository _games;
  final CatalogController _catalogs;
  final SaveSelectedMediaAssetUseCase _media;

  Future<String> save(GameFormSaveRequest request) async {
    final platformIds =
        {
          ...request.model.platformIds,
          for (final name in request.pendingPlatformNames)
            await _catalogs.createPlatform(name),
        }.toList();
    final genreIds =
        {
          ...request.model.genreIds,
          for (final name in request.pendingGenreNames)
            await _catalogs.createGenre(name),
        }.toList();
    final model = GameFormModel(
      entryId: request.model.entryId,
      gameId: request.model.gameId,
      title: request.model.title,
      sortTitle: request.model.sortTitle,
      releaseDate: request.model.releaseDate,
      type: request.model.type,
      isCompleted: request.model.isCompleted,
      completedAt: request.model.completedAt,
      playedYear: request.model.playedYear,
      hoursPlayed: request.model.hoursPlayed,
      playedPlatformId: request.model.playedPlatformId,
      personalRating: request.model.personalRating,
      personalNotes: request.model.personalNotes,
      platformIds: platformIds,
      genreIds: genreIds,
    );
    final entryId = await _games.save(model);
    if (request.cover case final cover?) {
      final saved = await _games.getByEntryId(entryId);
      final gameId = saved?.game.id ?? request.model.gameId;
      if (gameId != null) {
        await _media.fromRemoteCover(gameId: gameId, asset: cover);
      }
    }
    return entryId;
  }
}

class GameFormSaveRequest {
  const GameFormSaveRequest({
    required this.model,
    this.pendingPlatformNames = const {},
    this.pendingGenreNames = const {},
    this.cover,
  });

  final GameFormModel model;
  final Set<String> pendingPlatformNames;
  final Set<String> pendingGenreNames;
  final ExternalMediaAsset? cover;
}

/// Coordinates game deletion outside presentation.
class GameDetailViewModel {
  const GameDetailViewModel({required GameRepository games}) : _games = games;

  final GameRepository _games;

  Future<void> deleteGame(String entryId) => _games.softDelete(entryId);
}
