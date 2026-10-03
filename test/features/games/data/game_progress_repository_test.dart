import 'package:backlog_vault/core/database/app_database.dart';
import 'package:backlog_vault/core/time/clock.dart';
import 'package:backlog_vault/features/games/application/game_form_model.dart';
import 'package:backlog_vault/features/games/application/game_progress_summary.dart';
import 'package:backlog_vault/features/games/data/game_repository.dart';
import 'package:backlog_vault/features/library/data/library_query_repository.dart';
import 'package:backlog_vault/features/library/domain/game_status.dart';
import 'package:backlog_vault/features/playthroughs/application/completion_form_model.dart';
import 'package:backlog_vault/features/playthroughs/data/playthrough_repository.dart';
import 'package:backlog_vault/features/playthroughs/domain/playthrough_status.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:test/test.dart';

void main() {
  late AppDatabase db;
  late GameRepository repository;
  late LibraryQueryRepository queryRepository;
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = GameRepository(db, clock: const _FixedClock());
    queryRepository = LibraryQueryRepository(db);
  });
  tearDown(() => db.close());

  test(
    'completion without a date writes one record and no playthrough',
    () async {
      await _seedGame(db, status: GameStatus.backlog);
      await repository.completeGame(
        const CompletionFormModel(
          libraryEntryId: 'entry-1',
          hoursPlayed: 12.5,
          rating: 4,
          platformId: 'pc',
        ),
      );
      final entry = await _entry(db);
      expect(entry.isCompleted, isTrue);
      expect(entry.completedAt, isNull);
      expect(entry.hoursPlayed, 12.5);
      expect(entry.playedPlatformId, 'pc');
      expect(entry.personalRating, 4);
      expect(entry.status, 'backlog');
      expect(await db.select(db.playthroughs).get(), isEmpty);
    },
  );

  test('completion and reopening preserve every legacy playthrough', () async {
    await _seedGame(db, status: GameStatus.playing);
    await _seedPlaythrough(
      db,
      status: PlaythroughStatus.active,
      hoursPlayed: 99,
    );
    final history = await PlaythroughRepository(db).history('entry-1');
    await repository.completeGame(
      CompletionFormModel(
        libraryEntryId: 'entry-1',
        completedAt: _now,
        hoursPlayed: 7.5,
      ),
    );
    await repository.markBacklog('entry-1');
    final entry = await _entry(db);
    expect(entry.isCompleted, isFalse);
    expect(entry.completedAt, _now);
    expect(entry.hoursPlayed, 7.5);
    expect(entry.status, 'playing');
    expect(await PlaythroughRepository(db).history('entry-1'), history);
  });

  test(
    'library, details and summaries ignore conflicting legacy totals/status',
    () async {
      await _seedGame(db, status: GameStatus.completed);
      await _seedPlaythrough(
        db,
        status: PlaythroughStatus.completed,
        completedAt: DateTime(2040),
        hoursPlayed: 999,
      );
      await (db.update(db.libraryEntries)).write(
        LibraryEntriesCompanion(
          isCompleted: const Value(false),
          completedAt: Value(_now),
          hoursPlayed: const Value(4),
          playedPlatformId: const Value('pc'),
        ),
      );
      final row = (await queryRepository.watchRows().first).single;
      final details = (await repository.getByEntryId('entry-1'))!;
      final summary = GameProgressSummary.fromDetails(details);
      expect(row.isCompleted, isFalse);
      expect(row.status, GameStatus.backlog);
      expect(row.hoursPlayed, 4);
      expect(row.completedAt, _now);
      expect(row.playedPlatformId, 'pc');
      expect(details.entry.isCompleted, isFalse);
      expect(details.entry.hoursPlayed, 4);
      expect(summary.totalHours, 4);
      expect(summary.latestCompletedAt, _now);
      expect(summary.playthroughCount, 1);
    },
  );

  test(
    'saving edits and clearing optional fields never changes history',
    () async {
      await _seedGame(db, status: GameStatus.completed);
      await _seedPlaythrough(
        db,
        status: PlaythroughStatus.completed,
        hoursPlayed: 20,
      );
      final history = await PlaythroughRepository(db).history('entry-1');
      await repository.save(
        GameFormModel(
          entryId: 'entry-1',
          gameId: 'game-1',
          title: 'Edited',
          isCompleted: true,
          completedAt: _now,
          hoursPlayed: 8,
          playedPlatformId: 'pc',
          personalRating: 5,
          personalNotes: 'Notes',
        ),
      );
      var entry = await _entry(db);
      expect(entry.isCompleted, isTrue);
      expect(entry.hoursPlayed, 8);
      expect(entry.personalNotes, 'Notes');
      await repository.save(
        const GameFormModel(
          entryId: 'entry-1',
          gameId: 'game-1',
          title: 'Edited',
          isCompleted: true,
        ),
      );
      entry = await _entry(db);
      expect(entry.isCompleted, isTrue);
      expect(entry.completedAt, isNull);
      expect(entry.hoursPlayed, isNull);
      expect(entry.playedPlatformId, isNull);
      expect(entry.personalRating, isNull);
      expect(await PlaythroughRepository(db).history('entry-1'), history);
    },
  );

  test('creating a personal record supports completed without date', () async {
    final id = await repository.save(
      const GameFormModel(title: 'New', isCompleted: true, hoursPlayed: 0),
    );
    final details = (await repository.getByEntryId(id))!;
    expect(details.entry.isCompleted, isTrue);
    expect(details.entry.hoursPlayed, 0);
    expect(details.entry.completedAt, isNull);
    expect(details.playthroughs, isEmpty);
  });

  test('invalid platform rolls back all completion changes', () async {
    await _seedGame(db, status: GameStatus.backlog);
    final before = await _entry(db);
    await expectLater(
      repository.completeGame(
        const CompletionFormModel(
          libraryEntryId: 'entry-1',
          platformId: 'missing',
          hoursPlayed: 4,
        ),
      ),
      throwsA(anything),
    );
    expect(await _entry(db), before);
  });

  test('entry stream reflects authoritative changes', () async {
    await _seedGame(db, status: GameStatus.backlog);
    final rows = queryRepository.watchRows();
    final emitted = <bool>[];
    final subscription = rows.listen(
      (rows) => emitted.add(rows.single.isCompleted),
    );
    await rows.first;
    await repository.completeGame(
      const CompletionFormModel(libraryEntryId: 'entry-1'),
    );
    await rows.firstWhere((rows) => rows.single.isCompleted);
    expect(emitted, contains(true));
    await subscription.cancel();
  });

  test('deleting game keeps legacy history for export', () async {
    await _seedGame(db, status: GameStatus.completed);
    await _seedPlaythrough(db, status: PlaythroughStatus.completed);
    final history = await PlaythroughRepository(db).history('entry-1');
    await repository.softDelete('entry-1');
    expect(await repository.getByEntryId('entry-1'), isNull);
    expect(await queryRepository.watchRows().first, isEmpty);
    expect(await PlaythroughRepository(db).history('entry-1'), history);
  });

  test('details include selected IGDB cover asset', () async {
    await _seedGame(db, status: GameStatus.backlog);
    await db
        .into(db.mediaAssets)
        .insert(
          MediaAssetsCompanion.insert(
            id: 'igdb-cover-1',
            gameId: 'game-1',
            kind: 'cover',
            source: 'igdb',
            provider: const Value('igdb'),
            externalId: const Value('456'),
            localPath: 'media/games/game-1/igdb-cover-1.jpg',
            fileName: 'igdb-cover-1.jpg',
            isSelected: const Value(true),
            createdAt: _now,
            updatedAt: _now,
          ),
        );

    final detail = await repository.getByEntryId('entry-1');

    expect(detail, isNotNull);
    expect(detail!.selectedCover, isNotNull);
    expect(detail.selectedCover!.provider, 'igdb');
    expect(detail.selectedCover!.source, 'igdb');
    expect(
      detail.selectedCover!.localPath,
      'media/games/game-1/igdb-cover-1.jpg',
    );
  });
}

