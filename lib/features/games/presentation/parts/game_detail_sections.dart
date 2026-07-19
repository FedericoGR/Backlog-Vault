part of '../game_detail_page.dart';

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
                tooltip: context.l10n.gameActions,
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
                    (context) => [
                      PopupMenuItem(
                        value: 'cover',
                        child: Text(context.l10n.coverChange),
                      ),
                      PopupMenuItem(
                        value: 'metadata',
                        child: Text(context.l10n.metadataSearch),
                      ),
                      PopupMenuItem(
                        value: 'edit',
                        child: Text(context.l10n.edit),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(context.l10n.delete),
                      ),
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
                label: context.l10n.gameStatusLabel(status),
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
                label: context.l10n.displayGameType(item.game.type),
                icon: Icons.extension_outlined,
              ),
            ],
          ),
          const SizedBox(height: BvSpacing.md),
          _MetadataWrap(
            title: context.l10n.libraryPlatforms,
            icon: Icons.sports_esports_outlined,
            values: item.platforms.map((platform) => platform.name),
          ),
          const SizedBox(height: BvSpacing.sm),
          _MetadataWrap(
            title: context.l10n.libraryGenres,
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
                label: Text(
                  cover == null
                      ? context.l10n.coverSearch
                      : context.l10n.coverChange,
                ),
              ),
              if (cover != null)
                IconButton.outlined(
                  tooltip: context.l10n.gameRemoveCover,
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
        title: context.l10n.gameSummaryProgress,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                BvStatCard(
                  label: context.l10n.libraryHours,
                  value:
                      summary.totalHours == null
                          ? '-'
                          : summary.totalHours!.toStringAsFixed(1),
                  icon: Icons.timer_outlined,
                ),
                BvStatCard(
                  label: context.l10n.gameLastCompleted,
                  value: formatVisibleDate(summary.latestCompletedAt),
                  icon: Icons.emoji_events_outlined,
                ),
                BvStatCard(
                  label: context.l10n.gamePlaythroughs,
                  value: summary.playthroughCount.toString(),
                  icon: Icons.history_outlined,
                ),
                BvStatCard(
                  label: context.l10n.libraryStatus,
                  value: context.l10n.gameStatusLabel(
                    parseGameStatus(item.entry.status),
                  ),
                  icon: Icons.flag_outlined,
                ),
                BvStatCard(
                  label: context.l10n.libraryPlatforms,
                  value: _names(
                    item.platforms.map((platform) => platform.name),
                  ),
                  icon: Icons.sports_esports_outlined,
                ),
                BvStatCard(
                  label: context.l10n.libraryGenres,
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
            label: context.l10n.gameMarkPlaying,
            icon: Icons.play_arrow,
            onPressed:
                _can(current, GameStatus.playing)
                    ? () => _runProgressAction(
                      context,
                      ref,
                      item,
                      () => ref
                          .read(gameDetailViewModelProvider)
                          .markPlaying(item.entry.id),
                    )
                    : null,
          ),
          _ProgressAction(
            label: context.l10n.gamePause,
            icon: Icons.pause,
            onPressed:
                _can(current, GameStatus.paused)
                    ? () => _runProgressAction(
                      context,
                      ref,
                      item,
                      () => ref
                          .read(gameDetailViewModelProvider)
                          .markPaused(item.entry.id),
                    )
                    : null,
          ),
          _ProgressAction(
            label: context.l10n.gameComplete,
            icon: Icons.check_circle_outline,
            prominent: true,
            onPressed:
                _can(current, GameStatus.completed)
                    ? () => _showCompletionDialog(context, ref, item)
                    : null,
          ),
          _ProgressAction(
            label: context.l10n.gameDrop,
            icon: Icons.cancel_outlined,
            onPressed:
                _can(current, GameStatus.dropped)
                    ? () => _runProgressAction(
                      context,
                      ref,
                      item,
                      () => ref
                          .read(gameDetailViewModelProvider)
                          .markDropped(item.entry.id),
                    )
                    : null,
          ),
          _ProgressAction(
            label: context.l10n.gameMoveToBacklog,
            icon: Icons.assignment_return_outlined,
            onPressed:
                _can(current, GameStatus.backlog)
                    ? () => _runProgressAction(
                      context,
                      ref,
                      item,
                      () => ref
                          .read(gameDetailViewModelProvider)
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 520;
        return BvPanel(
          child: BvSection(
            title: context.l10n.gamePlaythroughs,
            padding: EdgeInsets.zero,
            trailing:
                compact
                    ? IconButton.filledTonal(
                      tooltip: context.l10n.gameNewPlaythrough,
                      onPressed:
                          () => _showPlaythroughDialog(context, ref, item),
                      icon: const Icon(Icons.add),
                    )
                    : FilledButton.icon(
                      onPressed:
                          () => _showPlaythroughDialog(context, ref, item),
                      icon: const Icon(Icons.add),
                      label: Text(context.l10n.gameNewPlaythrough),
                    ),
            child:
                playthroughs.isEmpty
                    ? BvEmptyState(
                      title: context.l10n.gameNoPlaythroughs,
                      message: context.l10n.gameNoPlaythroughsMessage,
                      icon: Icons.history_outlined,
                    )
                    : Column(
                      children: [
                        for (final playthrough in playthroughs)
                          _PlaythroughTile(
                            item: item,
                            playthrough: playthrough,
                          ),
                      ],
                    ),
          ),
        );
      },
    );
  }
}

class _PlaythroughTile extends ConsumerWidget {
  const _PlaythroughTile({required this.item, required this.playthrough});

  final LibraryGameDetails item;
  final PlaythroughDetails playthrough;

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
                        label: context.l10n.playthroughStatusLabel(status),
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
                    _playthroughSubtitle(context, playthrough, item.platforms),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: BvSpacing.xs),
            PopupMenuButton<String>(
              tooltip: context.l10n.gamePlaythroughActions,
              onSelected: (value) {
                if (value == 'edit') {
                  _showPlaythroughDialog(context, ref, item, playthrough);
                }
                if (value == 'delete') {
                  _confirmDeletePlaythrough(context, ref, item, playthrough);
                }
              },
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text(context.l10n.edit),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(context.l10n.delete),
                    ),
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
        title: context.l10n.gamePersonalNotes,
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
