import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Games,
    LibraryEntries,
    Platforms,
    LibraryEntryPlatforms,
    Genres,
    GameGenres,
    Playthroughs,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) => migrator.createAll(),
      );
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'backlog_vault');
}
