import 'package:backlog_vault/core/database/app_database.dart';
import 'package:backlog_vault/core/time/clock.dart';
import 'package:backlog_vault/features/games/application/game_progress_summary.dart';
import 'package:backlog_vault/features/games/data/game_repository.dart';
import 'package:backlog_vault/features/library/data/library_query_repository.dart';
import 'package:backlog_vault/features/library/domain/game_status.dart';
import 'package:backlog_vault/features/playthroughs/application/completion_form_model.dart';
import 'package:backlog_vault/features/playthroughs/application/playthrough_form_model.dart';
import 'package:backlog_vault/features/playthroughs/domain/playthrough_status.dart';
import 'package:drift/drift.dart' hide isNull;
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

  tearDown(() async {
    await db.close();
  });

  test('backlog to playing creates active playthrough', () async {
    await _seedGame(db, status: GameStatus.backlog);

    await repository.markPlaying('entry-1');

    final entry = await _entry(db);
    final playthroughs = await db.select(db.playthroughs).get();
    expect(entry.status, GameStatus.playing.name);
    expect(playthroughs.single.status, PlaythroughStatus.active.name);
    expect(playthroughs.single.startedAt, _now);
  });

  test('playing to paused pauses active playthrough', () async {
    await _seedGame(db, status: GameStatus.playing);
    await _seedPlaythrough(db, status: PlaythroughStatus.active);

    await repository.markPaused('entry-1');

    expect((await _entry(db)).status, GameStatus.paused.name);
    expect((await _playthrough(db)).status, PlaythroughStatus.paused.name);
  });

  test('paused to playing reactivates paused playthrough', () async {
    await _seedGame(db, status: GameStatus.paused);
    await _seedPlaythrough(db, status: PlaythroughStatus.paused);

    await repository.markPlaying('entry-1');

    expect((await _entry(db)).status, GameStatus.playing.name);
    expect((await _playthrough(db)).status, PlaythroughStatus.active.name);
  });

  test('playing to completed closes active playthrough', () async {
    await _seedGame(db, status: GameStatus.playing);
    await _seedPlaythrough(db, status: PlaythroughStatus.active);

    await repository.completeGame(
      CompletionFormModel(
        libraryEntryId: 'entry-1',
        completedAt: DateTime(2026, 6, 11),
        hoursPlayed: 12,
        rating: 4,
      ),
    );

    final entry = await _entry(db);
    final playthrough = await _playthrough(db);
    expect(entry.status, GameStatus.completed.name);
    expect(entry.personalRating, 4);
    expect(playthrough.status, PlaythroughStatus.completed.name);
    expect(playthrough.completedAt, DateTime(2026, 6, 11));
    expect(playthrough.hoursPlayed, 12);
  });

  test('completed without playthrough creates completed playthrough', () async {
    await _seedGame(db, status: GameStatus.backlog);

    await repository.completeGame(
      CompletionFormModel(
        libraryEntryId: 'entry-1',
        completedAt: DateTime(2026, 6, 11),
      ),
    );

    final playthroughs = await db.select(db.playthroughs).get();
    expect((await _entry(db)).status, GameStatus.completed.name);
    expect(playthroughs.single.status, PlaythroughStatus.completed.name);
    expect(playthroughs.single.completedAt, DateTime(2026, 6, 11));
  });

  test('playing to dropped closes active playthrough as dropped', () async {
    await _seedGame(db, status: GameStatus.playing);
    await _seedPlaythrough(db, status: PlaythroughStatus.active);

    await repository.markDropped('entry-1');

    expect((await _entry(db)).status, GameStatus.dropped.name);
    expect((await _playthrough(db)).status, PlaythroughStatus.dropped.name);
  });

  test('playing to backlog updates entry without deleting history', () async {
    await _seedGame(db, status: GameStatus.playing);
    await _seedPlaythrough(db, status: PlaythroughStatus.active);

    await repository.markBacklog('entry-1');

    expect((await _entry(db)).status, GameStatus.backlog.name);
    final playthroughs = await db.select(db.playthroughs).get();
    expect(playthroughs.single.status, PlaythroughStatus.active.name);
    expect(playthroughs.single.deletedAt, isNull);
  });

  test('editing playthrough updates fields', () async {
    await _seedGame(db, status: GameStatus.playing);
    await _seedPlaythrough(db, status: PlaythroughStatus.active);

    await repository.savePlaythrough(
      PlaythroughFormModel(
        playthroughId: 'playthrough-1',
        libraryEntryId: 'entry-1',
        platformId: 'pc',
        status: PlaythroughStatus.completed,
        startedAt: DateTime(2026, 6, 1),
        completedAt: DateTime(2026, 6, 9),
        hoursPlayed: 20,
        rating: 5,
        notes: 'Gran cierre',
      ),
    );

    final playthrough = await _playthrough(db);
    expect(playthrough.status, PlaythroughStatus.completed.name);
    expect(playthrough.platformId, 'pc');
    expect(playthrough.completedAt, DateTime(2026, 6, 9));
    expect(playthrough.hoursPlayed, 20);
    expect(playthrough.rating, 5);
    expect(playthrough.notes, 'Gran cierre');
  });

  test('soft-delete playthrough hides it from details and summary', () async {
    await _seedGame(db, status: GameStatus.completed);
    await _seedPlaythrough(
      db,
      status: PlaythroughStatus.completed,
      completedAt: DateTime(2026, 6, 9),
      hoursPlayed: 10,
    );

    await repository.softDeletePlaythrough('playthrough-1');

    final detail = await repository.getByEntryId('entry-1');
    final summary = GameProgressSummary.fromDetails(detail!);
    expect(detail.playthroughs, isEmpty);
    expect(summary.playthroughCount, 0);
    expect(summary.totalHours, isNull);
    expect(summary.latestCompletedAt, isNull);
  });

  test('advanced table projection reflects progress changes', () async {
    await _seedGame(db, status: GameStatus.backlog);

    await repository.markPlaying('entry-1');

    var rows = await queryRepository.watchRows().first;
    expect(rows.single.status, GameStatus.playing);
    expect(rows.single.playthroughCount, 1);

    await repository.completeGame(
      CompletionFormModel(
        libraryEntryId: 'entry-1',
        completedAt: DateTime(2026, 6, 11),
        hoursPlayed: 7.5,
      ),
    );

    rows = await queryRepository.watchRows().first;
    expect(rows.single.status, GameStatus.completed);
    expect(rows.single.completedAt, DateTime(2026, 6, 11));
    expect(rows.single.hoursPlayed, 7.5);
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
  await db
      .into(db.playthroughs)
      .insert(
        PlaythroughsCompanion.insert(
          id: 'playthrough-1',
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

Future<Playthrough> _playthrough(AppDatabase db) {
  return db.select(db.playthroughs).getSingle();
}
