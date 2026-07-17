const functionalTableNames = <String>[
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
];

const syncTableNames = <String>[
  'sync_groups',
  'sync_devices',
  'sync_changes',
  'sync_tombstones',
  'sync_states',
  'sync_entity_states',
];

const syncIndexNames = <String>[
  'idx_sync_devices_group_status',
  'idx_sync_devices_single_local',
  'idx_sync_changes_entity',
  'idx_sync_changes_mutation',
  'idx_sync_changes_origin',
  'idx_sync_tombstones_entity',
  'idx_sync_state_peer',
  'idx_sync_entity_state_entity',
];

const schemaV5FunctionalCounts = <String, int>{
  'games': 2,
  'library_entries': 2,
  'platforms': 1,
  'library_entry_platforms': 1,
  'genres': 1,
  'game_genres': 1,
  'playthroughs': 2,
  'saved_views': 1,
  'external_game_ids': 1,
  'media_assets': 1,
};

/// Builds a synthetic physical schema 5 database with all functional and Sync
/// tables populated. Values are deliberately fake and contain no user data.
void createSchemaV5Fixture(dynamic database) {
  database
    ..execute('PRAGMA foreign_keys = ON')
    ..execute('''
      CREATE TABLE games (
        id TEXT NOT NULL PRIMARY KEY, title TEXT NOT NULL, sort_title TEXT NULL,
        release_date INTEGER NULL, type TEXT NOT NULL DEFAULT 'game',
        created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL,
        deleted_at INTEGER NULL
      )
    ''')
    ..execute('''
      CREATE TABLE library_entries (
        id TEXT NOT NULL PRIMARY KEY,
        game_id TEXT NOT NULL REFERENCES games(id), status TEXT NOT NULL,
        personal_rating INTEGER NULL, personal_notes TEXT NULL,
        created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL,
        deleted_at INTEGER NULL
      )
    ''')
    ..execute('''
      CREATE TABLE platforms (
        id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL, short_name TEXT NULL,
        created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL,
        deleted_at INTEGER NULL
      )
    ''')
    ..execute('''
      CREATE TABLE library_entry_platforms (
        id TEXT NOT NULL PRIMARY KEY,
        library_entry_id TEXT NOT NULL REFERENCES library_entries(id),
        platform_id TEXT NOT NULL REFERENCES platforms(id),
        is_primary INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL,
        deleted_at INTEGER NULL
      )
    ''')
    ..execute('''
      CREATE TABLE genres (
        id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL,
        created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL,
        deleted_at INTEGER NULL
      )
    ''')
    ..execute('''
      CREATE TABLE game_genres (
        id TEXT NOT NULL PRIMARY KEY,
        game_id TEXT NOT NULL REFERENCES games(id),
        genre_id TEXT NOT NULL REFERENCES genres(id),
        created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL,
        deleted_at INTEGER NULL
      )
    ''')
    ..execute('''
      CREATE TABLE playthroughs (
        id TEXT NOT NULL PRIMARY KEY,
        library_entry_id TEXT NOT NULL REFERENCES library_entries(id),
        platform_id TEXT NULL REFERENCES platforms(id), status TEXT NOT NULL,
        started_at INTEGER NULL, completed_at INTEGER NULL,
        hours_played REAL NULL, rating INTEGER NULL, notes TEXT NULL,
        created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL,
        deleted_at INTEGER NULL
      )
    ''')
    ..execute('''
      CREATE TABLE saved_views (
        id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL,
        filter_json TEXT NOT NULL, sort_json TEXT NOT NULL,
        column_config_json TEXT NOT NULL,
        created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL,
        deleted_at INTEGER NULL
      )
    ''')
    ..execute('''
      CREATE TABLE external_game_ids (
        id TEXT NOT NULL PRIMARY KEY,
        game_id TEXT NOT NULL REFERENCES games(id), provider TEXT NOT NULL,
        external_id TEXT NOT NULL, external_slug TEXT NULL,
        external_url TEXT NULL, matched_title TEXT NULL,
        created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL,
        deleted_at INTEGER NULL
      )
    ''')
    ..execute('''
      CREATE TABLE media_assets (
        id TEXT NOT NULL PRIMARY KEY,
        game_id TEXT NOT NULL REFERENCES games(id), kind TEXT NOT NULL,
        source TEXT NOT NULL, provider TEXT NULL, external_id TEXT NULL,
        remote_url TEXT NULL, local_path TEXT NOT NULL, file_name TEXT NOT NULL,
        mime_type TEXT NULL, width INTEGER NULL, height INTEGER NULL,
        hash TEXT NULL, is_selected INTEGER NOT NULL DEFAULT 0,
        attribution TEXT NULL, created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL, deleted_at INTEGER NULL
      )
    ''')
    ..execute('''
      CREATE TABLE sync_groups (
        id TEXT NOT NULL PRIMARY KEY, display_name TEXT NOT NULL,
        protocol_version INTEGER NOT NULL, key_id TEXT NULL,
        status TEXT NOT NULL, created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL, key_rotated_at INTEGER NULL
      )
    ''')
    ..execute('''
      CREATE TABLE sync_devices (
        id TEXT NOT NULL PRIMARY KEY, sync_group_id TEXT NULL,
        display_name TEXT NOT NULL, platform TEXT NOT NULL,
        is_local INTEGER NOT NULL DEFAULT 0, public_key TEXT NULL,
        fingerprint TEXT NULL, status TEXT NOT NULL,
        created_at INTEGER NOT NULL, paired_at INTEGER NULL,
        last_seen_at INTEGER NULL, last_sync_at INTEGER NULL,
        revoked_at INTEGER NULL
      )
    ''')
    ..execute('''
      CREATE TABLE sync_changes (
        change_id TEXT NOT NULL PRIMARY KEY, sync_group_id TEXT NULL,
        origin_device_id TEXT NOT NULL, origin_counter INTEGER NOT NULL,
        mutation_id TEXT NOT NULL, mutation_sequence INTEGER NOT NULL,
        entity_type TEXT NOT NULL, entity_id TEXT NOT NULL,
        operation TEXT NOT NULL, changed_fields_json TEXT NOT NULL,
        payload_json TEXT NOT NULL, snapshot_json TEXT NOT NULL,
        causal_context_json TEXT NOT NULL, source TEXT NOT NULL,
        content_hash TEXT NOT NULL, created_at INTEGER NOT NULL,
        applied_at INTEGER NULL,
        UNIQUE(origin_device_id, origin_counter)
      )
    ''')
    ..execute('''
      CREATE TABLE sync_tombstones (
        tombstone_id TEXT NOT NULL PRIMARY KEY, sync_group_id TEXT NULL,
        entity_type TEXT NOT NULL, entity_id TEXT NOT NULL,
        delete_change_id TEXT NOT NULL, origin_device_id TEXT NOT NULL,
        origin_counter INTEGER NOT NULL, causal_context_json TEXT NOT NULL,
        last_content_hash TEXT NULL, deleted_at INTEGER NOT NULL,
        fully_acknowledged_at INTEGER NULL, retain_until INTEGER NULL
      )
    ''')
    ..execute('''
      CREATE TABLE sync_states (
        id TEXT NOT NULL PRIMARY KEY, sync_group_id TEXT NULL,
        local_device_id TEXT NOT NULL, peer_device_id TEXT NULL,
        next_local_counter INTEGER NOT NULL DEFAULT 1,
        seen_vector_json TEXT NOT NULL DEFAULT '{}',
        peer_ack_vector_json TEXT NOT NULL DEFAULT '{}',
        last_exported_vector_json TEXT NOT NULL DEFAULT '{}',
        last_imported_package_id TEXT NULL,
        replica_epoch INTEGER NOT NULL DEFAULT 1,
        baseline_created INTEGER NOT NULL DEFAULT 0,
        requires_reconciliation INTEGER NOT NULL DEFAULT 0,
        last_successful_sync_at INTEGER NULL, updated_at INTEGER NOT NULL
      )
    ''')
    ..execute('''
      CREATE TABLE sync_entity_states (
        id TEXT NOT NULL PRIMARY KEY, sync_group_id TEXT NULL,
        entity_type TEXT NOT NULL, entity_id TEXT NOT NULL,
        field_versions_json TEXT NOT NULL, entity_vector_json TEXT NOT NULL,
        last_change_id TEXT NOT NULL, content_hash TEXT NOT NULL,
        is_deleted INTEGER NOT NULL DEFAULT 0, updated_at INTEGER NOT NULL
      )
    ''');

  for (final statement in <String>[
    'CREATE INDEX idx_sync_devices_group_status ON sync_devices(sync_group_id, status)',
    'CREATE UNIQUE INDEX idx_sync_devices_single_local ON sync_devices(is_local) WHERE is_local = 1',
    'CREATE INDEX idx_sync_changes_entity ON sync_changes(entity_type, entity_id)',
    'CREATE INDEX idx_sync_changes_mutation ON sync_changes(mutation_id, mutation_sequence)',
    'CREATE INDEX idx_sync_changes_origin ON sync_changes(sync_group_id, origin_device_id, origin_counter)',
    'CREATE INDEX idx_sync_tombstones_entity ON sync_tombstones(entity_type, entity_id)',
    'CREATE INDEX idx_sync_state_peer ON sync_states(sync_group_id, local_device_id, peer_device_id)',
    'CREATE INDEX idx_sync_entity_state_entity ON sync_entity_states(entity_type, entity_id)',
  ]) {
    database.execute(statement);
  }

  database
    ..execute(
      "INSERT INTO games VALUES ('game-active', 'Synthetic Game', 'synthetic game', 946684800000, 'game', 946684800000, 946684800000, NULL)",
    )
    ..execute(
      "INSERT INTO games VALUES ('game-deleted', 'Deleted Game', NULL, NULL, 'game', 946684800000, 946684800000, 946684800000)",
    )
    ..execute(
      "INSERT INTO library_entries VALUES ('entry-active', 'game-active', 'playing', 8, 'Synthetic notes', 946684800000, 946684800000, NULL)",
    )
    ..execute(
      "INSERT INTO library_entries VALUES ('entry-deleted', 'game-deleted', 'backlog', NULL, NULL, 946684800000, 946684800000, 946684800000)",
    )
    ..execute(
      "INSERT INTO platforms VALUES ('platform-pc', 'PC', 'PC', 946684800000, 946684800000, NULL)",
    )
    ..execute(
      "INSERT INTO library_entry_platforms VALUES ('entry-platform', 'entry-active', 'platform-pc', 1, 946684800000, 946684800000, NULL)",
    )
    ..execute(
      "INSERT INTO genres VALUES ('genre-rpg', 'RPG', 946684800000, 946684800000, NULL)",
    )
    ..execute(
      "INSERT INTO game_genres VALUES ('game-genre', 'game-active', 'genre-rpg', 946684800000, 946684800000, NULL)",
    )
    ..execute(
      "INSERT INTO playthroughs VALUES ('play-active', 'entry-active', 'platform-pc', 'active', 946684800000, NULL, 12.5, 9, 'Run notes', 946684800000, 946684800000, NULL)",
    )
    ..execute(
      "INSERT INTO playthroughs VALUES ('play-deleted', 'entry-deleted', NULL, 'planned', NULL, NULL, NULL, NULL, NULL, 946684800000, 946684800000, 946684800000)",
    )
    ..execute(
      "INSERT INTO saved_views VALUES ('view-custom', 'Playing', '{\"statuses\":[\"playing\"]}', '{\"field\":\"title\"}', '{\"title\":true}', 946684800000, 946684800000, NULL)",
    )
    ..execute(
      "INSERT INTO external_game_ids VALUES ('external-rawg', 'game-active', 'rawg', '123', 'synthetic-game', 'https://example.invalid/game/123', 'Synthetic Game', 946684800000, 946684800000, NULL)",
    )
    ..execute(
      "INSERT INTO media_assets VALUES ('media-cover', 'game-active', 'cover', 'local', NULL, NULL, NULL, 'media/games/game-active/cover.png', 'cover.png', 'image/png', 600, 900, 'synthetic-sha256', 1, 'Synthetic attribution', 946684800000, 946684800000, NULL)",
    )
    ..execute(
      "INSERT INTO sync_groups VALUES ('sync-group', 'Synthetic group', 1, 'sync-key', 'active', 946684800000, 946684800000, NULL)",
    )
    ..execute(
      "INSERT INTO sync_devices VALUES ('sync-device', 'sync-group', 'Synthetic device', 'test', 1, 'fake-public-key', 'fake-fingerprint', 'active', 946684800000, NULL, NULL, NULL, NULL)",
    )
    ..execute(
      "INSERT INTO sync_changes VALUES ('sync-change', 'sync-group', 'sync-device', 1, 'mutation-1', 0, 'game', 'game-active', 'upsert', '[\"title\"]', '{}', '{}', '{}', 'manual', 'fake-hash', 946684800000, NULL)",
    )
    ..execute(
      "INSERT INTO sync_tombstones VALUES ('sync-tombstone', 'sync-group', 'game', 'game-deleted', 'sync-change', 'sync-device', 2, '{}', 'fake-hash', 946684800000, NULL, NULL)",
    )
    ..execute(
      "INSERT INTO sync_states VALUES ('sync-state', 'sync-group', 'sync-device', NULL, 3, '{\"sync-device\":2}', '{}', '{}', NULL, 1, 1, 0, NULL, 946684800000)",
    )
    ..execute(
      "INSERT INTO sync_entity_states VALUES ('sync-entity', 'sync-group', 'game', 'game-active', '{}', '{}', 'sync-change', 'fake-hash', 0, 946684800000)",
    )
    ..execute('PRAGMA user_version = 5');
}
