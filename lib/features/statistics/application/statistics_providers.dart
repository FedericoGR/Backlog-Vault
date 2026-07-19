import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/statistics_repository.dart';
import '../domain/statistics_models.dart';
import 'library_statistics_calculator.dart';

final statisticsPlaythroughsProvider =
    StreamProvider.autoDispose<List<StatisticsPlaythrough>>((ref) {
      return ref.watch(statisticsRepositoryProvider).watchPlaythroughs();
    });

final libraryStatisticsCalculatorProvider =
    Provider<LibraryStatisticsCalculator>(
      (ref) => const LibraryStatisticsCalculator(),
    );
