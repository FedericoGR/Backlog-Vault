import 'package:go_router/go_router.dart';
import 'package:backlog_vault/features/games/presentation/widgets/personal_rating_field.dart';
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
import 'package:backlog_vault/features/metadata/application/metadata_providers.dart';
import 'package:backlog_vault/features/metadata/domain/metadata_provider.dart';
import 'package:backlog_vault/features/metadata/domain/metadata_search_candidate.dart';
import 'package:backlog_vault/features/metadata/domain/external_game_details.dart';

class _MockCatalogController extends Mock implements CatalogController {}

class _MockGameRepository extends Mock implements GameRepository {}

class _MockMetadataProvider extends Mock implements MetadataProvider {}

void main() {
  late _MockCatalogController catalogs;
  late _MockGameRepository games;
  setUpAll(() => registerFallbackValue(const GameFormModel(title: 'fallback')));
  setUp(() {
    catalogs = _MockCatalogController();
    games = _MockGameRepository();
    when(
      () => catalogs.watchPlatforms(),
    ).thenAnswer((_) => Stream.value(_platforms));
    when(() => catalogs.watchGenres()).thenAnswer((_) => Stream.value(_genres));
    when(() => games.save(any())).thenAnswer((_) async => 'entry-1');
  });

  Future<void> open(
    WidgetTester tester, {
    bool? completed,
    MetadataProvider? metadata,
    Size size = const Size(1500, 1800),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    if (completed != null) {
      when(
        () => games.getByEntryId('entry-1'),
      ).thenAnswer((_) async => _details(completed: completed));
    }
    final router = GoRouter(
      initialLocation: '/form',
      routes: [
        GoRoute(
          path: '/form',
          builder:
              (_, _) => GameFormPage(
                entryId: completed == null ? null : 'entry-1',
                initialPlayedYear: 2026,
              ),
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
          catalogControllerProvider.overrideWith((ref) => catalogs),
          gameRepositoryProvider.overrideWith((ref) => games),
          if (metadata != null)
            metadataProviderListProvider.overrideWithValue([metadata]),
        ],
        child: MaterialApp.router(
          theme: buildBacklogVaultDarkTheme(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder field(String key) => find.byKey(ValueKey(key));
  String value(WidgetTester tester, String key) =>
      tester.widget<TextFormField>(field(key)).controller!.text;
  Future<GameFormModel> save(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Guardar'));
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('Saved'), findsOneWidget);
    expect(tester.takeException(), isNull);
    return verify(() => games.save(captureAny())).captured.single
        as GameFormModel;
  }

  Future<void> selectPlatform(WidgetTester tester, String name) async {
    await tester.ensureVisible(field('played-platform-field'));
    await tester.tap(field('played-platform-field'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(name).last);
    await tester.pumpAndSettle();
  }

  for (final completed in [false, true]) {
    testWidgets(
      'edit isCompleted=$completed preloads and preserves every personal field',
      (tester) async {
        // Archived played platform must stay selected even outside the active catalog.
        when(
          () => catalogs.watchPlatforms(),
        ).thenAnswer((_) => Stream.value([_platforms.first]));
        await open(tester, completed: completed);
        expect(
          tester
              .widget<SegmentedButton<bool>>(
                find.byKey(const ValueKey('completion-state')),
              )
              .selected
              .single,
          completed,
        );
        expect(value(tester, 'played-year-field'), '2025');
        expect(value(tester, 'hours-field'), '42.5');
        expect(value(tester, 'notes-field'), 'Strong DLC.');
        expect(
          tester
              .widget<PersonalRatingField>(find.byType(PersonalRatingField))
              .value,
          3,
        );
        expect(
          tester
              .widget<DropdownButtonFormField<String?>>(
                field('played-platform-field'),
              )
              .initialValue,
          'ps4',
        );
        expect(
          find.text('20-08-2026'),
          completed ? findsOneWidget : findsNothing,
        );
        expect(find.text('Mi registro'), findsOneWidget);
        expect(find.byType(PersonalRatingField), findsOneWidget);
        expect(find.text('Biblioteca personal'), findsNothing);
        expect(find.text('Registro personal'), findsNothing);
        expect(find.text('Plataformas'), findsNothing);
        for (final label in [
          'Nueva partida',
          'Partidas',
          'Jugando',
          'Pausar',
          'Abandonar',
          'Retirado',
          'Pendiente',
          'Puntaje de partida',
        ]) {
          expect(find.textContaining(label), findsNothing);
        }
        final saved = await save(tester);
        expect(saved.isCompleted, completed);
        expect(saved.playedYear, 2025);
        expect(saved.completedAt, DateTime(2026, 8, 20));
        expect(saved.hoursPlayed, 42.5);
        expect(saved.playedPlatformId, 'ps4');
        expect(saved.personalRating, 3);
        expect(saved.personalNotes, 'Strong DLC.');
        expect(saved.platformIds, ['pc']);
        expect(saved.genreIds, ['action', 'adventure']);
        expect(saved.releaseDate, DateTime(2014, 2, 14));
        expect(saved.type, 'single_player');
        expect(saved.sortTitle, 'Last of Us');
      },
    );

    testWidgets(
      'creates isCompleted=$completed with optional date and all other personal fields',
      (tester) async {
        await open(tester);
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nombre'),
          'My game',
        );
        await tester.enterText(field('played-year-field'), '2024');
        await tester.enterText(field('hours-field'), '18.5');
        await selectPlatform(tester, 'PS4');
        await tester.tap(field('rating-4'));
        await tester.enterText(field('notes-field'), 'My own notes');
        if (completed) await tester.tap(find.text('Terminado'));
        await tester.pumpAndSettle();
        final saved = await save(tester);
        expect(saved.isCompleted, completed);
        expect(saved.playedYear, 2024);
        expect(saved.completedAt, isNull);
        expect(saved.hoursPlayed, 18.5);
        expect(saved.playedPlatformId, 'ps4');
        expect(saved.personalRating, 4);
        expect(saved.personalNotes, 'My own notes');
        expect(saved.platformIds, isEmpty);
      },
    );

    testWidgets(
      'toggling from isCompleted=$completed keeps completion data through repeated changes',
      (tester) async {
        await open(tester, completed: completed);
        for (var i = 0; i < 3; i++) {
          final selected =
              tester
                  .widget<SegmentedButton<bool>>(
                    find.byKey(const ValueKey('completion-state')),
                  )
                  .selected
                  .single;
          await tester.tap(find.text(selected ? 'No terminado' : 'Terminado'));
          await tester.pumpAndSettle();
        }
        expect(
          find.text('20-08-2026'),
          completed ? findsNothing : findsOneWidget,
        );
        final saved = await save(tester);
        expect(saved.isCompleted, !completed);
        expect(saved.completedAt, DateTime(2026, 8, 20));
        expect(saved.playedYear, 2025);
        expect(saved.hoursPlayed, 42.5);
        expect(saved.playedPlatformId, 'ps4');
        expect(saved.personalRating, 3);
        expect(saved.personalNotes, 'Strong DLC.');
      },
    );
  }

  testWidgets(
    'edits year, hours, personal platform, rating and notes independently of catalog',
    (tester) async {
      await open(tester, completed: false);
      await tester.enterText(field('played-year-field'), '2023');
      await tester.enterText(field('hours-field'), '19,5');
      await selectPlatform(tester, 'PC');
      await tester.tap(field('rating-5'));
      await tester.enterText(field('notes-field'), 'Updated notes');
      final saved = await save(tester);
      expect(saved.isCompleted, isFalse);
      expect(saved.playedYear, 2023);
      expect(saved.hoursPlayed, 19.5);
      expect(saved.playedPlatformId, 'pc');
      expect(saved.personalRating, 5);
      expect(saved.personalNotes, 'Updated notes');
      expect(saved.platformIds, ['pc']);
      expect(saved.completedAt, DateTime(2026, 8, 20));
    },
  );

  testWidgets('rating can be changed and cleared without a secondary source', (
    tester,
  ) async {
    await open(tester, completed: true);
    await tester.tap(field('rating-1'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<PersonalRatingField>(find.byType(PersonalRatingField))
          .value,
      1,
    );
    await tester.tap(field('clear-rating'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<PersonalRatingField>(find.byType(PersonalRatingField))
          .value,
      isNull,
    );
    expect(find.byIcon(Icons.star_border), findsNWidgets(5));
    expect((await save(tester)).personalRating, isNull);
  });

  testWidgets('completion date can be edited', (tester) async {
    await open(tester, completed: true);
    await tester.tap(find.text('Elegir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('21'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect((await save(tester)).completedAt, DateTime(2026, 8, 21));
  });

  testWidgets(
    'search fills catalog and title while personal fields remain independent',
    (tester) async {
      final provider = _MockMetadataProvider();
      when(() => provider.providerId).thenReturn('igdb');
      when(() => provider.displayName).thenReturn('IGDB');
      when(() => provider.requiresApiKey).thenReturn(false);
      when(() => provider.searchGames('hades')).thenAnswer(
        (_) async => [
          const MetadataSearchCandidate(
            providerId: 'igdb',
            providerName: 'IGDB',
            externalId: '1',
            title: 'Hades',
          ),
        ],
      );
      when(() => provider.getGameDetails('1')).thenAnswer(
        (_) async => ExternalGameDetails(
          providerId: 'igdb',
          providerName: 'IGDB',
          externalId: '1',
          title: 'Hades',
          releaseDate: DateTime(2020, 9, 17),
          type: 'game',
          platforms: const ['PC'],
          genres: const ['Acción'],
        ),
      );
      await open(tester, metadata: provider);
      await tester.enterText(field('hours-field'), '18');
      await tester.enterText(field('notes-field'), 'My experience');
      await tester.tap(field('rating-4'));
      await tester.tap(find.text('Buscar juego'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Buscar por título'),
        'hades',
      );
      await tester.tap(find.byTooltip('Buscar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hades'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Aplicar al formulario'));
      await tester.pumpAndSettle();
      expect(find.text('Hades'), findsOneWidget);
      expect(find.text('Plataformas'), findsNothing);
      final saved = await save(tester);
      expect(saved.title, 'Hades');
      expect(saved.releaseDate, DateTime(2020, 9, 17));
      expect(saved.type, 'game');
      expect(saved.platformIds, ['pc']);
      expect(saved.genreIds, ['action']);
      expect(saved.playedPlatformId, isNull);
      expect(saved.playedYear, 2026);
      expect(saved.hoursPlayed, 18);
      expect(saved.personalRating, 4);
      expect(saved.personalNotes, 'My experience');
      expect(saved.isCompleted, isFalse);
    },
  );

  testWidgets(
    'selecting catalog platform does not set personally played platform',
    (tester) async {
      await open(tester);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nombre'),
        'Manual game',
      );
      await tester.ensureVisible(find.text('Información del juego'));
      await tester.tap(find.text('Información del juego'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.widgetWithText(FilterChip, 'PC'));
      await tester.tap(find.widgetWithText(FilterChip, 'PC'));
      await tester.pumpAndSettle();
      final saved = await save(tester);
      expect(saved.platformIds, ['pc']);
      expect(saved.playedPlatformId, isNull);
      expect(saved.personalRating, isNull);
    },
  );

  testWidgets(
    'mobile edit keeps one personal section and secondary catalog accessible',
    (tester) async {
      await open(tester, completed: true, size: const Size(390, 844));
      await tester.scrollUntilVisible(
        find.text('Mi registro'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Mi registro'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Guardar'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('dense catalog remains editable on a narrow viewport', (
    tester,
  ) async {
    when(
      () => catalogs.watchPlatforms(),
    ).thenAnswer((_) => Stream.value(_densePlatforms));
    when(
      () => catalogs.watchGenres(),
    ).thenAnswer((_) => Stream.value(_denseGenres));
    await open(tester, size: const Size(390, 844));
    await tester.scrollUntilVisible(
      find.text('Información del juego'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Información del juego'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Géneros'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Géneros'), findsOneWidget);
    expect(find.byType(FilterChip), findsNWidgets(32));
    expect(tester.takeException(), isNull);
  });
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

LibraryGameDetails _details({bool completed = true}) {
  return LibraryGameDetails(
    game: GameDetails(
      id: 'game-1',
      title: 'The Last of Us: Left Behind',
      sortTitle: 'Last of Us',
      releaseDate: DateTime(2014, 2, 14),
      type: 'single_player',
      createdAt: _now,
      updatedAt: _now,
      deletedAt: null,
    ),
    entry: LibraryEntryDetails(
      id: 'entry-1',
      gameId: 'game-1',
      isCompleted: completed,
      completedAt: DateTime(2026, 8, 20),
      playedYear: 2025,
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
