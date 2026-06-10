import '../domain/game_status.dart';
import '../domain/library_filter_state.dart';
import '../domain/library_game_row.dart';
import '../domain/library_sort_state.dart';
import '../domain/library_table_summary.dart';

class LibraryTableResult {
  const LibraryTableResult({required this.rows, required this.summary});

  final List<LibraryGameRow> rows;
  final LibraryTableSummary summary;
}

class LibraryTableProcessor {
  const LibraryTableProcessor();

  LibraryTableResult apply({
    required List<LibraryGameRow> rows,
    required LibraryFilterState filter,
    required LibrarySortState sort,
  }) {
    final filtered = rows.where((row) => _matches(row, filter)).toList();
    filtered.sort((a, b) => _compareRows(a, b, sort));
    return LibraryTableResult(
      rows: filtered,
      summary: LibraryTableSummary.fromRows(filtered),
    );
  }

  bool _matches(LibraryGameRow row, LibraryFilterState filter) {
    if (filter.textQuery.trim().isNotEmpty &&
        !_matchesSearch(row, filter.textQuery)) {
      return false;
    }
    if (filter.statuses.isNotEmpty && !filter.statuses.contains(row.status)) {
      return false;
    }
    if (filter.platformIds.isNotEmpty &&
        !row.platforms.any(
          (platform) => filter.platformIds.contains(platform.id),
        )) {
      return false;
    }
    if (filter.genreIds.isNotEmpty &&
        !row.genres.any((genre) => filter.genreIds.contains(genre.id))) {
      return false;
    }
    if (filter.minRating != null &&
        (row.personalRating == null ||
            row.personalRating! < filter.minRating!)) {
      return false;
    }
    if (filter.maxRating != null &&
        (row.personalRating == null ||
            row.personalRating! > filter.maxRating!)) {
      return false;
    }
    if (filter.releaseDateFrom != null &&
        (row.releaseDate == null ||
            row.releaseDate!.isBefore(_startOfDay(filter.releaseDateFrom!)))) {
      return false;
    }
    if (filter.releaseDateTo != null &&
        (row.releaseDate == null ||
            row.releaseDate!.isAfter(_endOfDay(filter.releaseDateTo!)))) {
      return false;
    }
    if (filter.completedDateFrom != null &&
        (row.completedAt == null ||
            row.completedAt!.isBefore(
              _startOfDay(filter.completedDateFrom!),
            ))) {
      return false;
    }
    if (filter.completedDateTo != null &&
        (row.completedAt == null ||
            row.completedAt!.isAfter(_endOfDay(filter.completedDateTo!)))) {
      return false;
    }
    if (filter.minHours != null &&
        (row.hoursPlayed == null || row.hoursPlayed! < filter.minHours!)) {
      return false;
    }
    if (filter.maxHours != null &&
        (row.hoursPlayed == null || row.hoursPlayed! > filter.maxHours!)) {
      return false;
    }
    if (filter.type?.trim().isNotEmpty ?? false) {
      if (_normalize(row.type) != _normalize(filter.type!)) return false;
    }
    if (filter.hasRating && row.personalRating == null) return false;
    if (filter.missingRating && row.personalRating != null) return false;
    if (filter.hasPlatform && row.platforms.isEmpty) return false;
    if (filter.missingPlatform && row.platforms.isNotEmpty) return false;
    if (filter.hasGenre && row.genres.isEmpty) return false;
    if (filter.missingGenre && row.genres.isNotEmpty) return false;
    if (filter.hasCompletedDate && row.completedAt == null) return false;
    if (filter.missingCompletedDate && row.completedAt != null) return false;
    return true;
  }

  bool _matchesSearch(LibraryGameRow row, String query) {
    final normalizedQuery = _normalize(query);
    if (normalizedQuery.isEmpty) return true;
    final haystack = _normalize(
      [
        row.title,
        row.sortTitle,
        row.personalNotes,
        row.type,
        for (final platform in row.platforms) platform.name,
        for (final genre in row.genres) genre.name,
      ].whereType<String>().join(' '),
    );
    return haystack.contains(normalizedQuery);
  }

  int _compareRows(LibraryGameRow a, LibraryGameRow b, LibrarySortState sort) {
    final result = switch (sort.field) {
      LibrarySortField.title => _compareString(
        a.sortTitle ?? a.title,
        b.sortTitle ?? b.title,
      ),
      LibrarySortField.status => _compareStatus(a.status, b.status),
      LibrarySortField.rating => _compareNullable(
        a.personalRating,
        b.personalRating,
        sort.ascending,
      ),
      LibrarySortField.releaseDate => _compareNullable(
        a.releaseDate,
        b.releaseDate,
        sort.ascending,
      ),
      LibrarySortField.completedDate => _compareNullable(
        a.completedAt,
        b.completedAt,
        sort.ascending,
      ),
      LibrarySortField.hours => _compareNullable(
        a.hoursPlayed,
        b.hoursPlayed,
        sort.ascending,
      ),
      LibrarySortField.updatedAt => _compareNullable(
        a.updatedAt,
        b.updatedAt,
        sort.ascending,
      ),
    };
    if (result == 0) return _compareString(a.title, b.title);
    if (sort.field != LibrarySortField.title &&
        sort.field != LibrarySortField.status) {
      return result;
    }
    return sort.ascending ? result : -result;
  }

  int _compareStatus(GameStatus a, GameStatus b) {
    return a.label.compareTo(b.label);
  }

  int _compareString(String a, String b) {
    return _normalize(a).compareTo(_normalize(b));
  }

  int _compareNullable<T extends Comparable<Object>>(
    T? a,
    T? b,
    bool ascending,
  ) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    final result = a.compareTo(b);
    return ascending ? result : -result;
  }
}

String normalizeLibrarySearchText(String value) => _normalize(value);

String _normalize(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

DateTime _startOfDay(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

DateTime _endOfDay(DateTime value) {
  return DateTime(value.year, value.month, value.day, 23, 59, 59, 999);
}
