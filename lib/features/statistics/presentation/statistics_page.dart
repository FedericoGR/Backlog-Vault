import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/formatting/date_formatters.dart';
import '../../library/data/library_query_repository.dart';
import '../../library/domain/game_status.dart';
import '../application/statistics_providers.dart';
import '../data/statistics_repository.dart';
import '../domain/statistics_models.dart';

class StatisticsPage extends ConsumerStatefulWidget {
  const StatisticsPage({super.key});

  @override
  ConsumerState<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends ConsumerState<StatisticsPage> {
  int? _selectedYear;

  @override
  Widget build(BuildContext context) {
    final rows = ref.watch(libraryRowsProvider);
    final playthroughs = ref.watch(statisticsPlaythroughsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: rows.when(
        data:
            (items) => playthroughs.when(
              data: (playthroughItems) {
                final stats = ref
                    .watch(libraryStatisticsCalculatorProvider)
                    .calculate(rows: items, playthroughs: playthroughItems);
                if (items.isEmpty) return const _EmptyStatisticsState();
                final selectedYear = _resolveSelectedYear(stats);
                return _StatisticsContent(
                  stats: stats,
                  selectedYear: selectedYear,
                  onYearChanged: (year) => setState(() => _selectedYear = year),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stackTrace) => _ErrorState(
                    message: 'No se pudo cargar progreso.\n$error',
                  ),
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stackTrace) =>
                _ErrorState(message: 'No se pudo cargar biblioteca.\n$error'),
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
    final selectedYearStats = stats.statsForYear(selectedYear);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _SummaryCards(stats: stats),
        const SizedBox(height: 16),
        _Section(
          title: 'Biblioteca por estado',
          child: _StatusBreakdown(stats: stats),
        ),
        _Section(
          title: 'Progreso anual',
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
        _Section(title: 'Ratings', child: _RatingDistribution(stats: stats)),
        _Section(
          title: 'Plataformas más usadas',
          child: _CategoryBreakdownList(
            items: stats.platformBreakdown,
            emptyText: 'No hay plataformas registradas.',
          ),
        ),
        _Section(
          title: 'Géneros más usados',
          child: _CategoryBreakdownList(
            items: stats.genreBreakdown,
            emptyText: 'No hay géneros registrados.',
          ),
        ),
        _Section(title: 'Calidad de datos', child: _QualityStats(stats: stats)),
        _Section(
          title: 'Últimos completados',
          child: _LatestCompletedList(items: stats.latestCompleted),
        ),
      ],
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.stats});

  final LibraryStatistics stats;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _StatCard(label: 'Juegos', value: stats.totalGames.toString()),
        _StatCard(label: 'Backlog', value: stats.backlogCount.toString()),
        _StatCard(label: 'Jugando', value: stats.playingCount.toString()),
        _StatCard(label: 'Completados', value: stats.completedCount.toString()),
        _StatCard(label: 'Horas', value: _formatHours(stats.totalHours)),
        _StatCard(
          label: 'Rating promedio',
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
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 142),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 4),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

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
            label: status.label,
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
        decoration: const InputDecoration(labelText: 'Año'),
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
      return const Text('Todavía no hay playthroughs completados con fecha.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final year in stats.yearlyStatistics)
          _StatBar(
            label: year.year.toString(),
            value: year.completedCount,
            maxValue: yearlyMax,
            trailing: _formatHours(year.hours),
          ),
        if (selected != null) ...[
          const SizedBox(height: 16),
          Text(
            'Meses de ${selected.year}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          for (final month in selected.monthlyCompletions)
            if (month.completedCount > 0 || month.hours > 0)
              _StatBar(
                label: _monthLabel(month.month),
                value: month.completedCount,
                maxValue: _maxInt(
                  selected.monthlyCompletions.map(
                    (item) => item.completedCount,
                  ),
                ),
                trailing: _formatHours(month.hours),
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
          const Text('Todavía no hay puntajes personales registrados.')
        else
          for (var rating = 5; rating >= 1; rating--)
            _StatBar(
              label: '$rating estrella${rating == 1 ? '' : 's'}',
              value: distribution.countByRating[rating] ?? 0,
              maxValue: maxCount,
            ),
        const SizedBox(height: 8),
        Text('Sin puntaje: ${distribution.unratedCount}'),
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
    if (items.isEmpty) return Text(emptyText);
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
      ('Sin portada', quality.missingCover),
      ('Sin metadata', quality.missingMetadata),
      ('Sin puntaje', quality.missingRating),
      ('Sin plataforma', quality.missingPlatform),
      ('Sin género', quality.missingGenre),
      ('Completados sin fecha', quality.completedWithoutDate),
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

class _LatestCompletedList extends StatelessWidget {
  const _LatestCompletedList({required this.items});

  final List<LatestCompletedGame> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Text('Todavía no hay completados con fecha registrada.');
    }
    return Column(
      children: [
        for (final item in items)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(item.row.title),
            subtitle: Text(formatVisibleDate(item.completedAt)),
            trailing: Text(
              item.hoursPlayed == null ? '-' : _formatHours(item.hoursPlayed!),
            ),
            onTap: () => context.go('/games/${item.row.libraryEntryId}'),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(value: ratio.clamp(0, 1)),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 88,
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
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bar_chart_outlined, size: 48),
            const SizedBox(height: 16),
            Text(
              'Todavía no hay datos para calcular estadísticas.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.library_books_outlined),
              label: const Text('Ir a biblioteca'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(padding: const EdgeInsets.all(24), child: Text(message)),
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

String _formatHours(double value) => '${value.toStringAsFixed(1)} h';

String _monthLabel(int month) {
  const labels = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];
  if (month < 1 || month > 12) return month.toString();
  return labels[month - 1];
}
