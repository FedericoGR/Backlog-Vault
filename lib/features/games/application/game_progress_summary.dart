import '../../../core/database/app_database.dart';
import '../../playthroughs/domain/playthrough_status.dart';
import 'library_game_details.dart';

class GameProgressSummary {
  const GameProgressSummary({
    required this.totalHours,
    required this.playthroughCount,
    this.latestCompletedAt,
    this.activePlaythrough,
  });

  factory GameProgressSummary.fromDetails(LibraryGameDetails details) {
    var totalHours = 0.0;
    var hasHours = false;
    DateTime? latestCompletedAt;
    var orderedPlaythroughs = [...details.playthroughs]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final activePlaythrough = _firstOrNull(
      orderedPlaythroughs.where((playthrough) {
        final status = parsePlaythroughStatus(playthrough.status);
        return status == PlaythroughStatus.active ||
            status == PlaythroughStatus.paused;
      }),
    );

    for (final playthrough in details.playthroughs) {
      final hours = playthrough.hoursPlayed;
      if (hours != null) {
        totalHours += hours;
        hasHours = true;
      }
      final completedAt = playthrough.completedAt;
      if (completedAt != null &&
          (latestCompletedAt == null ||
              completedAt.isAfter(latestCompletedAt))) {
        latestCompletedAt = completedAt;
      }
    }

    return GameProgressSummary(
      totalHours: hasHours ? totalHours : null,
      playthroughCount: details.playthroughs.length,
      latestCompletedAt: latestCompletedAt,
      activePlaythrough: activePlaythrough,
    );
  }

  final double? totalHours;
  final int playthroughCount;
  final DateTime? latestCompletedAt;
  final Playthrough? activePlaythrough;
}

T? _firstOrNull<T>(Iterable<T> values) {
  final iterator = values.iterator;
  if (!iterator.moveNext()) return null;
  return iterator.current;
}
