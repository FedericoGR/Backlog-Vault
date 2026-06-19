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
    SyncGroups,
    SyncDevices,
    SyncChanges,
    SyncTombstones,
    SyncStates,
    SyncEntityStates,
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
      await _createSyncIndexes();
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
      if (from < 5) {
        await migrator.createTable(syncGroups);
        await migrator.createTable(syncDevices);
        await migrator.createTable(syncChanges);
        await migrator.createTable(syncTombstones);
        await migrator.createTable(syncStates);
        await migrator.createTable(syncEntityStates);
        await _createSyncIndexes();
      }
    },
  );

  Future<void> _createSyncIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sync_devices_group_status '
      'ON sync_devices(sync_group_id, status)',
    );
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_sync_devices_single_local '
      'ON sync_devices(is_local) WHERE is_local = 1',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sync_changes_entity '
      'ON sync_changes(entity_type, entity_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sync_changes_mutation '
      'ON sync_changes(mutation_id, mutation_sequence)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sync_changes_origin '
      'ON sync_changes(sync_group_id, origin_device_id, origin_counter)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sync_tombstones_entity '
      'ON sync_tombstones(entity_type, entity_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sync_state_peer '
      'ON sync_states(sync_group_id, local_device_id, peer_device_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sync_entity_state_entity '
      'ON sync_entity_states(entity_type, entity_id)',
    );
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'backlog_vault');
}
