part of '../statistics_page.dart';

class _StatusBreakdown extends StatelessWidget {
  const _StatusBreakdown({required this.stats});

  final LibraryStatistics stats;

  @override
  Widget build(BuildContext context) {
    final maxCount = _maxInt(stats.statusCounts.values);
    return Column(
      children: [
        for (final status in GameStatus.values)
          _StatBar(
            label: context.l10n.gameStatusLabel(status),
            value: stats.statusCounts[status] ?? 0,
            maxValue: maxCount,
          ),
      ],
    );
  }
}

class _YearSelector extends StatelessWidget {
  const _YearSelector({
    required this.years,
    required this.selectedYear,
    required this.onChanged,
  });

  final List<int> years;
  final int selectedYear;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final availableYears = years.isEmpty ? [selectedYear] : years;
    return SizedBox(
      width: 128,
      child: DropdownButtonFormField<int>(
        initialValue: selectedYear,
        decoration: InputDecoration(labelText: context.l10n.statisticsYear),
        items: [
          for (final year in availableYears)
            DropdownMenuItem(value: year, child: Text(year.toString())),
        ],
        onChanged:
            years.isEmpty
                ? null
                : (value) {
                  if (value != null) onChanged(value);
                },
      ),
    );
  }
}

class _YearProgress extends StatelessWidget {
  const _YearProgress({required this.stats, required this.selectedYearStats});

  final LibraryStatistics stats;
  final YearlyStatistics? selectedYearStats;

  @override
  Widget build(BuildContext context) {
    final yearlyMax = _maxInt(stats.completedByYear.values);
    final selected = selectedYearStats;
    if (stats.yearlyStatistics.isEmpty) {
      return BvEmptyState(
        title: context.l10n.statisticsNoAnnualProgress,
        message: context.l10n.statisticsNoAnnualProgressMessage,
        icon: Icons.event_note_outlined,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final year in stats.yearlyStatistics)
          _StatBar(
            label: year.year.toString(),
            value: year.completedCount,
            maxValue: yearlyMax,
            trailing: context.l10n.hoursShort(year.hours.toStringAsFixed(1)),
          ),
        if (selected != null) ...[
          const SizedBox(height: BvSpacing.md),
          Text(
            context.l10n.statisticsMonthsOf(selected.year),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: BvSpacing.sm),
          for (final month in selected.monthlyCompletions)
            if (month.completedCount > 0 || month.hours > 0)
              _StatBar(
                label: context.l10n.monthLabel(month.month),
                value: month.completedCount,
                maxValue: _maxInt(
                  selected.monthlyCompletions.map(
                    (item) => item.completedCount,
                  ),
                ),
                trailing: context.l10n.hoursShort(
                  month.hours.toStringAsFixed(1),
                ),
              ),
        ],
      ],
    );
  }
}

class _RatingDistribution extends StatelessWidget {
  const _RatingDistribution({required this.stats});

  final LibraryStatistics stats;

  @override
  Widget build(BuildContext context) {
    final distribution = stats.ratingDistribution;
    final maxCount = _maxInt(distribution.countByRating.values);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (distribution.ratedCount == 0)
          BvEmptyState(
            title: context.l10n.statisticsNoRatings,
            message: context.l10n.statisticsNoRatingsMessage,
            icon: Icons.star_border_outlined,
          )
        else
          for (var rating = 5; rating >= 1; rating--)
            _StatBar(
              label: context.l10n.statisticsStars(rating),
              value: distribution.countByRating[rating] ?? 0,
              maxValue: maxCount,
            ),
        const SizedBox(height: BvSpacing.sm),
        BvSurface(
          child: Text(
            context.l10n.statisticsUnrated(distribution.unratedCount),
          ),
        ),
      ],
    );
  }
}

class _CategoryBreakdownList extends StatelessWidget {
  const _CategoryBreakdownList({required this.items, required this.emptyText});

  final List<CategoryBreakdown> items;
  final String emptyText;
  static const _limit = 8;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return BvEmptyState(
        title: context.l10n.statisticsNoData,
        message: emptyText,
        icon: Icons.category_outlined,
      );
    }
    final visibleItems = items.take(_limit).toList();
    final maxCount = _maxInt(visibleItems.map((item) => item.count));
    return Column(
      children: [
        for (final item in visibleItems)
          _StatBar(
            label: item.name,
            value: item.count,
            maxValue: maxCount,
            trailing: '${(item.percentage * 100).toStringAsFixed(0)}%',
          ),
      ],
    );
  }
}

class _QualityStats extends StatelessWidget {
  const _QualityStats({required this.stats});

  final LibraryStatistics stats;

  @override
  Widget build(BuildContext context) {
    final quality = stats.qualityStats;
    final items = [
      (context.l10n.missingCover, quality.missingCover),
      (context.l10n.missingMetadata, quality.missingMetadata),
      (context.l10n.missingRating, quality.missingRating),
      (context.l10n.missingPlatform, quality.missingPlatform),
      (context.l10n.missingGenre, quality.missingGenre),
      (
        context.l10n.statisticsCompletedWithoutDate,
        quality.completedWithoutDate,
      ),
    ];
    final maxCount = _maxInt(items.map((item) => item.$2));
    return Column(
      children: [
        for (final item in items)
          _StatBar(label: item.$1, value: item.$2, maxValue: maxCount),
      ],
    );
  }
}
