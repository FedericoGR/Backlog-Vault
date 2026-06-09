import 'dart:typed_data';

import '../data/csv_parser.dart';
import '../domain/csv_document.dart';

class ParseCsvFileUseCase {
  const ParseCsvFileUseCase({CsvParser parser = const CsvParser()})
    : _parser = parser;

  final CsvParser _parser;

  CsvDocument call({
    required String fileName,
    required int sizeBytes,
    required Uint8List bytes,
  }) {
    return _parser.parseBytes(
      fileName: fileName,
      sizeBytes: sizeBytes,
      bytes: bytes,
    );
  }
}
