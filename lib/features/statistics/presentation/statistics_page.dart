import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
import '../../../l10n/l10n.dart';
import '../../library/application/annual_game_log.dart';
import '../../library/application/library_providers.dart';
import '../../library/domain/library_game_row.dart';
import '../../library/domain/rating.dart';
import '../application/statistics_providers.dart';
import '../domain/statistics_models.dart';

/// Read-only annual statistics from each game's personal record.
class StatisticsPage extends ConsumerStatefulWidget {
  const StatisticsPage({super.key});

  @override
  ConsumerState<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends ConsumerState<StatisticsPage> {
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    _selectedYear = ref.read(annualLogClockProvider).now().year;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final rows = ref.watch(libraryRowsProvider);
    final currentYear = ref.watch(annualLogClockProvider).now().year;
    final years =
        {
            currentYear,
            _selectedYear,
            for (final row in rows.asData?.value ?? <LibraryGameRow>[])
              if (row.playedYear != null) row.playedYear!,
          }.toList()
          ..sort((a, b) => b.compareTo(a));

    return BvPageScaffold(
      title: l10n.navigationStatistics,
      maxContentWidth: BvLayout.wideContentWidth,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                key: const ValueKey('statistics-previous-year'),
                tooltip: l10n.logPreviousYear,
                onPressed:
                    _selectedYear <= 1
                        ? null
                        : () => setState(() => _selectedYear--),
                icon: const Icon(Icons.chevron_left),
              ),
              SizedBox(
                width: 132,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    key: const ValueKey('statistics-year'),
                    value: _selectedYear,
                    isExpanded: true,
                    style: Theme.of(context).textTheme.titleLarge,
                    items: [
                      for (final year in years)
                        DropdownMenuItem(value: year, child: Text('$year')),
                    ],
                    onChanged: (year) {
                      if (year != null) setState(() => _selectedYear = year);
                    },
                  ),
                ),
              ),
              IconButton(
                key: const ValueKey('statistics-next-year'),
                tooltip: l10n.logNextYear,
                onPressed:
                    _selectedYear >= 9999
                        ? null
                        : () => setState(() => _selectedYear++),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: BvSpacing.md),
          Expanded(
            child: rows.when(
              data:
                  (items) => _AnnualStatistics(
                    stats: ref
                        .watch(libraryStatisticsCalculatorProvider)
                        .calculate(rows: items, year: _selectedYear),
                  ),
              loading:
                  () => BvLoadingState(label: l10n.statisticsLibraryLoading),
              error:
                  (_, _) => BvErrorState(
                    title: l10n.statisticsLoadError,
                    message: l10n.unexpectedErrorMessage,
                    retryLabel: l10n.retry,
                    onRetry: () => ref.invalidate(libraryRowsProvider),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnnualStatistics extends StatelessWidget {
  const _AnnualStatistics({required this.stats});
  final LibraryStatistics stats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      children: [
        Wrap(
          spacing: BvSpacing.sm,
          runSpacing: BvSpacing.sm,
          children: [
            BvStatCard(
              key: const ValueKey('statistics-games'),
              label: l10n.games,
              value: '${stats.totalGames}',
              minWidth: 148,
            ),
            BvStatCard(
              key: const ValueKey('statistics-completed'),
              label: l10n.statisticsFinished,
              value: '${stats.completedCount}',
              minWidth: 148,
            ),
            BvStatCard(
              key: const ValueKey('statistics-hours'),
              label: l10n.libraryHours,
              value:
                  stats.totalHours?.toStringAsFixed(1) ??
                  l10n.statisticsUnavailable,
              minWidth: 148,
            ),
            BvStatCard(
              key: const ValueKey('statistics-rating'),
              label: l10n.statisticsAverageRating,
              value:
                  stats.averageRating?.toStringAsFixed(1) ??
                  l10n.statisticsUnavailable,
              minWidth: 148,
            ),
          ],
        ),
        const SizedBox(height: BvSpacing.md),
        if (stats.totalGames == 0)
          BvEmptyState(
            title: l10n.statisticsEmptyYear,
            message: l10n.statisticsEmptyYearHint,
            icon: Icons.bar_chart_outlined,
          )
        else ...[
          BvPanel(
            child: BvSection(
              title: l10n.statisticsFavorites,
              padding: EdgeInsets.zero,
              child:
                  stats.favorites.isEmpty
                      ? Text(l10n.statisticsNoRatedGames)
                      : Column(
                        children: [
                          for (final row in stats.favorites)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: BvSpacing.sm,
                              ),
                              child: BvSurface(
                                onTap:
                                    () => context.go(
                                      '/games/${row.libraryEntryId}',
                                    ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        row.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: BvSpacing.sm),
                                    Text(formatStarRating(row.personalRating)),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
            ),
          ),
          const SizedBox(height: BvSpacing.md),
          BvPanel(
            child: BvSection(
              title: l10n.statisticsPlayedPlatforms,
              subtitle: l10n.statisticsPlayedPlatformsHint,
              padding: EdgeInsets.zero,
              child:
                  stats.platformBreakdown.isEmpty
                      ? Text(l10n.statisticsNoPlayedPlatforms)
                      : Column(
                        children: [
                          for (final platform in stats.platformBreakdown)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: BvSpacing.xs,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.sports_esports_outlined,
                                    size: 18,
                                  ),
                                  const SizedBox(width: BvSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      platform.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: BvSpacing.sm),
                                  Text('${platform.count}'),
                                ],
                              ),
                            ),
                        ],
                      ),
            ),
          ),
        ],
        const SizedBox(height: BvSpacing.lg),
      ],
    );
  }
}
