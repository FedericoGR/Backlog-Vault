part of '../game_detail_page.dart';

class _GameInfoPanel extends StatelessWidget {
  const _GameInfoPanel({required this.item});
  final LibraryGameDetails item;

  @override
  Widget build(BuildContext context) {
    final entry = item.entry;
    final theme = Theme.of(context);
    final platform = item.playedPlatform?.name ?? entry.playedPlatformId;
    return Column(
      key: const ValueKey('detail-personal-record'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.game.title,
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (item.game.releaseDate != null) ...[
          const SizedBox(height: 6),
          Text(
            '${context.l10n.gameReleaseDate}: ${item.game.releaseDate!.year}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        if (entry.personalRating != null) ...[
          const SizedBox(height: 20),
          PersonalRatingStars(
            key: const ValueKey('detail-rating'),
            rating: entry.personalRating!,
            size: 24,
          ),
        ],
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 6,
          children: [
            if (entry.hoursPlayed != null)
              Text(
                '${NumberFormat('0.0', context.l10n.localeName).format(entry.hoursPlayed)} h',
                style: theme.textTheme.titleMedium,
              ),
            if (platform != null)
              Semantics(
                label: context.l10n.gamePlayedPlatform,
                child: Text(platform, style: theme.textTheme.titleMedium),
              ),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 16,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  entry.isCompleted ? Icons.check : Icons.remove,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  context.l10n.gameStatusLabel(
                    entry.isCompleted
                        ? GameStatus.completed
                        : GameStatus.pending,
                  ),
                ),
              ],
            ),
            Semantics(
              label: context.l10n.logPlayedYear,
              child: Text(
                entry.playedYear == null
                    ? '${context.l10n.gamePlayedYear}: ${context.l10n.logUnknownYear}'
                    : '${context.l10n.gamePlayedYear} ${entry.playedYear}',
              ),
            ),
          ],
        ),
        if (entry.isCompleted && entry.completedAt != null) ...[
          const SizedBox(height: 8),
          Text(
            '${context.l10n.gameCompletionDate}: ${formatVisibleDate(entry.completedAt)}',
            key: const ValueKey('detail-completion-date'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _GameCatalogPanel extends ConsumerWidget {
  const _GameCatalogPanel({required this.item});
  final LibraryGameDetails item;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
    children: [
      const SizedBox(height: 24),
      const Divider(),
      Material(
        type: MaterialType.transparency,
        child: ExpansionTile(
          key: const ValueKey('detail-game-information'),
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(bottom: 16),
          title: Text(context.l10n.gameInformation),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 24,
                runSpacing: 8,
                children: [
                  if (item.game.releaseDate != null)
                    Text(
                      '${context.l10n.gameReleaseDate}: ${formatVisibleDate(item.game.releaseDate)}',
                    ),
                  Text(context.l10n.displayGameType(item.game.type)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _MetadataWrap(
              title: context.l10n.libraryPlatforms,
              values: item.platforms.map((p) => p.name),
            ),
            const SizedBox(height: 16),
            _MetadataWrap(
              title: context.l10n.libraryGenres,
              values: item.genres.map((g) => g.name),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _showMetadataDialog(context, ref, item),
                icon: const Icon(Icons.travel_explore_outlined),
                label: Text(context.l10n.metadataSearch),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _GameCoverPanel extends StatelessWidget {
  const _GameCoverPanel({required this.item});
  final LibraryGameDetails item;

  @override
  Widget build(BuildContext context) => AspectRatio(
    key: const ValueKey('detail-poster'),
    aspectRatio: 2 / 3,
    child: LayoutBuilder(
      builder:
          (_, box) => LibraryCoverThumbnail(
            localPath: item.selectedCover?.localPath,
            width: box.maxWidth,
            height: box.maxHeight,
            borderRadius: BvRadii.md,
          ),
    ),
  );
}

class _MetadataWrap extends StatelessWidget {
  const _MetadataWrap({required this.title, required this.values});
  final String title;
  final Iterable<String> values;

  @override
  Widget build(BuildContext context) {
    final list = values.where((value) => value.trim().isNotEmpty).toList();
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: BvThemeExtension.of(context).textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(list.isEmpty ? '-' : list.join(' · ')),
        ],
      ),
    );
  }
}

class _NotesSection extends StatelessWidget {
  const _NotesSection({required this.item});
  final LibraryGameDetails item;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: BvSection(
      title: context.l10n.gamePersonalNotes,
      padding: EdgeInsets.zero,
      child: Text(
        item.entry.personalNotes ?? '',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
      ),
    ),
  );
}
