import '../data/notion_csv_import_repository.dart';
import '../domain/import_preview.dart';
import '../domain/import_result.dart';

class ImportNotionCsvUseCase {
  const ImportNotionCsvUseCase(this._repository);

  final NotionCsvImportRepository _repository;

  Future<ImportResult> call(ImportPreview preview) {
    return _repository.importPreview(preview);
  }
}
