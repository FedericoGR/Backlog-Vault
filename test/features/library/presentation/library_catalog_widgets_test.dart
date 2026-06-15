import 'package:backlog_vault/app/theme.dart';
import 'package:backlog_vault/features/library/domain/game_status.dart';
import 'package:backlog_vault/features/library/domain/library_filter_state.dart';
import 'package:backlog_vault/features/library/domain/library_game_row.dart';
import 'package:backlog_vault/features/library/domain/library_table_summary.dart';
import 'package:backlog_vault/features/library/presentation/widgets/library_catalog_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('catalog grid renders long titles and missing covers', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        child: SizedBox(
          width: 520,
          height: 520,
          child: LibraryCatalogGrid(
            rows: _rows,
            selectionMode: false,
            selectedIds: const {},
            onSelectionChanged: (_, _) {},
            rowActionsBuilder: _actions,
          ),
        ),
      ),
    );

    expect(find.textContaining('A Very Long Game Title'), findsOneWidget);
    expect(find.byIcon(Icons.image_outlined), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('catalog list is usable on an android-sized viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _TestApp(
        child: LibraryCatalogList(
          rows: _rows,
          selectionMode: false,
          selectedIds: const {},
          onSelectionChanged: (_, _) {},
          rowActionsBuilder: _actions,
        ),
      ),
    );

    expect(find.text('Hades'), findsOneWidget);
    expect(find.text('Completado'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('selection mode reflects selected catalog items', (tester) async {
    await tester.pumpWidget(
      _TestApp(
        child: SizedBox(
          width: 520,
          height: 520,
          child: LibraryCatalogGrid(
            rows: _rows,
            selectionMode: true,
            selectedIds: const {'entry-1'},
            onSelectionChanged: (_, _) {},
            rowActionsBuilder: _actions,
          ),
        ),
      ),
    );

    final selectedCheckbox = tester.widget<Checkbox>(
      find.byType(Checkbox).first,
    );
    expect(selectedCheckbox.value, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('summary strip and filter sidebar render compactly', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        child: Row(
          children: [
            LibraryFilterSidebar(
              filter: const LibraryFilterState(
                statuses: {GameStatus.completed},
              ),
              platforms: const [LibraryCatalogItem(id: 'pc', name: 'PC')],
              genres: const [LibraryCatalogItem(id: 'rpg', name: 'RPG')],
              onEditFilters: () {},
              onClearFilters: () {},
              onToggleStatus: (_) {},
              onTogglePlatform: (_) {},
              onToggleGenre: (_) {},
            ),
            const Expanded(
              child: LibrarySummaryStrip(
                summary: LibraryTableSummary(
                  visibleGames: 51,
                  statusCounts: {GameStatus.completed: 50},
                  completedCount: 50,
                  totalHours: 640.5,
                  averageRating: 3.4,
                  missingRating: 1,
                  missingPlatform: 1,
                  missingGenre: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    expect(find.text('Filtros'), findsOneWidget);
    expect(find.text('Juegos: 51'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: buildBacklogVaultDarkTheme(),
      home: Scaffold(body: child),
    );
  }
}

Widget _actions(LibraryGameRow row, bool compact) {
  return const IconButton(onPressed: null, icon: Icon(Icons.more_vert));
}

final _rows = [
  LibraryGameRow(
    gameId: 'game-1',
    libraryEntryId: 'entry-1',
    title: 'Hades',
    status: GameStatus.completed,
    type: 'game',
    platforms: const [LibraryCatalogItem(id: 'pc', name: 'PC')],
    genres: const [LibraryCatalogItem(id: 'rpg', name: 'Roguelike')],
    personalRating: 5,
    hoursPlayed: 24,
    releaseDate: DateTime(2020, 9, 17),
    completedAt: DateTime(2026, 1, 1),
    playthroughCount: 1,
    updatedAt: DateTime(2026, 6, 13),
  ),
  LibraryGameRow(
    gameId: 'game-2',
    libraryEntryId: 'entry-2',
    title:
        'A Very Long Game Title That Should Wrap Cleanly Without Overflowing',
    status: GameStatus.backlog,
    type: 'game',
    platforms: const [],
    genres: const [],
    playthroughCount: 0,
    updatedAt: DateTime(2026, 6, 13),
  ),
];
