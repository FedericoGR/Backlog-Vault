import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/library_query_repository.dart';
import '../data/saved_library_view_repository.dart';
import '../domain/library_game_row.dart';
import '../domain/saved_library_view.dart';

final libraryRowsProvider = StreamProvider.autoDispose<List<LibraryGameRow>>((
  ref,
) {
  return ref.watch(libraryQueryRepositoryProvider).watchRows();
});

final customLibraryViewsProvider =
    StreamProvider.autoDispose<List<SavedLibraryView>>((ref) {
      return ref.watch(savedLibraryViewRepositoryProvider).watchCustomViews();
    });
