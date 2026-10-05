import 'dart:io';
import 'package:backlog_vault/features/library/application/annual_game_log.dart';

import 'package:backlog_vault/core/database/app_database.dart';
import 'package:backlog_vault/features/import_export/notion_csv/application/build_import_preview_use_case.dart';
import 'package:backlog_vault/features/import_export/notion_csv/application/detect_notion_csv_mapping_use_case.dart';
import 'package:backlog_vault/features/import_export/notion_csv/data/csv_parser.dart';
import 'package:backlog_vault/features/import_export/notion_csv/data/notion_csv_import_repository.dart';
import 'package:backlog_vault/features/library/data/library_query_repository.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

void main() {
  late AppDatabase db;
  late NotionCsvImportRepository importRepository;
  late LibraryQueryRepository queryRepository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    importRepository = NotionCsvImportRepository(db);
    queryRepository = LibraryQueryRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('imports realistic Notion CSV into annual game log', () async {
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

    final importResult = await importRepository.importPreview(preview);
    final rows = await queryRepository.watchRows().first;

    expect(importResult.importedGames, 2);
    expect(rows, hasLength(2));
    expect(
      rows.map((row) => row.title),
      containsAll(['Completed Game', 'Playing Game']),
    );

    final yearly = const AnnualGameLogState(year: 2026).visibleRows(rows);
    expect(yearly.map((row) => row.title), ['Completed Game']);
    expect(yearly.single.isCompleted, isTrue);
    expect(yearly.single.completedAt, DateTime(2026, 1, 2));
    expect(
      const AnnualGameLogState(
        year: null,
      ).visibleRows(rows).map((row) => row.title),
      ['Playing Game'],
    );
    expect(
      const AnnualGameLogState(
        year: 2026,
        query: 'Completed',
      ).visibleRows(rows),
      hasLength(1),
    );
  });
}
