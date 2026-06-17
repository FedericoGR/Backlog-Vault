import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/design_system/bv_breakpoints.dart';
import '../../../core/design_system/bv_chip.dart';
import '../../../core/design_system/bv_empty_state.dart';
import '../../../core/design_system/bv_panel.dart';
import '../../../core/design_system/bv_section.dart';
import '../../../core/design_system/bv_spacing.dart';
import '../../../core/design_system/bv_stat_card.dart';
import '../../../core/design_system/bv_surface.dart';
import '../../../core/design_system/bv_theme_extension.dart';
import '../../../core/design_system/bv_tokens.dart';
import '../../../core/formatting/date_formatters.dart';
import '../../library/domain/game_status.dart';
import '../../library/domain/rating.dart';
import '../../library/data/library_query_repository.dart';
import '../../library/presentation/widgets/library_cover_thumbnail.dart';
import '../../media/application/media_providers.dart';
import '../../media/presentation/media_search_dialog.dart';
import '../../metadata/presentation/metadata_search_dialog.dart';
import '../../playthroughs/application/completion_form_model.dart';
import '../../playthroughs/application/playthrough_form_model.dart';
import '../../playthroughs/domain/playthrough_status.dart';
import '../application/game_progress_summary.dart';
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

        final summary = GameProgressSummary.fromDetails(item);
        return Scaffold(
          appBar: AppBar(
            title: Text(item.game.title),
            actions: [
              IconButton(
                tooltip:
                    item.selectedCover == null
                        ? 'Buscar portada'
                        : 'Cambiar portada',
                onPressed: () => _showMediaDialog(context, ref, item),
                icon: const Icon(Icons.image_search_outlined),
              ),
              IconButton(
                tooltip: 'Buscar metadata',
                onPressed: () => _showMetadataDialog(context, ref, item),
                icon: const Icon(Icons.travel_explore_outlined),
              ),
              IconButton(
                tooltip: 'Editar juego',
                onPressed: () => context.go('/games/${item.entry.id}/edit'),
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Eliminar juego',
                onPressed: () => _confirmDelete(context, ref, item),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= BvBreakpoints.detailWide;
              final compact = constraints.maxWidth < BvBreakpoints.mobile;
              final padding = compact ? BvSpacing.pageCompact : BvSpacing.page;
              final coverPanel = _GameCoverPanel(item: item);
              final infoPanel = _GameInfoPanel(item: item);
              final progress = _GameProgressSection(
                item: item,
                summary: summary,
              );
              final playthroughs = _PlaythroughSection(item: item);
              final notes = _NotesSection(item: item);

              return ListView(
                padding: padding,
                children: [
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 300,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              coverPanel,
                              const SizedBox(height: 16),
                              progress,
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              infoPanel,
                              const SizedBox(height: 16),
                              playthroughs,
                              const SizedBox(height: 16),
                              notes,
                            ],
                          ),
                        ),
                      ],
                    )
                  else ...[
                    infoPanel,
                    const SizedBox(height: 16),
                    coverPanel,
                    const SizedBox(height: 16),
                    progress,
                    const SizedBox(height: 16),
                    playthroughs,
                    const SizedBox(height: 16),
                    notes,
                  ],
                  const SizedBox(height: 80),
                ],
              );
            },
          ),
        );
      },
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (error, stackTrace) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text(error.toString())),
          ),
    );
  }
}

class _GameInfoPanel extends ConsumerWidget {
  const _GameInfoPanel({required this.item});

