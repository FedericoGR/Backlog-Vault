import 'package:go_router/go_router.dart';
import 'package:backlog_vault/features/games/application/game_form_model.dart';
import 'package:backlog_vault/app/theme/app_theme.dart';
import 'package:backlog_vault/features/catalogs/application/catalog_controller.dart';
import 'package:backlog_vault/features/catalogs/domain/catalog_item.dart';
import 'package:backlog_vault/features/games/application/library_game_details.dart';
import 'package:backlog_vault/features/games/data/game_repository.dart';
import 'package:backlog_vault/features/games/presentation/game_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCatalogController extends Mock implements CatalogController {}

class _MockGameRepository extends Mock implements GameRepository {}

void main() {
  late _MockCatalogController catalogRepository;
  late _MockGameRepository gameRepository;

  setUpAll(() => registerFallbackValue(const GameFormModel(title: 'fallback')));

  setUp(() {
    catalogRepository = _MockCatalogController();
    gameRepository = _MockGameRepository();
    when(
      () => catalogRepository.watchPlatforms(),
    ).thenAnswer((_) => Stream.value(_platforms));
    when(
      () => catalogRepository.watchGenres(),
    ).thenAnswer((_) => Stream.value(_genres));
  });

  testWidgets('completed edit preloads and saves exactly one personal record', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1500, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    when(
      () => gameRepository.getByEntryId('entry-1'),
    ).thenAnswer((_) async => _details());
    // Persisted PS4 remains selected even when removed from the active catalog.
    when(
      () => catalogRepository.watchPlatforms(),
    ).thenAnswer((_) => Stream.value([_platforms.first]));
    when(() => gameRepository.save(any())).thenAnswer((_) async => 'entry-1');
    final router = GoRouter(
      initialLocation: '/games/entry-1/edit',
      routes: [
        GoRoute(
          path: '/games/:id/edit',
          builder: (_, _) => const GameFormPage(entryId: 'entry-1'),
        ),
        GoRoute(
          path: '/games/:id',
          builder: (_, _) => const Scaffold(body: Text('Saved')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          catalogControllerProvider.overrideWith((ref) => catalogRepository),
          gameRepositoryProvider.overrideWith((ref) => gameRepository),
        ],
        child: MaterialApp.router(
          theme: buildBacklogVaultDarkTheme(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isTrue,
    );
    expect(find.text('Fecha de completado'), findsOneWidget);
    expect(find.text('Horas jugadas'), findsOneWidget);
    expect(find.text('Jugado en'), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<int?>), findsOneWidget);
    expect(
      tester
          .widget<DropdownButtonFormField<int?>>(
            find.byType(DropdownButtonFormField<int?>),
          )
          .initialValue,
      3,
    );
    final played = find.ancestor(
      of: find.text('Jugado en'),
      matching: find.byType(DropdownButtonFormField<String?>),
    );
    expect(
      tester.widget<DropdownButtonFormField<String?>>(played).initialValue,
      'ps4',
    );
    final hours = find.ancestor(
      of: find.text('Horas jugadas'),
      matching: find.byType(TextFormField),
    );
    expect(tester.widget<TextFormField>(hours).controller!.text, '42.5');
    expect(find.text('20-08-2026'), findsOneWidget);
    expect(find.text('Strong DLC.'), findsOneWidget);
    for (final label in [
      'Puntaje de partida',
      'Nueva partida',
      'Editar partida',
      'Jugando',
      'Pausar',
    ]) {
      expect(find.textContaining(label), findsNothing);
    }
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    final saved =
        verify(() => gameRepository.save(captureAny())).captured.single
            as GameFormModel;
    expect(saved.isCompleted, isTrue);
    expect(saved.completedAt, DateTime(2026, 8, 20));
    expect(saved.hoursPlayed, 42.5);
    expect(saved.playedPlatformId, 'ps4');
    expect(saved.personalRating, 3);
    expect(saved.personalNotes, 'Strong DLC.');
    expect(saved.platformIds, ['pc']);
    expect(find.text('Saved'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('GameFormPage renders create sections without overflow', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          catalogControllerProvider.overrideWith((ref) => catalogRepository),
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
          catalogControllerProvider.overrideWith((ref) => catalogRepository),
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
      find.text('Registro personal'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Registro personal'), findsOneWidget);
    expect(find.textContaining('Portada pendiente'), findsNothing);
    expect(find.text('Editar juego'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'GameFormPage handles many platforms and genres on android viewport',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      when(
        () => catalogRepository.watchPlatforms(),
      ).thenAnswer((_) => Stream.value(_densePlatforms));
      when(
        () => catalogRepository.watchGenres(),
      ).thenAnswer((_) => Stream.value(_denseGenres));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            catalogControllerProvider.overrideWith((ref) => catalogRepository),
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
        find.text('Géneros'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.scrollUntilVisible(
        find.text('Guardar'),
        300,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Plataformas'), findsOneWidget);
      expect(find.text('Géneros'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

final _now = DateTime(2026, 6, 16);

final _platforms = [
  CatalogItem(
    id: 'pc',
    name: 'PC',
    createdAt: _now,
    updatedAt: _now,
    deletedAt: null,
  ),
  CatalogItem(
    id: 'ps4',
    name: 'PS4',
    createdAt: _now,
    updatedAt: _now,
    deletedAt: null,
  ),
];

final _genres = [
  CatalogItem(
    id: 'action',
    name: 'Acción',
    createdAt: _now,
    updatedAt: _now,
    deletedAt: null,
  ),
  CatalogItem(
    id: 'adventure',
    name: 'Aventura',
    createdAt: _now,
    updatedAt: _now,
    deletedAt: null,
  ),
];

final _densePlatforms = List.generate(
  14,
  (index) => CatalogItem(
    id: 'platform-$index',
    name: 'Platform $index With Long Name',
    createdAt: _now,
    updatedAt: _now,
    deletedAt: null,
  ),
);

final _denseGenres = List.generate(
  18,
  (index) => CatalogItem(
    id: 'genre-$index',
    name: 'Genre $index With Long Label',
    createdAt: _now,
    updatedAt: _now,
    deletedAt: null,
  ),
);

LibraryGameDetails _details() {
  return LibraryGameDetails(
    game: GameDetails(
      id: 'game-1',
      title: 'The Last of Us: Left Behind',
      sortTitle: null,
      releaseDate: DateTime(2014, 2, 14),
      type: 'single_player',
      createdAt: _now,
      updatedAt: _now,
      deletedAt: null,
    ),
    entry: LibraryEntryDetails(
      id: 'entry-1',
      gameId: 'game-1',
      isCompleted: true,
      completedAt: DateTime(2026, 8, 20),
      hoursPlayed: 42.5,
      playedPlatformId: 'ps4',
      personalRating: 3,
      personalNotes: 'Strong DLC.',
      createdAt: _now,
      updatedAt: _now,
      deletedAt: null,
    ),
    platforms: [_platforms.first],
    playedPlatform: CatalogItem(id: 'ps4', name: 'PS4', deletedAt: _now),
    genres: _genres,
  );
}
