part of '../game_detail_page.dart';

class _GameInfoPanel extends StatelessWidget {
  const _GameInfoPanel({required this.item});

  final LibraryGameDetails item;

  @override
  Widget build(BuildContext context) {
    final entry = item.entry;
    final status =
        entry.isCompleted ? GameStatus.completed : GameStatus.pending;
    final platform = item.playedPlatform?.name ?? entry.playedPlatformId;
    return BvPanel(
      key: const ValueKey('detail-personal-record'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.game.title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          if (entry.personalRating != null) ...[
            const SizedBox(height: BvSpacing.sm),
            Semantics(
              label: context.l10n.ratingStars(entry.personalRating!),
              child: Text(
                formatStarRating(entry.personalRating),
                key: const ValueKey('detail-rating'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
          const SizedBox(height: BvSpacing.md),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (entry.hoursPlayed != null)
                BvChip(
                  label: '${entry.hoursPlayed} h',
                  icon: Icons.timer_outlined,
                ),
              if (platform != null)
                Semantics(
                  label: context.l10n.gamePlayedPlatform,
                  child: BvChip(
                    label: platform,
                    icon: Icons.sports_esports_outlined,
                  ),
                ),
            ],
          ),
          const SizedBox(height: BvSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              BvChip(
                label: context.l10n.gameStatusLabel(status),
                icon:
                    entry.isCompleted
                        ? Icons.check_circle_outline
                        : Icons.circle_outlined,
                tone: _statusTone(status),
                selected: true,
              ),
              BvChip(
                label:
                    entry.playedYear?.toString() ?? context.l10n.logUnknownYear,
                icon: Icons.calendar_today_outlined,
              ),
            ],
          ),
          if (entry.isCompleted && entry.completedAt != null) ...[
            const SizedBox(height: BvSpacing.sm),
            Text(
              '${context.l10n.gameCompletionDate}: ${formatVisibleDate(entry.completedAt)}',
              key: const ValueKey('detail-completion-date'),
            ),
          ],
        ],
      ),
    );
  }
}

class _GameCatalogPanel extends ConsumerWidget {
  const _GameCatalogPanel({required this.item});

  final LibraryGameDetails item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BvPanel(
      child: Material(
        type: MaterialType.transparency,
        child: ExpansionTile(
          key: const ValueKey('detail-game-information'),
          title: Text(context.l10n.gameInformation),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (item.game.releaseDate != null)
                    BvChip(
                      label:
                          '${context.l10n.gameReleaseDate}: ${formatVisibleDate(item.game.releaseDate)}',
                      icon: Icons.event_outlined,
                    ),
                  BvChip(
                    label: context.l10n.displayGameType(item.game.type),
                    icon: Icons.extension_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: BvSpacing.md),
            _MetadataWrap(
              title: context.l10n.libraryPlatforms,
              icon: Icons.sports_esports_outlined,
              values: item.platforms.map((platform) => platform.name),
            ),
            const SizedBox(height: BvSpacing.md),
            _MetadataWrap(
              title: context.l10n.libraryGenres,
              icon: Icons.category_outlined,
              values: item.genres.map((genre) => genre.name),
            ),
            const SizedBox(height: BvSpacing.md),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: () => _showMetadataDialog(context, ref, item),
                icon: const Icon(Icons.travel_explore_outlined),
                label: Text(context.l10n.metadataSearch),
              ),
            ),
          ],
        ),
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
