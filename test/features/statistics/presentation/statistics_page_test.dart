import 'package:backlog_vault/features/library/data/library_query_repository.dart';
import 'package:backlog_vault/features/library/domain/game_status.dart';
import 'package:backlog_vault/features/library/domain/library_game_row.dart';
import 'package:backlog_vault/features/playthroughs/domain/playthrough_status.dart';
import 'package:backlog_vault/features/statistics/data/statistics_repository.dart';
import 'package:backlog_vault/features/statistics/domain/statistics_models.dart';
import 'package:backlog_vault/features/statistics/presentation/statistics_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders statistics dashboard with lightweight sections', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          libraryRowsProvider.overrideWith((ref) => Stream.value(_rows)),
          statisticsPlaythroughsProvider.overrideWith(
            (ref) => Stream.value(_playthroughs),
          ),
        ],
        child: const MaterialApp(home: StatisticsPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Estadísticas'), findsOneWidget);
    expect(find.text('Biblioteca por estado'), findsOneWidget);
    expect(find.text('Progreso anual'), findsOneWidget);
    expect(find.text('Completados totales'), findsOneWidget);
    expect(find.text('Horas registradas'), findsOneWidget);
    expect(find.text('Ratings'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Calidad de datos'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Calidad de datos'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('stays readable on a narrow window with long titles', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(420, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          libraryRowsProvider.overrideWith(
            (ref) => Stream.value(_rowsWithLongTitle),
          ),
          statisticsPlaythroughsProvider.overrideWith(
            (ref) => Stream.value(_playthroughs),
          ),
        ],
        child: const MaterialApp(home: StatisticsPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Estadísticas'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Últimos completados'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Últimos completados'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows a clear empty state', (tester) async {
    tester.view.physicalSize = const Size(420, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          libraryRowsProvider.overrideWith((ref) => Stream.value(const [])),
          statisticsPlaythroughsProvider.overrideWith(
            (ref) => Stream.value(const []),
          ),
        ],
        child: const MaterialApp(home: StatisticsPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Todavía no hay datos para calcular estadísticas.'),
      findsOneWidget,
    );
    expect(find.text('Ir a biblioteca'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

final _rows = [
  LibraryGameRow(
    gameId: 'g1',
    libraryEntryId: 'e1',
    title: 'Hades',
    selectedCoverLocalPath: 'media/games/g1/cover.png',
    hasExternalMetadata: true,
    status: GameStatus.completed,
    personalRating: 5,
    type: 'game',
    platforms: const [LibraryCatalogItem(id: 'pc', name: 'PC')],
    genres: const [LibraryCatalogItem(id: 'roguelite', name: 'Roguelite')],
    playthroughCount: 1,
    updatedAt: DateTime(2026, 6, 1),
  ),
  LibraryGameRow(
    gameId: 'g2',
    libraryEntryId: 'e2',
    title: 'Celeste',
    status: GameStatus.backlog,
    type: 'game',
    platforms: const [],
    genres: const [],
    playthroughCount: 0,
    updatedAt: DateTime(2026, 6, 2),
  ),
];

final _rowsWithLongTitle = [
  LibraryGameRow(
    gameId: 'g1',
    libraryEntryId: 'e1',
    title:
        'The Legend of Heroes: Trails into Reverie Deluxe Complete Edition With A Very Long Subtitle',
    selectedCoverLocalPath: 'media/games/g1/cover.png',
    hasExternalMetadata: true,
    status: GameStatus.completed,
    personalRating: 5,
    type: 'game',
    platforms: const [
      LibraryCatalogItem(id: 'pc', name: 'PC'),
      LibraryCatalogItem(
        id: 'switch',
        name: 'Nintendo Switch OLED Portable Mode',
      ),
    ],
    genres: const [
      LibraryCatalogItem(id: 'jrpg', name: 'Japanese Role-Playing Game'),
      LibraryCatalogItem(id: 'story', name: 'Story Rich Adventure'),
    ],
    playthroughCount: 1,
    updatedAt: DateTime(2026, 6, 1),
  ),
  LibraryGameRow(
    gameId: 'g2',
    libraryEntryId: 'e2',
    title: 'Celeste',
    status: GameStatus.paused,
    type: 'game',
    platforms: const [],
    genres: const [],
    playthroughCount: 0,
    updatedAt: DateTime(2026, 6, 2),
  ),
  LibraryGameRow(
    gameId: 'g3',
    libraryEntryId: 'e3',
    title: 'Retired Game',
    status: GameStatus.retired,
    type: 'game',
    platforms: const [],
    genres: const [],
    playthroughCount: 0,
    updatedAt: DateTime(2026, 6, 3),
  ),
];

final _playthroughs = [
  StatisticsPlaythrough(
    libraryEntryId: 'e1',
    status: PlaythroughStatus.completed,
    completedAt: DateTime(2026, 1, 1),
    hoursPlayed: 12,
  ),
];
