import 'package:backlog_vault/core/database/app_database.dart';
import 'package:backlog_vault/features/games/data/game_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late GameRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = GameRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('softDeleteMany marks selected games and entries as deleted', () async {
    final now = DateTime(2026, 6, 14);
    for (final id in ['1', '2', '3']) {
      await db
          .into(db.games)
          .insert(
            GamesCompanion.insert(
              id: 'game-$id',
              title: 'Game $id',
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.libraryEntries)
          .insert(
            LibraryEntriesCompanion.insert(
              id: 'entry-$id',
              gameId: 'game-$id',
              status: 'backlog',
              createdAt: now,
              updatedAt: now,
            ),
          );
    }

    await repository.softDeleteMany(['entry-1', 'entry-3']);

    final entries = await db.select(db.libraryEntries).get();
    final games = await db.select(db.games).get();

    expect(
      entries
          .where((entry) => entry.deletedAt != null)
          .map((entry) => entry.id)
          .toSet(),
      {'entry-1', 'entry-3'},
    );
    expect(
      games
          .where((game) => game.deletedAt != null)
          .map((game) => game.id)
          .toSet(),
      {'game-1', 'game-3'},
    );
    expect(
      entries.singleWhere((entry) => entry.id == 'entry-2').deletedAt,
      null,
    );
  });
}