final _now = DateTime(2026, 6, 10, 12);

class _FixedClock extends Clock {
  const _FixedClock();

  @override
  DateTime now() => _now;
}

Future<void> _seedGame(AppDatabase db, {required GameStatus status}) async {
  await db
      .into(db.games)
      .insert(
        GamesCompanion.insert(
          id: 'game-1',
          title: 'Hades',
          createdAt: _now,
          updatedAt: _now,
        ),
      );
  await db
      .into(db.libraryEntries)
      .insert(
        LibraryEntriesCompanion.insert(
          id: 'entry-1',
          gameId: 'game-1',
          status: status.name,
          isCompleted: Value(status == GameStatus.completed),
          createdAt: _now,
          updatedAt: _now,
        ),
      );
  await db
      .into(db.platforms)
      .insert(
        PlatformsCompanion.insert(
          id: 'pc',
          name: 'PC',
          createdAt: _now,
          updatedAt: _now,
        ),
      );
  await db
      .into(db.libraryEntryPlatforms)
      .insert(
        LibraryEntryPlatformsCompanion.insert(
          id: 'entry-platform-1',
          libraryEntryId: 'entry-1',
          platformId: 'pc',
          isPrimary: const Value(true),
          createdAt: _now,
          updatedAt: _now,
        ),
      );
}

Future<void> _seedPlaythrough(
  AppDatabase db, {
  required PlaythroughStatus status,
  DateTime? completedAt,
  double? hoursPlayed,
}) async {
  await _insertPlaythrough(
    db,
    id: 'playthrough-1',
    status: status,
    completedAt: completedAt,
    hoursPlayed: hoursPlayed,
  );
}

Future<void> _insertPlaythrough(
  AppDatabase db, {
  required String id,
  required PlaythroughStatus status,
  DateTime? completedAt,
  double? hoursPlayed,
}) async {
  await db
      .into(db.playthroughs)
      .insert(
        PlaythroughsCompanion.insert(
          id: id,
          libraryEntryId: 'entry-1',
          platformId: const Value('pc'),
          status: status.name,
          startedAt: Value(DateTime(2026, 6, 1)),
          completedAt: Value(completedAt),
          hoursPlayed: Value(hoursPlayed),
          createdAt: _now,
          updatedAt: _now,
        ),
      );
}

Future<LibraryEntry> _entry(AppDatabase db) {
  return db.select(db.libraryEntries).getSingle();
}
