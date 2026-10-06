import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/time/clock.dart';
import '../domain/library_game_row.dart';

final annualLogClockProvider = Provider<Clock>((ref) => systemClock);
final annualGameLogProvider =
    NotifierProvider<AnnualGameLog, AnnualGameLogState>(AnnualGameLog.new);

enum LibraryCompletionFilter { all, completed, unfinished }

enum LibraryRatingFilter { any, fourPlus, threePlus, unrated }

/// Ephemeral filters for the selected annual log.
class AnnualGameLog extends Notifier<AnnualGameLogState> {
  @override
  AnnualGameLogState build() =>
      AnnualGameLogState(year: ref.watch(annualLogClockProvider).now().year);

  void selectYear(int? year) =>
      state = AnnualGameLogState(
        year: year,
        query: state.query,
        completionFilter: state.completionFilter,
        playedPlatformIds: state.playedPlatformIds,
        ratingFilter: state.ratingFilter,
      );
  void search(String query) => state = state.copyWith(query: query);

  void setCompletionFilter(LibraryCompletionFilter value) =>
      state = state.copyWith(completionFilter: value);

  void setRatingFilter(LibraryRatingFilter value) =>
      state = state.copyWith(ratingFilter: value);

  void togglePlayedPlatform(String id) {
    final selected = {...state.playedPlatformIds};
    if (!selected.add(id)) selected.remove(id);
    state = state.copyWith(playedPlatformIds: selected);
  }

  void clearFilters() =>
      state = state.copyWith(
        completionFilter: LibraryCompletionFilter.all,
        playedPlatformIds: const {},
        ratingFilter: LibraryRatingFilter.any,
      );
}

class AnnualGameLogState {
  const AnnualGameLogState({
    required this.year,
    this.query = '',
    this.completionFilter = LibraryCompletionFilter.all,
    this.playedPlatformIds = const {},
    this.ratingFilter = LibraryRatingFilter.any,
  });

  /// Null explicitly selects records with no known year.
  final int? year;
  final String query;
  final LibraryCompletionFilter completionFilter;
  final Set<String> playedPlatformIds;
  final LibraryRatingFilter ratingFilter;

  bool get hasActiveFilters =>
      completionFilter != LibraryCompletionFilter.all ||
      playedPlatformIds.isNotEmpty ||
      ratingFilter != LibraryRatingFilter.any;

  AnnualGameLogState copyWith({
    int? year,
    String? query,
    LibraryCompletionFilter? completionFilter,
    Set<String>? playedPlatformIds,
    LibraryRatingFilter? ratingFilter,
  }) => AnnualGameLogState(
    year: year ?? this.year,
    query: query ?? this.query,
    completionFilter: completionFilter ?? this.completionFilter,
    playedPlatformIds: playedPlatformIds ?? this.playedPlatformIds,
    ratingFilter: ratingFilter ?? this.ratingFilter,
  );

  List<LibraryGameRow> yearSearchRows(List<LibraryGameRow> rows) {
    final terms = query.trim().toLowerCase().split(RegExp(r'\s+'));
    return rows
        .where(
          (row) =>
              row.playedYear == year &&
              terms.every((term) => row.title.toLowerCase().contains(term)),
        )
        .toList();
  }

  List<LibraryGameRow> visibleRows(List<LibraryGameRow> rows) {
    final result =
        yearSearchRows(rows).where((row) {
          if (completionFilter == LibraryCompletionFilter.completed &&
              !row.isCompleted) {
            return false;
          }
          if (completionFilter == LibraryCompletionFilter.unfinished &&
              row.isCompleted) {
            return false;
          }
          if (playedPlatformIds.isNotEmpty &&
              !playedPlatformIds.contains(row.playedPlatformId)) {
            return false;
          }
          return switch (ratingFilter) {
            LibraryRatingFilter.any => true,
            LibraryRatingFilter.fourPlus => (row.personalRating ?? 0) >= 4,
            LibraryRatingFilter.threePlus => (row.personalRating ?? 0) >= 3,
            LibraryRatingFilter.unrated => row.personalRating == null,
          };
        }).toList();

    result.sort((a, b) {
      final aGroup = _completionGroup(a);
      final bGroup = _completionGroup(b);
      if (aGroup != bGroup) return aGroup.compareTo(bGroup);
      if (aGroup == 0) {
        final date = b.completedAt!.compareTo(a.completedAt!);
        if (date != 0) return date;
      }
      final aTitle = (a.sortTitle ?? a.title).toLowerCase();
      final bTitle = (b.sortTitle ?? b.title).toLowerCase();
      final title = aTitle.compareTo(bTitle);
      return title != 0 ? title : a.libraryEntryId.compareTo(b.libraryEntryId);
    });
    return result;
  }

  static int _completionGroup(LibraryGameRow row) =>
      !row.isCompleted
          ? 2
          : row.completedAt == null
          ? 1
          : 0;
}
