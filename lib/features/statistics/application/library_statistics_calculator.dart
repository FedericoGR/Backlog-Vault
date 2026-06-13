import '../../library/domain/game_status.dart';
import '../../library/domain/library_game_row.dart';
import '../../playthroughs/domain/playthrough_status.dart';
import '../domain/statistics_models.dart';

class LibraryStatisticsCalculator {
  const LibraryStatisticsCalculator();

  LibraryStatistics calculate({
    required List<LibraryGameRow> rows,
    required List<StatisticsPlaythrough> playthroughs,
  }) {
    final rowsByEntryId = {for (final row in rows) row.libraryEntryId: row};
    final activePlaythroughs =
        playthroughs
            .where(
              (playthrough) =>
                  rowsByEntryId.containsKey(playthrough.libraryEntryId),
            )
            .toList();
    final completedPlaythroughs =
        activePlaythroughs
            .where(
              (playthrough) =>
                  playthrough.status == PlaythroughStatus.completed &&
                  playthrough.completedAt != null,
            )
            .toList();

    final statusCounts = <GameStatus, int>{
      for (final status in GameStatus.values) status: 0,
    };
    for (final row in rows) {
      statusCounts[row.status] = (statusCounts[row.status] ?? 0) + 1;
    }

    final totalHours = _sumHours(activePlaythroughs);
    final ratingDistribution = _buildRatingDistribution(rows);
    final completedByYear = <int, int>{};
    final hoursByYear = <int, double>{};
    final monthlyByYear = <int, Map<int, _MutableMonthStats>>{};
    final latestByEntryId = <String, LatestCompletedGame>{};

    for (final playthrough in completedPlaythroughs) {
      final completedAt = playthrough.completedAt!;
      final year = completedAt.year;
      final month = completedAt.month;
      completedByYear[year] = (completedByYear[year] ?? 0) + 1;
      final hours = playthrough.hoursPlayed ?? 0;
      hoursByYear[year] = (hoursByYear[year] ?? 0) + hours;
      final monthStats = monthlyByYear
          .putIfAbsent(year, () => {})
          .putIfAbsent(month, () => _MutableMonthStats(month));
      monthStats.completedCount++;
      monthStats.hours += hours;

      final row = rowsByEntryId[playthrough.libraryEntryId];
      if (row != null) {
        final current = latestByEntryId[row.libraryEntryId];
        if (current == null || completedAt.isAfter(current.completedAt)) {
          latestByEntryId[row.libraryEntryId] = LatestCompletedGame(
            row: row,
            completedAt: completedAt,
            hoursPlayed: playthrough.hoursPlayed,
          );
        }
      }
    }

    final yearlyStatistics =
        completedByYear.keys.map((year) {
            final monthly = monthlyByYear[year] ?? const {};
            return YearlyStatistics(
              year: year,
              completedCount: completedByYear[year] ?? 0,
              hours: hoursByYear[year] ?? 0,
              monthlyCompletions: [
                for (var month = 1; month <= 12; month++)
                  MonthlyCompletionStats(
                    month: month,
                    completedCount: monthly[month]?.completedCount ?? 0,
                    hours: monthly[month]?.hours ?? 0,
                  ),
              ],
            );
          }).toList()
          ..sort((a, b) => b.year.compareTo(a.year));

    final completedEntriesWithDate = {
      for (final playthrough in completedPlaythroughs)
        playthrough.libraryEntryId,
    };
    final latestCompleted =
        latestByEntryId.values.toList()
          ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

    return LibraryStatistics(
      totalGames: rows.length,
      statusCounts: statusCounts,
      backlogCount: statusCounts[GameStatus.backlog] ?? 0,
      playingCount: statusCounts[GameStatus.playing] ?? 0,
      pausedCount: statusCounts[GameStatus.paused] ?? 0,
      completedCount: statusCounts[GameStatus.completed] ?? 0,
      completedByYear: Map.unmodifiable(completedByYear),
      hoursByYear: Map.unmodifiable(hoursByYear),
      totalHours: totalHours,
      ratingDistribution: ratingDistribution,
      platformBreakdown: _buildBreakdown(
        rows: rows,
        itemsForRow: (row) => row.platforms,
      ),
      genreBreakdown: _buildBreakdown(
        rows: rows,
        itemsForRow: (row) => row.genres,
      ),
      qualityStats: LibraryQualityStats(
        missingCover:
            rows
                .where(
                  (row) =>
                      row.selectedCoverLocalPath == null ||
                      row.selectedCoverLocalPath!.trim().isEmpty,
                )
                .length,
        missingMetadata: rows.where((row) => !row.hasExternalMetadata).length,
        missingRating: rows.where((row) => row.personalRating == null).length,
        missingPlatform: rows.where((row) => row.platforms.isEmpty).length,
        missingGenre: rows.where((row) => row.genres.isEmpty).length,
        completedWithoutDate:
            rows
                .where(
                  (row) =>
                      row.status == GameStatus.completed &&
                      !completedEntriesWithDate.contains(row.libraryEntryId),
                )
                .length,
      ),
      yearlyStatistics: yearlyStatistics,
      latestCompleted: latestCompleted.take(8).toList(growable: false),
      availableYears:
          completedByYear.keys.toList()..sort((a, b) => b.compareTo(a)),
    );
  }

  double _sumHours(List<StatisticsPlaythrough> playthroughs) {
    var total = 0.0;
    for (final playthrough in playthroughs) {
      total += playthrough.hoursPlayed ?? 0;
    }
    return total;
  }

  RatingDistribution _buildRatingDistribution(List<LibraryGameRow> rows) {
    final countByRating = {
      for (var rating = 1; rating <= 5; rating++) rating: 0,
    };
    var ratingTotal = 0;
    var ratedCount = 0;
    for (final row in rows) {
      final rating = row.personalRating;
      if (rating == null || rating < 1 || rating > 5) continue;
      countByRating[rating] = (countByRating[rating] ?? 0) + 1;
      ratingTotal += rating;
      ratedCount++;
    }
    return RatingDistribution(
      countByRating: Map.unmodifiable(countByRating),
      ratedCount: ratedCount,
      unratedCount: rows.length - ratedCount,
      average: ratedCount == 0 ? null : ratingTotal / ratedCount,
    );
  }

  List<CategoryBreakdown> _buildBreakdown({
    required List<LibraryGameRow> rows,
    required List<LibraryCatalogItem> Function(LibraryGameRow row) itemsForRow,
  }) {
    final counts = <String, _MutableCategoryStats>{};
    for (final row in rows) {
      for (final item in itemsForRow(row)) {
        counts
            .putIfAbsent(
              item.id,
              () => _MutableCategoryStats(id: item.id, name: item.name),
            )
            .count++;
      }
    }
    final total = rows.isEmpty ? 1 : rows.length;
    final breakdown =
        counts.values
            .map(
              (item) => CategoryBreakdown(
                id: item.id,
                name: item.name,
                count: item.count,
                percentage: item.count / total,
              ),
            )
            .toList()
          ..sort((a, b) {
            final countResult = b.count.compareTo(a.count);
            return countResult == 0 ? a.name.compareTo(b.name) : countResult;
          });
    return breakdown;
  }
}

class _MutableMonthStats {
  _MutableMonthStats(this.month);

  final int month;
  var completedCount = 0;
  var hours = 0.0;
}

class _MutableCategoryStats {
  _MutableCategoryStats({required this.id, required this.name});

  final String id;
  final String name;
  var count = 0;
}
