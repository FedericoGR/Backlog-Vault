part of '../game_detail_page.dart';

class _GameInfoPanel extends ConsumerWidget {
  const _GameInfoPanel({required this.item});

  final LibraryGameDetails item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final status =
        (item.entry.isCompleted ? GameStatus.completed : GameStatus.pending);
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
  const _GameProgressSection({required this.item});

  final LibraryGameDetails item;

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
                      item.entry.hoursPlayed == null
                          ? '-'
                          : item.entry.hoursPlayed!.toStringAsFixed(1),
                  icon: Icons.timer_outlined,
                ),
                BvStatCard(
                  label: context.l10n.gameLastCompleted,
                  value: formatVisibleDate(item.entry.completedAt),
                  icon: Icons.emoji_events_outlined,
                ),
                BvStatCard(
                  label: context.l10n.libraryStatus,
                  value: context.l10n.gameStatusLabel(
                    (item.entry.isCompleted
                        ? GameStatus.completed
                        : GameStatus.pending),
                  ),
                  icon: Icons.flag_outlined,
                ),
                BvStatCard(
                  label: context.l10n.gamePlayedPlatform,
                  value:
                      item.playedPlatform?.name ??
                      item.entry.playedPlatformId ??
                      '-',
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

BvChipTone _statusTone(GameStatus status) =>
    status == GameStatus.completed ? BvChipTone.primary : BvChipTone.neutral;

String _names(Iterable<String> values) =>
    values.isEmpty ? '-' : values.join(', ');
