import 'package:backlog_vault/core/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

void main() {
  test('migrates schema 1 database to schema 2 preserving library data', () async {
    final executor = NativeDatabase.memory(
      setup: (db) {
        db
          ..execute('''
            CREATE TABLE games (
              id TEXT NOT NULL PRIMARY KEY,
              title TEXT NOT NULL,
              sort_title TEXT NULL,
              release_date INTEGER NULL,
              type TEXT NOT NULL DEFAULT 'game',
              created_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL,
              deleted_at INTEGER NULL
            );
          ''')
          ..execute('''
            CREATE TABLE library_entries (
              id TEXT NOT NULL PRIMARY KEY,
              game_id TEXT NOT NULL REFERENCES games(id),
              status TEXT NOT NULL,
              personal_rating INTEGER NULL,
              personal_notes TEXT NULL,
              created_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL,
              deleted_at INTEGER NULL
            );
          ''')
          ..execute('''
            CREATE TABLE platforms (
              id TEXT NOT NULL PRIMARY KEY,
              name TEXT NOT NULL,
              short_name TEXT NULL,
              created_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL,
              deleted_at INTEGER NULL
            );
          ''')
          ..execute('''
            CREATE TABLE library_entry_platforms (
              id TEXT NOT NULL PRIMARY KEY,
              library_entry_id TEXT NOT NULL REFERENCES library_entries(id),
              platform_id TEXT NOT NULL REFERENCES platforms(id),
              is_primary INTEGER NOT NULL DEFAULT 0,
              created_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL,
              deleted_at INTEGER NULL
            );
          ''')
          ..execute('''
            CREATE TABLE genres (
              id TEXT NOT NULL PRIMARY KEY,
              name TEXT NOT NULL,
              created_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL,
              deleted_at INTEGER NULL
            );
          ''')
          ..execute('''
            CREATE TABLE game_genres (
              id TEXT NOT NULL PRIMARY KEY,
              game_id TEXT NOT NULL REFERENCES games(id),
              genre_id TEXT NOT NULL REFERENCES genres(id),
              created_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL,
              deleted_at INTEGER NULL
            );
          ''')
          ..execute('''
            CREATE TABLE playthroughs (
              id TEXT NOT NULL PRIMARY KEY,
              library_entry_id TEXT NOT NULL REFERENCES library_entries(id),
              platform_id TEXT NULL REFERENCES platforms(id),
              status TEXT NOT NULL,
              started_at INTEGER NULL,
              completed_at INTEGER NULL,
              hours_played REAL NULL,
              rating INTEGER NULL,
              notes TEXT NULL,
              created_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL,
              deleted_at INTEGER NULL
            );
          ''')
          ..execute(
            "INSERT INTO games (id, title, type, created_at, updated_at) VALUES ('game-1', 'Existing Game', 'game', 0, 0);",
          )
          ..execute(
            "INSERT INTO library_entries (id, game_id, status, created_at, updated_at) VALUES ('entry-1', 'game-1', 'backlog', 0, 0);",
          )
          ..execute('PRAGMA user_version = 1;');
      },
    );
    final db = AppDatabase(executor);
    addTearDown(db.close);

    final savedViewsTable =
        await db
            .customSelect(
              "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'saved_views';",
            )
            .getSingleOrNull();
    final gameCount =
        await db
            .customSelect('SELECT COUNT(*) AS count FROM games;')
            .map((row) => row.read<int>('count'))
            .getSingle();
    final entryCount =
        await db
            .customSelect('SELECT COUNT(*) AS count FROM library_entries;')
            .map((row) => row.read<int>('count'))
            .getSingle();

    expect(savedViewsTable, isNotNull);
    expect(gameCount, 1);
    expect(entryCount, 1);
    expect(await db.select(db.savedViews).get(), isEmpty);
  });
}
