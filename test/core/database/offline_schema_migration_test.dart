import 'dart:io';

import 'package:backlog_vault/core/database/app_database.dart';
import 'package:backlog_vault/core/version/app_versions.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:test/test.dart';

import '../../fixtures/schema_v5_fixture.dart';

void main() {
  test(
    'migrates the complete synthetic schema 5 fixture to annual log 8',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'backlog_vault_v5_',
      );
      final file = File('${directory.path}/fixture.sqlite');
      addTearDown(() => directory.delete(recursive: true));

      final db = AppDatabase(
        NativeDatabase(file, setup: createSchemaV5Fixture),
      );

      expect(databaseSchemaVersion, 8);
      expect(db.schemaVersion, 8);
      expect(await _userVersion(db), 8);

      for (final entry in schemaV5FunctionalCounts.entries) {
        expect(
          await _count(db, entry.key),
          entry.value,
          reason: '${entry.key} count must survive 5→8',
        );
      }
      for (final table in functionalTableNames) {
        expect(await _objectExists(db, 'table', table), isTrue);
      }
      for (final table in syncTableNames) {
        expect(await _objectExists(db, 'table', table), isFalse);
      }
      for (final index in syncIndexNames) {
        expect(await _objectExists(db, 'index', index), isFalse);
      }

      final activeGame =
          await (db.select(db.games)
            ..where((row) => row.id.equals('game-active'))).getSingle();
      final deletedGame =
          await (db.select(db.games)
            ..where((row) => row.id.equals('game-deleted'))).getSingle();
      final playthrough =
          await (db.select(db.playthroughs)
            ..where((row) => row.id.equals('play-active'))).getSingle();
      final view = await db.select(db.savedViews).getSingle();
      final externalId = await db.select(db.externalGameIds).getSingle();
      final media = await db.select(db.mediaAssets).getSingle();

      expect(activeGame.title, 'Synthetic Game');
      expect(deletedGame.deletedAt, isNotNull);
      expect(playthrough.libraryEntryId, 'entry-active');
      expect(playthrough.platformId, 'platform-pc');
      expect(playthrough.hoursPlayed, 12.5);
      expect(view.filterJson, contains('playing'));
      expect(externalId.provider, 'rawg');
      expect(media.localPath, 'media/games/game-active/cover.png');
      expect(media.isSelected, isTrue);
      expect(await _foreignKeyViolations(db), isEmpty);

      await db
          .into(db.games)
          .insert(
            GamesCompanion.insert(
              id: 'game-after-migration',
              title: 'Writable after migration',
              createdAt: DateTime.utc(2026),
              updatedAt: DateTime.utc(2026),
            ),
          );
      expect(await _count(db, 'games'), 3);
      await db.close();

      final reopened = AppDatabase(NativeDatabase(file));
      expect(await _userVersion(reopened), 8);
      expect(await _count(reopened, 'games'), 3);
      expect(await _foreignKeyViolations(reopened), isEmpty);
      await reopened.close();
    },
  );

  test(
    'rejects an incomplete schema 5 without dropping available data',
    () async {
      final executor = NativeDatabase.memory(
        setup: (database) {
          database
            ..execute('''
            CREATE TABLE games (
              id TEXT NOT NULL PRIMARY KEY, title TEXT NOT NULL,
              sort_title TEXT NULL, release_date INTEGER NULL,
              type TEXT NOT NULL DEFAULT 'game', created_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL, deleted_at INTEGER NULL
            )
          ''')
            ..execute(
              "INSERT INTO games VALUES ('survivor', 'Still here', NULL, NULL, 'game', 0, 0, NULL)",
            )
            ..execute('PRAGMA user_version = 5');
        },
      );
      final db = AppDatabase(executor);

      await expectLater(
        db.customSelect('SELECT 1').get(),
        throwsA(isA<StateError>()),
      );
      await db.close();
    },
  );
}

Future<int> _count(AppDatabase db, String table) {
  return db
      .customSelect('SELECT COUNT(*) AS row_count FROM $table')
      .map((row) => row.read<int>('row_count'))
      .getSingle();
}

Future<int> _userVersion(AppDatabase db) {
  return db
      .customSelect('PRAGMA user_version')
      .map((row) => row.read<int>('user_version'))
      .getSingle();
}

Future<bool> _objectExists(AppDatabase db, String type, String name) async {
  final row =
      await db
          .customSelect(
            'SELECT name FROM sqlite_master WHERE type = ? AND name = ?',
            variables: [Variable<String>(type), Variable<String>(name)],
          )
          .getSingleOrNull();
  return row != null;
}

Future<List<QueryRow>> _foreignKeyViolations(AppDatabase db) {
  return db.customSelect('PRAGMA foreign_key_check').get();
}
