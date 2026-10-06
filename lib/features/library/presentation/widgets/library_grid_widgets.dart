part of 'library_catalog_widgets.dart';

/// The annual game log gallery. Poster proportions stay fixed at every width.
class LibraryCatalogGrid extends StatelessWidget {
  const LibraryCatalogGrid({required this.rows, super.key});
  final List<LibraryGameRow> rows;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns =
          constraints.maxWidth >= 1100
              ? 6
              : constraints.maxWidth >= 760
              ? 4
              : constraints.maxWidth >= 500
              ? 3
              : 2;
      final width = (constraints.maxWidth - 32 - (columns - 1) * 20) / columns;
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisExtent: width * 1.5 + 118,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
        ),
        itemCount: rows.length,
        itemBuilder:
            (_, index) => LibraryCatalogCard(
              key: ValueKey(rows[index].libraryEntryId),
              row: rows[index],
            ),
      );
    },
  );
}

/// A poster and a compact personal record, without a surrounding card.
class LibraryCatalogCard extends StatefulWidget {
  const LibraryCatalogCard({required this.row, super.key});
  final LibraryGameRow row;

  @override
  State<LibraryCatalogCard> createState() => _LibraryCatalogCardState();
}

class _LibraryCatalogCardState extends State<LibraryCatalogCard> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final row = widget.row;
    final theme = Theme.of(context);
    final bv = BvThemeExtension.of(context);
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => context.go('/games/${row.libraryEntryId}'),
        onHover: (value) => setState(() => _hovered = value),
        onFocusChange: (value) => setState(() => _focused = value),
        borderRadius: BorderRadius.circular(4),
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 2 / 3,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color:
                        _hovered || _focused
                            ? theme.colorScheme.primary
                            : bv.borderStrong,
                  ),
                ),
                padding: const EdgeInsets.all(1),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    LayoutBuilder(
                      builder:
                          (_, box) => LibraryCoverThumbnail(
                            localPath: row.selectedCoverLocalPath,
                            width: box.maxWidth,
                            height: box.maxHeight,
                            borderRadius: 4,
                          ),
                    ),
                    if (row.isCompleted)
                      Positioned(
                        right: 6,
                        bottom: 6,
                        child: Tooltip(
                          message: context.l10n.statusCompleted,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: bv.canvas,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.check, size: 16),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 9),
            Text(
              row.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (row.personalRating != null)
                  PersonalRatingStars(rating: row.personalRating!),
                if (row.hoursPlayed != null)
                  Text(
                    context.l10n.hoursShort(
                      row.hoursPlayed!.toStringAsFixed(1),
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            if (row.playedPlatform != null) ...[
              const SizedBox(height: 4),
              Text(
                row.playedPlatform!.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(color: bv.textMuted),
              ),
            ],
            Semantics(
              label: context.l10n.gameStatusLabel(row.status),
              child: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
