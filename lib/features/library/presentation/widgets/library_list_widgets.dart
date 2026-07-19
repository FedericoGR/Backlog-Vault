part of 'library_catalog_widgets.dart';

/// Lazy compact list used on phones and in explicit list layout.
class LibraryCatalogList extends StatelessWidget {
  const LibraryCatalogList({
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
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: rows.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final row = rows[index];
        final selected = selectedIds.contains(row.libraryEntryId);
        return LibraryCatalogListTile(
          key: ValueKey(row.libraryEntryId),
          row: row,
          selected: selected,
          selectionMode: selectionMode,
          onSelected: (value) => onSelectionChanged(row.libraryEntryId, value),
          actions: rowActionsBuilder(row, true),
        );
      },
    );
  }
}

/// One selectable library item in the compact list layout.
class LibraryCatalogListTile extends StatelessWidget {
  const LibraryCatalogListTile({
    required this.row,
    required this.selected,
    required this.selectionMode,
    required this.onSelected,
    required this.actions,
    super.key,
  });

  final LibraryGameRow row;
  final bool selected;
  final bool selectionMode;
  final ValueChanged<bool> onSelected;
  final Widget actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 430;
        final coverWidth = compact ? 84.0 : 112.0;
        final coverHeight = compact ? 62.0 : 76.0;

        return BvSurface(
          padding: const EdgeInsets.all(10),
          selected: selected,
          onTap:
              selectionMode
                  ? () => onSelected(!selected)
                  : () => context.go('/games/${row.libraryEntryId}'),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (selectionMode) ...[
                _SelectionBadge(selected: selected, onChanged: onSelected),
                const SizedBox(width: 10),
              ],
              LibraryCoverThumbnail(
                localPath: row.selectedCoverLocalPath,
                width: coverWidth,
                height: coverHeight,
                borderRadius: BvRadii.sm,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        BvChip(
                          label: context.l10n.gameStatusLabel(row.status),
                          tone: _statusTone(row.status),
                        ),
                        BvChip(label: formatStarRating(row.personalRating)),
                        if (row.hoursPlayed != null)
                          BvChip(
                            label: context.l10n.hoursShort(
                              row.hoursPlayed!.toStringAsFixed(1),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        _InlineMetadata(
                          icon: Icons.sports_esports_outlined,
                          text: _limitedNames(
                            row.platforms.map((platform) => platform.name),
                            limit: compact ? 2 : 3,
                          ),
                        ),
                        _InlineMetadata(
                          icon: Icons.category_outlined,
                          text: _limitedNames(
                            row.genres.map((genre) => genre.name),
                            limit: compact ? 2 : 3,
                          ),
                        ),
                        _InlineMetadata(
                          icon: Icons.event_outlined,
                          text: formatVisibleDate(
                            row.completedAt ?? row.releaseDate,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!selectionMode)
                SizedBox(width: 48, child: Align(child: actions)),
            ],
          ),
        );
      },
    );
  }
}
