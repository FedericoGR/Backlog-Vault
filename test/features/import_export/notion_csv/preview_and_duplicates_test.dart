import 'dart:io';

import 'package:backlog_vault/features/import_export/notion_csv/application/build_import_preview_use_case.dart';
import 'package:backlog_vault/features/import_export/notion_csv/application/detect_notion_csv_mapping_use_case.dart';
import 'package:backlog_vault/features/import_export/notion_csv/data/csv_parser.dart';
import 'package:backlog_vault/features/import_export/notion_csv/domain/existing_game_summary.dart';
import 'package:backlog_vault/features/library/domain/game_status.dart';
import 'package:test/test.dart';

void main() {
  const parser = CsvParser();
  const detectMapping = DetectNotionCsvMappingUseCase();
  const buildPreview = BuildImportPreviewUseCase();

  test('builds preview with warnings for ambiguous dates', () {
    final text =
        File('test/fixtures/notion_ambiguous_dates.csv').readAsStringSync();
    final document = parser.parseText(
      fileName: 'notion_ambiguous_dates.csv',
      sizeBytes: text.length,
      text: text,
    );
    final preview = buildPreview(
      document: document,
      mapping: detectMapping(document.headers),
      existingGames: const [],
    );

    expect(preview.rows.single.hasWarnings, isTrue);
    expect(preview.rows.single.canImport, isTrue);
  });

  test('marks missing title as blocking error', () {
    final text =
        File('test/fixtures/notion_missing_title.csv').readAsStringSync();
    final document = parser.parseText(
      fileName: 'notion_missing_title.csv',
      sizeBytes: text.length,
      text: text,
    );
    final preview = buildPreview(
      document: document,
      mapping: detectMapping(document.headers),
      existingGames: const [],
    );

    expect(preview.rows.single.hasErrors, isTrue);
    expect(preview.importableCount, 0);
  });

  test('detects duplicates inside CSV and against existing library', () {
    final text = File('test/fixtures/notion_duplicates.csv').readAsStringSync();
    final document = parser.parseText(
      fileName: 'notion_duplicates.csv',
      sizeBytes: text.length,
      text: text,
    );
    final preview = buildPreview(
      document: document,
      mapping: detectMapping(document.headers),
      existingGames: const [
        ExistingGameSummary(
          title: 'Hades',
          releaseYear: 2020,
          platforms: ['PC'],
        ),
      ],
    );

    expect(preview.duplicateCount, 2);
    expect(preview.importableCount, 0);
  });

  test('normalizes multiple platforms and genres', () {
    final text =
        File('test/fixtures/notion_multi_values.csv').readAsStringSync();
    final document = parser.parseText(
      fileName: 'notion_multi_values.csv',
      sizeBytes: text.length,
      text: text,
    );
    final preview = buildPreview(
      document: document,
      mapping: detectMapping(document.headers),
      existingGames: const [],
    );

    expect(preview.rows.single.genres, ['RPG', 'Acción']);
    expect(preview.rows.single.platforms, ['PC', 'Xbox']);
  });

  test('handles realistic Notion export headers and value formats', () {
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
      existingGames: const [],
    );

    expect(preview.rows, hasLength(2));
    expect(preview.rows.first.completedAt, DateTime(2026, 1, 2));
    expect(preview.rows.first.personalRating, 4);
    expect(preview.rows.first.platforms, [
      'Nintendo Switch',
      'PC',
      'Xbox Series X|S',
    ]);
    expect(preview.rows.last.status, GameStatus.playing);
    expect(preview.rows.last.personalRating, 3);
    expect(preview.rows.last.personalNotes, contains('Linea dos'));
  });
}
