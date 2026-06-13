import 'package:backlog_vault/core/database/app_database.dart';
import 'package:backlog_vault/features/playthroughs/domain/playthrough_status.dart';
import 'package:backlog_vault/features/statistics/data/statistics_repository.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

void main() {
  late AppDatabase db;
  late StatisticsRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = StatisticsRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('watches playthroughs and excludes soft-deleted rows', () async {
    final now = DateTime(2026, 6, 13);
    await db
        .into(db.games)
        .insert(
          GamesCompanion.insert(
            id: 'game-1',
            title: 'Hades',
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db
        .into(db.libraryEntries)
        .insert(
          LibraryEntriesCompanion.insert(
            id: 'entry-1',
            gameId: 'game-1',
            status: 'completed',
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db
        .into(db.playthroughs)
        .insert(
          PlaythroughsCompanion.insert(
            id: 'playthrough-1',
            libraryEntryId: 'entry-1',
            status: PlaythroughStatus.completed.name,
            completedAt: Value(DateTime(2026, 1, 1)),
            hoursPlayed: const Value(12),
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db
        .into(db.playthroughs)
        .insert(
          PlaythroughsCompanion.insert(
            id: 'playthrough-deleted',
            libraryEntryId: 'entry-1',
            status: PlaythroughStatus.completed.name,
            completedAt: Value(DateTime(2026, 2, 1)),
            hoursPlayed: const Value(99),
            createdAt: now,
            updatedAt: now,
            deletedAt: Value(now),
          ),
        );

    final rows = await repository.watchPlaythroughs().first;

    expect(rows, hasLength(1));
    expect(rows.single.libraryEntryId, 'entry-1');
    expect(rows.single.status, PlaythroughStatus.completed);
    expect(rows.single.completedAt, DateTime(2026, 1, 1));
    expect(rows.single.hoursPlayed, 12);
  });
}
