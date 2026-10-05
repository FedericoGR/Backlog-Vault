part of 'library_catalog_widgets.dart';

/// The annual game log gallery.
class LibraryCatalogGrid extends StatelessWidget {
  const LibraryCatalogGrid({required this.rows, super.key});

  final List<LibraryGameRow> rows;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 238,
        mainAxisExtent: 366,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: rows.length,
      itemBuilder: (context, index) {
        final row = rows[index];
        return LibraryCatalogCard(key: ValueKey(row.libraryEntryId), row: row);
      },
    );
  }
}

/// Opens one personal game record.
class LibraryCatalogCard extends StatelessWidget {
  const LibraryCatalogCard({required this.row, super.key});

  final LibraryGameRow row;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bv = BvThemeExtension.of(context);
    return BvSurface(
      padding: EdgeInsets.zero,
      backgroundColor: bv.surfaceRaised,
      onTap: () => context.go('/games/${row.libraryEntryId}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 196,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                LayoutBuilder(
                  builder:
                      (context, constraints) => LibraryCoverThumbnail(
                        localPath: row.selectedCoverLocalPath,
                        width: constraints.maxWidth,
                        height: 196,
                        borderRadius: 0,
                      ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.10),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          row.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (row.personalRating != null)
                        Semantics(
                          label: context.l10n.gamePersonalRating,
                          child: Text(formatStarRating(row.personalRating)),
                        ),
                      if (row.hoursPlayed != null)
                        Text(
                          context.l10n.hoursShort(
                            row.hoursPlayed!.toStringAsFixed(1),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _MetadataLine(
                    icon:
                        row.isCompleted
                            ? Icons.check_circle_outline
                            : Icons.circle_outlined,
                    text: context.l10n.gameStatusLabel(row.status),
                  ),
                  if (row.playedPlatform != null) ...[
                    const SizedBox(height: 3),
                    _MetadataLine(
                      icon: Icons.sports_esports_outlined,
                      text: row.playedPlatform!.name,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetadataLine extends StatelessWidget {
  const _MetadataLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 15,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
