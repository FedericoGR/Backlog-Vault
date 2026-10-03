import 'package:backlog_vault/features/library/domain/library_game_row.dart';
import 'package:backlog_vault/features/statistics/application/library_statistics_calculator.dart';
import 'package:test/test.dart';

void main() {
  const calculator = LibraryStatisticsCalculator();

  test('calculates global, yearly, monthly and quality statistics', () {
    final stats = calculator.calculate(rows: _rows);

    expect(stats.totalGames, 5);
    expect(stats.backlogCount, 2);
    expect(stats.completedCount, 3);
    expect(stats.completedByYear[2026], 2);
    expect(stats.completedByYear[2025], isNull);
    expect(stats.hoursByYear[2026], 77);
    expect(stats.hoursByYear[2025], isNull);
    expect(stats.totalHours, 77);

    final year2026 = stats.statsForYear(2026)!;
    expect(year2026.completedCount, 2);
    expect(year2026.hours, 77);
    expect(year2026.monthlyCompletions[0].completedCount, 0);
    expect(year2026.monthlyCompletions[1].completedCount, 1);
    expect(year2026.monthlyCompletions[2].completedCount, 1);
    expect(year2026.monthlyCompletions[2].hours, 42);

    expect(stats.averageRating, closeTo(3.67, 0.01));
    expect(stats.ratingDistribution.countByRating[5], 1);
    expect(stats.ratingDistribution.countByRating[4], 1);
    expect(stats.ratingDistribution.countByRating[2], 1);
    expect(stats.ratingDistribution.unratedCount, 2);

    final pc = stats.platformBreakdown.singleWhere((item) => item.name == 'PC');
    final rpg = stats.genreBreakdown.singleWhere((item) => item.name == 'RPG');
    expect(pc.count, 2);
    expect(rpg.count, 1);

    expect(stats.qualityStats.missingCover, 2);
    expect(stats.qualityStats.missingMetadata, 3);
    expect(stats.qualityStats.missingRating, 2);
    expect(stats.qualityStats.missingPlatform, 2);
    expect(stats.qualityStats.missingGenre, 1);
    expect(stats.qualityStats.completedWithoutDate, 1);
  });

  test('builds latest completions without duplicating the same game', () {
    final stats = calculator.calculate(rows: _rows);

    expect(stats.latestCompleted.map((item) => item.row.title), [
      'Baldur\'s Gate 3',
      'Hades',
    ]);
    expect(stats.latestCompleted.first.completedAt, DateTime(2026, 3, 10));
    expect(stats.latestCompleted.last.completedAt, DateTime(2026, 2, 2));
  });

  test('handles an empty library without ugly values', () {
    final stats = calculator.calculate(rows: const []);

    expect(stats.totalGames, 0);
    expect(stats.totalHours, 0);
    expect(stats.averageRating, isNull);
    expect(stats.ratingDistribution.unratedCount, 0);
    expect(stats.platformBreakdown, isEmpty);
    expect(stats.genreBreakdown, isEmpty);
    expect(stats.yearlyStatistics, isEmpty);
    expect(stats.latestCompleted, isEmpty);
  });
}

final _rows = [
  LibraryGameRow(
    gameId: 'g1',
    libraryEntryId: 'e1',
    title: 'Hades',
    selectedCoverLocalPath: 'media/games/g1/cover.png',
    hasExternalMetadata: true,
    isCompleted: true,
    completedAt: DateTime(2026, 2, 2),
    hoursPlayed: 35,
    playedPlatformId: 'pc',
    playedPlatformName: 'PC',
    personalRating: 5,
    type: 'game',
    platforms: const [
      LibraryCatalogItem(id: 'pc', name: 'PC'),
      LibraryCatalogItem(id: 'switch', name: 'Nintendo Switch'),
    ],
    genres: const [LibraryCatalogItem(id: 'roguelite', name: 'Roguelite')],

    updatedAt: DateTime(2026, 6, 1),
  ),
  LibraryGameRow(
    gameId: 'g2',
    libraryEntryId: 'e2',
    title: 'Baldur\'s Gate 3',
    isCompleted: true,
    completedAt: DateTime(2026, 3, 10),
    hoursPlayed: 42,
    playedPlatformId: 'pc',
    playedPlatformName: 'PC',
    personalRating: 4,
    type: 'game',
    platforms: const [LibraryCatalogItem(id: 'pc', name: 'PC')],
    genres: const [LibraryCatalogItem(id: 'rpg', name: 'RPG')],

    updatedAt: DateTime(2026, 6, 2),
  ),
  LibraryGameRow(
    gameId: 'g3',
    libraryEntryId: 'e3',
    title: 'Celeste',
    isCompleted: false,
    type: 'game',
    platforms: const [],
    genres: const [],

    updatedAt: DateTime(2026, 6, 3),
  ),
  LibraryGameRow(
    gameId: 'g4',
    libraryEntryId: 'e4',
    title: 'Silent Hill 3',
    selectedCoverLocalPath: 'media/games/g4/cover.png',
    isCompleted: true,
    playedPlatformId: 'ps2',
    playedPlatformName: 'PlayStation 2',
    personalRating: 2,
    type: 'game',
    platforms: const [LibraryCatalogItem(id: 'ps2', name: 'PlayStation 2')],
    genres: const [LibraryCatalogItem(id: 'horror', name: 'Horror')],

    updatedAt: DateTime(2026, 6, 4),
  ),
  LibraryGameRow(
    gameId: 'g5',
    libraryEntryId: 'e5',
    title: 'Dropped Game',
    selectedCoverLocalPath: 'media/games/g5/cover.png',
    hasExternalMetadata: true,
    isCompleted: false,
    type: 'game',
    platforms: const [
      LibraryCatalogItem(id: 'switch', name: 'Nintendo Switch'),
    ],
    genres: const [LibraryCatalogItem(id: 'strategy', name: 'Strategy')],

    updatedAt: DateTime(2026, 6, 5),
  ),
];
