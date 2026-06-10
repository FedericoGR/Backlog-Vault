import 'package:backlog_vault/core/database/app_database.dart';
import 'package:backlog_vault/features/library/data/library_query_repository.dart';
import 'package:backlog_vault/features/library/domain/game_status.dart';
import 'package:backlog_vault/features/playthroughs/domain/playthrough_status.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

void main() {
  late AppDatabase db;
  late LibraryQueryRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = LibraryQueryRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'projects library rows in batch and excludes soft-deleted records',
    () async {
      final now = DateTime(2026, 6, 9);
      await db
          .into(db.games)
          .insert(
            GamesCompanion.insert(
              id: 'game-1',
              title: 'Hades',
              sortTitle: const Value('hades'),
              releaseDate: Value(DateTime(2020, 9, 17)),
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
              status: GameStatus.completed.name,
              personalRating: const Value(5),
              personalNotes: const Value('Gran run.'),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.platforms)
          .insert(
            PlatformsCompanion.insert(
              id: 'pc',
              name: 'PC',
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.libraryEntryPlatforms)
          .insert(
            LibraryEntryPlatformsCompanion.insert(
              id: 'entry-platform-1',
              libraryEntryId: 'entry-1',
              platformId: 'pc',
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.genres)
          .insert(
            GenresCompanion.insert(
              id: 'roguelite',
              name: 'Roguelite',
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.gameGenres)
          .insert(
            GameGenresCompanion.insert(
              id: 'game-genre-1',
              gameId: 'game-1',
              genreId: 'roguelite',
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
              completedAt: Value(DateTime(2026, 1, 2)),
              hoursPlayed: const Value(10),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.playthroughs)
          .insert(
            PlaythroughsCompanion.insert(
              id: 'playthrough-2',
              libraryEntryId: 'entry-1',
              status: PlaythroughStatus.completed.name,
              completedAt: Value(DateTime(2026, 2, 2)),
              hoursPlayed: const Value(20),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.mediaAssets)
          .insert(
            MediaAssetsCompanion.insert(
              id: 'cover-1',
              gameId: 'game-1',
              kind: 'cover',
              source: 'local',
              localPath: 'media/games/game-1/cover-1.png',
              fileName: 'cover-1.png',
              isSelected: const Value(true),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.externalGameIds)
          .insert(
            ExternalGameIdsCompanion.insert(
              id: 'external-1',
              gameId: 'game-1',
              provider: 'rawg',
              externalId: '123',
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.externalGameIds)
          .insert(
            ExternalGameIdsCompanion.insert(
              id: 'external-deleted',
              gameId: 'game-1',
              provider: 'steamgriddb',
              externalId: '456',
              createdAt: now,
              updatedAt: now,
              deletedAt: Value(now),
            ),
          );
      await db
          .into(db.games)
          .insert(
            GamesCompanion.insert(
              id: 'deleted-game',
              title: 'Deleted',
              createdAt: now,
              updatedAt: now,
              deletedAt: Value(now),
            ),
          );
      await db
          .into(db.libraryEntries)
          .insert(
            LibraryEntriesCompanion.insert(
              id: 'deleted-entry',
              gameId: 'deleted-game',
              status: GameStatus.backlog.name,
              createdAt: now,
              updatedAt: now,
              deletedAt: Value(now),
            ),
          );

      final rows = await repository.watchRows().first;

      expect(rows, hasLength(1));
      expect(rows.single.title, 'Hades');
      expect(rows.single.platforms.single.name, 'PC');
      expect(rows.single.genres.single.name, 'Roguelite');
      expect(rows.single.completedAt, DateTime(2026, 2, 2));
      expect(rows.single.hoursPlayed, 30);
      expect(rows.single.playthroughCount, 2);
      expect(rows.single.updatedAt, now);
      expect(
        rows.single.selectedCoverLocalPath,
        'media/games/game-1/cover-1.png',
      );
      expect(rows.single.hasExternalMetadata, isTrue);
    },
  );
}
