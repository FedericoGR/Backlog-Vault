import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/bv_empty_state.dart';
import '../../../core/design_system/bv_error_state.dart';
import '../../../core/design_system/bv_loading_state.dart';

import '../../../core/design_system/bv_section.dart';
import '../../../core/design_system/bv_spacing.dart';

import '../../../l10n/l10n.dart';
import '../../library/application/annual_game_log.dart';
import '../../library/application/library_providers.dart';
import '../../library/domain/library_game_row.dart';

import '../application/statistics_providers.dart';
import '../domain/statistics_models.dart';
import '../../library/presentation/widgets/library_catalog_widgets.dart';

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

    return Scaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.navigationStatistics.toUpperCase(),
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(letterSpacing: 1.6),
                ),
                const SizedBox(height: 12),
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
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                          items: [
                            for (final year in years)
                              DropdownMenuItem(
                                value: year,
                                child: Text('$year'),
                              ),
                          ],
                          onChanged: (year) {
                            if (year != null) {
                              setState(() => _selectedYear = year);
                            }
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
                        () => BvLoadingState(
                          label: l10n.statisticsLibraryLoading,
                        ),
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
          ),
        ),
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
    final colors = Theme.of(context).colorScheme;
    return ListView(
      children: [
        LayoutBuilder(
          builder: (context, box) {
            final columns = MediaQuery.sizeOf(context).width >= 1200 ? 4 : 2;
            final values = [
              ('games', l10n.games, '${stats.totalGames}'),
              ('completed', l10n.statisticsFinished, '${stats.completedCount}'),
              (
                'hours',
                l10n.libraryHours,
                (stats.totalHours == null
                        ? null
                        : NumberFormat(
                          '0.0',
                          l10n.localeName,
                        ).format(stats.totalHours!)) ??
                    l10n.statisticsUnavailable,
              ),
              (
                'rating',
                l10n.statisticsAverageRating,
                (stats.averageRating == null
                        ? null
                        : NumberFormat(
                          '0.0',
                          l10n.localeName,
                        ).format(stats.averageRating!)) ??
                    l10n.statisticsUnavailable,
              ),
            ];
            return Wrap(
              children: [
                for (var i = 0; i < values.length; i++)
                  Container(
                    width: box.maxWidth / columns,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color:
                              i % columns == 0
                                  ? Colors.transparent
                                  : colors.outlineVariant,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          values[i].$2,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          values[i].$3,
                          key: ValueKey('statistics-${values[i].$1}'),
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
        const Divider(),
        const SizedBox(height: 24),
        if (stats.totalGames == 0)
          BvEmptyState(
            title: l10n.statisticsEmptyYear,
            message: l10n.statisticsEmptyYearHint,
            icon: Icons.bar_chart_outlined,
          )
        else ...[
          BvSection(
            title: l10n.statisticsFavorites,
            padding: EdgeInsets.zero,
            child:
                stats.favorites.isEmpty
                    ? Text(l10n.statisticsNoRatedGames)
                    : LayoutBuilder(
                      builder: (context, box) {
                        final width = (box.maxWidth - 64) / 5;
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final row in stats.favorites)
                                Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: SizedBox(
                                    width: width.clamp(136, 200),
                                    child: LibraryCatalogCard(
                                      row: row,
                                      showPersonalDetails: false,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
          const SizedBox(height: 28),
          const Divider(),
          const SizedBox(height: 24),
          BvSection(
            title: l10n.statisticsPlayedPlatforms,
            padding: EdgeInsets.zero,
            child:
                stats.platformBreakdown.isEmpty
                    ? Text(l10n.statisticsNoPlayedPlatforms)
                    : Column(
                      children: [
                        for (final platform in stats.platformBreakdown)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: Text(platform.name)),
                                    const SizedBox(width: 16),
                                    Text('${platform.count}'),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                LinearProgressIndicator(
                                  value: platform.count / stats.totalGames,
                                  minHeight: 4,
                                  color: colors.onSurfaceVariant,
                                  backgroundColor: colors.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}
