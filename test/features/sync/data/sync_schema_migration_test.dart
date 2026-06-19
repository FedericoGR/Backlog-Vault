import 'package:backlog_vault/core/database/app_database.dart';
import 'package:backlog_vault/core/version/app_versions.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:test/test.dart';

void main() {
  test(
    'migrates physical schema 4 to 5 and preserves every library table',
    () async {
      final executor = NativeDatabase.memory(setup: _createSchema4Database);
      final db = AppDatabase(executor);
      addTearDown(db.close);

      expect(db.schemaVersion, databaseSchemaVersion);
      expect(databaseSchemaVersion, 5);
      for (final table in [
        'games',
        'library_entries',
        'platforms',
        'library_entry_platforms',
        'genres',
        'game_genres',
        'playthroughs',
        'saved_views',
        'external_game_ids',
        'media_assets',
      ]) {
        final count =
            await db
                .customSelect('SELECT COUNT(*) AS count FROM $table')
                .map((row) => row.read<int>('count'))
                .getSingle();
        expect(count, 1, reason: '$table data must survive migration');
      }

      for (final table in [
        'sync_groups',
        'sync_devices',
        'sync_changes',
        'sync_tombstones',
        'sync_states',
        'sync_entity_states',
      ]) {
        final exists =
            await db
                .customSelect(
                  "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
                  variables: [Variable<String>(table)],
                )
                .getSingleOrNull();
        expect(exists, isNotNull, reason: '$table must be created');
      }

      final indexes =
          await db
              .customSelect(
                "SELECT name FROM sqlite_master WHERE type = 'index' AND name LIKE 'idx_sync_%'",
              )
              .get();
      expect(indexes.length, greaterThanOrEqualTo(8));
    },
  );
}

void _createSchema4Database(dynamic database) {
  database
    ..execute('''
      CREATE TABLE games (
        id TEXT NOT NULL PRIMARY KEY, title TEXT NOT NULL, sort_title TEXT NULL,
        release_date INTEGER NULL, type TEXT NOT NULL DEFAULT 'game',
        created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, deleted_at INTEGER NULL
      );
    ''')
    ..execute('''
      CREATE TABLE library_entries (
        id TEXT NOT NULL PRIMARY KEY, game_id TEXT NOT NULL REFERENCES games(id),
        status TEXT NOT NULL, personal_rating INTEGER NULL, personal_notes TEXT NULL,
        created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, deleted_at INTEGER NULL
      );
    ''')
    ..execute('''
      CREATE TABLE platforms (
        id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL, short_name TEXT NULL,
        created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, deleted_at INTEGER NULL
      );
    ''')
    ..execute('''
      CREATE TABLE library_entry_platforms (
        id TEXT NOT NULL PRIMARY KEY,
        library_entry_id TEXT NOT NULL REFERENCES library_entries(id),
        platform_id TEXT NOT NULL REFERENCES platforms(id), is_primary INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, deleted_at INTEGER NULL
      );
    ''')
    ..execute('''
      CREATE TABLE genres (
        id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL,
        created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, deleted_at INTEGER NULL
      );
    ''')
    ..execute('''
      CREATE TABLE game_genres (
        id TEXT NOT NULL PRIMARY KEY, game_id TEXT NOT NULL REFERENCES games(id),
        genre_id TEXT NOT NULL REFERENCES genres(id),
        created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, deleted_at INTEGER NULL
      );
    ''')
    ..execute('''
      CREATE TABLE playthroughs (
        id TEXT NOT NULL PRIMARY KEY,
        library_entry_id TEXT NOT NULL REFERENCES library_entries(id),
        platform_id TEXT NULL REFERENCES platforms(id), status TEXT NOT NULL,
        started_at INTEGER NULL, completed_at INTEGER NULL, hours_played REAL NULL,
        rating INTEGER NULL, notes TEXT NULL,
        created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, deleted_at INTEGER NULL
      );
    ''')
    ..execute('''
      CREATE TABLE saved_views (
        id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL, filter_json TEXT NOT NULL,
        sort_json TEXT NOT NULL, column_config_json TEXT NOT NULL,
        created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, deleted_at INTEGER NULL
      );
    ''')
    ..execute('''
      CREATE TABLE external_game_ids (
        id TEXT NOT NULL PRIMARY KEY, game_id TEXT NOT NULL REFERENCES games(id),
        provider TEXT NOT NULL, external_id TEXT NOT NULL, external_slug TEXT NULL,
        external_url TEXT NULL, matched_title TEXT NULL,
        created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, deleted_at INTEGER NULL
      );
    ''')
    ..execute('''
      CREATE TABLE media_assets (
        id TEXT NOT NULL PRIMARY KEY, game_id TEXT NOT NULL REFERENCES games(id),
        kind TEXT NOT NULL, source TEXT NOT NULL, provider TEXT NULL, external_id TEXT NULL,
        remote_url TEXT NULL, local_path TEXT NOT NULL, file_name TEXT NOT NULL,
        mime_type TEXT NULL, width INTEGER NULL, height INTEGER NULL, hash TEXT NULL,
        is_selected INTEGER NOT NULL DEFAULT 0, attribution TEXT NULL,
        created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, deleted_at INTEGER NULL
      );
    ''')
    ..execute(
      "INSERT INTO games VALUES ('game-1', 'Game', NULL, NULL, 'game', 0, 0, NULL)",
    )
    ..execute(
      "INSERT INTO library_entries VALUES ('entry-1', 'game-1', 'backlog', NULL, NULL, 0, 0, NULL)",
    )
    ..execute(
      "INSERT INTO platforms VALUES ('platform-1', 'PC', NULL, 0, 0, NULL)",
    )
    ..execute(
      "INSERT INTO library_entry_platforms VALUES ('link-platform-1', 'entry-1', 'platform-1', 1, 0, 0, NULL)",
    )
    ..execute("INSERT INTO genres VALUES ('genre-1', 'RPG', 0, 0, NULL)")
    ..execute(
      "INSERT INTO game_genres VALUES ('link-genre-1', 'game-1', 'genre-1', 0, 0, NULL)",
    )
    ..execute(
      "INSERT INTO playthroughs VALUES ('play-1', 'entry-1', 'platform-1', 'active', NULL, NULL, NULL, NULL, NULL, 0, 0, NULL)",
    )
    ..execute(
      "INSERT INTO saved_views VALUES ('view-1', 'View', '{}', '{}', '{}', 0, 0, NULL)",
    )
    ..execute(
      "INSERT INTO external_game_ids VALUES ('external-1', 'game-1', 'rawg', '1', NULL, NULL, 'Game', 0, 0, NULL)",
    )
    ..execute(
      "INSERT INTO media_assets VALUES ('media-1', 'game-1', 'cover', 'local', NULL, NULL, NULL, 'media/games/game-1/cover.png', 'cover.png', 'image/png', NULL, NULL, 'hash', 1, NULL, 0, 0, NULL)",
    )
    ..execute('PRAGMA user_version = 4');
}
