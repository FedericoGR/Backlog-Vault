import '../domain/library_column_config.dart';
import '../domain/library_filter_state.dart';
import '../domain/library_sort_state.dart';
import '../domain/saved_library_view.dart';

class LibraryTableState {
  const LibraryTableState({
    required this.activeViewId,
    required this.filter,
    required this.sort,
    required this.columnConfig,
  });

  factory LibraryTableState.initial() {
    return LibraryTableState.fromView(defaultAllGamesView);
  }

  factory LibraryTableState.fromView(SavedLibraryView view) {
    return LibraryTableState(
      activeViewId: view.id,
      filter: view.filter,
      sort: view.sort,
      columnConfig: view.columnConfig,
    );
  }

  final String activeViewId;
  final LibraryFilterState filter;
  final LibrarySortState sort;
  final LibraryColumnConfig columnConfig;

  LibraryTableState copyWith({
    String? activeViewId,
    LibraryFilterState? filter,
    LibrarySortState? sort,
    LibraryColumnConfig? columnConfig,
  }) {
    return LibraryTableState(
      activeViewId: activeViewId ?? this.activeViewId,
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
      columnConfig: columnConfig ?? this.columnConfig,
    );
  }
}

const defaultAllGamesViewId = 'default:all';

final defaultAllGamesView = SavedLibraryView(
  id: defaultAllGamesViewId,
  name: 'Todos los juegos',
  filter: const LibraryFilterState(),
  sort: const LibrarySortState(),
  columnConfig: LibraryColumnConfig(),
  isDefault: true,
);
