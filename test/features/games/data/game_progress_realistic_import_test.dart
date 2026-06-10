import 'dart:io';

import 'package:backlog_vault/core/database/app_database.dart';
import 'package:backlog_vault/features/games/data/game_repository.dart';
import 'package:backlog_vault/features/import_export/notion_csv/application/build_import_preview_use_case.dart';
import 'package:backlog_vault/features/import_export/notion_csv/application/detect_notion_csv_mapping_use_case.dart';
import 'package:backlog_vault/features/import_export/notion_csv/data/csv_parser.dart';
import 'package:backlog_vault/features/import_export/notion_csv/data/notion_csv_import_repository.dart';
import 'package:backlog_vault/features/library/data/library_query_repository.dart';
import 'package:backlog_vault/features/library/domain/game_status.dart';
import 'package:backlog_vault/features/playthroughs/application/completion_form_model.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

void main() {
  late AppDatabase db;
  late NotionCsvImportRepository importRepository;
  late GameRepository gameRepository;
  late LibraryQueryRepository queryRepository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    importRepository = NotionCsvImportRepository(db);
    gameRepository = GameRepository(db);
    queryRepository = LibraryQueryRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'completes an imported realistic Notion game and updates table row',
    () async {
      const parser = CsvParser();
      const detectMapping = DetectNotionCsvMappingUseCase();
      const buildPreview = BuildImportPreviewUseCase();
      final text =
          File('test/fixtures/notion_realistic_export.csv').readAsStringSync();
      final document = parser.parseText(
        fileName: 'notion_realistic_export.csv',
        sizeBytes: text.length,
        text: text,
      );
      final preview = buildPreview(
        document: document,
        mapping: detectMapping(document.headers),
        existingGames: await importRepository.loadExistingGames(),
      );

      await importRepository.importPreview(preview);
      var rows = await queryRepository.watchRows().first;
      final importedPlaying = rows.singleWhere(
        (row) => row.title == 'Playing Game',
      );
      expect(importedPlaying.status, GameStatus.playing);
      expect(importedPlaying.playthroughCount, 1);

      await gameRepository.completeGame(
        CompletionFormModel(
          libraryEntryId: importedPlaying.libraryEntryId,
          completedAt: DateTime(2026, 6, 10),
          hoursPlayed: 8.5,
          rating: 5,
          notes: 'Cierre validado desde fixture realista',
        ),
      );

      rows = await queryRepository.watchRows().first;
      final completed = rows.singleWhere((row) => row.title == 'Playing Game');
      expect(completed.status, GameStatus.completed);
      expect(completed.completedAt, DateTime(2026, 6, 10));
      expect(completed.hoursPlayed, 8.5);
      expect(completed.personalRating, 5);
      expect(completed.playthroughCount, 1);
    },
  );
}
