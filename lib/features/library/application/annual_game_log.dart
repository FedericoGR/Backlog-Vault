import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/time/clock.dart';
import '../domain/library_game_row.dart';

final annualLogClockProvider = Provider<Clock>((ref) => systemClock);
final annualGameLogProvider =
    NotifierProvider<AnnualGameLog, AnnualGameLogState>(AnnualGameLog.new);

/// The active library state consists only of year and search.
class AnnualGameLog extends Notifier<AnnualGameLogState> {
  @override
  AnnualGameLogState build() =>
      AnnualGameLogState(year: ref.watch(annualLogClockProvider).now().year);

  void selectYear(int? year) =>
      state = AnnualGameLogState(year: year, query: state.query);
  void search(String query) =>
      state = AnnualGameLogState(year: state.year, query: query);
}

class AnnualGameLogState {
  const AnnualGameLogState({required this.year, this.query = ''});

  /// Null explicitly selects records with no known year.
  final int? year;
  final String query;

  List<LibraryGameRow> visibleRows(List<LibraryGameRow> rows) {
    final terms = query.trim().toLowerCase().split(RegExp(r'\s+'));
    return rows
        .where(
          (row) =>
              row.playedYear == year &&
              terms.every((term) => row.title.toLowerCase().contains(term)),
        )
        .toList()
      ..sort((a, b) {
        final title = a.title.toLowerCase().compareTo(b.title.toLowerCase());
        return title != 0
            ? title
            : a.libraryEntryId.compareTo(b.libraryEntryId);
      });
  }
}
