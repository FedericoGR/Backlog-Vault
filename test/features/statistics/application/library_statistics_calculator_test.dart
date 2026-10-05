import 'package:backlog_vault/features/library/domain/library_game_row.dart';
import 'package:backlog_vault/features/statistics/application/library_statistics_calculator.dart';
import 'package:test/test.dart';

void main() {
  const calculator = LibraryStatisticsCalculator();
  test(
    'played year scopes all personal KPIs, independent of completion and catalog dates',
    () {
      final rows = [
        row(
          'a',
          year: 2026,
          completed: true,
          date: DateTime(2025, 12),
          hours: 10,
          rating: 5,
          played: 'ps5',
        ),
        row('b', year: 2026, hours: 18, rating: 3),
        row('c', year: 2026, completed: true, played: 'pc'),
        row(
          'other-year',
          year: 2025,
          completed: true,
          date: DateTime(2026),
          hours: 99,
          rating: 1,
        ),
        row(
          'unknown-year',
          completed: true,
          date: DateTime(2026),
          hours: 100,
          rating: 1,
        ),
      ];
      final stats = calculator.calculate(rows: rows, year: 2026);
      expect(stats.year, 2026);
      expect(stats.totalGames, 3);
      expect(stats.completedCount, 2); // No completion date required.
      expect(stats.totalHours, 28); // Includes unfinished games.
      expect(stats.averageRating, 4); // Unrated game is ignored.
      expect(stats.favorites.map((r) => r.libraryEntryId), ['a', 'b']);
      expect(stats.platformBreakdown.map((p) => p.id).toSet(), {'pc', 'ps5'});
      expect(stats.platformBreakdown.map((p) => p.count), [1, 1]);
      expect(calculator.calculate(rows: rows, year: 2025).totalGames, 1);
      expect(calculator.calculate(rows: rows, year: 2024).totalGames, 0);
    },
  );

  test(
    'unknown played year is never inferred from release, completion or update dates',
    () {
      final stats = calculator.calculate(
        rows: [row('unknown', completed: true, date: DateTime(2026))],
        year: 2026,
      );
      expect(stats.totalGames, 0);
      expect(stats.completedCount, 0);
      expect(stats.totalHours, isNull);
      expect(stats.averageRating, isNull);
      expect(stats.favorites, isEmpty);
    },
  );

  test('one LibraryEntry counts once even when an input row repeats', () {
    final game = row(
      'one',
      year: 2026,
      completed: true,
      hours: 12,
      rating: 5,
      played: 'ps5',
    );
    final stats = calculator.calculate(rows: [game, game, game], year: 2026);
    expect(stats.totalGames, 1);
    expect(stats.completedCount, 1);
    expect(stats.totalHours, 12);
    expect(stats.favorites, hasLength(1));
    expect(stats.platformBreakdown.single.count, 1);
  });

  test(
    'platform distribution uses personal platform ID, never catalog platforms',
    () {
      final stats = calculator.calculate(
        rows: [
          row('a', year: 2026, played: 'ps5'),
          row('b', year: 2026, played: 'ps5'),
          row('c', year: 2026),
        ],
        year: 2026,
      );
      expect(stats.platformBreakdown.single.id, 'ps5');
      expect(stats.platformBreakdown.single.name, 'Played ps5');
      expect(stats.platformBreakdown.single.count, 2);
    },
  );

  test(
    'unknown hours and ratings remain unavailable, while explicit zero hours remains zero',
    () {
      final stats = calculator.calculate(
        rows: [row('a', year: 2026)],
        year: 2026,
      );
      expect(stats.totalHours, isNull);
      expect(stats.averageRating, isNull);
      expect(stats.favorites, isEmpty);
      expect(stats.platformBreakdown, isEmpty);
      expect(
        calculator
            .calculate(rows: [row('zero', year: 2026, hours: 0)], year: 2026)
            .totalHours,
        0,
      );
    },
  );

  test(
    'favorites include only rated entries, use stable ties and stay small',
    () {
      final rows = [
        row('unrated', year: 2026),
        for (var i = 8; i >= 0; i--) row('$i', year: 2026, rating: 4),
      ];
      final stats = calculator.calculate(rows: rows, year: 2026);
      expect(stats.favorites.map((r) => r.title), ['0', '1', '2', '3', '4']);
      expect(stats.averageRating, 4);
    },
  );

  test('empty year has zero records and unavailable personal measurements', () {
    final stats = calculator.calculate(rows: [], year: 2026);
    expect(stats.totalGames, 0);
    expect(stats.completedCount, 0);
    expect(stats.totalHours, isNull);
    expect(stats.averageRating, isNull);
    expect(stats.platformBreakdown, isEmpty);
  });
}

LibraryGameRow row(
  String id, {
  int? year,
  bool completed = false,
  DateTime? date,
  double? hours,
  int? rating,
  String? played,
}) => LibraryGameRow(
  gameId: 'game-$id',
  libraryEntryId: id,
  title: id,
  playedYear: year,
  isCompleted: completed,
  completedAt: date,
  hoursPlayed: hours,
  personalRating: rating,
  playedPlatformId: played,
  playedPlatformName: played == null ? null : 'Played $played',
  releaseDate: DateTime(2026),
  updatedAt: DateTime(2026),
  type: 'game',
  platforms: const [
    LibraryCatalogItem(id: 'catalog-only', name: 'Catalog platform'),
  ],
  genres: const [],
);
