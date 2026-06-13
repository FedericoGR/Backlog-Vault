import '../domain/game_status.dart';
import '../domain/library_column_config.dart';
import '../domain/library_filter_state.dart';
import '../domain/library_game_row.dart';
import '../domain/library_sort_state.dart';
import '../domain/saved_library_view.dart';
import 'library_table_state.dart';

const defaultCompletedYearViewId = 'default:completed-year';

List<SavedLibraryView> buildDefaultLibraryViews({
  required List<LibraryCatalogItem> platforms,
}) {
  final currentYear = DateTime.now().year;
  return [
    defaultAllGamesView,
    _view(
      id: 'default:pending',
      name: 'Pendientes',
      filter: const LibraryFilterState(statuses: {GameStatus.backlog}),
    ),
    _view(
      id: 'default:completed',
      name: 'Completados',
      filter: const LibraryFilterState(statuses: {GameStatus.completed}),
      sort: const LibrarySortState(
        field: LibrarySortField.completedDate,
        direction: LibrarySortDirection.descending,
      ),
    ),
    _view(
      id: defaultCompletedYearViewId,
      name: 'Filtrar por año',
      filter: LibraryFilterState(
        statuses: const {GameStatus.completed},
        completedDateFrom: DateTime(currentYear),
        completedDateTo: DateTime(currentYear, 12, 31),
      ),
      sort: const LibrarySortState(
        field: LibrarySortField.completedDate,
        direction: LibrarySortDirection.descending,
      ),
    ),
  ];
}

SavedLibraryView _view({
  required String id,
  required String name,
  required LibraryFilterState filter,
  LibrarySortState sort = const LibrarySortState(),
}) {
  return SavedLibraryView(
    id: id,
    name: name,
    filter: filter,
    sort: sort,
    columnConfig: LibraryColumnConfig(),
    isDefault: true,
  );
}
