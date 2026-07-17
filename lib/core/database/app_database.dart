import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../version/app_versions.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Games,
    LibraryEntries,
    Platforms,
    LibraryEntryPlatforms,
    Genres,
    GameGenres,
    Playthroughs,
    SavedViews,
    ExternalGameIds,
    MediaAssets,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => databaseSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(savedViews);
      }
      if (from < 3) {
        await migrator.createTable(externalGameIds);
      }
      if (from < 4) {
        await migrator.createTable(mediaAssets);
      }
      if (from == 5) {
        await _migrateSchema5ToOffline6();
      }
    },
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> _migrateSchema5ToOffline6() async {
    await _requireFunctionalSchema();
    await _requireForeignKeyIntegrity();

    await customStatement('DROP INDEX IF EXISTS idx_sync_devices_group_status');
    await customStatement('DROP INDEX IF EXISTS idx_sync_devices_single_local');
    await customStatement('DROP INDEX IF EXISTS idx_sync_changes_entity');
    await customStatement('DROP INDEX IF EXISTS idx_sync_changes_mutation');
    await customStatement('DROP INDEX IF EXISTS idx_sync_changes_origin');
    await customStatement('DROP INDEX IF EXISTS idx_sync_tombstones_entity');
    await customStatement('DROP INDEX IF EXISTS idx_sync_state_peer');
    await customStatement('DROP INDEX IF EXISTS idx_sync_entity_state_entity');

    await customStatement('DROP TABLE IF EXISTS sync_entity_states');
    await customStatement('DROP TABLE IF EXISTS sync_states');
    await customStatement('DROP TABLE IF EXISTS sync_tombstones');
    await customStatement('DROP TABLE IF EXISTS sync_changes');
    await customStatement('DROP TABLE IF EXISTS sync_devices');
    await customStatement('DROP TABLE IF EXISTS sync_groups');

    await _requireFunctionalSchema();
    await _requireForeignKeyIntegrity();
  }

  Future<void> _requireFunctionalSchema() async {
    const requiredTables = <String>{
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
    };
    await customStatement(
      'CREATE TEMP TABLE IF NOT EXISTS _offline_migration_guard '
      '(name TEXT NOT NULL PRIMARY KEY)',
    );
    await customStatement('DELETE FROM _offline_migration_guard');
    for (final name in requiredTables) {
      await customStatement(
        'INSERT INTO _offline_migration_guard(name) '
        'SELECT name FROM sqlite_master WHERE type = ? AND name = ?',
        ['table', name],
      );
    }
    final rows =
        await customSelect('SELECT name FROM _offline_migration_guard').get();
    final found = rows.map((row) => row.read<String>('name')).toSet();
    final missing = requiredTables.difference(found);
    if (missing.isNotEmpty) {
      throw StateError(
        'Schema 5 is incomplete; offline migration was not applied.',
      );
    }
  }

  Future<void> _requireForeignKeyIntegrity() async {
    final violations = await customSelect('PRAGMA foreign_key_check').get();
    if (violations.isNotEmpty) {
      throw StateError(
        'Foreign key validation failed; offline migration was rolled back.',
      );
    }
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'backlog_vault');
}
