import '../../library/domain/library_game_row.dart';

/// A summary of personal records belonging to one played year.
class LibraryStatistics {
  const LibraryStatistics({
    required this.year,
    required this.totalGames,
    required this.completedCount,
    required this.totalHours,
    required this.averageRating,
    required this.favorites,
    required this.platformBreakdown,
  });

  final int year;
  final int totalGames;
  final int completedCount;

  /// Null means no hours were entered; an explicit zero remains zero.
  final double? totalHours;
  final double? averageRating;
  final List<LibraryGameRow> favorites;
  final List<CategoryBreakdown> platformBreakdown;
}

class CategoryBreakdown {
  const CategoryBreakdown({
    required this.id,
    required this.name,
    required this.count,
  });
  final String id;
  final String name;
  final int count;
}
