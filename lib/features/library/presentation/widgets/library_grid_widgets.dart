part of 'library_catalog_widgets.dart';

/// Lazy gallery used when the library is in cover-oriented layout.
class LibraryCatalogGrid extends StatelessWidget {
  const LibraryCatalogGrid({
    required this.rows,
    required this.selectionMode,
    required this.selectedIds,
    required this.onSelectionChanged,
    required this.rowActionsBuilder,
    super.key,
  });

  final List<LibraryGameRow> rows;
  final bool selectionMode;
  final Set<String> selectedIds;
  final LibraryRowSelectionChanged onSelectionChanged;
  final LibraryRowActionsBuilder rowActionsBuilder;

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
        return LibraryCatalogCard(
          key: ValueKey(row.libraryEntryId),
          row: row,
          selectionMode: selectionMode,
          selected: selectedIds.contains(row.libraryEntryId),
          onSelected:
              (selected) => onSelectionChanged(row.libraryEntryId, selected),
          actions: rowActionsBuilder(row, true),
        );
      },
    );
  }
}

/// One selectable library item in the gallery layout.
class LibraryCatalogCard extends StatelessWidget {
  const LibraryCatalogCard({
    required this.row,
    required this.selectionMode,
    required this.selected,
    required this.onSelected,
    required this.actions,
    super.key,
  });

  final LibraryGameRow row;
  final bool selectionMode;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final Widget actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bv = BvThemeExtension.of(context);
    return BvSurface(
      padding: EdgeInsets.zero,
      selected: selected,
      backgroundColor: bv.surfaceRaised,
      onTap:
          selectionMode
              ? () => onSelected(!selected)
              : () => context.go('/games/${row.libraryEntryId}'),
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
                if (selectionMode)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _SelectionBadge(
                      selected: selected,
                      onChanged: onSelected,
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
                      if (!selectionMode) actions,
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
