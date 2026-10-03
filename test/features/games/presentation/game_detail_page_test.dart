import 'dart:io';

import 'package:backlog_vault/app/theme/app_theme.dart';
import 'package:backlog_vault/features/catalogs/domain/catalog_item.dart';
import 'package:backlog_vault/features/games/application/library_game_details.dart';
import 'package:backlog_vault/features/games/data/game_repository.dart';
import 'package:backlog_vault/features/games/presentation/game_detail_page.dart';
import 'package:backlog_vault/features/media/data/media_repository.dart';
import 'package:backlog_vault/features/library/domain/game_status.dart';
import 'package:backlog_vault/features/playthroughs/application/completion_form_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGameRepository extends Mock implements GameRepository {}

class _MockMediaRepository extends Mock implements MediaRepository {}

void main() {
  late _MockGameRepository gameRepository;
  late _MockMediaRepository mediaRepository;

  setUp(() {
    gameRepository = _MockGameRepository();
    mediaRepository = _MockMediaRepository();
    when(
      () => mediaRepository.resolveLocalFile(any()),
    ).thenAnswer((_) async => File('Z:/backlog-vault-test/missing-cover.png'));
  });

  testWidgets('completion dialog can save without a date', (tester) async {
    registerFallbackValue(const CompletionFormModel(libraryEntryId: ''));
    when(
      () => gameRepository.getByEntryId('entry-2'),
    ).thenAnswer((_) async => _details(withCover: false));
    when(() => gameRepository.completeGame(any())).thenAnswer((_) async {});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameRepositoryProvider.overrideWith((ref) => gameRepository),
          mediaRepositoryProvider.overrideWith((ref) => mediaRepository),
        ],
        child: MaterialApp(
          theme: buildBacklogVaultDarkTheme(),
          home: const GameDetailPage(entryId: 'entry-2'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final button = find.widgetWithText(FilledButton, 'Completar');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    final date = find.widgetWithText(ListTile, 'Fecha de completado');
    expect(find.descendant(of: date, matching: find.text('-')), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Completar').last);
    await tester.pumpAndSettle();
    final saved =
        verify(() => gameRepository.completeGame(captureAny())).captured.single
            as CompletionFormModel;
    expect(saved.completedAt, isNull);
  });

  testWidgets('GameDetailPage renders with cover and without overflow', (
    tester,
  ) async {
    when(
      () => gameRepository.getByEntryId('entry-1'),
    ).thenAnswer((_) async => _details(withCover: true));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameRepositoryProvider.overrideWith((ref) => gameRepository),
          mediaRepositoryProvider.overrideWith((ref) => mediaRepository),
        ],
        child: MaterialApp(
          theme: buildBacklogVaultDarkTheme(),
          home: const Scaffold(body: GameDetailPage(entryId: 'entry-1')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hades'), findsWidgets);
    expect(find.byType(GameDetailPage), findsOneWidget);
    expect(find.byIcon(Icons.image_search_outlined), findsWidgets);
    expect(find.byType(OutlinedButton), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('GameDetailPage renders without cover on android viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    when(
      () => gameRepository.getByEntryId('entry-2'),
    ).thenAnswer((_) async => _details(withCover: false, longTitle: true));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameRepositoryProvider.overrideWith((ref) => gameRepository),
          mediaRepositoryProvider.overrideWith((ref) => mediaRepository),
        ],
        child: MaterialApp(
          theme: buildBacklogVaultDarkTheme(),
          home: const Scaffold(body: GameDetailPage(entryId: 'entry-2')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.image_outlined), findsWidgets);
    expect(find.textContaining('A Very Long Game Title'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'GameDetailPage handles many platforms and genres without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      when(() => gameRepository.getByEntryId('entry-3')).thenAnswer(
        (_) async =>
            _details(withCover: false, longTitle: true, denseMetadata: true),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameRepositoryProvider.overrideWith((ref) => gameRepository),
            mediaRepositoryProvider.overrideWith((ref) => mediaRepository),
          ],
          child: MaterialApp(
            theme: buildBacklogVaultDarkTheme(),
            home: const Scaffold(body: GameDetailPage(entryId: 'entry-3')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Notas personales'),
        300,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Notas personales'), findsOneWidget);
      expect(find.text('Plataformas'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'legacy playthrough history is visible without mutation controls',
    (tester) async {
      tester.view.physicalSize = const Size(432, 960);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      when(() => gameRepository.getByEntryId('entry-4')).thenAnswer(
        (_) async => _details(withCover: false, missingPlaythroughStart: true),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameRepositoryProvider.overrideWith((ref) => gameRepository),
            mediaRepositoryProvider.overrideWith((ref) => mediaRepository),
          ],
          child: MaterialApp(
            theme: buildBacklogVaultDarkTheme(),
            home: const Scaffold(body: GameDetailPage(entryId: 'entry-4')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Notas personales'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byTooltip('Acciones de partida'), findsNothing);
      expect(find.text('Nueva partida'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}

final _now = DateTime(2026, 6, 16);

LibraryGameDetails _details({
  required bool withCover,
  bool longTitle = false,
  bool denseMetadata = false,
  bool missingPlaythroughStart = false,
}) {
  return LibraryGameDetails(
    game: GameDetails(
      id: 'game-1',
      title:
          longTitle
              ? 'A Very Long Game Title That Should Stay Inside The Detail Header Without Overflowing'
              : 'Hades',
      sortTitle: null,
      releaseDate: DateTime(2020, 9, 17),
      type: 'game',
      createdAt: _now,
      updatedAt: _now,
      deletedAt: null,
    ),
    entry: LibraryEntryDetails(
      id: withCover ? 'entry-1' : 'entry-2',
      gameId: 'game-1',
      status: GameStatus.completed.name,
      personalRating: 5,
      personalNotes: 'Escape attempt notes.',
      createdAt: _now,
      updatedAt: _now,
      deletedAt: null,
    ),
    platforms:
        denseMetadata
            ? List.generate(
              10,
              (index) => CatalogItem(
                id: 'platform-$index',
                name: 'Platform $index With Long Name',
                createdAt: _now,
                updatedAt: _now,
                deletedAt: null,
              ),
            )
            : [
              CatalogItem(
                id: 'pc',
                name: 'PC',
                createdAt: _now,
                updatedAt: _now,
                deletedAt: null,
              ),
            ],
    genres:
        denseMetadata
            ? List.generate(
              12,
              (index) => CatalogItem(
                id: 'genre-$index',
                name: 'Genre $index With Long Label',
                createdAt: _now,
                updatedAt: _now,
                deletedAt: null,
              ),
            )
            : [
              CatalogItem(
                id: 'rogue',
                name: 'Roguelike',
                createdAt: _now,
                updatedAt: _now,
                deletedAt: null,
              ),
            ],
    playthroughs: [
      PlaythroughDetails(
        id: 'pt-1',
        libraryEntryId: withCover ? 'entry-1' : 'entry-2',
        platformId: 'pc',
        status: 'completed',
        startedAt: missingPlaythroughStart ? null : DateTime(2026, 1, 1),
        completedAt: DateTime(2026, 1, 20),
        hoursPlayed: 24,
        rating: 5,
        notes: 'Clean clear.',
        createdAt: _now,
        updatedAt: _now,
        deletedAt: null,
      ),
    ],
    selectedCover:
        withCover
            ? GameCoverDetails(
              id: 'cover-1',
              source: 'local',
              localPath: 'missing-cover.png',
            )
            : null,
  );
}
