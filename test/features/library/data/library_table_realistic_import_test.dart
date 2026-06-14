import 'dart:io';

import 'package:backlog_vault/core/database/app_database.dart';
import 'package:backlog_vault/features/import_export/notion_csv/application/build_import_preview_use_case.dart';
import 'package:backlog_vault/features/import_export/notion_csv/application/detect_notion_csv_mapping_use_case.dart';
import 'package:backlog_vault/features/import_export/notion_csv/data/csv_parser.dart';
import 'package:backlog_vault/features/import_export/notion_csv/data/notion_csv_import_repository.dart';
import 'package:backlog_vault/features/library/application/library_default_views.dart';
import 'package:backlog_vault/features/library/application/library_table_processor.dart';
import 'package:backlog_vault/features/library/data/library_query_repository.dart';
import 'package:backlog_vault/features/library/domain/game_status.dart';
import 'package:backlog_vault/features/library/domain/library_filter_state.dart';
import 'package:backlog_vault/features/library/domain/library_game_row.dart';
import 'package:backlog_vault/features/library/domain/library_sort_state.dart';
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

  test(
    'imports realistic Notion CSV and feeds advanced table filters',
    () async {
      const parser = CsvParser();
      const detectMapping = DetectNotionCsvMappingUseCase();
      const buildPreview = BuildImportPreviewUseCase();
      const processor = LibraryTableProcessor();
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

      expect(
        _titles(
          processor,
          rows,
          const LibraryFilterState(textQuery: 'linea dos'),
        ),
        ['Playing Game'],
      );
      expect(
        _titles(
          processor,
          rows,
          const LibraryFilterState(statuses: {GameStatus.completed}),
        ),
        ['Completed Game'],
      );
      expect(
        _titles(
          processor,
          rows,
          LibraryFilterState(platformIds: {_idForPlatform(rows, 'Steam Deck')}),
        ),
        ['Playing Game'],
      );
      expect(
        _titles(
          processor,
          rows,
          LibraryFilterState(genreIds: {_idForGenre(rows, 'Acción')}),
        ),
        ['Completed Game'],
      );
      expect(_titles(processor, rows, const LibraryFilterState(minRating: 4)), [
        'Completed Game',
      ]);
      expect(
        _titles(
          processor,
          rows,
          LibraryFilterState(
            releaseDateFrom: DateTime(2024, 4, 1),
            releaseDateTo: DateTime(2024, 4, 30),
          ),
        ),
        ['Playing Game'],
      );
      expect(
        _titles(
          processor,
          rows,
          LibraryFilterState(
            completedDateFrom: DateTime(2026, 1, 1),
            completedDateTo: DateTime(2026, 1, 31),
          ),
        ),
        ['Completed Game'],
      );
      expect(_titles(processor, rows, const LibraryFilterState(minHours: 10)), [
        'Completed Game',
      ]);
      expect(
        _titles(
          processor,
          rows,
          LibraryFilterState(
            statuses: const {GameStatus.playing},
            platformIds: {_idForPlatform(rows, 'PC')},
            genreIds: {_idForGenre(rows, 'RPG')},
            maxHours: 5,
          ),
        ),
        ['Playing Game'],
      );

      final platforms =
          rows
              .expand((row) => row.platforms)
              .fold(<String, LibraryCatalogItem>{}, (map, platform) {
                map[platform.id] = platform;
                return map;
              })
              .values
              .toList();
      final defaultViews = buildDefaultLibraryViews(platforms: platforms);
      for (final view in defaultViews) {
        processor.apply(rows: rows, filter: view.filter, sort: view.sort);
      }
    },
  );
}

List<String> _titles(
  LibraryTableProcessor processor,
  List<LibraryGameRow> rows,
  LibraryFilterState filter,
) {
  return processor
      .apply(
        rows: rows,
        filter: filter,
        sort: const LibrarySortState(
          field: LibrarySortField.title,
          direction: LibrarySortDirection.ascending,
        ),
      )
      .rows
      .map((row) => row.title)
      .toList();
}

String _idForPlatform(List<LibraryGameRow> rows, String name) {
  return rows
      .expand((row) => row.platforms)
      .firstWhere((platform) => platform.name == name)
      .id;
}

String _idForGenre(List<LibraryGameRow> rows, String name) {
  return rows
      .expand((row) => row.genres)
      .firstWhere((genre) => genre.name == name)
      .id;
}
