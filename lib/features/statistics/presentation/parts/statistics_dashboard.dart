part of '../statistics_page.dart';

class _StatisticsContent extends StatelessWidget {
  const _StatisticsContent({
    required this.stats,
    required this.selectedYear,
    required this.onYearChanged,
  });

  final LibraryStatistics stats;
  final int selectedYear;
  final ValueChanged<int> onYearChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selectedYearStats = stats.statsForYear(selectedYear);
    return ListView(
      children: [
        _HeroSummary(stats: stats),
        const SizedBox(height: BvSpacing.md),
        _SummaryCards(stats: stats),
        const SizedBox(height: BvSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 1040;
            final left = Column(
              children: [
                _SectionPanel(
                  title: l10n.statisticsLibraryByStatus,
                  subtitle: l10n.statisticsLibraryByStatusSubtitle,
                  child: _StatusBreakdown(stats: stats),
                ),
                const SizedBox(height: BvSpacing.md),
                _SectionPanel(
                  title: l10n.statisticsRatings,
                  subtitle: l10n.statisticsRatingsSubtitle,
                  child: _RatingDistribution(stats: stats),
                ),
                const SizedBox(height: BvSpacing.md),
                _SectionPanel(
                  title: l10n.statisticsDataQuality,
                  subtitle: l10n.statisticsDataQualitySubtitle,
                  child: _QualityStats(stats: stats),
                ),
              ],
            );
            final right = Column(
              children: [
                _SectionPanel(
                  title: l10n.statisticsAnnualProgress,
                  subtitle: l10n.statisticsAnnualProgressSubtitle,
                  trailing: _YearSelector(
                    years: stats.availableYears,
                    selectedYear: selectedYear,
                    onChanged: onYearChanged,
                  ),
                  child: _YearProgress(
                    stats: stats,
                    selectedYearStats: selectedYearStats,
                  ),
                ),
                const SizedBox(height: BvSpacing.md),
                _SectionPanel(
                  title: l10n.statisticsTopPlatforms,
                  subtitle: l10n.statisticsTopPlatformsSubtitle,
                  child: _CategoryBreakdownList(
                    items: stats.platformBreakdown,
                    emptyText: l10n.statisticsNoPlatforms,
                  ),
                ),
                const SizedBox(height: BvSpacing.md),
                _SectionPanel(
                  title: l10n.statisticsTopGenres,
                  subtitle: l10n.statisticsTopGenresSubtitle,
                  child: _CategoryBreakdownList(
                    items: stats.genreBreakdown,
                    emptyText: l10n.statisticsNoGenres,
                  ),
                ),
                const SizedBox(height: BvSpacing.md),
                _SectionPanel(
                  title: l10n.statisticsRecentCompleted,
                  subtitle: l10n.statisticsRecentCompletedSubtitle,
                  child: _LatestCompletedList(items: stats.latestCompleted),
                ),
              ],
            );

            if (stacked) {
              return Column(
                children: [left, const SizedBox(height: BvSpacing.md), right],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: left),
                const SizedBox(width: BvSpacing.md),
                Expanded(child: right),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _HeroSummary extends StatelessWidget {
  const _HeroSummary({required this.stats});

  final LibraryStatistics stats;

  @override
  Widget build(BuildContext context) {
    final bv = BvThemeExtension.of(context);
    final l10n = context.l10n;
    return BvPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: BvSpacing.sm,
            runSpacing: BvSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                l10n.statisticsPulse,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              BvChip(
                label: l10n.statisticsCompletedHours(
                  stats.completedCount,
                  stats.totalHours.toStringAsFixed(1),
                ),
                selected: true,
              ),
            ],
          ),
          const SizedBox(height: BvSpacing.xs),
          Text(
            l10n.statisticsPulseSubtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: bv.textMuted),
          ),
        ],
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.stats});

  final LibraryStatistics stats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: BvSpacing.sm,
      runSpacing: BvSpacing.sm,
      children: [
        _StatCard(label: l10n.games, value: stats.totalGames.toString()),
        _StatCard(label: l10n.backlog, value: stats.backlogCount.toString()),
        _StatCard(
          label: l10n.statisticsTotalCompleted,
          value: stats.completedCount.toString(),
        ),
        _StatCard(
          label: l10n.statisticsLoggedHours,
          value: l10n.hoursShort(stats.totalHours.toStringAsFixed(1)),
        ),
        _StatCard(
          label: l10n.statisticsAverageRating,
          value:
              stats.averageRating == null
                  ? '-'
                  : stats.averageRating!.toStringAsFixed(1),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return BvStatCard(label: label, value: value, minWidth: 148);
  }
}

class _SectionPanel extends StatelessWidget {
  const _SectionPanel({
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return BvPanel(
      child: BvSection(
        title: title,
        subtitle: subtitle,
        padding: EdgeInsets.zero,
        trailing: trailing,
        child: child,
      ),
    );
  }
}
