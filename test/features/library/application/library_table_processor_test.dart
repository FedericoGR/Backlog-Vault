import 'package:backlog_vault/features/library/application/library_default_views.dart';
import 'package:backlog_vault/features/library/application/library_table_processor.dart';
import 'package:backlog_vault/features/library/domain/game_status.dart';
import 'package:backlog_vault/features/library/domain/library_column_config.dart';
import 'package:backlog_vault/features/library/domain/library_filter_state.dart';
import 'package:backlog_vault/features/library/domain/library_game_row.dart';
import 'package:backlog_vault/features/library/domain/library_sort_state.dart';
import 'package:test/test.dart';

void main() {
  const processor = LibraryTableProcessor();

  test('filters by text across title, platform, genre and notes', () {
    final result = processor.apply(
      rows: _rows,
      filter: const LibraryFilterState(textQuery: 'steam deck'),
      sort: const LibrarySortState(),
    );

    expect(result.rows.map((row) => row.title), ['Hades']);
  });

  test('filters by status, platform, genre, rating, dates and hours', () {
    final result = processor.apply(
      rows: _rows,
      filter: LibraryFilterState(
        statuses: const {GameStatus.completed},
        platformIds: const {'pc'},
        genreIds: const {'roguelite'},
        minRating: 4,
        releaseDateFrom: DateTime(2020),
        releaseDateTo: DateTime(2020, 12, 31),
        completedDateFrom: DateTime(2026),
        completedDateTo: DateTime(2026, 12, 31),
        minHours: 30,
        maxHours: 50,
        type: 'game',
      ),
      sort: const LibrarySortState(),
    );

    expect(result.rows.single.title, 'Hades');
  });

  test('filters missing values', () {
    final result = processor.apply(
      rows: _rows,
      filter: const LibraryFilterState(
        missingRating: true,
        missingPlatform: true,
        missingGenre: true,
        missingCompletedDate: true,
      ),
      sort: const LibrarySortState(),
    );

    expect(result.rows.single.title, 'Celeste');
  });

  test('combines filters with AND between groups and OR inside groups', () {
    final result = processor.apply(
      rows: _rows,
      filter: const LibraryFilterState(
        statuses: {GameStatus.backlog, GameStatus.playing},
        platformIds: {'switch', 'pc'},
      ),
      sort: const LibrarySortState(field: LibrarySortField.title),
    );

    expect(result.rows.map((row) => row.title), ['Baldur\'s Gate 3']);
  });

  test('sorts by title, rating, dates, hours and updatedAt', () {
    expect(
      processor
          .apply(
            rows: _rows,
            filter: const LibraryFilterState(),
            sort: const LibrarySortState(
              field: LibrarySortField.title,
              direction: LibrarySortDirection.ascending,
            ),
          )
          .rows
          .map((row) => row.title),
      ['Baldur\'s Gate 3', 'Celeste', 'Hades'],
    );

    expect(
      processor
          .apply(
            rows: _rows,
            filter: const LibraryFilterState(),
            sort: const LibrarySortState(
              field: LibrarySortField.rating,
              direction: LibrarySortDirection.descending,
            ),
          )
          .rows
          .first
          .title,
      'Hades',
    );

    expect(
      processor
          .apply(
            rows: _rows,
            filter: const LibraryFilterState(),
            sort: const LibrarySortState(
              field: LibrarySortField.releaseDate,
              direction: LibrarySortDirection.ascending,
            ),
          )
          .rows
          .first
          .title,
      'Hades',
    );

    expect(
      processor
          .apply(
            rows: _rows,
            filter: const LibraryFilterState(),
            sort: const LibrarySortState(
              field: LibrarySortField.hours,
              direction: LibrarySortDirection.ascending,
            ),
          )
          .rows
          .first
          .title,
      'Hades',
    );

    expect(
      processor
          .apply(
            rows: _rows,
            filter: const LibraryFilterState(),
            sort: const LibrarySortState(field: LibrarySortField.updatedAt),
          )
          .rows
          .first
          .title,
      'Hades',
    );
  });

  test('builds visible totals summary', () {
    final result = processor.apply(
      rows: _rows,
      filter: const LibraryFilterState(),
      sort: const LibrarySortState(),
    );

    expect(result.summary.visibleGames, 3);
    expect(result.summary.totalHours, 160);
    expect(result.summary.averageRating, 4.5);
    expect(result.summary.completedCount, 1);
    expect(result.summary.missingRating, 1);
    expect(result.summary.missingPlatform, 1);
    expect(result.summary.missingGenre, 1);
  });

  test('serializes and deserializes filters, sort and columns', () {
    final filter = LibraryFilterState(
      textQuery: 'hades',
      statuses: const {GameStatus.completed},
      platformIds: const {'pc'},
      genreIds: const {'roguelite'},
      minRating: 4,
      maxRating: 5,
      releaseDateFrom: DateTime(2020),
      completedDateTo: DateTime(2026, 12, 31),
      minHours: 10,
      maxHours: 50,
      type: 'game',
      hasRating: true,
    );
    final filterRoundTrip = LibraryFilterState.fromJson(filter.toJson());

    expect(filterRoundTrip.textQuery, filter.textQuery);
    expect(filterRoundTrip.statuses, filter.statuses);
    expect(filterRoundTrip.platformIds, filter.platformIds);
    expect(filterRoundTrip.genreIds, filter.genreIds);
    expect(filterRoundTrip.completedDateTo, filter.completedDateTo);
    expect(filterRoundTrip.hasRating, isTrue);

    const sort = LibrarySortState(
      field: LibrarySortField.hours,
      direction: LibrarySortDirection.ascending,
    );
    expect(LibrarySortState.fromJson(sort.toJson()).field, sort.field);
    expect(LibrarySortState.fromJson(sort.toJson()).direction, sort.direction);

    final columns = LibraryColumnConfig(
      visibleColumns: const [LibraryColumnKey.status, LibraryColumnKey.hours],
    );
    final columnsRoundTrip = LibraryColumnConfig.fromJson(columns.toJson());

    expect(columnsRoundTrip.visibleColumns.first, LibraryColumnKey.title);
    expect(columnsRoundTrip.isVisible(LibraryColumnKey.hours), isTrue);
    expect(columnsRoundTrip.isVisible(LibraryColumnKey.genres), isFalse);
  });

  test('generates default views in memory without persisting ids', () {
    final views = buildDefaultLibraryViews(
      platforms: const [
        LibraryCatalogItem(id: 'pc', name: 'PC'),
        LibraryCatalogItem(id: 'switch', name: 'Nintendo Switch'),
      ],
    );

    expect(views.map((view) => view.name), contains('Todos los juegos'));
    expect(views.map((view) => view.name), contains('Completados 2026'));
    expect(views.singleWhere((view) => view.name == 'PC').filter.platformIds, {
      'pc',
    });
  });

  test(
    'default platform views stay safely empty when catalogs are missing',
    () {
      final views = buildDefaultLibraryViews(platforms: const []);
      final pcView = views.singleWhere((view) => view.name == 'PC');
      final switchView = views.singleWhere(
        (view) => view.name == 'Nintendo Switch',
      );

      expect(
        processor
            .apply(rows: _rows, filter: pcView.filter, sort: pcView.sort)
            .rows,
        isEmpty,
      );
      expect(
        processor
            .apply(
              rows: _rows,
              filter: switchView.filter,
              sort: switchView.sort,
            )
            .rows,
        isEmpty,
      );
    },
  );
}

