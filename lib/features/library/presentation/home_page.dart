import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/bv_action_card.dart';
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
import '../../../core/formatting/date_formatters.dart';
import '../application/library_home_summary.dart';
import '../data/library_query_repository.dart';
import '../domain/game_status.dart';
import '../domain/library_game_row.dart';
import 'widgets/library_cover_thumbnail.dart';
import 'widgets/rating_stars.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = ref.watch(libraryRowsProvider);

    return BvPageScaffold(
      title: 'Inicio',
      actions: [
        TextButton.icon(
          onPressed: () => context.go('/statistics'),
          icon: const Icon(Icons.bar_chart_outlined),
          label: const Text('Estadísticas'),
        ),
      ],
      body: rows.when(
        data: (items) {
          final data = buildLibraryHomeData(items);
          if (items.isEmpty) return const _EmptyHomeState();
          return ListView(
            children: [
              _HomeHero(data: data),
              const SizedBox(height: BvSpacing.md),
              _HomeCounters(data: data),
              const SizedBox(height: BvSpacing.md),
              _HomeSection(
                title: 'Jugando ahora',
                description: 'Lo más activo de tu biblioteca personal.',
                rows: data.playingNow,
                emptyText: 'No hay juegos en progreso.',
              ),
              const SizedBox(height: BvSpacing.md),
              _HomeSection(
                title: 'Backlog',
                description: 'Pendientes listos para volver a mirar.',
                rows: data.backlog,
                emptyText: 'No hay pendientes en backlog.',
              ),
              const SizedBox(height: BvSpacing.md),
              _HomeSection(
                title: 'Completados recientes',
                description: 'Los últimos cierres con fecha registrada.',
                rows: data.recentlyCompleted,
                emptyText: 'No hay completados con fecha registrada.',
                subtitleFor: (row) => formatVisibleDate(row.completedAt),
              ),
              const SizedBox(height: BvSpacing.md),
              _HomeSection(
                title: 'Sin portada',
                description: 'Entradas que todavía piden una selección visual.',
                rows: data.missingCover,
                emptyText: 'Todos los juegos visibles tienen portada.',
              ),
              const SizedBox(height: BvSpacing.md),
              _HomeSection(
                title: 'Sin metadata',
                description: 'Juegos que conviene enriquecer antes de ordenar.',
                rows: data.missingMetadata,
                emptyText: 'Todos los juegos visibles tienen metadata externa.',
              ),
              const SizedBox(height: BvSpacing.md),
              _HomeSection(
                title: 'Últimos actualizados',
                description:
                    'Movimiento reciente en estados, notas y partidas.',
                rows: data.recentlyUpdated,
                emptyText: 'No hay actividad reciente.',
                subtitleFor: (row) => formatVisibleDate(row.updatedAt),
              ),
            ],
          );
        },
        loading: () => const BvLoadingState(label: 'Cargando inicio'),
        error:
            (error, stackTrace) => BvErrorState(
              title: 'No se pudo cargar el inicio',
              message: error.toString(),
            ),
      ),
    );
  }
}

class _HomeHero extends StatelessWidget {
  const _HomeHero({required this.data});

  final LibraryHomeData data;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        final primary = BvActionCard(
          title: 'Biblioteca',
          subtitle:
              '${data.totalGames} juegos activos, ${data.completedCount} completados y ${data.playingCount} en progreso.',
          icon: Icons.library_books_outlined,
          emphasized: true,
          actions: [
            FilledButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.library_books_outlined),
              label: const Text('Abrir biblioteca'),
            ),
          ],
        );
        final secondary = BvActionCard(
          title: 'Panel rápido',
          subtitle:
              'Saltá a estadísticas o revisá lo que sigue sin portada o metadata.',
          icon: Icons.dashboard_customize_outlined,
          actions: [
            OutlinedButton.icon(
              onPressed: () => context.go('/statistics'),
              icon: const Icon(Icons.bar_chart_outlined),
              label: const Text('Ver estadísticas'),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go('/games/new'),
              icon: const Icon(Icons.add),
              label: const Text('Crear juego'),
            ),
          ],
        );

        if (compact) {
          return Column(
            children: [
              primary,
              const SizedBox(height: BvSpacing.md),
              secondary,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: primary),
            const SizedBox(width: BvSpacing.md),
            Expanded(flex: 2, child: secondary),
          ],
        );
      },
    );
  }
}

