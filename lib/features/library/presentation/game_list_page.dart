import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/formatting/date_formatters.dart';
import '../../catalogs/data/catalog_repository.dart';
import '../../games/application/library_game_details.dart';
import '../../games/data/game_repository.dart';
import '../domain/game_status.dart';
import '../domain/rating.dart';

class GameListPage extends ConsumerStatefulWidget {
  const GameListPage({super.key});

  @override
  ConsumerState<GameListPage> createState() => _GameListPageState();
}

class _GameListPageState extends ConsumerState<GameListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(catalogRepositoryProvider).seedDefaultsIfEmpty(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final games = ref.watch(libraryGamesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backlog Vault'),
        actions: [
          FilledButton.icon(
            onPressed: () => context.go('/games/new'),
            icon: const Icon(Icons.add),
            label: const Text('Crear juego'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: games.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.library_add_outlined, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Todavía no hay juegos en tu biblioteca.',
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

          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 780) {
                return _GameDataTable(items: items);
              }
              return _GameCardList(items: items);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _ErrorState(message: error.toString()),
      ),
    );
  }
}

class _GameDataTable extends ConsumerWidget {
  const _GameDataTable({required this.items});

  final List<LibraryGameDetails> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Título')),
            DataColumn(label: Text('Estado')),
            DataColumn(label: Text('Plataformas')),
            DataColumn(label: Text('Géneros')),
            DataColumn(label: Text('Puntaje')),
            DataColumn(label: Text('Salida')),
            DataColumn(label: Text('Acciones')),
          ],
          rows: [
            for (final item in items)
              DataRow(
                cells: [
                  DataCell(Text(item.game.title)),
                  DataCell(Text(parseGameStatus(item.entry.status).label)),
                  DataCell(Text(_names(item.platforms.map((p) => p.name)))),
                  DataCell(Text(_names(item.genres.map((g) => g.name)))),
                  DataCell(Text(formatStarRating(item.entry.personalRating))),
                  DataCell(Text(formatVisibleDate(item.game.releaseDate))),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Abrir detalle',
                          onPressed: () => context.go('/games/${item.entry.id}'),
                          icon: const Icon(Icons.open_in_new),
                        ),
                        IconButton(
                          tooltip: 'Editar',
                          onPressed: () =>
                              context.go('/games/${item.entry.id}/edit'),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          tooltip: 'Eliminar',
                          onPressed: () => _confirmDelete(context, ref, item),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _GameCardList extends ConsumerWidget {
  const _GameCardList({required this.items});

  final List<LibraryGameDetails> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          title: Text(item.game.title),
          subtitle: Text(
            [
              parseGameStatus(item.entry.status).label,
              if (item.platforms.isNotEmpty)
                _names(item.platforms.map((platform) => platform.name)),
              if (item.genres.isNotEmpty)
                _names(item.genres.map((genre) => genre.name)),
              formatStarRating(item.entry.personalRating),
            ].join(' · '),
          ),
          onTap: () => context.go('/games/${item.entry.id}'),
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') context.go('/games/${item.entry.id}/edit');
              if (value == 'delete') _confirmDelete(context, ref, item);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Editar')),
              PopupMenuItem(value: 'delete', child: Text('Eliminar')),
            ],
          ),
        );
      },
    );
  }
}

Future<void> _confirmDelete(
  BuildContext context,
  WidgetRef ref,
  LibraryGameDetails item,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Eliminar juego'),
      content: Text('Se ocultará "${item.game.title}" de la biblioteca.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  await ref.read(gameRepositoryProvider).softDelete(item.entry.id);
}

String _names(Iterable<String> values) {
  final list = values.toList();
  if (list.isEmpty) return '-';
  return list.join(', ');
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text('No se pudo cargar la biblioteca.\n$message'),
      ),
    );
  }
}
