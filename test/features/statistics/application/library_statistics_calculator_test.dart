import 'package:backlog_vault/features/library/domain/game_status.dart';
import 'package:backlog_vault/features/library/domain/library_game_row.dart';
import 'package:backlog_vault/features/playthroughs/domain/playthrough_status.dart';
import 'package:backlog_vault/features/statistics/application/library_statistics_calculator.dart';
import 'package:backlog_vault/features/statistics/domain/statistics_models.dart';
import 'package:test/test.dart';

void main() {
  const calculator = LibraryStatisticsCalculator();

  test('calculates global, yearly, monthly and quality statistics', () {
    final stats = calculator.calculate(
      rows: _rows,
      playthroughs: _playthroughs,
    );

    expect(stats.totalGames, 5);
    expect(stats.backlogCount, 1);
    expect(stats.playingCount, 1);
    expect(stats.pausedCount, 0);
    expect(stats.completedCount, 2);
    expect(stats.statusCounts[GameStatus.dropped], 1);
    expect(stats.completedByYear[2026], 3);
    expect(stats.completedByYear[2025], 1);
    expect(stats.hoursByYear[2026], 60);
    expect(stats.hoursByYear[2025], 5);
    expect(stats.totalHours, 77);

    final year2026 = stats.statsForYear(2026)!;
    expect(year2026.completedCount, 3);
    expect(year2026.hours, 60);
    expect(year2026.monthlyCompletions[0].completedCount, 1);
    expect(year2026.monthlyCompletions[1].completedCount, 1);
    expect(year2026.monthlyCompletions[2].completedCount, 1);
    expect(year2026.monthlyCompletions[2].hours, 30);

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
    expect(stats.qualityStats.missingPlatform, 1);
    expect(stats.qualityStats.missingGenre, 1);
    expect(stats.qualityStats.completedWithoutDate, 1);
  });

  test('builds latest completions without duplicating the same game', () {
    final stats = calculator.calculate(
      rows: _rows,
      playthroughs: _playthroughs,
    );

    expect(stats.latestCompleted.map((item) => item.row.title), [
      'Baldur\'s Gate 3',
      'Hades',
    ]);
    expect(stats.latestCompleted.first.completedAt, DateTime(2026, 3, 10));
    expect(stats.latestCompleted.last.completedAt, DateTime(2026, 2, 2));
  });

  test('handles an empty library without ugly values', () {
    final stats = calculator.calculate(rows: const [], playthroughs: const []);

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
    status: GameStatus.completed,
    personalRating: 5,
    type: 'game',
    platforms: const [
      LibraryCatalogItem(id: 'pc', name: 'PC'),
      LibraryCatalogItem(id: 'switch', name: 'Nintendo Switch'),
    ],
    genres: const [LibraryCatalogItem(id: 'roguelite', name: 'Roguelite')],
    playthroughCount: 3,
    updatedAt: DateTime(2026, 6, 1),
  ),
  LibraryGameRow(
    gameId: 'g2',
    libraryEntryId: 'e2',
    title: 'Baldur\'s Gate 3',
    status: GameStatus.playing,
    personalRating: 4,
    type: 'game',
    platforms: const [LibraryCatalogItem(id: 'pc', name: 'PC')],
    genres: const [LibraryCatalogItem(id: 'rpg', name: 'RPG')],
    playthroughCount: 2,
    updatedAt: DateTime(2026, 6, 2),
  ),
  LibraryGameRow(
    gameId: 'g3',
    libraryEntryId: 'e3',
    title: 'Celeste',
    status: GameStatus.backlog,
    type: 'game',
    platforms: const [],
    genres: const [],
    playthroughCount: 0,
    updatedAt: DateTime(2026, 6, 3),
  ),
  LibraryGameRow(
    gameId: 'g4',
    libraryEntryId: 'e4',
    title: 'Silent Hill 3',
    selectedCoverLocalPath: 'media/games/g4/cover.png',
    status: GameStatus.completed,
    personalRating: 2,
    type: 'game',
    platforms: const [LibraryCatalogItem(id: 'ps2', name: 'PlayStation 2')],
    genres: const [LibraryCatalogItem(id: 'horror', name: 'Horror')],
    playthroughCount: 0,
    updatedAt: DateTime(2026, 6, 4),
  ),
  LibraryGameRow(
    gameId: 'g5',
    libraryEntryId: 'e5',
    title: 'Dropped Game',
    selectedCoverLocalPath: 'media/games/g5/cover.png',
    hasExternalMetadata: true,
    status: GameStatus.dropped,
    type: 'game',
    platforms: const [
      LibraryCatalogItem(id: 'switch', name: 'Nintendo Switch'),
    ],
    genres: const [LibraryCatalogItem(id: 'strategy', name: 'Strategy')],
    playthroughCount: 1,
    updatedAt: DateTime(2026, 6, 5),
  ),
];

final _playthroughs = [
  StatisticsPlaythrough(
    libraryEntryId: 'e1',
    status: PlaythroughStatus.completed,
    completedAt: DateTime(2026, 1, 2),
    hoursPlayed: 10,
  ),
  StatisticsPlaythrough(
    libraryEntryId: 'e1',
    status: PlaythroughStatus.completed,
    completedAt: DateTime(2026, 2, 2),
    hoursPlayed: 20,
  ),
  StatisticsPlaythrough(
    libraryEntryId: 'e1',
    status: PlaythroughStatus.completed,
    completedAt: DateTime(2025, 12, 30),
    hoursPlayed: 5,
  ),
  StatisticsPlaythrough(
    libraryEntryId: 'e2',
    status: PlaythroughStatus.active,
    hoursPlayed: 12,
  ),
  StatisticsPlaythrough(
    libraryEntryId: 'e2',
    status: PlaythroughStatus.completed,
    completedAt: DateTime(2026, 3, 10),
    hoursPlayed: 30,
  ),
  StatisticsPlaythrough(
    libraryEntryId: 'deleted-entry',
    status: PlaythroughStatus.completed,
    completedAt: DateTime(2026, 4, 1),
    hoursPlayed: 999,
  ),
];
