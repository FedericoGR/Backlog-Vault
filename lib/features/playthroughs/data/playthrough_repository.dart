import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';

final playthroughRepositoryProvider = Provider<PlaythroughRepository>((ref) {
  return PlaythroughRepository(ref.watch(appDatabaseProvider));
});

/// Read-only access to preserved legacy playthrough history.
class PlaythroughRepository {
  const PlaythroughRepository(this._db);
  final AppDatabase _db;

  Future<List<Playthrough>> history(String entryId) =>
      (_db.select(_db.playthroughs)
            ..where((table) => table.libraryEntryId.equals(entryId))
            ..orderBy([(table) => OrderingTerm.asc(table.id)]))
          .get();
}
