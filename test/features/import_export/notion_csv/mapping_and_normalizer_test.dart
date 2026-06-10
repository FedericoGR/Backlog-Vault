import 'package:backlog_vault/features/import_export/notion_csv/application/csv_normalizer.dart';
import 'package:backlog_vault/features/import_export/notion_csv/application/detect_notion_csv_mapping_use_case.dart';
import 'package:backlog_vault/features/import_export/notion_csv/domain/import_field.dart';
import 'package:backlog_vault/features/import_export/notion_csv/domain/import_issue.dart';
import 'package:backlog_vault/features/library/domain/game_status.dart';
import 'package:test/test.dart';

void main() {
  group('DetectNotionCsvMappingUseCase', () {
    test('detects Notion-like headers by synonyms', () {
      final mapping = const DetectNotionCsvMappingUseCase().call([
        'Nombre',
        'Fecha de salida',
        'Duración',
        'Duracion ( en horas )',
        'Puntaje',
        'Género',
        'Plataformas',
        'Estado',
        'Notas',
      ]);

      expect(mapping.headerFor(ImportField.title), 'Nombre');
      expect(mapping.headerFor(ImportField.releaseDate), 'Fecha de salida');
      expect(mapping.headerFor(ImportField.hoursPlayed), 'Duración');
      expect(mapping.headerFor(ImportField.personalRating), 'Puntaje');
      expect(mapping.headerFor(ImportField.genres), 'Género');
      expect(mapping.headerFor(ImportField.platforms), 'Plataformas');
      expect(mapping.headerFor(ImportField.status), 'Estado');
      expect(mapping.headerFor(ImportField.personalNotes), 'Notas');
    });
  });

  group('CsvNormalizer', () {
    const normalizer = CsvNormalizer();

    test('parses valid dates and warns for ambiguous dates', () {
      final issues = <ImportRowIssue>[];

      expect(
        normalizer.parseDate('17-09-2020', issues, 'releaseDate'),
        DateTime(2020, 9, 17),
      );
      expect(
        normalizer.parseDate('2020-09-17', issues, 'releaseDate'),
        DateTime(2020, 9, 17),
      );
      expect(
        normalizer.parseDate('03/04/2024', issues, 'releaseDate'),
        DateTime(2024, 4, 3),
      );
      expect(
        normalizer.parseDate('January 2, 2026', issues, 'completedAt'),
        DateTime(2026, 1, 2),
      );
      expect(issues.any((issue) => issue.message.contains('ambigua')), isTrue);
    });

    test('warns and returns null for invalid date', () {
      final issues = <ImportRowIssue>[];

      expect(normalizer.parseDate('99/99/2024', issues, 'releaseDate'), isNull);
      expect(issues.single.isWarning, isTrue);
    });

    test('parses durations with dot, comma and suffixes', () {
      final issues = <ImportRowIssue>[];

      expect(normalizer.parseHours('12', issues), 12);
      expect(normalizer.parseHours('12.5', issues), 12.5);
      expect(normalizer.parseHours('12,5', issues), 12.5);
      expect(normalizer.parseHours('12h', issues), 12);
      expect(normalizer.parseHours('12 hs', issues), 12);
      expect(normalizer.parseHours('12 horas', issues), 12);
      expect(issues, isEmpty);
    });

    test('parses Notion star ratings', () {
      final issues = <ImportRowIssue>[];

      expect(normalizer.parseRating('⭐⭐⭐⭐', issues), 4);
      expect(normalizer.parseRating('⭐️⭐️⭐️', issues), 3);
      expect(issues, isEmpty);
    });

    test('warns for invalid duration and rating', () {
      final issues = <ImportRowIssue>[];

      expect(normalizer.parseHours('-1', issues), isNull);
      expect(normalizer.parseRating('8', issues), isNull);
      expect(issues, hasLength(2));
    });

    test('maps Notion status text to GameStatus', () {
      final issues = <ImportRowIssue>[];

      expect(
        normalizer.parseStatus('lista de deseos', issues),
        GameStatus.wishlist,
      );
      expect(normalizer.parseStatus('pendiente', issues), GameStatus.backlog);
      expect(normalizer.parseStatus('en curso', issues), GameStatus.playing);
      expect(
        normalizer.parseStatus('Jugando Actualmente', issues),
        GameStatus.playing,
      );
      expect(normalizer.parseStatus('finished', issues), GameStatus.completed);
      expect(normalizer.parseStatus('???', issues), GameStatus.backlog);
      expect(issues.single.isWarning, isTrue);
    });

    test('splits and deduplicates multi values', () {
      expect(normalizer.splitMultiValue('RPG; RPG | Action, Puzzle'), [
        'RPG',
        'Action',
        'Puzzle',
      ]);
      expect(
        normalizer.splitMultiValue('PC, Xbox Series X|S, PC | Steam Deck'),
        ['PC', 'Xbox Series X|S', 'Steam Deck'],
      );
    });
  });
}
