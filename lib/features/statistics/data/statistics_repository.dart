import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../playthroughs/domain/playthrough_status.dart';
import '../domain/statistics_models.dart';

final statisticsRepositoryProvider = Provider<StatisticsRepository>((ref) {
  return StatisticsRepository(ref.watch(appDatabaseProvider));
});

final statisticsPlaythroughsProvider =
    StreamProvider.autoDispose<List<StatisticsPlaythrough>>((ref) {
      return ref.watch(statisticsRepositoryProvider).watchPlaythroughs();
    });

class StatisticsRepository {
  const StatisticsRepository(this._db);

  final AppDatabase _db;

  Stream<List<StatisticsPlaythrough>> watchPlaythroughs() {
    return (_db.select(_db.playthroughs)
      ..where((table) => table.deletedAt.isNull())).watch().map(
      (rows) => [
        for (final row in rows)
          StatisticsPlaythrough(
            libraryEntryId: row.libraryEntryId,
            status: parsePlaythroughStatus(row.status),
            completedAt: row.completedAt,
            hoursPlayed: row.hoursPlayed,
          ),
      ],
    );
  }
}
