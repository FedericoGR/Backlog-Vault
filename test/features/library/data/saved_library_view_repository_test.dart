import 'package:backlog_vault/core/database/app_database.dart';
import 'package:backlog_vault/features/library/data/saved_library_view_repository.dart';
import 'package:backlog_vault/features/library/domain/game_status.dart';
import 'package:backlog_vault/features/library/domain/library_column_config.dart';
import 'package:backlog_vault/features/library/domain/library_filter_state.dart';
import 'package:backlog_vault/features/library/domain/library_sort_state.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

void main() {
  late AppDatabase db;
  late SavedLibraryViewRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = SavedLibraryViewRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('creates, lists, updates and soft-deletes custom views', () async {
    final id = await repository.create(
      name: 'Mi backlog PC',
      filter: const LibraryFilterState(
        statuses: {GameStatus.backlog},
        platformIds: {'pc'},
      ),
      sort: const LibrarySortState(field: LibrarySortField.title),
      columnConfig: LibraryColumnConfig(
        visibleColumns: const [
          LibraryColumnKey.title,
          LibraryColumnKey.status,
          LibraryColumnKey.platforms,
        ],
      ),
    );

    var views = await repository.watchCustomViews().first;
    expect(views.single.id, id);
    expect(views.single.name, 'Mi backlog PC');
    expect(views.single.filter.statuses, {GameStatus.backlog});
    expect(views.single.sort.field, LibrarySortField.title);
    expect(
      views.single.columnConfig.isVisible(LibraryColumnKey.platforms),
      isTrue,
    );

    await repository.update(views.single.copyWith(name: 'Backlog PC'));

    views = await repository.watchCustomViews().first;
    expect(views.single.name, 'Backlog PC');

    await repository.softDelete(id);

    views = await repository.watchCustomViews().first;
    expect(views, isEmpty);

    final rawRows = await db.select(db.savedViews).get();
    expect(rawRows.single.deletedAt, isNotNull);
  });
}
