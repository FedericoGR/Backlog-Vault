import 'dart:io';

import 'package:backlog_vault/core/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

import '../../fixtures/schema_v6_fixture.dart';

void main() {
  late Directory directory;
  late File file;
  late Database raw;
  setUp(() {
    directory = Directory.systemTemp.createTempSync('played_year_v8_');
    file = File('${directory.path}/fixture.sqlite');
    raw = sqlite3.open(file.path);
    createEmptySchemaV6(raw);
    raw.execute(
      'ALTER TABLE library_entries ADD COLUMN is_completed INTEGER NOT NULL DEFAULT 0',
    );
    raw.execute('ALTER TABLE library_entries ADD COLUMN completed_at INTEGER');
    raw.execute('ALTER TABLE library_entries ADD COLUMN hours_played REAL');
    raw.execute(
      'ALTER TABLE library_entries ADD COLUMN played_platform_id TEXT REFERENCES platforms(id)',
    );
    raw.execute('PRAGMA user_version = 7');
  });
  tearDown(() {
    raw.close();
    directory.deleteSync(recursive: true);
  });

  void entry(
    String id, {
    DateTime? completedAt,
    bool completed = false,
    bool deleted = false,
  }) {
    raw.execute(
      'INSERT INTO games(id,title,release_date,created_at,updated_at) VALUES (?,?,?,1,2)',
      [id, id, DateTime(1999).millisecondsSinceEpoch ~/ 1000],
    );
    raw.execute(
      '''INSERT INTO library_entries
      (id,game_id,status,is_completed,completed_at,hours_played,personal_rating,personal_notes,created_at,updated_at,deleted_at)
      VALUES (?,?,'paused',?,?,18,4,'Original notes',1,2,?)''',
      [
        id,
        id,
        completed ? 1 : 0,
        completedAt == null ? null : completedAt.millisecondsSinceEpoch ~/ 1000,
        deleted ? 3 : null,
      ],
    );
  }

  test(
    'v7 dates establish played year while all original values and history survive',
    () async {
      entry('finished', completed: true, completedAt: DateTime(2025, 12, 31));
      entry('boundary', completed: true, completedAt: DateTime(2026, 1, 1));
      entry('unfinished-dated', completedAt: DateTime(2024, 6, 1));
      entry('unknown');
      entry('completed-no-date', completed: true);
      entry('deleted', deleted: true, completedAt: DateTime(2020));
      raw.execute(
        "INSERT INTO playthroughs(id,library_entry_id,status,hours_played,created_at,updated_at) VALUES ('legacy','unknown','active',18,1,2)",
      );
      raw.execute(
        "INSERT INTO saved_views(id,name,filter_json,sort_json,column_config_json,created_at,updated_at) VALUES ('view','Saved','{}','{}','{}',1,2)",
      );
      final before =
          raw
              .select('SELECT * FROM library_entries ORDER BY id')
              .map(Map.of)
              .toList();
      final history =
          raw.select('SELECT * FROM playthroughs').map(Map.of).toList();
      final views =
          raw.select('SELECT * FROM saved_views').map(Map.of).toList();
      final db = AppDatabase(NativeDatabase(file));
      final entries = await db.select(db.libraryEntries).get();
      expect(
        {for (final e in entries) e.id: e.playedYear},
        {
          'finished': 2025,
          'boundary': 2026,
          'unfinished-dated': 2024,
          'unknown': null,
          'completed-no-date': null,
          'deleted': 2020,
        },
      );
      expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
      await db.close();
      final after = raw.select('SELECT * FROM library_entries ORDER BY id');
      for (var i = 0; i < before.length; i++) {
        expect({
          for (final key in before[i].keys) key: after[i][key],
        }, before[i]);
      }
      expect(
        raw.select('SELECT * FROM playthroughs').map(Map.of).toList(),
        history,
      );
      expect(
        raw.select('SELECT * FROM saved_views').map(Map.of).toList(),
        views,
      );
      expect(raw.select('PRAGMA user_version').single['user_version'], 8);
      final reopened = AppDatabase(NativeDatabase(file));
      expect(
        (await reopened.select(reopened.libraryEntries).get()).map(
          (e) => e.playedYear,
        ),
        entries.map((e) => e.playedYear),
      );
      await reopened.close();
    },
  );

  test(
    'failed v8 backfill rolls back column and version, then retries safely',
    () async {
      entry('dated', completedAt: DateTime(2026));
      raw.execute(
        "CREATE TRIGGER fail_year BEFORE UPDATE ON library_entries BEGIN SELECT RAISE(ABORT, 'injected'); END",
      );
      final before =
          raw
              .select('SELECT sql FROM sqlite_master ORDER BY name')
              .map((r) => r['sql'])
              .toList();
      final db = AppDatabase(NativeDatabase(file));
      await expectLater(db.select(db.libraryEntries).get(), throwsA(anything));
      await db.close();
      expect(raw.select('PRAGMA user_version').single['user_version'], 7);
      expect(
        raw
            .select('SELECT sql FROM sqlite_master ORDER BY name')
            .map((r) => r['sql'])
            .toList(),
        before,
      );
      raw.execute('DROP TRIGGER fail_year');
      final retry = AppDatabase(NativeDatabase(file));
      expect(
        (await retry.select(retry.libraryEntries).getSingle()).playedYear,
        2026,
      );
      await retry.close();
    },
  );
}
