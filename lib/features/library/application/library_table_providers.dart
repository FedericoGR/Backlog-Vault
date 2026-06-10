import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'library_table_processor.dart';
import 'library_table_state.dart';
import '../domain/library_layout_mode.dart';

final libraryTableStateProvider =
    NotifierProvider<LibraryTableController, LibraryTableState>(
      LibraryTableController.new,
    );

class LibraryTableController extends Notifier<LibraryTableState> {
  @override
  LibraryTableState build() => LibraryTableState.initial();

  void setTableState(LibraryTableState nextState) {
    state = nextState;
  }
}

final libraryTableProcessorProvider = Provider<LibraryTableProcessor>((ref) {
  return const LibraryTableProcessor();
});

final libraryLayoutModeProvider =
    NotifierProvider<LibraryLayoutModeController, LibraryLayoutMode>(
      LibraryLayoutModeController.new,
    );

class LibraryLayoutModeController extends Notifier<LibraryLayoutMode> {
  @override
  LibraryLayoutMode build() => LibraryLayoutMode.table;

  void setMode(LibraryLayoutMode mode) {
    state = mode;
  }
}
