import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/formatting/date_formatters.dart';
import '../../library/domain/game_status.dart';
import '../../library/domain/rating.dart';
import '../../playthroughs/application/completion_form_model.dart';
import '../../playthroughs/application/playthrough_form_model.dart';
import '../../playthroughs/domain/playthrough_status.dart';
import '../application/library_game_details.dart';
import '../data/game_repository.dart';

class GameDetailPage extends ConsumerWidget {
  const GameDetailPage({required this.entryId, super.key});

  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(libraryGameProvider(entryId));

    return detail.when(
      data: (item) {
        if (item == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Juego no encontrado')),
            body: const Center(child: Text('No se encontró el juego.')),
          );
        }

        final status = parseGameStatus(item.entry.status);
        return Scaffold(
          appBar: AppBar(
            title: Text(item.game.title),
            actions: [
              IconButton(
                tooltip: 'Editar',
                onPressed: () => context.go('/games/${item.entry.id}/edit'),
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Eliminar',
                onPressed: () => _confirmDelete(context, ref, item),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showPlaythroughDialog(context, ref, item),
            icon: const Icon(Icons.add),
            label: const Text('Partida'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(label: Text(status.label)),
                  Chip(label: Text('Puntaje ${formatStarRating(item.entry.personalRating)}')),
                  if (item.game.releaseDate != null)
                    Chip(label: Text('Salida ${formatVisibleDate(item.game.releaseDate)}')),
                ],
              ),
              const SizedBox(height: 24),
              _Section(
                title: 'Plataformas',
                child: Text(_names(item.platforms.map((platform) => platform.name))),
              ),
              _Section(
                title: 'Géneros',
                child: Text(_names(item.genres.map((genre) => genre.name))),
              ),
              _Section(
                title: 'Notas personales',
                child: Text(item.entry.personalNotes?.trim().isEmpty ?? true
                    ? '-'
                    : item.entry.personalNotes!),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: status == GameStatus.completed ||
                            !canTransitionGameStatus(
                              status,
                              GameStatus.completed,
                            )
                        ? null
                        : () => _showCompletionDialog(context, ref, item),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Marcar completado'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Playthroughs', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (item.playthroughs.isEmpty)
                const Text('No hay partidas registradas.')
              else
                for (final playthrough in item.playthroughs)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.sports_esports_outlined),
                    title: Text(parsePlaythroughStatus(playthrough.status).label),
                    subtitle: Text(
                      [
                        if (playthrough.startedAt != null)
                          'Inicio ${formatVisibleDate(playthrough.startedAt)}',
                        if (playthrough.completedAt != null)
                          'Fin ${formatVisibleDate(playthrough.completedAt)}',
                        if (playthrough.hoursPlayed != null)
                          '${playthrough.hoursPlayed!.toStringAsFixed(1)} h',
                        if (playthrough.rating != null)
                          '${playthrough.rating}/5',
                      ].join(' · '),
                    ),
                  ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text(error.toString())),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}

Future<void> _showCompletionDialog(
  BuildContext context,
  WidgetRef ref,
  LibraryGameDetails item,
) async {
  final result = await showDialog<CompletionFormModel>(
    context: context,
    builder: (context) => _CompletionDialog(item: item),
  );
  if (result == null || !context.mounted) return;
  try {
    await ref.read(gameRepositoryProvider).completeGame(result);
  } catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.toString())),
    );
  }
}

Future<void> _showPlaythroughDialog(
  BuildContext context,
  WidgetRef ref,
  LibraryGameDetails item,
) async {
  final result = await showDialog<PlaythroughFormModel>(
    context: context,
    builder: (context) => _PlaythroughDialog(item: item),
  );
  if (result == null || !context.mounted) return;
  try {
    await ref.read(gameRepositoryProvider).registerPlaythrough(result);
  } catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.toString())),
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
  if (context.mounted) context.go('/');
}

class _CompletionDialog extends StatefulWidget {
  const _CompletionDialog({required this.item});

  final LibraryGameDetails item;

  @override
  State<_CompletionDialog> createState() => _CompletionDialogState();
}

