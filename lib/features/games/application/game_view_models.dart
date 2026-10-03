import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../catalogs/application/catalog_controller.dart';
import '../../media/application/media_providers.dart';
import '../../media/application/media_use_cases.dart';
import '../../media/domain/media_asset_models.dart';
import '../../playthroughs/application/completion_form_model.dart';
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
    request.completion?.validate();
    final completion = request.completion;
    final model = GameFormModel(
      entryId: request.model.entryId,
      gameId: request.model.gameId,
      title: request.model.title,
      sortTitle: request.model.sortTitle,
      releaseDate: request.model.releaseDate,
      type: request.model.type,
      status: request.model.status,
      isCompleted: completion != null || request.model.isCompleted,
      completedAt:
          completion != null
              ? completion.completedAt
              : request.model.completedAt,
      hoursPlayed:
          completion != null
              ? completion.hoursPlayed
              : request.model.hoursPlayed,
      playedPlatformId:
          completion != null
              ? completion.platformId
              : request.model.playedPlatformId,
      personalRating: completion?.rating ?? request.model.personalRating,
      personalNotes: completion?.notes ?? request.model.personalNotes,
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
    this.completion,
    this.cover,
  });

  final GameFormModel model;
  final Set<String> pendingPlatformNames;
  final Set<String> pendingGenreNames;
  final CompletionFormModel? completion;
  final ExternalMediaAsset? cover;
}

/// Coordinates game progress and playthrough actions outside presentation.
class GameDetailViewModel {
  const GameDetailViewModel({required GameRepository games}) : _games = games;

  final GameRepository _games;

  Future<void> markPlaying(String entryId) => _games.markPlaying(entryId);
  Future<void> markPaused(String entryId) => _games.markPaused(entryId);
  Future<void> markDropped(String entryId) => _games.markDropped(entryId);
  Future<void> markBacklog(String entryId) => _games.markBacklog(entryId);
  Future<void> complete(CompletionFormModel model) =>
      _games.completeGame(model);
  Future<void> deleteGame(String entryId) => _games.softDelete(entryId);
  Future<void> deleteGames(Iterable<String> entryIds) =>
      _games.softDeleteMany(entryIds);
}
