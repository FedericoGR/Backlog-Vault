import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/library_query_repository.dart';
import '../domain/library_game_row.dart';

final libraryRowsProvider = StreamProvider.autoDispose<List<LibraryGameRow>>((
  ref,
) {
  return ref.watch(libraryQueryRepositoryProvider).watchRows();
});
