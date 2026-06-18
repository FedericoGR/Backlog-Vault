import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/bv_chip.dart';
import '../../../core/design_system/bv_empty_state.dart';
import '../../../core/design_system/bv_error_state.dart';
import '../../../core/design_system/bv_loading_state.dart';
import '../../../core/design_system/bv_page_scaffold.dart';
import '../../../core/design_system/bv_panel.dart';
import '../../../core/design_system/bv_section.dart';
import '../../../core/design_system/bv_spacing.dart';
import '../../../core/design_system/bv_stat_card.dart';
import '../../../core/design_system/bv_surface.dart';
import '../../../core/design_system/bv_theme_extension.dart';
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

    return BvPageScaffold(
      title: 'Estadísticas',
      actions: [
        TextButton.icon(
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.library_books_outlined),
          label: const Text('Biblioteca'),
        ),
      ],
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
              loading: () => const BvLoadingState(label: 'Cargando progreso'),
              error:
                  (error, stackTrace) => BvErrorState(
                    title: 'No se pudo cargar progreso',
                    message: error.toString(),
                  ),
            ),
        loading: () => const BvLoadingState(label: 'Cargando biblioteca'),
        error:
            (error, stackTrace) => BvErrorState(
              title: 'No se pudo cargar estadísticas',
              message: error.toString(),
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
                  title: 'Biblioteca por estado',
                  subtitle: 'Distribución rápida del backlog actual.',
                  child: _StatusBreakdown(stats: stats),
                ),
                const SizedBox(height: BvSpacing.md),
                _SectionPanel(
                  title: 'Ratings',
                  subtitle:
                      'Cómo se reparte tu valoración personal entre los juegos puntuados.',
                  child: _RatingDistribution(stats: stats),
                ),
                const SizedBox(height: BvSpacing.md),
                _SectionPanel(
                  title: 'Calidad de datos',
                  subtitle: 'Huecos de metadata que todavía conviene revisar.',
                  child: _QualityStats(stats: stats),
                ),
              ],
            );
            final right = Column(
              children: [
                _SectionPanel(
                  title: 'Progreso anual',
                  subtitle:
                      'Playthroughs completados con fecha, más horas registradas por período.',
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
                  title: 'Plataformas más usadas',
                  subtitle: 'Dónde se concentra más actividad jugable.',
                  child: _CategoryBreakdownList(
                    items: stats.platformBreakdown,
                    emptyText: 'No hay plataformas registradas.',
                  ),
                ),
                const SizedBox(height: BvSpacing.md),
                _SectionPanel(
                  title: 'Géneros más usados',
                  subtitle: 'Qué estilos dominan tu biblioteca personal.',
                  child: _CategoryBreakdownList(
                    items: stats.genreBreakdown,
                    emptyText: 'No hay géneros registrados.',
                  ),
                ),
                const SizedBox(height: BvSpacing.md),
                _SectionPanel(
                  title: 'Últimos completados',
                  subtitle: 'Tus cierres más recientes con fecha registrada.',
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
                'Pulso de tu biblioteca',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              BvChip(
                label:
                    '${stats.completedCount} completados · ${_formatHours(stats.totalHours)}',
                selected: true,
              ),
            ],
          ),
          const SizedBox(height: BvSpacing.xs),
          Text(
            'Un vistazo rápido a backlog, progreso y calidad de datos sin salir del mismo catálogo.',
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
    return Wrap(
      spacing: BvSpacing.sm,
      runSpacing: BvSpacing.sm,
      children: [
        _StatCard(label: 'Juegos', value: stats.totalGames.toString()),
        _StatCard(label: 'Backlog', value: stats.backlogCount.toString()),
        _StatCard(label: 'Jugando', value: stats.playingCount.toString()),
        _StatCard(
          label: 'Completados totales',
          value: stats.completedCount.toString(),
        ),
        _StatCard(
          label: 'Horas registradas',
          value: _formatHours(stats.totalHours),
        ),
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
      return const BvEmptyState(
        title: 'Todavía no hay progreso anual',
        message:
            'Cuando completes partidas con fecha, este panel las resume por año y mes.',
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
            trailing: _formatHours(year.hours),
          ),
        if (selected != null) ...[
          const SizedBox(height: BvSpacing.md),
          Text(
            'Meses de ${selected.year}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: BvSpacing.sm),
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
          const BvEmptyState(
            title: 'Todavía no hay puntajes',
            message:
                'Cuando empieces a calificar juegos, esta sección va a mostrar cómo se reparte tu criterio.',
            icon: Icons.star_border_outlined,
          )
        else
          for (var rating = 5; rating >= 1; rating--)
            _StatBar(
              label: '$rating estrella${rating == 1 ? '' : 's'}',
              value: distribution.countByRating[rating] ?? 0,
              maxValue: maxCount,
            ),
        const SizedBox(height: BvSpacing.sm),
        BvSurface(child: Text('Sin puntaje: ${distribution.unratedCount}')),
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
        title: 'Sin datos todavía',
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
      return const BvEmptyState(
        title: 'Todavía no hay completados',
        message:
            'Registrá una fecha de cierre en tus partidas para verlas acá.',
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
                        : _formatHours(item.hoursPlayed!),
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
      title: 'Todavía no hay datos para calcular estadísticas.',
      message:
          'Cuando cargues juegos y partidas, este panel te va a resumir progreso, ratings y calidad de metadata.',
      icon: Icons.bar_chart_outlined,
      action: FilledButton.icon(
        onPressed: () => context.go('/'),
        icon: const Icon(Icons.library_books_outlined),
        label: const Text('Ir a biblioteca'),
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