  final LibraryGameDetails item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bv = BvThemeExtension.of(context);
    final status = parseGameStatus(item.entry.status);
    return BvPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.game.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: BvSpacing.sm),
              PopupMenuButton<String>(
                tooltip: 'Acciones del juego',
                onSelected: (value) {
                  if (value == 'cover') _showMediaDialog(context, ref, item);
                  if (value == 'metadata') {
                    _showMetadataDialog(context, ref, item);
                  }
                  if (value == 'edit') {
                    context.go('/games/${item.entry.id}/edit');
                  }
                  if (value == 'delete') _confirmDelete(context, ref, item);
                },
                itemBuilder:
                    (context) => const [
                      PopupMenuItem(
                        value: 'cover',
                        child: Text('Cambiar portada'),
                      ),
                      PopupMenuItem(
                        value: 'metadata',
                        child: Text('Buscar metadata'),
                      ),
                      PopupMenuItem(value: 'edit', child: Text('Editar')),
                      PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                    ],
              ),
            ],
          ),
          const SizedBox(height: BvSpacing.xs),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              BvChip(
                label: status.label,
                icon: Icons.bookmark_outline,
                tone: _statusTone(status),
                selected: true,
              ),
              BvChip(
                label: formatStarRating(item.entry.personalRating),
                icon: Icons.star_border,
              ),
              if (item.game.releaseDate != null)
                BvChip(
                  label: formatVisibleDate(item.game.releaseDate),
                  icon: Icons.event_outlined,
                ),
              BvChip(
                label: _displayGameType(item.game.type),
                icon: Icons.extension_outlined,
              ),
            ],
          ),
          const SizedBox(height: BvSpacing.md),
          _MetadataWrap(
            title: 'Plataformas',
            icon: Icons.sports_esports_outlined,
            values: item.platforms.map((platform) => platform.name),
          ),
          const SizedBox(height: BvSpacing.sm),
          _MetadataWrap(
            title: 'Géneros',
            icon: Icons.category_outlined,
            values: item.genres.map((genre) => genre.name),
          ),
          const SizedBox(height: BvSpacing.md),
          Divider(color: bv.border),
          const SizedBox(height: BvSpacing.sm),
          _QuickProgressActions(item: item),
        ],
      ),
    );
  }
}

class _GameCoverPanel extends ConsumerWidget {
  const _GameCoverPanel({required this.item});

