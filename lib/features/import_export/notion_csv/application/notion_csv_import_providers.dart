import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/csv_file_picker_service.dart';
import '../data/csv_parser.dart';
import '../data/notion_csv_import_repository.dart';
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
