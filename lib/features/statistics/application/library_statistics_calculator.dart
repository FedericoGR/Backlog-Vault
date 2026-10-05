import '../../library/domain/library_game_row.dart';
import '../domain/statistics_models.dart';

class LibraryStatisticsCalculator {
  const LibraryStatisticsCalculator();

  LibraryStatistics calculate({
    required List<LibraryGameRow> rows,
    required int year,
  }) {
    // Membership never depends on catalog dates or legacy playthrough history.
    final entries = <String, LibraryGameRow>{};
    for (final row in rows) {
      if (row.playedYear == year) {
        entries.putIfAbsent(row.libraryEntryId, () => row);
      }
    }
    final personalRecords = entries.values.toList();
    final hours =
        personalRecords
            .map((row) => row.hoursPlayed)
            .whereType<double>()
            .toList();
    final rated =
        personalRecords.where((row) => row.personalRating != null).toList()
          ..sort((a, b) {
            final rating = b.personalRating!.compareTo(a.personalRating!);
            if (rating != 0) return rating;
            final title = a.title.toLowerCase().compareTo(
              b.title.toLowerCase(),
            );
            return title != 0
                ? title
                : a.libraryEntryId.compareTo(b.libraryEntryId);
          });
    final platforms = <String, CategoryBreakdown>{};
    for (final row in personalRecords) {
      if (row.playedPlatform case final platform?) {
        platforms[platform.id] = CategoryBreakdown(
          id: platform.id,
          name: platform.name,
          count: (platforms[platform.id]?.count ?? 0) + 1,
        );
      }
    }
    final breakdown =
        platforms.values.toList()..sort((a, b) {
          final count = b.count.compareTo(a.count);
          return count != 0 ? count : a.name.compareTo(b.name);
        });
    return LibraryStatistics(
      year: year,
      totalGames: personalRecords.length,
      completedCount: personalRecords.where((row) => row.isCompleted).length,
      totalHours: hours.isEmpty ? null : hours.reduce((a, b) => a + b),
      averageRating:
          rated.isEmpty
              ? null
              : rated.fold(0, (sum, row) => sum + row.personalRating!) /
                  rated.length,
      favorites: List.unmodifiable(rated.take(5)),
      platformBreakdown: List.unmodifiable(breakdown),
    );
  }
}