  final LibraryGameDetails item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cover = item.selectedCover;
    return BvPanel(
      padding: const EdgeInsets.all(BvSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 2 / 3,
            child: LayoutBuilder(
              builder:
                  (context, constraints) => LibraryCoverThumbnail(
                    localPath: cover?.localPath,
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    borderRadius: BvRadii.md,
                  ),
            ),
          ),
          const SizedBox(height: BvSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _showMediaDialog(context, ref, item),
                icon: const Icon(Icons.image_search_outlined),
                label: Text(cover == null ? 'Buscar portada' : 'Cambiar'),
              ),
              if (cover != null)
                IconButton.outlined(
                  tooltip: 'Quitar portada',
                  onPressed: () => _confirmDeleteCover(context, ref, item),
                  icon: const Icon(Icons.delete_outline),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GameProgressSection extends StatelessWidget {
  const _GameProgressSection({required this.item, required this.summary});

  final LibraryGameDetails item;
  final GameProgressSummary summary;

  @override
  Widget build(BuildContext context) {
    return BvPanel(
      dense: true,
      child: BvSection(
        title: 'Resumen y progreso',
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                BvStatCard(
                  label: 'Horas',
                  value:
                      summary.totalHours == null
                          ? '-'
                          : summary.totalHours!.toStringAsFixed(1),
                  icon: Icons.timer_outlined,
                ),
                BvStatCard(
                  label: 'Último completado',
                  value: formatVisibleDate(summary.latestCompletedAt),
                  icon: Icons.emoji_events_outlined,
                ),
                BvStatCard(
                  label: 'Partidas',
                  value: summary.playthroughCount.toString(),
                  icon: Icons.history_outlined,
                ),
                BvStatCard(
                  label: 'Estado',
                  value: parseGameStatus(item.entry.status).label,
                  icon: Icons.flag_outlined,
                ),
                BvStatCard(
                  label: 'Plataformas',
                  value: _names(
                    item.platforms.map((platform) => platform.name),
                  ),
                  icon: Icons.sports_esports_outlined,
                ),
                BvStatCard(
                  label: 'Géneros',
                  value: _names(item.genres.map((genre) => genre.name)),
                  icon: Icons.category_outlined,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickProgressActions extends ConsumerWidget {
  const _QuickProgressActions({required this.item});

  final LibraryGameDetails item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = parseGameStatus(item.entry.status);
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 440;
        final actions = [
          _ProgressAction(
            label: 'Jugando',
            icon: Icons.play_arrow,
            onPressed:
                _can(current, GameStatus.playing)
                    ? () => _runProgressAction(
                      context,
                      ref,
                      item,
                      () => ref
                          .read(gameRepositoryProvider)
                          .markPlaying(item.entry.id),
                    )
                    : null,
          ),
          _ProgressAction(
            label: 'Pausar',
            icon: Icons.pause,
            onPressed:
                _can(current, GameStatus.paused)
                    ? () => _runProgressAction(
                      context,
                      ref,
                      item,
                      () => ref
                          .read(gameRepositoryProvider)
                          .markPaused(item.entry.id),
                    )
                    : null,
          ),
          _ProgressAction(
            label: 'Completar',
            icon: Icons.check_circle_outline,
            prominent: true,
            onPressed:
                _can(current, GameStatus.completed)
                    ? () => _showCompletionDialog(context, ref, item)
                    : null,
          ),
          _ProgressAction(
            label: 'Abandonar',
            icon: Icons.cancel_outlined,
            onPressed:
                _can(current, GameStatus.dropped)
                    ? () => _runProgressAction(
                      context,
                      ref,
                      item,
                      () => ref
                          .read(gameRepositoryProvider)
                          .markDropped(item.entry.id),
                    )
                    : null,
          ),
          _ProgressAction(
            label: 'Pendiente',
            icon: Icons.assignment_return_outlined,
            onPressed:
                _can(current, GameStatus.backlog)
                    ? () => _runProgressAction(
                      context,
                      ref,
                      item,
                      () => ref
                          .read(gameRepositoryProvider)
                          .markBacklog(item.entry.id),
                    )
                    : null,
          ),
        ];
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final action in actions)
              SizedBox(
                width: compact ? constraints.maxWidth : null,
                child: action,
              ),
          ],
        );
      },
    );
  }

  bool _can(GameStatus from, GameStatus to) {
    return from != to && canTransitionGameStatus(from, to);
  }
}

class _PlaythroughSection extends ConsumerWidget {
  const _PlaythroughSection({required this.item});

  final LibraryGameDetails item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playthroughs = [...item.playthroughs]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return BvPanel(
      child: BvSection(
        title: 'Partidas',
        padding: EdgeInsets.zero,
        trailing: FilledButton.icon(
          onPressed: () => _showPlaythroughDialog(context, ref, item),
          icon: const Icon(Icons.add),
          label: const Text('Nueva partida'),
        ),
        child:
            playthroughs.isEmpty
                ? const BvEmptyState(
                  title: 'Sin partidas registradas',
                  message:
                      'Cuando juegues o completes una partida aparecerá acá.',
                  icon: Icons.history_outlined,
                )
                : Column(
                  children: [
                    for (final playthrough in playthroughs)
                      _PlaythroughTile(item: item, playthrough: playthrough),
                  ],
                ),
      ),
    );
  }
}

class _PlaythroughTile extends ConsumerWidget {
  const _PlaythroughTile({required this.item, required this.playthrough});

