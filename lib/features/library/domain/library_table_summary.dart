import 'game_status.dart';
import 'library_game_row.dart';

class LibraryTableSummary {
  const LibraryTableSummary({
    required this.visibleGames,
    required this.statusCounts,
    required this.totalHours,
    required this.averageRating,
    required this.completedCount,
    required this.missingRating,
    required this.missingPlatform,
    required this.missingGenre,
  });

  factory LibraryTableSummary.fromRows(List<LibraryGameRow> rows) {
    final statusCounts = <GameStatus, int>{
      for (final status in GameStatus.values) status: 0,
    };
    var totalHours = 0.0;
    var ratingTotal = 0;
    var ratingCount = 0;
    var completedCount = 0;
    var missingRating = 0;
    var missingPlatform = 0;
    var missingGenre = 0;

    for (final row in rows) {
      statusCounts[row.status] = (statusCounts[row.status] ?? 0) + 1;
      totalHours += row.hoursPlayed ?? 0;
      if (row.personalRating == null) {
        missingRating++;
      } else {
        ratingTotal += row.personalRating!;
        ratingCount++;
      }
      if (row.status == GameStatus.completed) completedCount++;
      if (row.platforms.isEmpty) missingPlatform++;
      if (row.genres.isEmpty) missingGenre++;
    }

    return LibraryTableSummary(
      visibleGames: rows.length,
      statusCounts: statusCounts,
      totalHours: totalHours,
      averageRating: ratingCount == 0 ? null : ratingTotal / ratingCount,
      completedCount: completedCount,
      missingRating: missingRating,
      missingPlatform: missingPlatform,
      missingGenre: missingGenre,
    );
  }

  final int visibleGames;
  final Map<GameStatus, int> statusCounts;
  final double totalHours;
  final double? averageRating;
  final int completedCount;
  final int missingRating;
  final int missingPlatform;
  final int missingGenre;
}
