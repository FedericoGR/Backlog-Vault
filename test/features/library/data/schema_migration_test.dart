import 'package:backlog_vault/core/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

void main() {
  test('migrates schema 1 database to schema 4 preserving library data', () async {
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
    final externalGameIdsTable =
        await db
            .customSelect(
              "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'external_game_ids';",
            )
            .getSingleOrNull();
    final mediaAssetsTable =
        await db
            .customSelect(
              "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'media_assets';",
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
    expect(externalGameIdsTable, isNotNull);
    expect(mediaAssetsTable, isNotNull);
    expect(gameCount, 1);
    expect(entryCount, 1);
    expect(await db.select(db.savedViews).get(), isEmpty);
    expect(await db.select(db.externalGameIds).get(), isEmpty);
    expect(await db.select(db.mediaAssets).get(), isEmpty);
  });

  test('migrates schema 2 database to schema 4 preserving saved views', () async {
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
            CREATE TABLE saved_views (
              id TEXT NOT NULL PRIMARY KEY,
              name TEXT NOT NULL,
              filter_json TEXT NOT NULL,
              sort_json TEXT NOT NULL,
              column_config_json TEXT NOT NULL,
              created_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL,
              deleted_at INTEGER NULL
            );
          ''')
          ..execute(
            "INSERT INTO games (id, title, type, created_at, updated_at) VALUES ('game-1', 'Existing Game', 'game', 0, 0);",
          )
          ..execute(
            "INSERT INTO saved_views (id, name, filter_json, sort_json, column_config_json, created_at, updated_at) VALUES ('view-1', 'Vista', '{}', '{}', '{}', 0, 0);",
          )
          ..execute('PRAGMA user_version = 2;');
      },
    );
    final db = AppDatabase(executor);
    addTearDown(db.close);

    final externalGameIdsTable =
        await db
            .customSelect(
              "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'external_game_ids';",
            )
            .getSingleOrNull();
    final mediaAssetsTable =
        await db
            .customSelect(
              "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'media_assets';",
            )
            .getSingleOrNull();
    final savedViewCount =
        await db
            .customSelect('SELECT COUNT(*) AS count FROM saved_views;')
            .map((row) => row.read<int>('count'))
            .getSingle();
    final gameCount =
        await db
            .customSelect('SELECT COUNT(*) AS count FROM games;')
            .map((row) => row.read<int>('count'))
            .getSingle();

    expect(externalGameIdsTable, isNotNull);
    expect(mediaAssetsTable, isNotNull);
    expect(savedViewCount, 1);
    expect(gameCount, 1);
    expect(await db.select(db.externalGameIds).get(), isEmpty);
    expect(await db.select(db.mediaAssets).get(), isEmpty);
  });

  test('migrates schema 3 database to schema 4 preserving external ids', () async {
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
            CREATE TABLE external_game_ids (
              id TEXT NOT NULL PRIMARY KEY,
              game_id TEXT NOT NULL REFERENCES games(id),
              provider TEXT NOT NULL,
              external_id TEXT NOT NULL,
              external_slug TEXT NULL,
              external_url TEXT NULL,
              matched_title TEXT NULL,
              created_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL,
              deleted_at INTEGER NULL
            );
          ''')
          ..execute(
            "INSERT INTO games (id, title, type, created_at, updated_at) VALUES ('game-1', 'Existing Game', 'game', 0, 0);",
          )
          ..execute(
            "INSERT INTO external_game_ids (id, game_id, provider, external_id, created_at, updated_at) VALUES ('external-1', 'game-1', 'rawg', '123', 0, 0);",
          )
          ..execute('PRAGMA user_version = 3;');
      },
    );
    final db = AppDatabase(executor);
    addTearDown(db.close);

    final mediaAssetsTable =
        await db
            .customSelect(
              "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'media_assets';",
            )
            .getSingleOrNull();
    final externalIdCount =
        await db
            .customSelect('SELECT COUNT(*) AS count FROM external_game_ids;')
            .map((row) => row.read<int>('count'))
            .getSingle();

    expect(mediaAssetsTable, isNotNull);
    expect(externalIdCount, 1);
    expect(await db.select(db.mediaAssets).get(), isEmpty);
  });
}
