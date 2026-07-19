import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/library_query_repository.dart';
import '../data/saved_library_view_repository.dart';
import '../domain/library_layout_mode.dart';
import '../domain/saved_library_view.dart';
import 'library_table_processor.dart';
import 'library_table_state.dart';

final libraryViewModelProvider =
    NotifierProvider<LibraryViewModel, LibraryViewState>(LibraryViewModel.new);

final libraryTableProcessorProvider = Provider<LibraryTableProcessor>((ref) {
  return const LibraryTableProcessor();
});

/// Single mutable source for the library query/view configuration.
class LibraryViewModel extends Notifier<LibraryViewState> {
  @override
  LibraryViewState build() => LibraryViewState.initial();

  void setTableState(LibraryTableState nextState) {
    state = state.copyWith(table: nextState);
  }

  void setLayoutMode(LibraryLayoutMode mode) {
    state = state.copyWith(layoutMode: mode);
  }

  Future<String> createView({
    required String name,
    required LibraryTableState table,
  }) {
    return ref
        .read(savedLibraryViewRepositoryProvider)
        .create(
          name: name,
          filter: table.filter,
          sort: table.sort,
          columnConfig: table.columnConfig,
        );
  }

  Future<void> updateView(SavedLibraryView view) =>
      ref.read(savedLibraryViewRepositoryProvider).update(view);

  Future<void> deleteView(String id) =>
      ref.read(savedLibraryViewRepositoryProvider).softDelete(id);

  Future<void> deleteGame(String entryId) =>
      ref.read(libraryQueryRepositoryProvider).softDelete(entryId);

  Future<void> deleteGames(Iterable<String> entryIds) =>
      ref.read(libraryQueryRepositoryProvider).softDeleteMany(entryIds);
}

class LibraryViewState {
  const LibraryViewState({required this.table, required this.layoutMode});

  factory LibraryViewState.initial() => LibraryViewState(
    table: LibraryTableState.initial(),
    layoutMode: LibraryLayoutMode.table,
  );

  final LibraryTableState table;
  final LibraryLayoutMode layoutMode;

  LibraryViewState copyWith({
    LibraryTableState? table,
    LibraryLayoutMode? layoutMode,
  }) {
    return LibraryViewState(
      table: table ?? this.table,
      layoutMode: layoutMode ?? this.layoutMode,
    );
  }
}
