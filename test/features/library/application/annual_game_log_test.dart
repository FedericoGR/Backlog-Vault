import 'package:backlog_vault/core/time/clock.dart';
import 'package:backlog_vault/features/library/application/annual_game_log.dart';
import 'package:backlog_vault/features/library/domain/library_game_row.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final rows = [
    _row('jan', 'Hades', completedAt: DateTime(2026, 1, 1), rating: 5),
    _row('sep', 'Onimusha', completedAt: DateTime(2026, 9, 26), rating: 4),
    _row('old', 'Celeste', completedAt: DateTime(2025, 12, 30), rating: 3),
    _row('undated-z', 'Zelda', completed: true, rating: 2),
    _row('undated-a', 'Animal Well', completed: true),
    _row('unfinished-z', 'Yakuza', rating: 5),
    _row('unfinished-a', 'Balatro', rating: 3, platformId: 'ps5'),
    _row('other-year', 'Other Year', year: 2025, completedAt: DateTime(2025)),
    _row(
      'other-year-newer',
      'Other Year Newer',
      year: 2025,
      completedAt: DateTime(2025, 6),
    ),
    _row('unknown-year', 'No Year', year: null, completedAt: DateTime(2024)),
    _row(
      'unknown-older',
      'No Year Older',
      year: null,
      completedAt: DateTime(2023),
    ),
  ];

  test('sorts completion dates newest first, then undated groups by title', () {
    final visible = const AnnualGameLogState(year: 2026).visibleRows(rows);
    expect(visible.map((row) => row.title), [
      'Onimusha',
      'Hades',
      'Celeste',
      'Animal Well',
      'Zelda',
      'Balatro',
      'Yakuza',
    ]);
  });

  test('search, another year and Sin año preserve the same ordering rules', () {
    expect(
      const AnnualGameLogState(
        year: 2026,
        query: 'a',
      ).visibleRows(rows).map((row) => row.title).toList(),
      ['Onimusha', 'Hades', 'Animal Well', 'Zelda', 'Balatro', 'Yakuza'],
    );
    expect(
      const AnnualGameLogState(
        year: 2025,
      ).visibleRows(rows).map((row) => row.title),
      ['Other Year Newer', 'Other Year'],
    );
    expect(
      const AnnualGameLogState(
        year: null,
      ).visibleRows(rows).map((row) => row.title),
      ['No Year', 'No Year Older'],
    );
  });

  test('completion filters use only isCompleted', () {
    expect(
      const AnnualGameLogState(
        year: 2026,
        completionFilter: LibraryCompletionFilter.completed,
      ).visibleRows(rows).every((row) => row.isCompleted),
      isTrue,
    );
    expect(
      const AnnualGameLogState(
        year: 2026,
        completionFilter: LibraryCompletionFilter.unfinished,
      ).visibleRows(rows).map((row) => row.title),
      ['Balatro', 'Yakuza'],
    );
    expect(
      const AnnualGameLogState(year: 2026).visibleRows(rows),
      hasLength(7),
    );
    expect(
      const AnnualGameLogState(
        year: 2026,
        query: 'a',
        completionFilter: LibraryCompletionFilter.unfinished,
      ).visibleRows(rows).map((row) => row.title),
      ['Balatro', 'Yakuza'],
    );
  });

  test('platform filter uses playedPlatformId, not catalog platforms', () {
    final pc = const AnnualGameLogState(
      year: 2026,
      playedPlatformIds: {'pc'},
    ).visibleRows(rows);
    expect(pc.map((row) => row.title), [
      'Onimusha',
      'Hades',
      'Celeste',
      'Animal Well',
      'Zelda',
      'Yakuza',
    ]);

    final multiple = const AnnualGameLogState(
      year: 2026,
      playedPlatformIds: {'ps5', 'pc'},
    ).visibleRows(rows);
    expect(multiple, hasLength(7));
    expect(multiple.any((row) => row.libraryEntryId == 'unfinished-a'), isTrue);
  });

  test('rating choices use personalRating and leave unrated separate', () {
    final fourPlus = const AnnualGameLogState(
      year: 2026,
      ratingFilter: LibraryRatingFilter.fourPlus,
    ).visibleRows(rows);
    expect(fourPlus.map((row) => row.title), ['Onimusha', 'Hades', 'Yakuza']);

    final threePlus = const AnnualGameLogState(
      year: 2026,
      ratingFilter: LibraryRatingFilter.threePlus,
    ).visibleRows(rows);
    expect(threePlus.map((row) => row.title), [
      'Onimusha',
      'Hades',
      'Celeste',
      'Balatro',
      'Yakuza',
    ]);

    final unrated = const AnnualGameLogState(
      year: 2026,
      ratingFilter: LibraryRatingFilter.unrated,
    ).visibleRows(rows);
    expect(unrated.map((row) => row.title), ['Animal Well']);
  });

  test('clear filters leaves year and search intact', () {
    final container = ProviderContainer(
      overrides: [annualLogClockProvider.overrideWithValue(_Clock())],
    );
    addTearDown(container.dispose);
    final controller = container.read(annualGameLogProvider.notifier);
    controller.search('Hades');
    controller.setCompletionFilter(LibraryCompletionFilter.completed);
    controller.togglePlayedPlatform('pc');
    controller.setRatingFilter(LibraryRatingFilter.fourPlus);
    controller.clearFilters();
    final state = container.read(annualGameLogProvider);
    expect(state.year, 2026);
    expect(state.query, 'Hades');
    expect(state.hasActiveFilters, isFalse);
    expect(state.visibleRows(rows).map((row) => row.title), ['Hades']);
  });
}

class _Clock extends Clock {
  @override
  DateTime now() => DateTime(2026, 10, 6);
}

LibraryGameRow _row(
  String id,
  String title, {
  int? year = 2026,
  bool completed = false,
  DateTime? completedAt,
  int? rating,
  String platformId = 'pc',
}) => LibraryGameRow(
  gameId: id,
  libraryEntryId: id,
  title: title,
  isCompleted: completed || completedAt != null,
  type: 'game',
  platforms: const [LibraryCatalogItem(id: 'catalog-ps5', name: 'Catalog PS5')],
  genres: const [],
  updatedAt: DateTime(2026),
  playedYear: year,
  completedAt: completedAt,
  playedPlatformId: platformId,
  playedPlatformName: platformId.toUpperCase(),
  personalRating: rating,
);
