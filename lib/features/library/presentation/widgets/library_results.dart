part of '../game_list_page.dart';

class _LibraryContent extends StatelessWidget {
  const _LibraryContent({
    required this.items,
    required this.rows,
    required this.layoutMode,
    required this.isWide,
    required this.selectionMode,
    required this.selectedIds,
    required this.onSelectionChanged,
  });

  final List<LibraryGameRow> items;
  final List<LibraryGameRow> rows;
  final LibraryLayoutMode layoutMode;
  final bool isWide;
  final bool selectionMode;
  final Set<String> selectedIds;
  final LibraryRowSelectionChanged onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const _EmptyLibraryState();
    if (rows.isEmpty) return const _EmptyFilteredState();

    Widget rowActionsBuilder(LibraryGameRow row, bool compact) {
      return LibraryRowActions(row: row, compact: compact);
    }

    if (layoutMode == LibraryLayoutMode.gallery) {
      return LibraryCatalogGrid(
        rows: rows,
        selectionMode: selectionMode,
        selectedIds: selectedIds,
        onSelectionChanged: onSelectionChanged,
        rowActionsBuilder: rowActionsBuilder,
      );
    }

    if (layoutMode == LibraryLayoutMode.list || !isWide) {
      return LibraryCatalogList(
        rows: rows,
        selectionMode: selectionMode,
        selectedIds: selectedIds,
        onSelectionChanged: onSelectionChanged,
        rowActionsBuilder: rowActionsBuilder,
      );
    }

    return _LibraryDataTable(
      rows: rows,
      selectionMode: selectionMode,
      selectedIds: selectedIds,
      onSelectionChanged: onSelectionChanged,
    );
  }
}

class _LibraryDataTable extends ConsumerWidget {
  const _LibraryDataTable({
    required this.rows,
    required this.selectionMode,
    required this.selectedIds,
    required this.onSelectionChanged,
  });

  final List<LibraryGameRow> rows;
  final bool selectionMode;
  final Set<String> selectedIds;
  final void Function(String entryId, bool selected) onSelectionChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(libraryViewModelProvider).table;
    final theme = Theme.of(context);
    final bv = BvThemeExtension.of(context);
    final visibleColumns = state.columnConfig.visibleColumns;
    final sortedColumnIndex = visibleColumns.indexWhere(
      (column) => _sortFieldForColumn(column) == state.sort.field,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: DataTable2(
        minWidth: _tableMinWidth(visibleColumns, selectionMode),
        fixedLeftColumns: 1,
        columnSpacing: 16,
        horizontalMargin: 10,
        headingRowHeight: 44,
        dataRowHeight: 48,
        dividerThickness: 1,
        headingTextStyle: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w800,
        ),
        dataTextStyle: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
        headingRowColor: WidgetStatePropertyAll(bv.surfaceRaised),
        dataRowColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return theme.colorScheme.primaryContainer.withValues(alpha: 0.30);
          }
          if (states.contains(WidgetState.hovered)) {
            return theme.colorScheme.primary.withValues(alpha: 0.05);
          }
          return null;
        }),
        sortColumnIndex: sortedColumnIndex == -1 ? null : sortedColumnIndex,
        sortAscending: state.sort.ascending,
        columns: [
          if (selectionMode) const DataColumn2(label: Text(''), fixedWidth: 56),
          for (final column in visibleColumns)
            DataColumn2(
              label: Text(context.l10n.libraryColumnLabel(column)),
              size:
                  column == LibraryColumnKey.title
                      ? ColumnSize.L
                      : column == LibraryColumnKey.cover
                      ? ColumnSize.S
                      : ColumnSize.M,
              onSort:
                  _sortFieldForColumn(column) == null
                      ? null
                      : (index, ascending) => _toggleSort(ref, column),
            ),
          const DataColumn2(label: Text(''), fixedWidth: 56),
        ],
        rows: [
          for (final row in rows)
            DataRow(
              selected: selectedIds.contains(row.libraryEntryId),
              cells: [
                if (selectionMode)
                  DataCell(
                    Checkbox(
                      value: selectedIds.contains(row.libraryEntryId),
                      onChanged:
                          (value) => onSelectionChanged(
                            row.libraryEntryId,
                            value ?? false,
                          ),
                    ),
                  ),
                for (final column in visibleColumns)
                  DataCell(
                    _tableCell(context, row, column),
                    onTap:
                        column == LibraryColumnKey.title
                            ? () => context.go('/games/${row.libraryEntryId}')
                            : null,
                  ),
                DataCell(LibraryRowActions(row: row, compact: true)),
              ],
            ),
        ],
      ),
    );
  }

  double _tableMinWidth(
    List<LibraryColumnKey> visibleColumns,
    bool selectionMode,
  ) {
    var width = selectionMode ? 56.0 : 0.0;
    for (final column in visibleColumns) {
      width += switch (column) {
        LibraryColumnKey.title => 280,
        LibraryColumnKey.cover => 72,
        LibraryColumnKey.status => 116,
        LibraryColumnKey.platforms || LibraryColumnKey.genres => 150,
        LibraryColumnKey.rating ||
        LibraryColumnKey.releaseDate ||
        LibraryColumnKey.completedDate ||
        LibraryColumnKey.hours ||
        LibraryColumnKey.type ||
        LibraryColumnKey.playthroughs => 120,
        LibraryColumnKey.notes || LibraryColumnKey.updatedAt => 150,
      };
    }
    return (width + 56).clamp(760.0, 1120.0).toDouble();
  }
}

/// Width-aware navigation and delete actions for one library entry.
class LibraryRowActions extends ConsumerWidget {
  const LibraryRowActions({required this.row, this.compact = false, super.key});

  final LibraryGameRow row;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final shouldCompact =
            compact ||
            (constraints.hasBoundedWidth && constraints.maxWidth < 120);
        if (shouldCompact) {
          return _RowActionsMenu(row: row, ref: ref);
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: context.l10n.libraryOpenDetails,
              onPressed: () => context.go('/games/${row.libraryEntryId}'),
              icon: const Icon(Icons.open_in_new),
            ),
            IconButton(
              tooltip: context.l10n.edit,
              onPressed: () => context.go('/games/${row.libraryEntryId}/edit'),
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: context.l10n.deleteAction,
              onPressed: () => _confirmDelete(context, ref, row),
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        );
      },
    );
  }
}

class _RowActionsMenu extends StatelessWidget {
  const _RowActionsMenu({required this.row, required this.ref});

  final LibraryGameRow row;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: PopupMenuButton<String>(
        tooltip: context.l10n.libraryActionsTooltip,
        onSelected: (value) {
          if (value == 'open') context.go('/games/${row.libraryEntryId}');
          if (value == 'edit') context.go('/games/${row.libraryEntryId}/edit');
          if (value == 'delete') _confirmDelete(context, ref, row);
        },
        itemBuilder:
            (context) => [
              PopupMenuItem(
                value: 'open',
                child: Text(context.l10n.libraryOpenDetails),
              ),
              PopupMenuItem(value: 'edit', child: Text(context.l10n.edit)),
              PopupMenuItem(
                value: 'delete',
                child: Text(context.l10n.deleteAction),
              ),
            ],
      ),
    );
  }
}
