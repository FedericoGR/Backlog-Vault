import 'dart:io';

import 'package:backlog_vault/core/ids/id_generator.dart';
import 'package:backlog_vault/core/database/app_database.dart';
import 'package:backlog_vault/features/import_export/notion_csv/application/build_import_preview_use_case.dart';
import 'package:backlog_vault/features/import_export/notion_csv/application/detect_notion_csv_mapping_use_case.dart';
import 'package:backlog_vault/features/import_export/notion_csv/data/csv_parser.dart';
import 'package:backlog_vault/features/import_export/notion_csv/data/notion_csv_import_repository.dart';
import 'package:backlog_vault/features/import_export/notion_csv/domain/import_preview.dart';
import 'package:backlog_vault/features/library/domain/game_status.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

void main() {
  late AppDatabase db;
  late NotionCsvImportRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = NotionCsvImportRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'imports a valid row creating game, entry, catalogs and playthrough',
    () async {
      final preview = await _previewFromFixture(
        db,
        repository,
        'test/fixtures/notion_basic.csv',
      );

      final result = await repository.importPreview(preview);

      expect(result.importedGames, 1);
      expect(result.platformsCreated, 1);
      expect(result.genresCreated, 1);
      expect(result.playthroughsCreated, 1);

      final games = await db.select(db.games).get();
      final entries = await db.select(db.libraryEntries).get();
      final platforms = await db.select(db.platforms).get();
      final genres = await db.select(db.genres).get();
      final playthroughs = await db.select(db.playthroughs).get();

      expect(games.single.title, 'Hades');
      expect(entries.single.status, GameStatus.completed.name);
      expect(entries.single.personalRating, 5);
      expect(platforms.single.name, 'PC');
      expect(genres.single.name, 'Roguelite');
      expect(playthroughs.single.completedAt, DateTime(2026, 6, 9));
      expect(playthroughs.single.hoursPlayed, 42.5);
    },
  );

  test('does not import rows with blocking validation errors', () async {
    final preview = await _previewFromFixture(
      db,
      repository,
      'test/fixtures/notion_missing_title.csv',
    );

    final result = await repository.importPreview(preview);

    expect(result.importedGames, 0);
    expect(await db.select(db.games).get(), isEmpty);
    expect(await db.select(db.libraryEntries).get(), isEmpty);
  });

  test('skips exact duplicates by default', () async {
    final firstPreview = await _previewFromFixture(
      db,
      repository,
      'test/fixtures/notion_basic.csv',
    );
    await repository.importPreview(firstPreview);

    final duplicatePreview = await _previewFromFixture(
      db,
      repository,
      'test/fixtures/notion_basic.csv',
    );
    final result = await repository.importPreview(duplicatePreview);

    expect(result.importedGames, 0);
    expect(result.duplicatesSkipped, 1);
    expect(await db.select(db.games).get(), hasLength(1));
  });

  test('rolls back the transaction if a write fails', () async {
    repository = NotionCsvImportRepository(db, ids: _ConstantIdGenerator());
    final preview = await _previewFromFixture(
      db,
      repository,
      'test/fixtures/notion_two_valid_rows.csv',
    );

    await expectLater(repository.importPreview(preview), throwsA(anything));

    expect(await db.select(db.games).get(), isEmpty);
    expect(await db.select(db.libraryEntries).get(), isEmpty);
  });
}

Future<ImportPreview> _previewFromFixture(
  AppDatabase db,
  NotionCsvImportRepository repository,
  String path,
) async {
  const parser = CsvParser();
  const detectMapping = DetectNotionCsvMappingUseCase();
  const buildPreview = BuildImportPreviewUseCase();
  final text = File(path).readAsStringSync();
  final document = parser.parseText(
    fileName: path,
    sizeBytes: text.length,
    text: text,
  );
  return buildPreview(
    document: document,
    mapping: detectMapping(document.headers),
    existingGames: await repository.loadExistingGames(),
  );
}

class _ConstantIdGenerator extends IdGenerator {
  @override
  String newId() => 'same-id';
}
