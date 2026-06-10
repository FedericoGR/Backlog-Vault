import 'package:backlog_vault/features/library/application/library_home_summary.dart';
import 'package:backlog_vault/features/library/domain/game_status.dart';
import 'package:backlog_vault/features/library/domain/library_game_row.dart';
import 'package:test/test.dart';

void main() {
  test('builds lightweight home counts and sections', () {
    final data = buildLibraryHomeData(_rows);

    expect(data.totalGames, 5);
    expect(data.backlogCount, 1);
    expect(data.playingCount, 1);
    expect(data.completedCount, 1);
    expect(data.missingCoverCount, 2);
    expect(data.playingNow.map((row) => row.title), [
      'Metroid Prime',
      'Baldur\'s Gate 3',
    ]);
    expect(data.backlog.single.title, 'Celeste');
    expect(data.recentlyCompleted.single.title, 'Hades');
    expect(data.missingCover.map((row) => row.title), [
      'Baldur\'s Gate 3',
      'Celeste',
    ]);
    expect(data.missingMetadata.map((row) => row.title), [
      'Metroid Prime',
      'Baldur\'s Gate 3',
      'Celeste',
    ]);
    expect(data.recentlyUpdated.first.title, 'Metroid Prime');
  });

  test('limits home sections without changing counts', () {
    final data = buildLibraryHomeData(_rows, sectionLimit: 1);

    expect(data.totalGames, 5);
    expect(data.playingNow, hasLength(1));
    expect(data.missingMetadata, hasLength(1));
    expect(data.recentlyUpdated, hasLength(1));
  });
}

final _rows = [
  LibraryGameRow(
    gameId: 'g1',
    libraryEntryId: 'e1',
    title: 'Hades',
    sortTitle: 'hades',
    selectedCoverLocalPath: 'media/games/g1/cover.png',
    hasExternalMetadata: true,
    status: GameStatus.completed,
    completedAt: DateTime(2026, 1, 2),
    hoursPlayed: 40,
    personalRating: 5,
    type: 'game',
    platforms: const [LibraryCatalogItem(id: 'pc', name: 'PC')],
    genres: const [LibraryCatalogItem(id: 'roguelite', name: 'Roguelite')],
    playthroughCount: 1,
    updatedAt: DateTime(2026, 1, 3),
  ),
  LibraryGameRow(
    gameId: 'g2',
    libraryEntryId: 'e2',
    title: 'Baldur\'s Gate 3',
    status: GameStatus.playing,
    type: 'game',
    platforms: const [LibraryCatalogItem(id: 'pc', name: 'PC')],
    genres: const [LibraryCatalogItem(id: 'rpg', name: 'RPG')],
    playthroughCount: 1,
    updatedAt: DateTime(2026, 3, 1),
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
    updatedAt: DateTime(2026, 2, 1),
  ),
  LibraryGameRow(
    gameId: 'g4',
    libraryEntryId: 'e4',
    title: 'Silent Hill 3',
    selectedCoverLocalPath: 'media/games/g4/cover.png',
    hasExternalMetadata: true,
    status: GameStatus.dropped,
    type: 'game',
    platforms: const [LibraryCatalogItem(id: 'ps2', name: 'PlayStation 2')],
    genres: const [LibraryCatalogItem(id: 'horror', name: 'Horror')],
    playthroughCount: 1,
    updatedAt: DateTime(2026, 4, 1),
  ),
  LibraryGameRow(
    gameId: 'g5',
    libraryEntryId: 'e5',
    title: 'Metroid Prime',
    selectedCoverLocalPath: 'media/games/g5/cover.png',
    status: GameStatus.paused,
    type: 'game',
    platforms: const [LibraryCatalogItem(id: 'switch', name: 'Switch')],
    genres: const [LibraryCatalogItem(id: 'adventure', name: 'Adventure')],
    playthroughCount: 1,
    updatedAt: DateTime(2026, 5, 1),
  ),
];
