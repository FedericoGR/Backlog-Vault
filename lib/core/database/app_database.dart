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
      await transaction(() async {
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
        if (from < 7) {
          await _migratePersonalRecord7(migrator);
        }
      });
    },
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> _migratePersonalRecord7(Migrator migrator) async {
    await migrator.addColumn(libraryEntries, libraryEntries.isCompleted);
    await migrator.addColumn(libraryEntries, libraryEntries.completedAt);
    await migrator.addColumn(libraryEntries, libraryEntries.hoursPlayed);
    await migrator.addColumn(libraryEntries, libraryEntries.playedPlatformId);

    // Dates sort before undated completions. Stable IDs resolve remaining ties.
    // SUM intentionally returns NULL when no recorded hours exist.
    const completed = '''
      FROM playthroughs p
      WHERE p.library_entry_id = library_entries.id
        AND p.deleted_at IS NULL AND p.status = 'completed'
    ''';
    const latestCompleted = '''
      $completed ORDER BY p.completed_at DESC, p.updated_at DESC, p.id ASC LIMIT 1
    ''';
    await customStatement('''
      UPDATE library_entries SET
        is_completed = (status = 'completed' OR EXISTS (SELECT 1 $completed)),
        completed_at = (SELECT MAX(p.completed_at) $completed),
        hours_played = (
          SELECT SUM(p.hours_played) FROM playthroughs p
          WHERE p.library_entry_id = library_entries.id AND p.deleted_at IS NULL
        ),
        played_platform_id = COALESCE(
          (SELECT p.platform_id $latestCompleted),
          (SELECT p.platform_id FROM playthroughs p
           WHERE p.library_entry_id = library_entries.id AND p.deleted_at IS NULL
           ORDER BY p.updated_at DESC, p.id ASC LIMIT 1),
          (SELECT lp.platform_id FROM library_entry_platforms lp
           WHERE lp.library_entry_id = library_entries.id
             AND lp.deleted_at IS NULL AND lp.is_primary = 1
           ORDER BY lp.updated_at DESC, lp.id ASC LIMIT 1)
        ),
        personal_rating = COALESCE(
          personal_rating, (SELECT p.rating $latestCompleted)
        )
    ''');
    await _requireForeignKeyIntegrity();
  }

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
