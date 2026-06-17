import 'package:backlog_vault/app/theme.dart';
import 'package:backlog_vault/core/database/app_database.dart';
import 'package:backlog_vault/features/catalogs/data/catalog_repository.dart';
import 'package:backlog_vault/features/games/application/library_game_details.dart';
import 'package:backlog_vault/features/games/data/game_repository.dart';
import 'package:backlog_vault/features/games/presentation/game_form_page.dart';
import 'package:backlog_vault/features/library/domain/game_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCatalogRepository extends Mock implements CatalogRepository {}

class _MockGameRepository extends Mock implements GameRepository {}

void main() {
  late _MockCatalogRepository catalogRepository;
  late _MockGameRepository gameRepository;

  setUp(() {
    catalogRepository = _MockCatalogRepository();
    gameRepository = _MockGameRepository();
    when(
      () => catalogRepository.watchPlatforms(),
    ).thenAnswer((_) => Stream.value(_platforms));
    when(
      () => catalogRepository.watchGenres(),
    ).thenAnswer((_) => Stream.value(_genres));
  });

  testWidgets('GameFormPage renders create sections without overflow', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          catalogRepositoryProvider.overrideWith((ref) => catalogRepository),
          gameRepositoryProvider.overrideWith((ref) => gameRepository),
        ],
        child: MaterialApp(
          theme: buildBacklogVaultDarkTheme(),
          home: const GameFormPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Guardar'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.byType(GameFormPage), findsOneWidget);
    expect(find.byType(Scrollable), findsWidgets);
    expect(find.text('Guardar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('GameFormPage renders edit mode on small viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    when(
      () => gameRepository.getByEntryId('entry-1'),
    ).thenAnswer((_) async => _details());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          catalogRepositoryProvider.overrideWith((ref) => catalogRepository),
          gameRepositoryProvider.overrideWith((ref) => gameRepository),
        ],
        child: MaterialApp(
          theme: buildBacklogVaultDarkTheme(),
          home: const GameFormPage(entryId: 'entry-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Completado / partida'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Completado / partida'), findsOneWidget);
    expect(find.textContaining('Portada pendiente'), findsNothing);
    expect(find.text('Completado'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}

final _now = DateTime(2026, 6, 16);

final _platforms = [
  Platform(
    id: 'pc',
    name: 'PC',
    createdAt: _now,
    updatedAt: _now,
    deletedAt: null,
  ),
  Platform(
    id: 'ps4',
    name: 'PS4',
    createdAt: _now,
    updatedAt: _now,
    deletedAt: null,
  ),
];

final _genres = [
  Genre(
    id: 'action',
    name: 'Acción',
    createdAt: _now,
    updatedAt: _now,
    deletedAt: null,
  ),
  Genre(
    id: 'adventure',
    name: 'Aventura',
    createdAt: _now,
    updatedAt: _now,
    deletedAt: null,
  ),
];

LibraryGameDetails _details() {
  return LibraryGameDetails(
    game: Game(
      id: 'game-1',
      title: 'The Last of Us: Left Behind',
      sortTitle: null,
      releaseDate: DateTime(2014, 2, 14),
      type: 'single_player',
      createdAt: _now,
      updatedAt: _now,
      deletedAt: null,
    ),
    entry: LibraryEntry(
      id: 'entry-1',
      gameId: 'game-1',
      status: GameStatus.completed.name,
      personalRating: 3,
      personalNotes: 'Strong DLC.',
      createdAt: _now,
      updatedAt: _now,
      deletedAt: null,
    ),
    platforms: _platforms,
    genres: _genres,
    playthroughs: const [],
  );
}
