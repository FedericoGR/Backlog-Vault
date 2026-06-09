import 'normalized_import_row.dart';

class ImportPreview {
  const ImportPreview({required this.rows});

  final List<NormalizedImportRow> rows;

  int get importableCount => rows.where((row) => row.canImport).length;
  int get omittedCount => rows.where((row) => !row.canImport).length;
  int get errorCount => rows.where((row) => row.hasErrors).length;
  int get warningCount => rows.where((row) => row.hasWarnings).length;
  int get duplicateCount => rows.where((row) => row.hasDuplicates).length;

  ImportPreview replaceRow(NormalizedImportRow row) {
    return ImportPreview(
      rows: [
        for (final current in rows)
          if (current.rowNumber == row.rowNumber) row else current,
      ],
    );
  }
}
