import 'package:backlog_vault/features/library/data/library_query_repository.dart';
import 'package:backlog_vault/features/library/domain/game_status.dart';
import 'package:backlog_vault/features/library/domain/library_game_row.dart';
import 'package:backlog_vault/features/library/presentation/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders empty home sections without overflow', (tester) async {
    tester.view.physicalSize = const Size(420, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          libraryRowsProvider.overrideWith((ref) => Stream.value(_emptyRows)),
        ],
        child: const MaterialApp(home: HomePage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No hay juegos en progreso.'), findsOneWidget);
    expect(find.text('No hay pendientes en backlog.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders long titles and home cards in a narrow window', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(420, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          libraryRowsProvider.overrideWith((ref) => Stream.value(_longRows)),
        ],
        child: const MaterialApp(home: HomePage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Jugando ahora'), findsOneWidget);
    expect(find.textContaining('Final Fantasy'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('Sin metadata'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Sin metadata'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

final _emptyRows = [
  LibraryGameRow(
    gameId: 'g1',
    libraryEntryId: 'e1',
    title: 'Hades',
    hasExternalMetadata: true,
    status: GameStatus.completed,
    completedAt: DateTime(2026, 1, 1),
    type: 'game',
    platforms: const [],
    genres: const [],
    playthroughCount: 1,
    updatedAt: DateTime(2026, 1, 2),
  ),
];

final _longRows = [
  LibraryGameRow(
    gameId: 'g2',
    libraryEntryId: 'e2',
    title:
        'Final Fantasy XIII-2 Collector Edition With An Extremely Long Title',
    status: GameStatus.playing,
    type: 'game',
    platforms: const [
      LibraryCatalogItem(id: 'pc', name: 'PC'),
      LibraryCatalogItem(id: 'switch', name: 'Nintendo Switch'),
    ],
    genres: const [
      LibraryCatalogItem(id: 'jrpg', name: 'JRPG'),
      LibraryCatalogItem(id: 'adventure', name: 'Adventure'),
    ],
    playthroughCount: 1,
    updatedAt: DateTime(2026, 6, 10),
  ),
  LibraryGameRow(
    gameId: 'g3',
    libraryEntryId: 'e3',
    title: 'A Short Hike',
    hasExternalMetadata: true,
    status: GameStatus.backlog,
    type: 'game',
    platforms: const [LibraryCatalogItem(id: 'pc', name: 'PC')],
    genres: const [LibraryCatalogItem(id: 'cozy', name: 'Cozy')],
    playthroughCount: 0,
    updatedAt: DateTime(2026, 6, 1),
  ),
];
