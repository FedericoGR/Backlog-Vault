import 'dart:io';

import 'package:backlog_vault/core/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

import '../../fixtures/schema_v6_fixture.dart';

void main() {
  late Directory directory;
  late String path;
  late Database raw;

  setUp(() {
    directory = Directory.systemTemp.createTempSync('personal_record_v7_');
    path = '${directory.path}/fixture.sqlite';
    raw = sqlite3.open(path);
    createEmptySchemaV6(raw);
    for (final id in ['pc', 'switch', 'ps']) {
      raw.execute(
        'INSERT INTO platforms(id, name, created_at, updated_at) VALUES (?, ?, 1, 1)',
        [id, id],
      );
    }
  });

  tearDown(() {
    raw.close();
    directory.deleteSync(recursive: true);
  });

  void entry({String status = 'backlog', int? rating, bool deleted = false}) {
    raw.execute(
      "INSERT INTO games(id,title,created_at,updated_at) VALUES ('g','Game',1,2)",
    );
    raw.execute(
      '''
      INSERT INTO library_entries(id,game_id,status,personal_rating,personal_notes,
                                  created_at,updated_at,deleted_at)
      VALUES ('e','g',?,?,'  Keep my notes\nexactly.  ',1,2,?)
    ''',
      [status, rating, deleted ? 3 : null],
    );
  }

  void play(
    String id, {
    String status = 'completed',
    int? date,
    int updated = 10,
    double? hours,
    String? platform,
    int? rating,
    bool deleted = false,
  }) {
    raw.execute(
      '''
      INSERT INTO playthroughs(id,library_entry_id,platform_id,status,started_at,
        completed_at,hours_played,rating,notes,created_at,updated_at,deleted_at)
      VALUES (?,'e',?,?,1,?,?,?,'Legacy notes',1,?,?)
    ''',
      [
        id,
        platform,
        status,
        date,
        hours,
        rating,
        updated,
        deleted ? 1000 : null,
      ],
    );
  }

  void primary(String platform, {bool deleted = false, bool isPrimary = true}) {
    raw.execute(
      '''
      INSERT INTO library_entry_platforms(id,library_entry_id,platform_id,
        is_primary,created_at,updated_at,deleted_at) VALUES (?,'e',?,?,1,1,?)
    ''',
      [platform, platform, isPrimary ? 1 : 0, deleted ? 1000 : null],
    );
  }

  Future<LibraryEntry> migrate() async {
    final legacy =
        raw
            .select('SELECT * FROM playthroughs ORDER BY id')
            .map((r) => Map.of(r))
            .toList();
    final oldEntry = Map.of(raw.select('SELECT * FROM library_entries').single);
    final db = AppDatabase(NativeDatabase(File(path)));
    try {
      final result = await db.select(db.libraryEntries).getSingle();
      expect(db.schemaVersion, 8);
      expect(
        (await db.customSelect('PRAGMA user_version').getSingle()).read<int>(
          'user_version',
        ),
        8,
      );
      expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
      expect(
        raw
            .select('SELECT * FROM playthroughs ORDER BY id')
            .map((r) => Map.of(r))
            .toList(),
        legacy,
      );
      final migrated = raw.select('SELECT * FROM library_entries').single;
      for (final key in oldEntry.keys.where(
        (key) => key != 'personal_rating',
      )) {
        expect(migrated[key], oldEntry[key], reason: 'Preserve legacy $key');
      }
      return result;
    } finally {
      await db.close();
    }
  }

  test('completed game with one playthrough', () async {
    entry(status: 'completed');
    play('one', date: 100, hours: 12.5, platform: 'pc', rating: 4);
    final result = await migrate();
    expect(result.isCompleted, isTrue);
    expect(result.completedAt!.millisecondsSinceEpoch, 100000);
    expect(result.hoursPlayed, 12.5);
    expect(result.playedPlatformId, 'pc');
    expect(result.personalRating, 4);
  });

  test(
    'multiple completions choose latest date and aggregate all active hours',
    () async {
      entry(status: 'playing', rating: 5);
      play(
        'older',
        date: 100,
        updated: 900,
        hours: 5,
        platform: 'pc',
        rating: 2,
      );
      play(
        'newer',
        date: 200,
        updated: 300,
        hours: 8.5,
        platform: 'switch',
        rating: 4,
      );
      play(
        'paused',
        status: 'paused',
        date: 999,
        updated: 800,
        hours: 2,
        platform: 'ps',
      );
      play('dropped', status: 'dropped', hours: 1);
      play('null-hours');
      play(
        'deleted',
        date: 1000,
        hours: 100,
        rating: 1,
        platform: 'ps',
        deleted: true,
      );
      final result = await migrate();
      expect(result.isCompleted, isTrue);
      expect(result.completedAt!.millisecondsSinceEpoch, 200000);
      expect(result.hoursPlayed, 16.5);
      expect(result.playedPlatformId, 'switch');
      expect(result.personalRating, 5);
    },
  );

  test('no playthrough preserves nulls and existing rating', () async {
    entry(rating: 3);
    final result = await migrate();
    expect(result.isCompleted, isFalse);
    expect(result.completedAt, isNull);
    expect(result.hoursPlayed, isNull);
    expect(result.playedPlatformId, isNull);
    expect(result.personalRating, 3);
  });

  for (final status in [
    'playing',
    'paused',
    'backlog',
    'wishlist',
    'dropped',
    'retired',
  ]) {
    test('legacy $status stays pending, ignoring deleted completion', () async {
      entry(status: status);
      play('active', status: 'active', hours: 0, updated: 20, platform: 'pc');
      play('deleted', date: 200, hours: 99, deleted: true, platform: 'ps');
      final result = await migrate();
      expect(result.isCompleted, isFalse);
      expect(result.completedAt, isNull);
      expect(result.hoursPlayed, 0);
      expect(result.playedPlatformId, 'pc');
    });
  }

  test('legacy completed without playthrough does not require date', () async {
    entry(status: 'completed');
    final result = await migrate();
    expect(result.isCompleted, isTrue);
    expect(result.completedAt, isNull);
  });

  test('undated completion sets completion and supplies rating', () async {
    entry();
    play('one', platform: 'switch', rating: 4);
    final result = await migrate();
    expect(result.isCompleted, isTrue);
    expect(result.completedAt, isNull);
    expect(result.hoursPlayed, isNull);
    expect(result.personalRating, 4);
  });

  test(
    'latest completed rating is not taken from an older rated playthrough',
    () async {
      entry();
      play('older', date: 100, rating: 5);
      play('newer', date: 200);
      expect((await migrate()).personalRating, isNull);
    },
  );

  test(
    'platform falls back from null completed platform to latest updated',
    () async {
      entry();
      primary('ps');
      play('complete', date: 200, updated: 10);
      play('recent', status: 'active', updated: 20, platform: 'pc');
      expect((await migrate()).playedPlatformId, 'pc');
    },
  );

  test('platform falls back to active primary link', () async {
    entry();
    primary('ps', deleted: true);
    primary('pc', isPrimary: false);
    primary('switch');
    play('no-platform');
    expect((await migrate()).playedPlatformId, 'switch');
  });

  test('non-primary link alone is not chosen', () async {
    entry();
    primary('pc', isPrimary: false);
    expect((await migrate()).playedPlatformId, isNull);
  });

  test(
    'ties use update time then stable ID, independent of insertion order',
    () async {
      entry();
      play('z', date: 200, updated: 20, platform: 'ps', rating: 2);
      play('b', date: 200, updated: 30, platform: 'switch', rating: 3);
      play('a', date: 200, updated: 30, platform: 'pc', rating: 5);
      final result = await migrate();
      expect(result.playedPlatformId, 'pc');
      expect(result.personalRating, 5);
      final reopened = AppDatabase(NativeDatabase(File(path)));
      expect(
        await reopened.select(reopened.libraryEntries).getSingle(),
        result,
      );
      await reopened.close();
    },
  );

  test(
    'soft-deleted entries and their history are preserved and migrated',
    () async {
      entry(deleted: true);
      play('one', hours: 4, date: 100);
      final result = await migrate();
      expect(result.deletedAt, isNotNull);
      expect(result.isCompleted, isTrue);
    },
  );

  test(
    'migration failure rolls back columns, values and schema version',
    () async {
      entry();
      play('one', date: 100);
      raw.execute(
        "CREATE TRIGGER fail_migration BEFORE UPDATE ON library_entries BEGIN SELECT RAISE(ABORT, 'injected failure'); END",
      );
      final schemaBefore =
          raw
              .select('SELECT sql FROM sqlite_master ORDER BY name')
              .map((r) => r['sql'])
              .toList();
      final db = AppDatabase(NativeDatabase(File(path)));
      await expectLater(db.select(db.libraryEntries).get(), throwsA(anything));
      await db.close();
      expect(raw.select('PRAGMA user_version').single['user_version'], 6);
      expect(
        raw
            .select('SELECT sql FROM sqlite_master ORDER BY name')
            .map((r) => r['sql'])
            .toList(),
        schemaBefore,
      );
      expect(
        raw.select('SELECT status FROM library_entries').single['status'],
        'backlog',
      );
      expect(
        raw.select('SELECT COUNT(*) AS n FROM playthroughs').single['n'],
        1,
      );
      raw.execute('DROP TRIGGER fail_migration');
      expect((await migrate()).isCompleted, isTrue);
    },
  );
}