  final LibraryGameDetails item;
  final Playthrough playthrough;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = parsePlaythroughStatus(playthrough.status);
    return Padding(
      padding: const EdgeInsets.only(bottom: BvSpacing.xs),
      child: BvSurface(
        padding: const EdgeInsets.symmetric(
          horizontal: BvSpacing.sm,
          vertical: BvSpacing.xs,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Icon(Icons.sports_esports_outlined, size: 18),
            ),
            const SizedBox(width: BvSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      BvChip(
                        label: status.label,
                        tone:
                            status == PlaythroughStatus.completed
                                ? BvChipTone.primary
                                : BvChipTone.neutral,
                      ),
                      BvChip(
                        label: _platformName(
                          item.platforms,
                          playthrough.platformId,
                        ),
                        icon: Icons.videogame_asset_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: BvSpacing.xxs),
                  Text(
                    _playthroughSubtitle(playthrough, item.platforms),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: BvSpacing.xs),
            PopupMenuButton<String>(
              tooltip: 'Acciones de partida',
              onSelected: (value) {
                if (value == 'edit') {
                  _showPlaythroughDialog(context, ref, item, playthrough);
                }
                if (value == 'delete') {
                  _confirmDeletePlaythrough(context, ref, item, playthrough);
                }
              },
              itemBuilder:
                  (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Editar')),
                    PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                  ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressAction extends StatelessWidget {
  const _ProgressAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.prominent = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    if (prominent) {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      );
    }
    return FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

class _MetadataWrap extends StatelessWidget {
  const _MetadataWrap({
    required this.title,
    required this.icon,
    required this.values,
  });

  final String title;
  final IconData icon;
  final Iterable<String> values;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bv = BvThemeExtension.of(context);
    final list = values
        .where((value) => value.trim().isNotEmpty)
        .toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: bv.textMuted),
            const SizedBox(width: BvSpacing.xxs),
            Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: BvSpacing.xs),
        if (list.isEmpty)
          Text('-', style: theme.textTheme.bodyMedium)
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final value in list) BvChip(label: value)],
          ),
      ],
    );
  }
}

class _NotesSection extends StatelessWidget {
  const _NotesSection({required this.item});

  final LibraryGameDetails item;

  @override
  Widget build(BuildContext context) {
    return BvPanel(
      child: BvSection(
        title: 'Notas personales',
        padding: EdgeInsets.zero,
        child: Text(
          item.entry.personalNotes?.trim().isEmpty ?? true
              ? '-'
              : item.entry.personalNotes!,
        ),
      ),
    );
  }
}

Future<void> _showMetadataDialog(
  BuildContext context,
  WidgetRef ref,
  LibraryGameDetails item,
) async {
  final applied = await showDialog<bool>(
    context: context,
    builder: (context) => MetadataSearchDialog(item: item),
  );
  if (applied != true || !context.mounted) return;
  ref.invalidate(libraryGameProvider(item.entry.id));
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text('Metadata aplicada.')));
}

Future<void> _showMediaDialog(
  BuildContext context,
  WidgetRef ref,
  LibraryGameDetails item,
) async {
  final saved = await showDialog<bool>(
    context: context,
    builder: (context) => MediaSearchDialog(item: item),
  );
  if (saved != true || !context.mounted) return;
  ref.invalidate(libraryGameProvider(item.entry.id));
  ref.invalidate(libraryRowsProvider);
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text('Portada actualizada.')));
}

Future<void> _confirmDeleteCover(
  BuildContext context,
  WidgetRef ref,
  LibraryGameDetails item,
) async {
  final cover = item.selectedCover;
  if (cover == null) return;
  final confirmed = await showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('Quitar portada'),
          content: const Text(
            'La portada se ocultará del juego, sin borrar físicamente tu historial de media.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Quitar'),
            ),
          ],
        ),
  );
  if (confirmed != true || !context.mounted) return;
  await ref.read(deleteMediaAssetUseCaseProvider).call(cover.id);
  ref.invalidate(libraryGameProvider(item.entry.id));
  ref.invalidate(libraryRowsProvider);
  if (!context.mounted) return;
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text('Portada quitada.')));
}

Future<void> _runProgressAction(
  BuildContext context,
  WidgetRef ref,
  LibraryGameDetails item,
  Future<void> Function() action,
) async {
  try {
    await action();
    ref.invalidate(libraryGameProvider(item.entry.id));
  } catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error.toString())));
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
  await _runProgressAction(
    context,
    ref,
    item,
    () => ref.read(gameRepositoryProvider).completeGame(result),
  );
}

