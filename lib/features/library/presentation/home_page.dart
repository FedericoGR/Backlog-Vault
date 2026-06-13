import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/formatting/date_formatters.dart';
import '../application/library_home_summary.dart';
import '../data/library_query_repository.dart';
import '../domain/game_status.dart';
import '../domain/library_game_row.dart';
import '../domain/rating.dart';
import 'widgets/library_cover_thumbnail.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = ref.watch(libraryRowsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          TextButton.icon(
            onPressed: () => context.go('/statistics'),
            icon: const Icon(Icons.bar_chart_outlined),
            label: const Text('Estadísticas'),
          ),
        ],
      ),
      body: rows.when(
        data: (items) {
          final data = buildLibraryHomeData(items);
          if (items.isEmpty) return const _EmptyHomeState();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _HomeCounters(data: data),
              const SizedBox(height: 16),
              _HomeSection(
                title: 'Jugando ahora',
                rows: data.playingNow,
                emptyText: 'No hay juegos en progreso.',
              ),
              _HomeSection(
                title: 'Backlog',
                rows: data.backlog,
                emptyText: 'No hay pendientes en backlog.',
              ),
              _HomeSection(
                title: 'Completados recientes',
                rows: data.recentlyCompleted,
                emptyText: 'No hay completados con fecha registrada.',
                subtitleFor: (row) => formatVisibleDate(row.completedAt),
              ),
              _HomeSection(
                title: 'Sin portada',
                rows: data.missingCover,
                emptyText: 'Todos los juegos visibles tienen portada.',
              ),
              _HomeSection(
                title: 'Sin metadata',
                rows: data.missingMetadata,
                emptyText: 'Todos los juegos visibles tienen metadata externa.',
              ),
              _HomeSection(
                title: 'Últimos actualizados',
                rows: data.recentlyUpdated,
                emptyText: 'No hay actividad reciente.',
                subtitleFor: (row) => formatVisibleDate(row.updatedAt),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stackTrace) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('No se pudo cargar el inicio.\n$error'),
              ),
            ),
      ),
    );
  }
}

class _HomeCounters extends StatelessWidget {
  const _HomeCounters({required this.data});

  final LibraryHomeData data;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
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
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 132),
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
              Text(
                value.toString(),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeSection extends StatelessWidget {
  const _HomeSection({
    required this.title,
    required this.rows,
    required this.emptyText,
    this.subtitleFor,
  });

  final String title;
  final List<LibraryGameRow> rows;
  final String emptyText;
  final String Function(LibraryGameRow row)? subtitleFor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
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
              TextButton(
                onPressed: () => context.go('/'),
                child: const Text('Ver biblioteca'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (rows.isEmpty)
            Text(emptyText, style: Theme.of(context).textTheme.bodyMedium)
          else
            SizedBox(
              height: 176,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: rows.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder:
                    (context, index) => _HomeGameCard(
                      row: rows[index],
                      subtitle: subtitleFor?.call(rows[index]),
                    ),
              ),
            ),
        ],
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
      width: 132,
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: () => context.go('/games/${row.libraryEntryId}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LibraryCoverThumbnail(
                localPath: row.selectedCoverLocalPath,
                width: 132,
                height: 92,
                borderRadius: 0,
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle ?? row.status.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (row.personalRating != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        formatStarRating(row.personalRating),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyHomeState extends StatelessWidget {
  const _EmptyHomeState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.home_outlined, size: 48),
            const SizedBox(height: 16),
            Text(
              'Tu biblioteca todavía está vacía.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.go('/games/new'),
              icon: const Icon(Icons.add),
              label: const Text('Crear primer juego'),
            ),
          ],
        ),
      ),
    );
  }
}
