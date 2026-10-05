import 'package:backlog_vault/core/database/app_database.dart';
import 'package:backlog_vault/features/games/application/game_form_model.dart';
import 'package:backlog_vault/features/games/data/game_repository.dart';
import 'package:backlog_vault/features/import_export/library_export/data/library_export_repository.dart';
import 'package:backlog_vault/features/library/data/library_query_repository.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

void main() {
  late AppDatabase db;
  late GameRepository repository;
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = GameRepository(db);
  });
  tearDown(() => db.close());

  test(
    'unfinished personal record belongs to a year, edits independently and exports it',
    () async {
      final id = await repository.save(
        GameFormModel(
          title: 'Unfinished',
          playedYear: 2026,
          hoursPlayed: 18,
          releaseDate: DateTime(1999),
        ),
      );
      var detail = (await repository.getByEntryId(id))!;
      expect(detail.entry.isCompleted, isFalse);
      expect(detail.entry.playedYear, 2026);
      expect(
        (await LibraryQueryRepository(db).watchRows().first).single.playedYear,
        2026,
      );
      await repository.save(
        GameFormModel(
          title: detail.game.title,
          gameId: detail.game.id,
          entryId: id,
          isCompleted: true,
          completedAt: DateTime(2027),
          playedYear: 2025,
          hoursPlayed: 18,
        ),
      );
      detail = (await repository.getByEntryId(id))!;
      expect(detail.entry.playedYear, 2025);
      final export =
          await LibraryExportRepository(
            db,
            sourcePlatform: 'windows',
          ).createDocument();
      expect(export.libraryEntries.single['playedYear'], 2025);
      expect(export.libraryEntries.single['hoursPlayed'], 18);
      await repository.save(
        GameFormModel(
          title: detail.game.title,
          gameId: detail.game.id,
          entryId: id,
          completedAt: DateTime(2027),
          playedYear: null,
        ),
      );
      expect((await repository.getByEntryId(id))!.entry.playedYear, isNull);
      expect(await db.select(db.playthroughs).get(), isEmpty);
    },
  );

  test(
    'catalog release year and timestamps never substitute for an unknown played year',
    () async {
      final id = await repository.save(
        GameFormModel(title: 'Unknown', releaseDate: DateTime(2026)),
      );
      expect((await repository.getByEntryId(id))!.entry.playedYear, isNull);
      expect(
        (await LibraryQueryRepository(db).watchRows().first).single.playedYear,
        isNull,
      );
    },
  );

  test(
    'out-of-range played year is rejected before writing any game',
    () async {
      for (final year in [0, -1, 10000]) {
        await expectLater(
          repository.save(GameFormModel(title: 'Invalid', playedYear: year)),
          throwsArgumentError,
        );
      }
      expect(await db.select(db.games).get(), isEmpty);
    },
  );
}
