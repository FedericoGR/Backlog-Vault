import 'dart:io';

import 'package:backlog_vault/features/import_export/notion_csv/data/csv_parser.dart';
import 'package:test/test.dart';

void main() {
  const parser = CsvParser();

  test('parses comma CSV', () {
    final text = File('test/fixtures/notion_basic.csv').readAsStringSync();
    final document = parser.parseText(
      fileName: 'notion_basic.csv',
      sizeBytes: text.length,
      text: text,
    );

    expect(document.delimiter, ',');
    expect(document.headers.first, 'Nombre');
    expect(document.rows, hasLength(1));
    expect(document.rows.single.valueFor('Nombre'), 'Hades');
  });

  test('parses semicolon CSV', () {
    final text = File('test/fixtures/notion_semicolon.csv').readAsStringSync();
    final document = parser.parseText(
      fileName: 'notion_semicolon.csv',
      sizeBytes: text.length,
      text: text,
    );

    expect(document.delimiter, ';');
    expect(document.headers, contains('Duracion'));
    expect(document.rows.single.valueFor('Plataformas'), 'Nintendo Switch');
  });

  test('parses quoted notes with comma and line break', () {
    final text = File('test/fixtures/notion_quotes.csv').readAsStringSync();
    final document = parser.parseText(
      fileName: 'notion_quotes.csv',
      sizeBytes: text.length,
      text: text,
    );

    expect(document.rows, hasLength(1));
    expect(document.rows.single.valueFor('Notas'), contains('Notas con coma,'));
    expect(document.rows.single.valueFor('Notas'), contains('salto'));
  });
}
