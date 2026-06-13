import '../../library/domain/game_status.dart';
import '../../library/domain/library_game_row.dart';
import '../../playthroughs/domain/playthrough_status.dart';

class StatisticsPlaythrough {
  const StatisticsPlaythrough({
    required this.libraryEntryId,
    required this.status,
    this.completedAt,
    this.hoursPlayed,
  });

  final String libraryEntryId;
  final PlaythroughStatus status;
  final DateTime? completedAt;
  final double? hoursPlayed;
}

class MonthlyCompletionStats {
  const MonthlyCompletionStats({
    required this.month,
    required this.completedCount,
    required this.hours,
  });

  final int month;
  final int completedCount;
  final double hours;
}

class YearlyStatistics {
  const YearlyStatistics({
    required this.year,
    required this.completedCount,
    required this.hours,
    required this.monthlyCompletions,
  });

  final int year;
  final int completedCount;
  final double hours;
  final List<MonthlyCompletionStats> monthlyCompletions;
}

class RatingDistribution {
  const RatingDistribution({
    required this.countByRating,
    required this.ratedCount,
    required this.unratedCount,
    required this.average,
  });

  final Map<int, int> countByRating;
  final int ratedCount;
  final int unratedCount;
  final double? average;
}

class CategoryBreakdown {
  const CategoryBreakdown({
    required this.id,
    required this.name,
    required this.count,
    required this.percentage,
  });

  final String id;
  final String name;
  final int count;
  final double percentage;
}

class LibraryQualityStats {
  const LibraryQualityStats({
    required this.missingCover,
    required this.missingMetadata,
    required this.missingRating,
    required this.missingPlatform,
    required this.missingGenre,
    required this.completedWithoutDate,
  });

  final int missingCover;
  final int missingMetadata;
  final int missingRating;
  final int missingPlatform;
  final int missingGenre;
  final int completedWithoutDate;
}

class LatestCompletedGame {
  const LatestCompletedGame({
    required this.row,
    required this.completedAt,
    this.hoursPlayed,
  });

  final LibraryGameRow row;
  final DateTime completedAt;
  final double? hoursPlayed;
}

class LibraryStatistics {
  const LibraryStatistics({
    required this.totalGames,
    required this.statusCounts,
    required this.backlogCount,
    required this.playingCount,
    required this.pausedCount,
    required this.completedCount,
    required this.completedByYear,
    required this.hoursByYear,
    required this.totalHours,
    required this.ratingDistribution,
    required this.platformBreakdown,
    required this.genreBreakdown,
    required this.qualityStats,
    required this.yearlyStatistics,
    required this.latestCompleted,
    required this.availableYears,
  });

  final int totalGames;
  final Map<GameStatus, int> statusCounts;
  final int backlogCount;
  final int playingCount;
  final int pausedCount;
  final int completedCount;
  final Map<int, int> completedByYear;
  final Map<int, double> hoursByYear;
  final double totalHours;
  final RatingDistribution ratingDistribution;
  final List<CategoryBreakdown> platformBreakdown;
  final List<CategoryBreakdown> genreBreakdown;
  final LibraryQualityStats qualityStats;
  final List<YearlyStatistics> yearlyStatistics;
  final List<LatestCompletedGame> latestCompleted;
  final List<int> availableYears;

  double? get averageRating => ratingDistribution.average;

  YearlyStatistics? statsForYear(int year) {
    for (final stats in yearlyStatistics) {
      if (stats.year == year) return stats;
    }
    return null;
  }
}
