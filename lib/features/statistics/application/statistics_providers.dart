import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'library_statistics_calculator.dart';

final libraryStatisticsCalculatorProvider =
    Provider<LibraryStatisticsCalculator>(
      (ref) => const LibraryStatisticsCalculator(),
    );
