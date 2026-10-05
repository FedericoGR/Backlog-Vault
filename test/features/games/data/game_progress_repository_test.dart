import 'package:backlog_vault/core/database/app_database.dart';
import 'package:backlog_vault/features/games/application/game_form_model.dart';
import 'package:backlog_vault/features/games/data/game_repository.dart';
import 'package:backlog_vault/features/library/data/library_query_repository.dart';
import 'package:backlog_vault/features/library/domain/game_status.dart';
import 'package:backlog_vault/features/statistics/application/library_statistics_calculator.dart';
import 'package:backlog_vault/features/import_export/library_export/data/library_export_repository.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:test/test.dart';

void main() {
  late AppDatabase db;
  late GameRepository games;
  late LibraryQueryRepository library;
  final date = DateTime(2026, 8, 20);
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    games = GameRepository(db);
    library = LibraryQueryRepository(db);
    for (final id in ['catalog-pc', 'played-switch']) {
      await db
          .into(db.platforms)
          .insert(
            PlatformsCompanion.insert(
              id: id,
              name: id == 'catalog-pc' ? 'PC' : 'Switch',
              createdAt: date,
              updatedAt: date,
            ),
          );
    }
  });
  tearDown(() => db.close());

  Future<String> create({bool completed = false}) => games.save(
    GameFormModel(
      title: 'Game',
      isCompleted: completed,
      platformIds: const ['catalog-pc'],
    ),
  );
  Future<void> edit(
    String id, {
    bool completed = true,
    DateTime? completedAt,
    double? hours = 7.5,
    String? platform = 'played-switch',
    int? rating = 4,
    String? notes = 'Personal notes',
  }) async {
    final details = (await games.getByEntryId(id))!;
    await games.save(
      GameFormModel(
        entryId: id,
        gameId: details.game.id,
        title: details.game.title,
        isCompleted: completed,
        playedYear: 2026,
        completedAt: completedAt,
        hoursPlayed: hours,
        playedPlatformId: platform,
        personalRating: rating,
        personalNotes: notes,
        platformIds: const ['catalog-pc'],
      ),
    );
  }

  Future<void> history(String id) async {
    for (var i = 0; i < 3; i++) {
      await db
          .into(db.playthroughs)
          .insert(
            PlaythroughsCompanion.insert(
              id: 'legacy-$i',
              libraryEntryId: id,
              status: 'completed',
              completedAt: Value(DateTime(2040)),
              hoursPlayed: const Value(999),
              rating: const Value(1),
              notes: const Value('Historical notes'),
              platformId: const Value('catalog-pc'),
              createdAt: date,
              updatedAt: date,
              deletedAt: Value(i == 2 ? date : null),
            ),
          );
    }
  }

  for (final completed in [false, true]) {
    test(
      'creates ${completed ? "completed" : "pending"} without requiring a date or playthrough',
      () async {
        final id = await create(completed: completed);
        final details = (await games.getByEntryId(id))!;
        expect(details.entry.isCompleted, completed);
        expect(details.entry.completedAt, isNull);
        expect(details.entry.hoursPlayed, isNull);
        expect(details.entry.playedPlatformId, isNull);
        expect(await db.select(db.playthroughs).get(), isEmpty);
        expect(await library.watchRows().first, hasLength(1));
      },
    );
  }
  test(
    'pending to completed to pending uses one record and preserves personal values',
    () async {
      final id = await create();
      await edit(id, completedAt: date);
      expect((await games.getByEntryId(id))!.entry.isCompleted, isTrue);
      await edit(id, completed: false, completedAt: date);
      final entry = (await games.getByEntryId(id))!.entry;
      expect(entry.isCompleted, isFalse);
      expect(entry.completedAt, date);
      expect(entry.hoursPlayed, 7.5);
      expect(await db.select(db.libraryEntries).get(), hasLength(1));
      expect(await db.select(db.playthroughs).get(), isEmpty);
    },
  );
  test(
    'edits and clears date, hours, platform, rating and notes independently of history',
    () async {
      final id = await create(completed: true);
      await history(id);
      final before = await db.select(db.playthroughs).get();
      await edit(id, completedAt: date);
      final editedDate = DateTime(2026, 9, 21);
      await edit(
        id,
        completedAt: editedDate,
        hours: 11,
        platform: 'catalog-pc',
        rating: 5,
        notes: 'Updated notes',
      );
      var entry = (await games.getByEntryId(id))!.entry;
      expect(entry.completedAt, editedDate);
      expect(entry.hoursPlayed, 11);
      expect(entry.playedPlatformId, 'catalog-pc');
      expect(entry.personalRating, 5);
      expect(entry.personalNotes, 'Updated notes');
      await edit(id, hours: null, platform: null, rating: null, notes: null);
      entry = (await games.getByEntryId(id))!.entry;
      expect(entry.isCompleted, isTrue);
      expect(entry.completedAt, isNull);
      expect(entry.hoursPlayed, isNull);
      expect(entry.playedPlatformId, isNull);
      expect(entry.personalRating, isNull);
      expect(entry.personalNotes, isNull);
      expect(await db.select(db.playthroughs).get(), before);
    },
  );
  for (final legacy in [
    'playing',
    'paused',
    'dropped',
    'retired',
    'wishlist',
    'backlog',
    'completed',
  ]) {
    for (final completed in [false, true]) {
      test(
        'legacy $legacy with isCompleted=$completed is interpreted only through boolean',
        () async {
          final id = await create(completed: completed);
          await db
              .update(db.libraryEntries)
              .write(LibraryEntriesCompanion(status: Value(legacy)));
          final row = (await library.watchRows().first).single;
          expect(
            row.status,
            completed ? GameStatus.completed : GameStatus.pending,
          );
          expect((await games.getByEntryId(id))!.entry.isCompleted, completed);
          await edit(id, completed: completed);
          expect(
            (await db.select(db.libraryEntries).getSingle()).status,
            legacy,
          );
        },
      );
    }
  }
  test(
    'multiple legacy rows never duplicate game or personal statistics and still export',
    () async {
      final id = await create();
      await history(id);
      final before = await db.select(db.playthroughs).get();
      await edit(id, completedAt: date);
      final rows = await library.watchRows().first;
      expect(rows, hasLength(1));
      expect(rows.single.personalNotes, 'Personal notes');
      expect(rows.single.platforms.single.id, 'catalog-pc');
      expect(rows.single.playedPlatformId, 'played-switch');
      final stats = const LibraryStatisticsCalculator().calculate(
        rows: rows,
        year: 2026,
      );
      expect(stats.totalGames, 1);
      expect(stats.completedCount, 1);
      expect(stats.totalHours, 7.5);
      expect(stats.averageRating, 4);
      expect(stats.platformBreakdown.single.id, 'played-switch');
      expect(stats.platformBreakdown.single.name, 'Switch');
      expect(stats.favorites.single.completedAt, date);
      final export =
          await LibraryExportRepository(
            db,
            sourcePlatform: 'windows',
          ).createDocument();
      expect(export.playthroughs, hasLength(3));
      expect(export.libraryEntries.single['personalRating'], 4);
      expect(export.libraryEntries.single['personalNotes'], 'Personal notes');
      expect(await db.select(db.playthroughs).get(), before);
      await games.softDelete(id);
      expect(await library.watchRows().first, isEmpty);
      expect(await db.select(db.playthroughs).get(), before);
    },
  );
  test(
    'archived personal platform resolves separately from catalog links',
    () async {
      final id = await create();
      await edit(id);
      await (db.update(db.platforms)..where(
        (p) => p.id.equals('played-switch'),
      )).write(PlatformsCompanion(deletedAt: Value(date)));
      final details = (await games.getByEntryId(id))!;
      expect(details.platforms.single.name, 'PC');
      expect(details.playedPlatform!.name, 'Switch');
      expect(
        (await library.watchRows().first).single.playedPlatform!.name,
        'Switch',
      );
    },
  );
  test(
    'invalid personal platform rolls back entry and catalog edits',
    () async {
      final id = await create();
      final before = await db.select(db.libraryEntries).getSingle();
      await expectLater(edit(id, platform: 'missing'), throwsA(anything));
      expect(await db.select(db.libraryEntries).getSingle(), before);
    },
  );
}