final _rows = [
  LibraryGameRow(
    gameId: 'g1',
    libraryEntryId: 'e1',
    title: 'Hades',
    sortTitle: 'hades',
    status: GameStatus.completed,
    releaseDate: DateTime(2020, 9, 17),
    completedAt: DateTime(2026, 1, 2),
    hoursPlayed: 40,
    personalRating: 5,
    personalNotes: 'Perfecto para Steam Deck.',
    type: 'game',
    platforms: const [
      LibraryCatalogItem(id: 'pc', name: 'PC'),
      LibraryCatalogItem(id: 'switch', name: 'Nintendo Switch'),
    ],
    genres: const [LibraryCatalogItem(id: 'roguelite', name: 'Roguelite')],
    playthroughCount: 1,
    updatedAt: DateTime(2026, 6, 9),
  ),
  LibraryGameRow(
    gameId: 'g2',
    libraryEntryId: 'e2',
    title: 'Baldur\'s Gate 3',
    sortTitle: 'baldurs gate 3',
    status: GameStatus.playing,
    releaseDate: DateTime(2023, 8, 3),
    hoursPlayed: 120,
    personalRating: 4,
    type: 'game',
    platforms: const [LibraryCatalogItem(id: 'pc', name: 'PC')],
    genres: const [LibraryCatalogItem(id: 'rpg', name: 'RPG')],
    playthroughCount: 1,
    updatedAt: DateTime(2026, 5, 1),
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
    updatedAt: DateTime(2026, 1, 1),
  ),
];
