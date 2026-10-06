import 'dart:io';

import 'package:backlog_vault/app/theme/app_theme.dart';
import 'package:backlog_vault/features/catalogs/domain/catalog_item.dart';
import 'package:backlog_vault/features/games/application/library_game_details.dart';
import 'package:backlog_vault/features/games/data/game_repository.dart';
import 'package:backlog_vault/features/games/presentation/game_detail_page.dart';
import 'package:backlog_vault/features/media/data/media_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGameRepository extends Mock implements GameRepository {}

class _MockMediaRepository extends Mock implements MediaRepository {}

void main() {
  late _MockGameRepository games;
  late _MockMediaRepository media;
  setUp(() {
    games = _MockGameRepository();
    media = _MockMediaRepository();
    when(
      () => media.resolveLocalFile(any()),
    ).thenAnswer((_) async => File('Z:/backlog-vault-test/missing-cover.png'));
  });
  Future<void> open(
    WidgetTester tester,
    LibraryGameDetails item, {
    Size size = const Size(1500, 1800),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    when(() => games.getByEntryId('entry-1')).thenAnswer((_) async => item);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameRepositoryProvider.overrideWith((ref) => games),
          mediaRepositoryProvider.overrideWith((ref) => media),
        ],
        child: MaterialApp(
          theme: buildBacklogVaultDarkTheme(),
          home: const GameDetailPage(entryId: 'entry-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> expandCatalog(WidgetTester tester) async {
    await tester.scrollUntilVisible(
      find.text('Información del juego'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Información del juego'));
    await tester.pumpAndSettle();
  }

  for (final completed in [true, false]) {
    testWidgets(
      'detail prioritizes and displays each personal field once, completed=$completed',
      (tester) async {
        await open(tester, _details(withCover: true, completed: completed));
        expect(find.text('Hades'), findsOneWidget);
        expect(find.byKey(const ValueKey('detail-rating')), findsOneWidget);
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('detail-rating')),
            matching: find.byIcon(Icons.star),
          ),
          findsNWidgets(5),
        );
        expect(find.text('24.0 h'), findsOneWidget);
        expect(find.text('PS5'), findsOneWidget);
        expect(
          find.text(completed ? 'Terminado' : 'No terminado'),
          findsOneWidget,
        );
        expect(find.text('2025'), findsOneWidget);
        expect(
          find.textContaining('20-01-2026'),
          completed ? findsOneWidget : findsNothing,
        );
        expect(find.text('Escape attempt notes.'), findsOneWidget);
        expect(find.text('Editar'), findsOneWidget);
        expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
        expect(find.byIcon(Icons.image_search_outlined), findsNothing);
        expect(find.text('PC'), findsNothing);
        expect(find.text('Roguelike'), findsNothing);
        expect(find.textContaining('17-09-2020'), findsNothing);
        expect(
          tester
              .getTopLeft(find.byKey(const ValueKey('detail-personal-record')))
              .dy,
          lessThan(tester.getTopLeft(find.text('Información del juego')).dy),
        );
        expect(
          tester.getTopLeft(find.text('Escape attempt notes.')).dy,
          lessThan(tester.getTopLeft(find.text('Información del juego')).dy),
        );
        for (final label in [
          'Partidas',
          'Nueva partida',
          'Jugando',
          'Pausar',
          'Abandonar',
          'Retirado',
          'Pendiente',
          'Resumen y progreso',
          'Puntaje de partida',
        ]) {
          expect(find.textContaining(label), findsNothing);
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'catalog remains secondary and separate from personally played platform',
    (tester) async {
      await open(tester, _details(withCover: false));
      await expandCatalog(tester);
      expect(find.text('PC'), findsOneWidget);
      expect(find.text('Roguelike'), findsOneWidget);
      expect(find.text('Plataformas'), findsOneWidget);
      expect(find.text('Géneros'), findsOneWidget);
      expect(find.textContaining('17-09-2020'), findsOneWidget);
      expect(find.text('PS5'), findsOneWidget);
      expect(find.text('Terminado'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('detail-rating')),
          matching: find.byIcon(Icons.star),
        ),
        findsNWidgets(5),
      );
      expect(find.byIcon(Icons.travel_explore_outlined), findsOneWidget);
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'unknown year and empty optional personal fields render without duplicates',
    (tester) async {
      await open(tester, _details(withCover: false, emptyPersonal: true));
      expect(find.text('Sin año'), findsOneWidget);
      expect(find.byKey(const ValueKey('detail-rating')), findsNothing);
      expect(
        find.byKey(const ValueKey('detail-completion-date')),
        findsNothing,
      );
      expect(find.text('Notas personales'), findsNothing);
      expect(find.text('No terminado'), findsOneWidget);
      expect(find.text('PC'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'mobile detail handles long title without cover and keeps notes prominent',
    (tester) async {
      await open(
        tester,
        _details(withCover: false, longTitle: true),
        size: const Size(390, 844),
      );
      expect(find.textContaining('A Very Long Game Title'), findsOneWidget);
      expect(
        tester.getTopLeft(find.byKey(const ValueKey('detail-poster'))).dy,
        lessThan(
          tester
              .getTopLeft(find.byKey(const ValueKey('detail-personal-record')))
              .dy,
        ),
      );
      await tester.scrollUntilVisible(
        find.text('Escape attempt notes.'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Escape attempt notes.'), findsOneWidget);
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      expect(find.text('Buscar portada'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('dense secondary catalog stays usable on a narrow viewport', (
    tester,
  ) async {
    await open(
      tester,
      _details(withCover: false, longTitle: true, denseMetadata: true),
      size: const Size(412, 915),
    );
    await expandCatalog(tester);
    await tester.scrollUntilVisible(
      find.text('Géneros'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Géneros'), findsOneWidget);
    expect(find.textContaining('Genre 11'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

final _now = DateTime(2026, 6, 16);

LibraryGameDetails _details({
  required bool withCover,
  bool longTitle = false,
  bool denseMetadata = false,
  bool completed = true,
  bool emptyPersonal = false,
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
      isCompleted: emptyPersonal ? false : completed,
      playedYear: emptyPersonal ? null : 2025,
      playedPlatformId: emptyPersonal ? null : 'ps5',
      completedAt: emptyPersonal ? null : DateTime(2026, 1, 20),
      hoursPlayed: emptyPersonal ? null : 24,
      personalRating: emptyPersonal ? null : 5,
      personalNotes: emptyPersonal ? null : 'Escape attempt notes.',
      createdAt: _now,
      updatedAt: _now,
      deletedAt: null,
    ),
    playedPlatform: emptyPersonal ? null : CatalogItem(id: 'ps5', name: 'PS5'),
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
