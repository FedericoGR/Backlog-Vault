class CsvDocument {
  const CsvDocument({
    required this.fileName,
    required this.sizeBytes,
    required this.headers,
    required this.rows,
    required this.delimiter,
  });

  final String fileName;
  final int sizeBytes;
  final List<String> headers;
  final List<RawCsvRow> rows;
  final String delimiter;

  int get rowCount => rows.length;
}

class RawCsvRow {
  const RawCsvRow({required this.rowNumber, required this.values});

  final int rowNumber;
  final Map<String, String> values;

  String valueFor(String? header) {
    if (header == null) return '';
    return values[header] ?? '';
  }
}
