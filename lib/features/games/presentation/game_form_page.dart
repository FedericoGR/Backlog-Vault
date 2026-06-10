import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/formatting/date_formatters.dart';
import '../../catalogs/data/catalog_repository.dart';
import '../../library/domain/game_status.dart';
import '../../playthroughs/application/completion_form_model.dart';
import '../application/game_form_model.dart';
import '../application/library_game_details.dart';
import '../data/game_repository.dart';

class GameFormPage extends ConsumerStatefulWidget {
  const GameFormPage({this.entryId, super.key});

  final String? entryId;

  @override
  ConsumerState<GameFormPage> createState() => _GameFormPageState();
}

class _GameFormPageState extends ConsumerState<GameFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _newPlatformController = TextEditingController();
  final _newGenreController = TextEditingController();
  final _completedHoursController = TextEditingController();
  final _completedNotesController = TextEditingController();

  GameStatus _status = GameStatus.backlog;
  DateTime? _releaseDate;
  int? _rating;
  DateTime? _completedAt;
  double? _completedHours;
  String? _completedPlatformId;
  int? _completedRating;
  bool _loadedExisting = false;
  bool _saving = false;
  final _selectedPlatformIds = <String>{};
  final _selectedGenreIds = <String>{};

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _newPlatformController.dispose();
    _newGenreController.dispose();
    _completedHoursController.dispose();
    _completedNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detail =
        widget.entryId == null
            ? const AsyncData<LibraryGameDetails?>(null)
            : ref.watch(libraryGameProvider(widget.entryId!));
    final platforms = ref.watch(catalogRepositoryProvider).watchPlatforms();
    final genres = ref.watch(catalogRepositoryProvider).watchGenres();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entryId == null ? 'Crear juego' : 'Editar juego'),
      ),
      body: detail.when(
        data: (item) {
          if (item != null && !_loadedExisting) {
            _loadExisting(item);
          }

          return StreamBuilder(
            stream: platforms,
            builder: (context, platformSnapshot) {
              return StreamBuilder(
                stream: genres,
                builder: (context, genreSnapshot) {
                  final platformItems = platformSnapshot.data ?? [];
                  final genreItems = genreSnapshot.data ?? [];

                  return Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El nombre es obligatorio.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _DateField(
                          label: 'Fecha de salida',
                          value: _releaseDate,
                          onChanged: (value) {
                            setState(() => _releaseDate = value);
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<GameStatus>(
                          initialValue: _status,
                          decoration: const InputDecoration(
                            labelText: 'Estado',
                          ),
                          items: [
                            for (final status in GameStatus.values)
                              DropdownMenuItem(
                                value: status,
                                child: Text(status.label),
                              ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _status = value;
                              if (value == GameStatus.completed) {
                                _completedAt ??= DateTime.now();
                                _completedRating ??= _rating;
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int?>(
                          initialValue: _rating,
                          decoration: const InputDecoration(
                            labelText: 'Puntaje personal',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: null,
                              child: Text('Sin puntaje'),
                            ),
                            DropdownMenuItem(
                              value: 1,
                              child: Text('1 estrella'),
                            ),
                            DropdownMenuItem(
                              value: 2,
                              child: Text('2 estrellas'),
                            ),
                            DropdownMenuItem(
                              value: 3,
                              child: Text('3 estrellas'),
                            ),
                            DropdownMenuItem(
                              value: 4,
                              child: Text('4 estrellas'),
                            ),
                            DropdownMenuItem(
                              value: 5,
                              child: Text('5 estrellas'),
                            ),
                          ],
                          onChanged: (value) => setState(() => _rating = value),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _notesController,
                          minLines: 3,
                          maxLines: 6,
                          decoration: const InputDecoration(
                            labelText: 'Notas personales',
                          ),
                        ),
                        const SizedBox(height: 24),
                        _CatalogSelector(
                          title: 'Plataformas',
                          addLabel: 'Agregar plataforma',
                          controller: _newPlatformController,
                          items: {
                            for (final platform in platformItems)
                              platform.id: platform.name,
                          },
                          selectedIds: _selectedPlatformIds,
                          onToggle: (id, selected) {
                            setState(() {
                              if (selected) {
                                _selectedPlatformIds.add(id);
                                _completedPlatformId ??= id;
                              } else {
                                _selectedPlatformIds.remove(id);
                              }
                            });
                          },
                          onCreate: () async {
                            final id = await ref
                                .read(catalogRepositoryProvider)
                                .createPlatform(_newPlatformController.text);
                            setState(() {
                              _selectedPlatformIds.add(id);
                              _completedPlatformId ??= id;
                              _newPlatformController.clear();
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                        _CatalogSelector(
                          title: 'Géneros',
                          addLabel: 'Agregar género',
                          controller: _newGenreController,
                          items: {
                            for (final genre in genreItems)
                              genre.id: genre.name,
                          },
                          selectedIds: _selectedGenreIds,
                          onToggle: (id, selected) {
                            setState(() {
                              if (selected) {
                                _selectedGenreIds.add(id);
                              } else {
                                _selectedGenreIds.remove(id);
                              }
                            });
                          },
                          onCreate: () async {
                            final id = await ref
                                .read(catalogRepositoryProvider)
                                .createGenre(_newGenreController.text);
                            setState(() {
                              _selectedGenreIds.add(id);
                              _newGenreController.clear();
                            });
                          },
                        ),
                        if (_status == GameStatus.completed) ...[
                          const SizedBox(height: 24),
                          _CompletionFields(
                            completedAt: _completedAt ?? DateTime.now(),
                            hoursController: _completedHoursController,
                            notesController: _completedNotesController,
                            rating: _completedRating,
                            platformId: _completedPlatformId,
                            platforms: {
                              for (final platform in platformItems)
                                platform.id: platform.name,
                            },
                            onDateChanged: (value) {
                              setState(() => _completedAt = value);
                            },
                            onRatingChanged: (value) {
                              setState(() => _completedRating = value);
                            },
                            onPlatformChanged: (value) {
                              setState(() => _completedPlatformId = value);
                            },
                          ),
                        ],
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: _saving ? null : () => _save(item),
                          icon:
                              _saving
                                  ? const SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Icon(Icons.save_outlined),
                          label: const Text('Guardar'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text(error.toString())),
      ),
    );
  }

  void _loadExisting(LibraryGameDetails item) {
    _loadedExisting = true;
    _titleController.text = item.game.title;
    _releaseDate = item.game.releaseDate;
    _status = parseGameStatus(item.entry.status);
    _rating = item.entry.personalRating;
    _notesController.text = item.entry.personalNotes ?? '';
    _selectedPlatformIds.addAll(item.platforms.map((platform) => platform.id));
    _selectedGenreIds.addAll(item.genres.map((genre) => genre.id));
    _completedPlatformId =
        item.platforms.isEmpty ? null : item.platforms.first.id;
  }

  Future<void> _save(LibraryGameDetails? existing) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final model = GameFormModel(
        entryId: existing?.entry.id,
        gameId: existing?.game.id,
        title: _titleController.text,
        releaseDate: _releaseDate,
        status: _status,
        personalRating: _rating,
        personalNotes: _notesController.text,
        platformIds: _selectedPlatformIds.toList(),
        genreIds: _selectedGenreIds.toList(),
      );
      final entryId = await ref.read(gameRepositoryProvider).save(model);

      final wasCompleted =
          existing != null &&
          parseGameStatus(existing.entry.status) == GameStatus.completed;
      if (_status == GameStatus.completed && !wasCompleted) {
        _completedHours = double.tryParse(
          _completedHoursController.text.trim().replaceAll(',', '.'),
        );
        await ref
            .read(gameRepositoryProvider)
            .completeGame(
              CompletionFormModel(
                libraryEntryId: entryId,
                completedAt: _completedAt ?? DateTime.now(),
                platformId: _completedPlatformId,
                hoursPlayed: _completedHours,
                rating: _completedRating,
                notes: _completedNotesController.text,
              ),
            );
      }

      if (!mounted) return;
      context.go('/games/$entryId');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: Row(
        children: [
          Expanded(child: Text(formatVisibleDate(value))),
          TextButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: value ?? DateTime.now(),
                firstDate: DateTime(1970),
                lastDate: DateTime(2100),
              );
              if (picked != null) onChanged(picked);
            },
            child: const Text('Elegir'),
          ),
          if (value != null)
            IconButton(
              tooltip: 'Limpiar',
              onPressed: () => onChanged(null),
              icon: const Icon(Icons.clear),
            ),
        ],
      ),
    );
  }
}

class _CatalogSelector extends StatelessWidget {
  const _CatalogSelector({
    required this.title,
    required this.addLabel,
    required this.controller,
    required this.items,
    required this.selectedIds,
    required this.onToggle,
    required this.onCreate,
  });

  final String title;
  final String addLabel;
  final TextEditingController controller;
  final Map<String, String> items;
  final Set<String> selectedIds;
  final void Function(String id, bool selected) onToggle;
  final Future<void> Function() onCreate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final item in items.entries)
              FilterChip(
                label: Text(item.value),
                selected: selectedIds.contains(item.key),
                onSelected: (selected) => onToggle(item.key, selected),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(labelText: addLabel),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              tooltip: addLabel,
              onPressed: onCreate,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }
}

class _CompletionFields extends StatelessWidget {
  const _CompletionFields({
    required this.completedAt,
    required this.hoursController,
    required this.notesController,
    required this.rating,
    required this.platformId,
    required this.platforms,
    required this.onDateChanged,
    required this.onRatingChanged,
    required this.onPlatformChanged,
  });

  final DateTime completedAt;
  final TextEditingController hoursController;
  final TextEditingController notesController;
  final int? rating;
  final String? platformId;
  final Map<String, String> platforms;
  final ValueChanged<DateTime?> onDateChanged;
  final ValueChanged<int?> onRatingChanged;
  final ValueChanged<String?> onPlatformChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Datos de completado',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        _DateField(
          label: 'Fecha de completado',
          value: completedAt,
          onChanged: onDateChanged,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: hoursController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Horas jugadas'),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int?>(
          initialValue: rating,
          decoration: const InputDecoration(labelText: 'Puntaje de partida'),
          items: const [
            DropdownMenuItem(value: null, child: Text('Sin puntaje')),
            DropdownMenuItem(value: 1, child: Text('1 estrella')),
            DropdownMenuItem(value: 2, child: Text('2 estrellas')),
            DropdownMenuItem(value: 3, child: Text('3 estrellas')),
            DropdownMenuItem(value: 4, child: Text('4 estrellas')),
            DropdownMenuItem(value: 5, child: Text('5 estrellas')),
          ],
          onChanged: onRatingChanged,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String?>(
          initialValue: platformId,
          decoration: const InputDecoration(labelText: 'Plataforma'),
          items: [
            const DropdownMenuItem(value: null, child: Text('Sin plataforma')),
            for (final platform in platforms.entries)
              DropdownMenuItem(
                value: platform.key,
                child: Text(platform.value),
              ),
          ],
          onChanged: onPlatformChanged,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: notesController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Nota de partida'),
        ),
      ],
    );
  }
}
