import 'package:backlog_vault/features/catalogs/application/catalog_controller.dart';
import 'package:backlog_vault/features/games/application/game_form_model.dart';
import 'package:backlog_vault/features/games/application/game_view_models.dart';
import 'package:backlog_vault/features/games/data/game_repository.dart';
import 'package:backlog_vault/features/media/application/media_use_cases.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockGames extends Mock implements GameRepository {}

class _MockCatalogs extends Mock implements CatalogController {}

class _MockMedia extends Mock implements SaveSelectedMediaAssetUseCase {}

void main() {
  late _MockGames games;
  late _MockCatalogs catalogs;
  late GameFormViewModel viewModel;

  setUpAll(() {
    registerFallbackValue(
      const GameFormModel(title: 'fallback', isCompleted: false),
    );
  });

  setUp(() {
    games = _MockGames();
    catalogs = _MockCatalogs();
    viewModel = GameFormViewModel(
      games: games,
      catalogs: catalogs,
      media: _MockMedia(),
    );
  });

  test('save resolves pending catalogs before one game write', () async {
    when(
      () => catalogs.createPlatform('Steam Deck'),
    ).thenAnswer((_) async => 'platform-steam-deck');
    when(
      () => catalogs.createGenre('RPG'),
    ).thenAnswer((_) async => 'genre-rpg');
    when(() => games.save(any())).thenAnswer((_) async => 'entry-1');

    final entryId = await viewModel.save(
      const GameFormSaveRequest(
        model: GameFormModel(
          title: 'Hades',
          isCompleted: false,
          playedYear: 2026,
          platformIds: ['pc'],
        ),
        pendingPlatformNames: {'Steam Deck'},
        pendingGenreNames: {'RPG'},
      ),
    );

    expect(entryId, 'entry-1');
    final saved = verify(() => games.save(captureAny())).captured.single;
    expect(saved, isA<GameFormModel>());
    expect(
      (saved as GameFormModel).platformIds,
      containsAll(['pc', 'platform-steam-deck']),
    );
    expect(saved.genreIds, ['genre-rpg']);
    expect(saved.playedYear, 2026);
  });

  test('save propagates persistence errors as a controlled failed future', () {
    when(() => games.save(any())).thenThrow(StateError('write failed'));

    expect(
      viewModel.save(
        const GameFormSaveRequest(
          model: GameFormModel(title: 'Hades', isCompleted: false),
        ),
      ),
      throwsStateError,
    );
  });
}
