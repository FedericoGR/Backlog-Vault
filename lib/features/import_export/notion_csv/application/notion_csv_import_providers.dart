import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/csv_file_picker_service.dart';
import '../data/csv_parser.dart';
import '../data/notion_csv_import_repository.dart';
import '../domain/csv_column_mapping.dart';
import '../domain/csv_document.dart';
import '../domain/import_preview.dart';
import '../domain/import_result.dart';
import 'build_import_preview_use_case.dart';
import 'detect_notion_csv_mapping_use_case.dart';
import 'import_notion_csv_use_case.dart';
import 'parse_csv_file_use_case.dart';

final csvFilePickerServiceProvider = Provider<CsvFilePickerService>((ref) {
  return const CsvFilePickerService();
});

final csvParserProvider = Provider<CsvParser>((ref) {
  return const CsvParser();
});

final parseCsvFileUseCaseProvider = Provider<ParseCsvFileUseCase>((ref) {
  return ParseCsvFileUseCase(parser: ref.watch(csvParserProvider));
});

final detectNotionCsvMappingUseCaseProvider =
    Provider<DetectNotionCsvMappingUseCase>((ref) {
      return const DetectNotionCsvMappingUseCase();
    });

final buildImportPreviewUseCaseProvider = Provider<BuildImportPreviewUseCase>((
  ref,
) {
  return const BuildImportPreviewUseCase();
});

final importNotionCsvUseCaseProvider = Provider<ImportNotionCsvUseCase>((ref) {
  return ImportNotionCsvUseCase(ref.watch(notionCsvImportRepositoryProvider));
});

final notionCsvImportViewModelProvider = Provider<NotionCsvImportViewModel>((
  ref,
) {
  return NotionCsvImportViewModel(
    picker: ref.watch(csvFilePickerServiceProvider),
    parser: ref.watch(parseCsvFileUseCaseProvider),
    mappingDetector: ref.watch(detectNotionCsvMappingUseCaseProvider),
    previewBuilder: ref.watch(buildImportPreviewUseCaseProvider),
    importer: ref.watch(importNotionCsvUseCaseProvider),
    repository: ref.watch(notionCsvImportRepositoryProvider),
  );
});

/// Coordinates the CSV picker, pure parsing, preview and transactional import.
class NotionCsvImportViewModel {
  const NotionCsvImportViewModel({
    required CsvFilePickerService picker,
    required ParseCsvFileUseCase parser,
    required DetectNotionCsvMappingUseCase mappingDetector,
    required BuildImportPreviewUseCase previewBuilder,
    required ImportNotionCsvUseCase importer,
    required NotionCsvImportRepository repository,
  }) : _picker = picker,
       _parser = parser,
       _mappingDetector = mappingDetector,
       _previewBuilder = previewBuilder,
       _importer = importer,
       _repository = repository;

  final CsvFilePickerService _picker;
  final ParseCsvFileUseCase _parser;
  final DetectNotionCsvMappingUseCase _mappingDetector;
  final BuildImportPreviewUseCase _previewBuilder;
  final ImportNotionCsvUseCase _importer;
  final NotionCsvImportRepository _repository;

  Future<CsvSelection?> pickAndParse() async {
    final picked = await _picker.pickCsvFile();
    if (picked == null) return null;
    final document = _parser.call(
      fileName: picked.name,
      sizeBytes: picked.sizeBytes,
      bytes: picked.bytes,
    );
    return CsvSelection(
      document: document,
      mapping: _mappingDetector.call(document.headers),
    );
  }

  Future<ImportPreview> buildPreview({
    required CsvDocument document,
    required CsvColumnMapping mapping,
  }) async {
    return _previewBuilder.call(
      document: document,
      mapping: mapping,
      existingGames: await _repository.loadExistingGames(),
    );
  }

  Future<ImportResult> import(ImportPreview preview) => _importer.call(preview);
}

class CsvSelection {
  const CsvSelection({required this.document, required this.mapping});

  final CsvDocument document;
  final CsvColumnMapping mapping;
}