class _CompletionDialogState extends State<_CompletionDialog> {
  DateTime _completedAt = DateTime.now();
  String? _platformId;
  int? _rating;
  final _hoursController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _platformId = widget.item.platforms.isEmpty ? null : widget.item.platforms.first.id;
    _rating = widget.item.entry.personalRating;
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Marcar como completado'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Fecha de completado'),
              subtitle: Text(formatVisibleDate(_completedAt)),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _completedAt,
                  firstDate: DateTime(1970),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => _completedAt = picked);
              },
            ),
            TextField(
              controller: _hoursController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Horas jugadas'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int?>(
              initialValue: _rating,
              decoration: const InputDecoration(labelText: 'Puntaje'),
              items: const [
                DropdownMenuItem(value: null, child: Text('Sin puntaje')),
                DropdownMenuItem(value: 1, child: Text('1 estrella')),
                DropdownMenuItem(value: 2, child: Text('2 estrellas')),
                DropdownMenuItem(value: 3, child: Text('3 estrellas')),
                DropdownMenuItem(value: 4, child: Text('4 estrellas')),
                DropdownMenuItem(value: 5, child: Text('5 estrellas')),
              ],
              onChanged: (value) => setState(() => _rating = value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _platformId,
              decoration: const InputDecoration(labelText: 'Plataforma'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Sin plataforma')),
                for (final platform in widget.item.platforms)
                  DropdownMenuItem(value: platform.id, child: Text(platform.name)),
              ],
              onChanged: (value) => setState(() => _platformId = value),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Nota'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            CompletionFormModel(
              libraryEntryId: widget.item.entry.id,
              completedAt: _completedAt,
              platformId: _platformId,
              hoursPlayed: double.tryParse(
                _hoursController.text.trim().replaceAll(',', '.'),
              ),
              rating: _rating,
              notes: _notesController.text,
            ),
          ),
          child: const Text('Completar'),
        ),
      ],
    );
  }
}

class _PlaythroughDialog extends StatefulWidget {
  const _PlaythroughDialog({required this.item});

  final LibraryGameDetails item;

  @override
  State<_PlaythroughDialog> createState() => _PlaythroughDialogState();
}

class _PlaythroughDialogState extends State<_PlaythroughDialog> {
  PlaythroughStatus _status = PlaythroughStatus.active;
  final DateTime _startedAt = DateTime.now();
  DateTime? _completedAt;
  String? _platformId;
  int? _rating;
  final _hoursController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _platformId = widget.item.platforms.isEmpty ? null : widget.item.platforms.first.id;
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registrar partida'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<PlaythroughStatus>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Estado'),
              items: [
                for (final status in PlaythroughStatus.values)
                  DropdownMenuItem(value: status, child: Text(status.label)),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _status = value;
                  if (value == PlaythroughStatus.completed) {
                    _completedAt ??= DateTime.now();
                  }
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _platformId,
              decoration: const InputDecoration(labelText: 'Plataforma'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Sin plataforma')),
                for (final platform in widget.item.platforms)
                  DropdownMenuItem(value: platform.id, child: Text(platform.name)),
              ],
              onChanged: (value) => setState(() => _platformId = value),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _hoursController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Horas jugadas'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int?>(
              initialValue: _rating,
              decoration: const InputDecoration(labelText: 'Puntaje'),
              items: const [
                DropdownMenuItem(value: null, child: Text('Sin puntaje')),
                DropdownMenuItem(value: 1, child: Text('1 estrella')),
                DropdownMenuItem(value: 2, child: Text('2 estrellas')),
                DropdownMenuItem(value: 3, child: Text('3 estrellas')),
                DropdownMenuItem(value: 4, child: Text('4 estrellas')),
                DropdownMenuItem(value: 5, child: Text('5 estrellas')),
              ],
              onChanged: (value) => setState(() => _rating = value),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Nota'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            PlaythroughFormModel(
              libraryEntryId: widget.item.entry.id,
              platformId: _platformId,
              status: _status,
              startedAt: _startedAt,
              completedAt: _completedAt,
              hoursPlayed: double.tryParse(
                _hoursController.text.trim().replaceAll(',', '.'),
              ),
              rating: _rating,
              notes: _notesController.text,
            ),
          ),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

String _names(Iterable<String> values) {
  final list = values.toList();
  if (list.isEmpty) return '-';
  return list.join(', ');
}
