import '../domain/game_status.dart';
import '../domain/library_game_row.dart';

class LibraryHomeData {
  const LibraryHomeData({
    required this.totalGames,
    required this.backlogCount,
    required this.completedCount,
    required this.missingCoverCount,
    required this.backlog,
    required this.recentlyCompleted,
    required this.missingCover,
    required this.missingMetadata,
    required this.recentlyUpdated,
  });

  final int totalGames;
  final int backlogCount;
  final int completedCount;
  final int missingCoverCount;
  final List<LibraryGameRow> backlog;
  final List<LibraryGameRow> recentlyCompleted;
  final List<LibraryGameRow> missingCover;
  final List<LibraryGameRow> missingMetadata;
  final List<LibraryGameRow> recentlyUpdated;
}

LibraryHomeData buildLibraryHomeData(
  List<LibraryGameRow> rows, {
  int sectionLimit = 6,
}) {
  final backlog =
      rows.where((row) => row.status == GameStatus.pending).toList()
        ..sort(_byUpdatedDesc);
  final recentlyCompleted =
      rows.where((row) => row.isCompleted && row.completedAt != null).toList()
        ..sort(_byCompletedDesc);
  final missingCover =
      rows
          .where(
            (row) =>
                row.selectedCoverLocalPath == null ||
                row.selectedCoverLocalPath!.trim().isEmpty,
          )
          .toList()
        ..sort(_byUpdatedDesc);
  final missingMetadata =
      rows.where((row) => !row.hasExternalMetadata).toList()
        ..sort(_byUpdatedDesc);
  final recentlyUpdated = [...rows]..sort(_byUpdatedDesc);

  return LibraryHomeData(
    totalGames: rows.length,
    backlogCount: rows.where((row) => row.status == GameStatus.pending).length,
    completedCount:
        rows.where((row) => row.status == GameStatus.completed).length,
    missingCoverCount: missingCover.length,
    backlog: _take(backlog, sectionLimit),
    recentlyCompleted: _take(recentlyCompleted, sectionLimit),
    missingCover: _take(missingCover, sectionLimit),
    missingMetadata: _take(missingMetadata, sectionLimit),
    recentlyUpdated: _take(recentlyUpdated, sectionLimit),
  );
}

List<LibraryGameRow> _take(List<LibraryGameRow> rows, int limit) {
  return rows.take(limit).toList(growable: false);
}

int _byUpdatedDesc(LibraryGameRow a, LibraryGameRow b) {
  final result = b.updatedAt.compareTo(a.updatedAt);
  return result == 0 ? a.title.compareTo(b.title) : result;
}

int _byCompletedDesc(LibraryGameRow a, LibraryGameRow b) {
  final aDate = a.completedAt;
  final bDate = b.completedAt;
  if (aDate == null && bDate == null) return a.title.compareTo(b.title);
  if (aDate == null) return 1;
  if (bDate == null) return -1;
  final result = bDate.compareTo(aDate);
  return result == 0 ? a.title.compareTo(b.title) : result;
}
