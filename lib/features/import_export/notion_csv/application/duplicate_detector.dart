import '../domain/duplicate_candidate.dart';
import '../domain/existing_game_summary.dart';
import '../domain/normalized_import_row.dart';

class DuplicateDetector {
  const DuplicateDetector();

  List<NormalizedImportRow> apply({
    required List<NormalizedImportRow> rows,
    required List<ExistingGameSummary> existingGames,
  }) {
    final seenCsv = <String, NormalizedImportRow>{};
    final result = <NormalizedImportRow>[];

    for (final row in rows) {
      final duplicates = <DuplicateCandidate>[...row.duplicates];
      final titleKey = normalizeTitle(row.title);
      final releaseYear = row.releaseDate?.year;
      final platformKeys = row.platforms.map(normalizeTitle).toSet();

      final csvExisting = seenCsv[titleKey];
      if (csvExisting != null) {
        duplicates.add(
          DuplicateCandidate(
            source: DuplicateSource.csv,
            reason: 'Título repetido dentro del CSV.',
            existingTitle: csvExisting.title,
            rowNumber: csvExisting.rowNumber,
          ),
        );
      } else if (titleKey.isNotEmpty) {
        seenCsv[titleKey] = row;
      }

      for (final existing in existingGames) {
        final existingTitleKey = normalizeTitle(existing.title);
        if (existingTitleKey != titleKey) continue;

        var reason = 'Título ya existe en la biblioteca.';
        if (releaseYear != null && existing.releaseYear == releaseYear) {
          reason = 'Título y año de salida ya existen en la biblioteca.';
        }
        final existingPlatformKeys =
            existing.platforms.map(normalizeTitle).toSet();
        if (platformKeys.isNotEmpty &&
            existingPlatformKeys.intersection(platformKeys).isNotEmpty) {
          reason = 'Título y plataforma ya existen en la biblioteca.';
        }

        duplicates.add(
          DuplicateCandidate(
            source: DuplicateSource.database,
            reason: reason,
            existingTitle: existing.title,
          ),
        );
      }

      result.add(
        row.copyWith(
          duplicates: duplicates,
          include: row.include && duplicates.isEmpty,
        ),
      );
    }

    return result;
  }
}

String normalizeTitle(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^\w\s]+', unicode: true), ' ')
      .replaceAll(RegExp(r'_+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
