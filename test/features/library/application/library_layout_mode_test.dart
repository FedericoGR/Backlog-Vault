import 'package:backlog_vault/features/library/application/library_table_providers.dart';
import 'package:backlog_vault/features/library/domain/library_filter_state.dart';
import 'package:backlog_vault/features/library/domain/library_layout_mode.dart';
import 'package:backlog_vault/features/library/domain/library_sort_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/test.dart';

void main() {
  test('changing layout mode does not alter table filters or sort', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final tableController = container.read(libraryTableStateProvider.notifier);
    final initial = container.read(libraryTableStateProvider);
    tableController.setTableState(
      initial.copyWith(
        filter: const LibraryFilterState(textQuery: 'hades'),
        sort: const LibrarySortState(field: LibrarySortField.rating),
      ),
    );

    container
        .read(libraryLayoutModeProvider.notifier)
        .setMode(LibraryLayoutMode.gallery);

    final tableState = container.read(libraryTableStateProvider);
    expect(
      container.read(libraryLayoutModeProvider),
      LibraryLayoutMode.gallery,
    );
    expect(tableState.filter.textQuery, 'hades');
    expect(tableState.sort.field, LibrarySortField.rating);
  });

  test('list layout mode is available without touching table state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(libraryLayoutModeProvider.notifier)
        .setMode(LibraryLayoutMode.list);

    expect(container.read(libraryLayoutModeProvider), LibraryLayoutMode.list);
    expect(LibraryLayoutMode.list.label, 'Lista');
  });
}
