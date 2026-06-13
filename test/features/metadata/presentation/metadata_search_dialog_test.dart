import 'package:backlog_vault/core/database/app_database.dart';
import 'package:backlog_vault/features/games/application/library_game_details.dart';
import 'package:backlog_vault/features/library/domain/game_status.dart';
import 'package:backlog_vault/features/metadata/presentation/metadata_search_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('allows choosing RAWG or IGDB as metadata provider', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: MetadataSearchDialog(item: _details())),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Proveedor'), findsOneWidget);
    expect(find.text('RAWG'), findsOneWidget);

    await tester.tap(find.text('RAWG'));
    await tester.pumpAndSettle();

    expect(find.text('IGDB'), findsOneWidget);
    await tester.tap(find.text('IGDB').last);
    await tester.pumpAndSettle();

    expect(
      find.text('Buscá un juego para ver candidatos de IGDB.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}

final _now = DateTime(2026, 6, 13);

LibraryGameDetails _details() {
  return LibraryGameDetails(
    game: Game(
      id: 'game-1',
      title: 'Hades',
      sortTitle: null,
      releaseDate: null,
      type: 'game',
      createdAt: _now,
      updatedAt: _now,
      deletedAt: null,
    ),
    entry: LibraryEntry(
      id: 'entry-1',
      gameId: 'game-1',
      status: GameStatus.backlog.name,
      personalRating: null,
      personalNotes: null,
      createdAt: _now,
      updatedAt: _now,
      deletedAt: null,
    ),
    platforms: const [],
    genres: const [],
    playthroughs: const [],
  );
}