Future<void> _showPlaythroughDialog(
  BuildContext context,
  WidgetRef ref,
  LibraryGameDetails item, [
  Playthrough? playthrough,
]) async {
  final result = await showDialog<PlaythroughFormModel>(
    context: context,
    builder:
        (context) => _PlaythroughDialog(item: item, playthrough: playthrough),
  );
  if (result == null || !context.mounted) return;
  await _runProgressAction(
    context,
    ref,
    item,
    () => ref.read(gameRepositoryProvider).savePlaythrough(result),
  );
}

Future<void> _confirmDeletePlaythrough(
  BuildContext context,
  WidgetRef ref,
  LibraryGameDetails item,
  Playthrough playthrough,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('Eliminar partida'),
          content: const Text('La partida se ocultará del historial.'),
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
  await _runProgressAction(
    context,
    ref,
    item,
    () =>
        ref.read(gameRepositoryProvider).softDeletePlaythrough(playthrough.id),
  );
}

Future<void> _confirmDelete(
  BuildContext context,
  WidgetRef ref,
  LibraryGameDetails item,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
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
    _platformId =
        widget.item.platforms.isEmpty ? null : widget.item.platforms.first.id;
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
            _DatePickerTile(
              label: 'Fecha de completado',
              value: _completedAt,
              allowClear: false,
              onChanged: (value) {
                if (value != null) setState(() => _completedAt = value);
              },
            ),
            TextField(
              controller: _hoursController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Horas jugadas'),
            ),
            const SizedBox(height: 12),
            _RatingField(
              value: _rating,
              onChanged: (value) => setState(() => _rating = value),
            ),
            const SizedBox(height: 12),
            _PlatformField(
              platformId: _platformId,
              platforms: widget.item.platforms,
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
          onPressed:
              () => Navigator.pop(
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
  const _PlaythroughDialog({required this.item, this.playthrough});

  final LibraryGameDetails item;
  final Playthrough? playthrough;

  @override
  State<_PlaythroughDialog> createState() => _PlaythroughDialogState();
}

class _PlaythroughDialogState extends State<_PlaythroughDialog> {
  late PlaythroughStatus _status;
  DateTime? _startedAt;
  DateTime? _completedAt;
  String? _platformId;
  int? _rating;
  late final TextEditingController _hoursController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final playthrough = widget.playthrough;
    _status =
        playthrough == null
            ? PlaythroughStatus.active
            : parsePlaythroughStatus(playthrough.status);
    _startedAt = playthrough?.startedAt ?? DateTime.now();
    _completedAt = playthrough?.completedAt;
    _platformId =
        playthrough?.platformId ??
        (widget.item.platforms.isEmpty ? null : widget.item.platforms.first.id);
    _rating = playthrough?.rating;
    _hoursController = TextEditingController(
      text: playthrough?.hoursPlayed?.toString() ?? '',
    );
    _notesController = TextEditingController(text: playthrough?.notes ?? '');
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
      title: Text(
        widget.playthrough == null ? 'Registrar partida' : 'Editar partida',
      ),
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
            _PlatformField(
              platformId: _platformId,
              platforms: widget.item.platforms,
              onChanged: (value) => setState(() => _platformId = value),
            ),
            const SizedBox(height: 12),
            _DatePickerTile(
              label: 'Fecha de inicio',
              value: _startedAt,
              onChanged: (value) => setState(() => _startedAt = value),
            ),
            _DatePickerTile(
              label: 'Fecha de completado',
              value: _completedAt,
              onChanged: (value) => setState(() => _completedAt = value),
            ),
            TextField(
              controller: _hoursController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Horas jugadas'),
            ),
            const SizedBox(height: 12),
            _RatingField(
              value: _rating,
              onChanged: (value) => setState(() => _rating = value),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Notas'),
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
          onPressed: () {
            final model = PlaythroughFormModel(
              playthroughId: widget.playthrough?.id,
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
            );
            try {
              model.validate();
              Navigator.pop(context, model);
            } catch (error) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(error.toString())));
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  const _DatePickerTile({
    required this.label,
    required this.value,
    required this.onChanged,
    this.allowClear = true,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final bool allowClear;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(formatVisibleDate(value)),
      trailing: Wrap(
        children: [
          if (allowClear)
            IconButton(
              tooltip: 'Limpiar fecha',
              onPressed: value == null ? null : () => onChanged(null),
              icon: const Icon(Icons.clear),
            ),
          IconButton(
            tooltip: 'Elegir fecha',
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: value ?? DateTime.now(),
                firstDate: DateTime(1970),
                lastDate: DateTime(2100),
              );
              if (picked != null) onChanged(picked);
            },
            icon: const Icon(Icons.calendar_today_outlined),
          ),
        ],
      ),
    );
  }
}

