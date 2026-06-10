import '../domain/game_status.dart';
import '../domain/library_column_config.dart';
import '../domain/library_filter_state.dart';
import '../domain/library_game_row.dart';
import '../domain/library_sort_state.dart';
import '../domain/saved_library_view.dart';
import 'library_table_state.dart';

List<SavedLibraryView> buildDefaultLibraryViews({
  required List<LibraryCatalogItem> platforms,
}) {
  final pcId = _platformIdByName(platforms, 'PC') ?? '__missing_platform_pc__';
  final switchId =
      _platformIdByName(platforms, 'Nintendo Switch') ??
      '__missing_platform_nintendo_switch__';

  return [
    defaultAllGamesView,
    _view(
      id: 'default:backlog',
      name: 'Backlog',
      filter: const LibraryFilterState(statuses: {GameStatus.backlog}),
    ),
    _view(
      id: 'default:playing',
      name: 'Jugando ahora',
      filter: const LibraryFilterState(statuses: {GameStatus.playing}),
    ),
    _view(
      id: 'default:completed-2026',
      name: 'Completados 2026',
      filter: LibraryFilterState(
        statuses: const {GameStatus.completed},
        completedDateFrom: DateTime(2026),
        completedDateTo: DateTime(2026, 12, 31),
      ),
      sort: const LibrarySortState(
        field: LibrarySortField.completedDate,
        direction: LibrarySortDirection.descending,
      ),
    ),
    _view(
      id: 'default:short-backlog',
      name: 'Pendientes cortos',
      filter: const LibraryFilterState(
        statuses: {GameStatus.backlog},
        maxHours: 15,
      ),
      sort: const LibrarySortState(
        field: LibrarySortField.hours,
        direction: LibrarySortDirection.ascending,
      ),
    ),
    _view(
      id: 'default:long-backlog',
      name: 'Pendientes largos',
      filter: const LibraryFilterState(
        statuses: {GameStatus.backlog},
        minHours: 40,
      ),
      sort: const LibrarySortState(field: LibrarySortField.hours),
    ),
    _view(
      id: 'default:pc',
      name: 'PC',
      filter: LibraryFilterState(platformIds: {pcId}),
    ),
    _view(
      id: 'default:nintendo-switch',
      name: 'Nintendo Switch',
      filter: LibraryFilterState(platformIds: {switchId}),
    ),
    _view(
      id: 'default:missing-rating',
      name: 'Sin puntaje',
      filter: const LibraryFilterState(missingRating: true),
    ),
    _view(
      id: 'default:missing-platform',
      name: 'Sin plataforma',
      filter: const LibraryFilterState(missingPlatform: true),
    ),
    _view(
      id: 'default:missing-genre',
      name: 'Sin género',
      filter: const LibraryFilterState(missingGenre: true),
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

String? _platformIdByName(
  List<LibraryCatalogItem> platforms,
  String expectedName,
) {
  final normalizedExpected = expectedName.trim().toLowerCase();
  for (final platform in platforms) {
    if (platform.name.trim().toLowerCase() == normalizedExpected) {
      return platform.id;
    }
  }
  return null;
}
