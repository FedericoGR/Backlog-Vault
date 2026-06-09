import '../../../library/domain/game_status.dart';
import '../../../playthroughs/domain/playthrough_status.dart';
import '../domain/csv_column_mapping.dart';
import '../domain/csv_document.dart';
import '../domain/existing_game_summary.dart';
import '../domain/import_field.dart';
import '../domain/import_issue.dart';
import '../domain/import_preview.dart';
import '../domain/normalized_import_row.dart';
import 'csv_normalizer.dart';
import 'duplicate_detector.dart';

class BuildImportPreviewUseCase {
  const BuildImportPreviewUseCase({
    CsvNormalizer normalizer = const CsvNormalizer(),
    DuplicateDetector duplicateDetector = const DuplicateDetector(),
  }) : _normalizer = normalizer,
       _duplicateDetector = duplicateDetector;

  final CsvNormalizer _normalizer;
  final DuplicateDetector _duplicateDetector;

  ImportPreview call({
    required CsvDocument document,
    required CsvColumnMapping mapping,
    required List<ExistingGameSummary> existingGames,
  }) {
    final rows = <NormalizedImportRow>[];
    for (final rawRow in document.rows) {
      final issues = <ImportRowIssue>[];
      final title = _value(rawRow, mapping, ImportField.title).trim();
      if (title.isEmpty) {
        issues.add(
          const ImportRowIssue(
            severity: ImportIssueSeverity.error,
            field: 'title',
            message: 'La fila no tiene nombre; no se puede importar.',
          ),
        );
      }

      final releaseDate = _normalizer.parseDate(
        _value(rawRow, mapping, ImportField.releaseDate),
        issues,
        'releaseDate',
      );
      final completedAt = _normalizer.parseDate(
        _value(rawRow, mapping, ImportField.completedAt),
        issues,
        'completedAt',
      );
      final hoursPlayed = _normalizer.parseHours(
        _value(rawRow, mapping, ImportField.hoursPlayed),
        issues,
      );
      final rating = _normalizer.parseRating(
        _value(rawRow, mapping, ImportField.personalRating),
        issues,
      );
      final status = _normalizer.parseStatus(
        _value(rawRow, mapping, ImportField.status),
        issues,
      );
      final genres = _normalizer.splitMultiValue(
        _value(rawRow, mapping, ImportField.genres),
      );
      final platforms = _normalizer.splitMultiValue(
        _value(rawRow, mapping, ImportField.platforms),
      );
      final type = _normalizer.normalizeType(
        _value(rawRow, mapping, ImportField.type),
      );
      final notes = _blankToNull(
        _value(rawRow, mapping, ImportField.personalNotes),
      );

      if (status == GameStatus.completed && completedAt == null) {
        issues.add(
          const ImportRowIssue(
            severity: ImportIssueSeverity.warning,
            field: 'completedAt',
            message: 'Completado sin fecha de completado.',
          ),
        );
      }
      if (completedAt != null && status != GameStatus.completed) {
        issues.add(
          const ImportRowIssue(
            severity: ImportIssueSeverity.warning,
            field: 'completedAt',
            message:
                'Hay fecha de completado, pero el estado no es Completado.',
          ),
        );
      }
      if (hoursPlayed != null &&
          !_shouldCreatePlaythrough(status, completedAt, rating, notes)) {
        issues.add(
          const ImportRowIssue(
            severity: ImportIssueSeverity.warning,
            field: 'hoursPlayed',
            message: 'Hay duración, pero no hay estado de partida claro.',
          ),
        );
      }

      rows.add(
        NormalizedImportRow(
          rowNumber: rawRow.rowNumber,
          title: title,
          releaseDate: releaseDate,
          completedAt: completedAt,
          hoursPlayed: hoursPlayed,
          personalRating: rating,
          genres: genres,
          platforms: platforms,
          status: status,
          type: type,
          personalNotes: notes,
          issues: issues,
          duplicates: const [],
          include: issues.every((issue) => !issue.isError),
          forceCreateDuplicate: false,
        ),
      );
    }

    return ImportPreview(
      rows: _duplicateDetector.apply(rows: rows, existingGames: existingGames),
    );
  }
}

String _value(RawCsvRow row, CsvColumnMapping mapping, ImportField field) {
  return row.valueFor(mapping.headerFor(field));
}

String? _blankToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

bool _shouldCreatePlaythrough(
  GameStatus status,
  DateTime? completedAt,
  int? rating,
  String? notes,
) {
  if (completedAt != null) return true;
  if (rating != null &&
      status != GameStatus.wishlist &&
      status != GameStatus.backlog) {
    return true;
  }
  if (notes != null &&
      status != GameStatus.wishlist &&
      status != GameStatus.backlog) {
    return true;
  }
  return switch (status) {
    GameStatus.completed ||
    GameStatus.playing ||
    GameStatus.paused ||
    GameStatus.dropped => true,
    GameStatus.wishlist || GameStatus.backlog || GameStatus.retired => false,
  };
}

PlaythroughStatus playthroughStatusForImport(NormalizedImportRow row) {
  if (row.completedAt != null || row.status == GameStatus.completed) {
    return PlaythroughStatus.completed;
  }
  return switch (row.status) {
    GameStatus.playing => PlaythroughStatus.active,
    GameStatus.paused => PlaythroughStatus.paused,
    GameStatus.dropped => PlaythroughStatus.dropped,
    GameStatus.wishlist ||
    GameStatus.backlog ||
    GameStatus.retired => PlaythroughStatus.planned,
    GameStatus.completed => PlaythroughStatus.completed,
  };
}

bool shouldCreatePlaythroughForImport(NormalizedImportRow row) {
  if (row.completedAt != null) return true;
  if (row.status == GameStatus.completed) {
    return row.hoursPlayed != null ||
        row.personalRating != null ||
        (row.personalNotes?.trim().isNotEmpty ?? false);
  }
  if (row.hoursPlayed != null) {
    return row.status == GameStatus.playing ||
        row.status == GameStatus.completed ||
        row.status == GameStatus.paused ||
        row.status == GameStatus.dropped;
  }
  if (row.personalRating != null) {
    return row.status == GameStatus.playing ||
        row.status == GameStatus.completed ||
        row.status == GameStatus.paused ||
        row.status == GameStatus.dropped;
  }
  return row.status == GameStatus.playing ||
      row.status == GameStatus.paused ||
      row.status == GameStatus.dropped;
}