class _RatingField extends StatelessWidget {
  const _RatingField({required this.value, required this.onChanged});

  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int?>(
      initialValue: value,
      decoration: const InputDecoration(labelText: 'Puntaje'),
      items: const [
        DropdownMenuItem(value: null, child: Text('Sin puntaje')),
        DropdownMenuItem(value: 1, child: Text('1 estrella')),
        DropdownMenuItem(value: 2, child: Text('2 estrellas')),
        DropdownMenuItem(value: 3, child: Text('3 estrellas')),
        DropdownMenuItem(value: 4, child: Text('4 estrellas')),
        DropdownMenuItem(value: 5, child: Text('5 estrellas')),
      ],
      onChanged: onChanged,
    );
  }
}

class _PlatformField extends StatelessWidget {
  const _PlatformField({
    required this.platformId,
    required this.platforms,
    required this.onChanged,
  });

  final String? platformId;
  final List<Platform> platforms;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final safePlatformId =
        platforms.any((platform) => platform.id == platformId)
            ? platformId
            : null;
    return DropdownButtonFormField<String?>(
      initialValue: safePlatformId,
      decoration: const InputDecoration(labelText: 'Plataforma'),
      items: [
        const DropdownMenuItem(value: null, child: Text('Sin plataforma')),
        for (final platform in platforms)
          DropdownMenuItem(value: platform.id, child: Text(platform.name)),
      ],
      onChanged: onChanged,
    );
  }
}

String _playthroughSubtitle(Playthrough playthrough, List<Platform> platforms) {
  final parts =
      [
        _platformName(platforms, playthrough.platformId),
        if (playthrough.startedAt != null)
          'Inicio ${formatVisibleDate(playthrough.startedAt)}',
        if (playthrough.completedAt != null)
          'Fin ${formatVisibleDate(playthrough.completedAt)}',
        if (playthrough.hoursPlayed != null)
          '${playthrough.hoursPlayed!.toStringAsFixed(1)} h',
        if (playthrough.rating != null) '${playthrough.rating}/5',
        if (playthrough.notes?.trim().isNotEmpty ?? false)
          playthrough.notes!.trim(),
      ].where((value) => value != '-').toList();
  return parts.isEmpty ? '-' : parts.join(' · ');
}

String _platformName(List<Platform> platforms, String? platformId) {
  if (platformId == null) return '-';
  for (final platform in platforms) {
    if (platform.id == platformId) return platform.name;
  }
  return '-';
}

String _displayGameType(String value) {
  final normalized = value.trim().toLowerCase();
  return switch (normalized) {
    'un jugador' || 'single_player' || 'single player' => 'Un jugador',
    'multijugador' || 'multiplayer' => 'Multijugador',
    'cooperativo' || 'cooperative' || 'coop' || 'co-op' => 'Cooperativo',
    _ => 'Sin definir',
  };
}

BvChipTone _statusTone(GameStatus status) {
  return switch (status) {
    GameStatus.completed || GameStatus.playing => BvChipTone.primary,
    GameStatus.paused => BvChipTone.warning,
    GameStatus.dropped || GameStatus.retired => BvChipTone.danger,
    GameStatus.wishlist || GameStatus.backlog => BvChipTone.neutral,
  };
}

String _names(Iterable<String> values) {
  final list = values.toList();
  if (list.isEmpty) return '-';
  return list.join(', ');
}
