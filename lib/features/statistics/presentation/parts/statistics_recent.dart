part of '../statistics_page.dart';

class _LatestCompletedList extends StatelessWidget {
  const _LatestCompletedList({required this.items});

  final List<LatestCompletedGame> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return BvEmptyState(
        title: context.l10n.statisticsNoCompleted,
        message: context.l10n.statisticsNoCompletedMessage,
        icon: Icons.history_toggle_off_outlined,
      );
    }
    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: BvSpacing.sm),
            child: BvSurface(
              onTap: () => context.go('/games/${item.row.libraryEntryId}'),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.row.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: BvSpacing.xxs),
                        Text(
                          formatVisibleDate(item.completedAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: BvSpacing.sm),
                  Text(
                    item.hoursPlayed == null
                        ? '-'
                        : context.l10n.hoursShort(
                          item.hoursPlayed!.toStringAsFixed(1),
                        ),
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _StatBar extends StatelessWidget {
  const _StatBar({
    required this.label,
    required this.value,
    required this.maxValue,
    this.trailing,
  });

  final String label;
  final int value;
  final int maxValue;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final ratio = maxValue <= 0 ? 0.0 : value / maxValue;
    final compact = MediaQuery.sizeOf(context).width < 560;
    final bar = ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(value: ratio.clamp(0, 1)),
    );

    if (compact) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: BvSpacing.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: BvSpacing.sm),
                Text(
                  trailing == null ? value.toString() : '$value · $trailing',
                ),
              ],
            ),
            const SizedBox(height: BvSpacing.xs),
            bar,
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: BvSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 156,
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          Expanded(child: bar),
          const SizedBox(width: BvSpacing.sm),
          SizedBox(
            width: 92,
            child: Text(
              trailing == null ? value.toString() : '$value · $trailing',
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStatisticsState extends StatelessWidget {
  const _EmptyStatisticsState();

  @override
  Widget build(BuildContext context) {
    return BvEmptyState(
      title: context.l10n.statisticsEmptyTitle,
      message: context.l10n.statisticsEmptyMessage,
      icon: Icons.bar_chart_outlined,
      action: FilledButton.icon(
        onPressed: () => context.go('/'),
        icon: const Icon(Icons.library_books_outlined),
        label: Text(context.l10n.statisticsGoToLibrary),
      ),
    );
  }
}

int _maxInt(Iterable<int> values) {
  var max = 0;
  for (final value in values) {
    if (value > max) max = value;
  }
  return max;
}
