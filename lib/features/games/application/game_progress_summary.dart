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
    var orderedPlaythroughs = [...details.playthroughs]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final activePlaythrough = _firstOrNull(
      orderedPlaythroughs.where((playthrough) {
        final status = parsePlaythroughStatus(playthrough.status);
        return status == PlaythroughStatus.active ||
            status == PlaythroughStatus.paused;
      }),
    );

    return GameProgressSummary(
      totalHours: details.entry.hoursPlayed,
      playthroughCount: details.playthroughs.length,
      latestCompletedAt: details.entry.completedAt,
      activePlaythrough: activePlaythrough,
    );
  }

  final double? totalHours;
  final int playthroughCount;
  final DateTime? latestCompletedAt;
  final PlaythroughDetails? activePlaythrough;
}

T? _firstOrNull<T>(Iterable<T> values) {
  final iterator = values.iterator;
  if (!iterator.moveNext()) return null;
  return iterator.current;
}
