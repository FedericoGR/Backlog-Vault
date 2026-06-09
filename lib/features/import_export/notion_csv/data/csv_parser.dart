import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';

import '../domain/csv_document.dart';

class CsvParser {
  const CsvParser();

  CsvDocument parseBytes({
    required String fileName,
    required int sizeBytes,
    required Uint8List bytes,
  }) {
    final text = _decodeUtf8(bytes);
    return parseText(fileName: fileName, sizeBytes: sizeBytes, text: text);
  }

  CsvDocument parseText({
    required String fileName,
    required int sizeBytes,
    required String text,
  }) {
    final normalizedText = _stripBom(text).trimRight();
    if (normalizedText.trim().isEmpty) {
      throw const FormatException('El archivo CSV está vacío.');
    }

    final candidates = [',', ';', '\t'];
    final parsedCandidates = <_ParsedCandidate>[];
    for (final delimiter in candidates) {
      try {
        final rows = Csv(
          fieldDelimiter: delimiter,
          autoDetect: false,
        ).decode(normalizedText);
        if (rows.isNotEmpty) {
          parsedCandidates.add(
            _ParsedCandidate(delimiter: delimiter, rows: rows),
          );
        }
      } catch (_) {
        // Try next delimiter.
      }
    }

    if (parsedCandidates.isEmpty) {
      throw const FormatException('No se pudo parsear el CSV.');
    }

    parsedCandidates.sort((a, b) => b.score.compareTo(a.score));
    final selected = parsedCandidates.first;
    final rawRows = selected.rows;
    final headers = rawRows.first.map(_cellToString).toList();
    if (headers.every((header) => header.trim().isEmpty)) {
      throw const FormatException('El CSV no tiene headers válidos.');
    }

    final uniqueHeaders = _uniqueHeaders(headers);
    final rows = <RawCsvRow>[];
    for (var index = 1; index < rawRows.length; index++) {
      final rawRow = rawRows[index];
      if (rawRow.every((cell) => _cellToString(cell).trim().isEmpty)) {
        continue;
      }

      final values = <String, String>{};
      for (
        var columnIndex = 0;
        columnIndex < uniqueHeaders.length;
        columnIndex++
      ) {
        final header = uniqueHeaders[columnIndex];
        final value =
            columnIndex < rawRow.length
                ? _cellToString(rawRow[columnIndex])
                : '';
        values[header] = value;
      }
      rows.add(RawCsvRow(rowNumber: index + 1, values: values));
    }

    return CsvDocument(
      fileName: fileName,
      sizeBytes: sizeBytes,
      headers: uniqueHeaders,
      rows: rows,
      delimiter: selected.delimiter,
    );
  }

  String _decodeUtf8(Uint8List bytes) {
    return utf8.decode(bytes, allowMalformed: true);
  }

  String _stripBom(String text) {
    if (text.startsWith('\uFEFF')) return text.substring(1);
    return text;
  }

  static String _cellToString(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  List<String> _uniqueHeaders(List<String> headers) {
    final seen = <String, int>{};
    return [
      for (final rawHeader in headers)
        () {
          final header =
              rawHeader.trim().isEmpty
                  ? 'Columna sin nombre'
                  : rawHeader.trim();
          final count = seen.update(
            header,
            (value) => value + 1,
            ifAbsent: () => 0,
          );
          if (count == 0) return header;
          return '$header ($count)';
        }(),
    ];
  }
}

class _ParsedCandidate {
  const _ParsedCandidate({required this.delimiter, required this.rows});

  final String delimiter;
  final List<List<dynamic>> rows;

  int get score {
    if (rows.isEmpty) return 0;
    final headerWidth = rows.first.length;
    final nonEmptyRows = rows.where(
      (row) => row.any((cell) => cell.toString().trim().isNotEmpty),
    );
    final consistentRows =
        nonEmptyRows.where((row) => row.length == headerWidth).length;
    return headerWidth * 100 + consistentRows;
  }
}