class _HomeCounters extends StatelessWidget {
  const _HomeCounters({required this.data});

  final LibraryHomeData data;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: BvSpacing.sm,
      runSpacing: BvSpacing.sm,
      children: [
        _CounterCard(label: 'Juegos', value: data.totalGames),
        _CounterCard(label: 'Backlog', value: data.backlogCount),
        _CounterCard(label: 'Jugando', value: data.playingCount),
        _CounterCard(label: 'Completados', value: data.completedCount),
        _CounterCard(label: 'Sin portada', value: data.missingCoverCount),
      ],
    );
  }
}

class _CounterCard extends StatelessWidget {
  const _CounterCard({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return BvStatCard(label: label, value: value.toString(), minWidth: 136);
  }
}

class _HomeSection extends StatelessWidget {
  const _HomeSection({
    required this.title,
    required this.description,
    required this.rows,
    required this.emptyText,
    this.subtitleFor,
  });

  final String title;
  final String description;
  final List<LibraryGameRow> rows;
  final String emptyText;
  final String Function(LibraryGameRow row)? subtitleFor;

  @override
  Widget build(BuildContext context) {
    return BvPanel(
      child: BvSection(
        title: title,
        subtitle: description,
        padding: EdgeInsets.zero,
        trailing: TextButton(
          onPressed: () => context.go('/'),
          child: const Text('Ver biblioteca'),
        ),
        child:
            rows.isEmpty
                ? BvEmptyState(
                  title: title,
                  message: emptyText,
                  icon: Icons.inbox_outlined,
                )
                : SizedBox(
                  height: 280,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: rows.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(width: BvSpacing.sm),
                    itemBuilder:
                        (context, index) => _HomeGameCard(
                          row: rows[index],
                          subtitle: subtitleFor?.call(rows[index]),
                        ),
                  ),
                ),
      ),
    );
  }
}

class _HomeGameCard extends StatelessWidget {
  const _HomeGameCard({required this.row, this.subtitle});

  final LibraryGameRow row;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 176,
      child: BvSurface(
        padding: EdgeInsets.zero,
        onTap: () => context.go('/games/${row.libraryEntryId}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LibraryCoverThumbnail(
              localPath: row.selectedCoverLocalPath,
              width: 176,
              height: 122,
              borderRadius: 0,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(BvSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: BvSpacing.xs),
                    Wrap(
                      spacing: BvSpacing.xs,
                      runSpacing: BvSpacing.xs,
                      children: [
                        BvChip(label: row.status.label, selected: true),
                        if (row.personalRating != null)
                          BvSurface(
                            padding: const EdgeInsets.symmetric(
                              horizontal: BvSpacing.xs,
                              vertical: BvSpacing.xxs,
                            ),
                            child: RatingStars(rating: row.personalRating),
                          ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      subtitle ??
                          [
                            if (row.platforms.isNotEmpty)
                              row.platforms.first.name,
                            if (row.hoursPlayed != null)
                              '${row.hoursPlayed!.toStringAsFixed(1)} h',
                          ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHomeState extends StatelessWidget {
  const _EmptyHomeState();

  @override
  Widget build(BuildContext context) {
    return BvEmptyState(
      title: 'Tu biblioteca todavía está vacía.',
      message:
          'Cuando cargues tus primeros juegos, este panel te va a mostrar actividad, pendientes y calidad de datos.',
      icon: Icons.home_outlined,
      action: FilledButton.icon(
        onPressed: () => context.go('/games/new'),
        icon: const Icon(Icons.add),
        label: const Text('Crear primer juego'),
      ),
    );
  }
}
