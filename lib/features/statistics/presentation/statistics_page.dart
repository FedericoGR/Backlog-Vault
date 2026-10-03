import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/bv_chip.dart';
import '../../../core/design_system/bv_empty_state.dart';
import '../../../core/design_system/bv_error_state.dart';
import '../../../core/design_system/bv_loading_state.dart';
import '../../../core/design_system/bv_layout.dart';
import '../../../core/design_system/bv_page_scaffold.dart';
import '../../../core/design_system/bv_panel.dart';
import '../../../core/design_system/bv_section.dart';
import '../../../core/design_system/bv_spacing.dart';
import '../../../core/design_system/bv_stat_card.dart';
import '../../../core/design_system/bv_surface.dart';
import '../../../core/design_system/bv_theme_extension.dart';
import '../../../core/formatting/date_formatters.dart';
import '../../../l10n/domain_localizations.dart';
import '../../../l10n/l10n.dart';
import '../../library/application/library_providers.dart';
import '../../library/domain/game_status.dart';
import '../application/statistics_providers.dart';
import '../domain/statistics_models.dart';

part 'parts/statistics_dashboard.dart';
part 'parts/statistics_breakdowns.dart';
part 'parts/statistics_recent.dart';

/// Displays responsive, read-only statistics for the local library.
class StatisticsPage extends ConsumerStatefulWidget {
  const StatisticsPage({super.key});

  @override
  ConsumerState<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends ConsumerState<StatisticsPage> {
  int? _selectedYear;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final rows = ref.watch(libraryRowsProvider);

    return BvPageScaffold(
      title: l10n.navigationStatistics,
      maxContentWidth: BvLayout.wideContentWidth,
      actions: [
        TextButton.icon(
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.library_books_outlined),
          label: Text(l10n.navigationLibrary),
        ),
      ],
      body: rows.when(
        data: (items) {
          final stats = ref
              .watch(libraryStatisticsCalculatorProvider)
              .calculate(rows: items);
          if (items.isEmpty) return const _EmptyStatisticsState();
          return _StatisticsContent(
            stats: stats,
            selectedYear: _resolveSelectedYear(stats),
            onYearChanged: (year) => setState(() => _selectedYear = year),
          );
        },
        loading: () => BvLoadingState(label: l10n.statisticsLibraryLoading),
        error:
            (error, stackTrace) => BvErrorState(
              title: l10n.statisticsLoadError,
              message: l10n.unexpectedErrorMessage,
              retryLabel: l10n.retry,
              onRetry: () => ref.invalidate(libraryRowsProvider),
            ),
      ),
    );
  }

  int _resolveSelectedYear(LibraryStatistics stats) {
    final years = stats.availableYears;
    if (years.isEmpty) return _selectedYear ?? DateTime.now().year;
    if (_selectedYear != null && years.contains(_selectedYear)) {
      return _selectedYear!;
    }
    return years.first;
  }
}
