import 'package:backlog_vault/features/library/domain/game_status.dart';
import 'package:backlog_vault/features/library/domain/library_game_row.dart';
import 'package:backlog_vault/features/library/presentation/game_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('uses compact menu when row actions have narrow width', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(width: 104, child: LibraryRowActions(row: _row)),
          ),
        ),
      ),
    );

    expect(find.byTooltip('Acciones'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Acciones'));
    await tester.pumpAndSettle();

    expect(find.text('Abrir detalle'), findsOneWidget);
    expect(find.text('Editar'), findsOneWidget);
    expect(find.text('Eliminar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps inline actions when row actions have enough width', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(width: 160, child: LibraryRowActions(row: _row)),
          ),
        ),
      ),
    );

    expect(find.byTooltip('Abrir detalle'), findsOneWidget);
    expect(find.byTooltip('Editar'), findsOneWidget);
    expect(find.byTooltip('Eliminar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

final _row = LibraryGameRow(
  gameId: 'game-1',
  libraryEntryId: 'entry-1',
  title: 'Hades',
  status: GameStatus.backlog,
  type: 'game',
  platforms: const [],
  genres: const [],
  playthroughCount: 0,
  updatedAt: DateTime(2026, 6, 13),
);
