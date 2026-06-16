import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/bv_chip.dart';
import '../../../../core/design_system/bv_panel.dart';
import '../../../../core/design_system/bv_surface.dart';
import '../../../../core/design_system/bv_theme_extension.dart';
import '../../../../core/design_system/bv_tokens.dart';
import '../../../../core/formatting/date_formatters.dart';
import '../../domain/game_status.dart';
import '../../domain/library_filter_state.dart';
import '../../domain/library_game_row.dart';
import '../../domain/library_table_summary.dart';
import '../../domain/rating.dart';
import 'library_cover_thumbnail.dart';

typedef LibraryRowActionsBuilder =
    Widget Function(LibraryGameRow row, bool compact);
typedef LibraryRowSelectionChanged =
    void Function(String entryId, bool selected);

class LibrarySummaryStrip extends StatelessWidget {
  const LibrarySummaryStrip({required this.summary, super.key});

  final LibraryTableSummary summary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _SummaryPill(label: 'Juegos', value: summary.visibleGames),
            _SummaryPill(label: 'Completados', value: summary.completedCount),
            _SummaryPill(
              label: 'Horas',
              textValue: summary.totalHours.toStringAsFixed(1),
            ),
            _SummaryPill(
              label: 'Promedio',
              textValue:
                  summary.averageRating == null
                      ? '-'
                      : summary.averageRating!.toStringAsFixed(1),
            ),
            _SummaryPill(label: 'Sin puntaje', value: summary.missingRating),
            _SummaryPill(
              label: 'Sin plataforma',
              value: summary.missingPlatform,
            ),
            _SummaryPill(label: 'Sin género', value: summary.missingGenre),
          ],
        ),
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({required this.label, this.value, this.textValue});

  final String label;
  final int? value;
  final String? textValue;

  @override
  Widget build(BuildContext context) {
    return BvChip(
      label: '$label: ${textValue ?? value}',
      tone: BvChipTone.neutral,
    );
  }
}

class LibrarySelectionBar extends StatelessWidget {
  const LibrarySelectionBar({
    required this.selectedCount,
    required this.visibleCount,
    required this.totalCount,
    required this.onSelectVisible,
    required this.onSelectAll,
    required this.onClear,
    required this.onDelete,
    super.key,
  });

  final int selectedCount;
  final int visibleCount;
  final int totalCount;
  final VoidCallback onSelectVisible;
  final VoidCallback onSelectAll;
  final VoidCallback onClear;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: BvPanel(
        dense: true,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            BvChip(
              icon: Icons.check_circle_outline,
              label: '$selectedCount seleccionados',
              tone: BvChipTone.primary,
              selected: selectedCount > 0,
            ),
            OutlinedButton(
              onPressed: visibleCount == 0 ? null : onSelectVisible,
              child: Text('Seleccionar visibles ($visibleCount)'),
            ),
            OutlinedButton(
              onPressed: totalCount == 0 ? null : onSelectAll,
              child: Text('Seleccionar todos ($totalCount)'),
            ),
            OutlinedButton(
              onPressed: selectedCount == 0 ? null : onClear,
              child: const Text('Limpiar selección'),
            ),
            FilledButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Eliminar'),
            ),
          ],
        ),
      ),
    );
  }
}

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
        mainAxisExtent: 444,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: rows.length,
      itemBuilder: (context, index) {
        final row = rows[index];
        return LibraryCatalogCard(
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
                      BvChip(
                        label: row.status.label,
                        tone: _statusTone(row.status),
                      ),
                      if (row.personalRating != null)
                        BvChip(label: formatStarRating(row.personalRating)),
                      if (row.hoursPlayed != null)
                        BvChip(
                          label: '${row.hoursPlayed!.toStringAsFixed(1)} h',
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _MetadataLine(
                    icon: Icons.sports_esports_outlined,
                    text: _limitedNames(
                      row.platforms.map((platform) => platform.name),
                    ),
                  ),
                  const SizedBox(height: 3),
                  _MetadataLine(
                    icon: Icons.category_outlined,
                    text: _limitedNames(row.genres.map((genre) => genre.name)),
                  ),
                  const SizedBox(height: 6),
                  _MetadataLine(
                    icon:
                        row.completedAt == null
                            ? Icons.event_outlined
                            : Icons.emoji_events_outlined,
                    text: formatVisibleDate(row.completedAt ?? row.releaseDate),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
                          label: row.status.label,
                          tone: _statusTone(row.status),
                        ),
                        BvChip(label: formatStarRating(row.personalRating)),
                        if (row.hoursPlayed != null)
                          BvChip(
                            label: '${row.hoursPlayed!.toStringAsFixed(1)} h',
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

class LibraryFilterSidebar extends StatelessWidget {
  const LibraryFilterSidebar({
    required this.filter,
    required this.platforms,
    required this.genres,
    required this.onEditFilters,
    required this.onClearFilters,
    required this.onToggleStatus,
    required this.onTogglePlatform,
    required this.onToggleGenre,
    super.key,
  });

  final LibraryFilterState filter;
  final List<LibraryCatalogItem> platforms;
  final List<LibraryCatalogItem> genres;
  final VoidCallback onEditFilters;
  final VoidCallback onClearFilters;
  final ValueChanged<GameStatus> onToggleStatus;
  final ValueChanged<String> onTogglePlatform;
  final ValueChanged<String> onToggleGenre;

  @override
  Widget build(BuildContext context) {
    final bv = BvThemeExtension.of(context);
    return SizedBox(
      width: 268,
      child: BvPanel(
        dense: true,
        child: ListView(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Filtros',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                BvChip(
                  label: filter.activeCount.toString(),
                  tone:
                      filter.activeCount == 0
                          ? BvChipTone.neutral
                          : BvChipTone.primary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SidebarSection(
              title: 'Estado',
              children: [
                for (final status in GameStatus.values)
                  Material(
                    color: Colors.transparent,
                    child: CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      value: filter.statuses.contains(status),
                      onChanged: (_) => onToggleStatus(status),
                      title: Text(status.label),
                    ),
                  ),
              ],
            ),
            _SidebarSection(
              title: 'Plataformas',
              children: [
                _FilterChipWrap(
                  items: platforms.take(10).toList(),
                  selectedIds: filter.platformIds,
                  onToggle: onTogglePlatform,
                ),
              ],
            ),
            _SidebarSection(
              title: 'Géneros',
              children: [
                _FilterChipWrap(
                  items: genres.take(12).toList(),
                  selectedIds: filter.genreIds,
                  onToggle: onToggleGenre,
                ),
              ],
            ),
            Divider(color: bv.border),
            OutlinedButton.icon(
              onPressed: onEditFilters,
              icon: const Icon(Icons.tune_outlined),
              label: const Text('Filtros avanzados'),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: filter.isEmpty ? null : onClearFilters,
              icon: const Icon(Icons.restart_alt),
              label: const Text('Limpiar filtros'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarSection extends StatelessWidget {
  const _SidebarSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _FilterChipWrap extends StatelessWidget {
  const _FilterChipWrap({
    required this.items,
    required this.selectedIds,
    required this.onToggle,
  });

  final List<LibraryCatalogItem> items;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text('Sin opciones', style: Theme.of(context).textTheme.bodySmall);
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final item in items)
          FilterChip(
            label: Text(item.name, overflow: TextOverflow.ellipsis),
            selected: selectedIds.contains(item.id),
            onSelected: (_) => onToggle(item.id),
          ),
      ],
    );
  }
}

class _SelectionBadge extends StatelessWidget {
  const _SelectionBadge({required this.selected, required this.onChanged});

  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final bv = BvThemeExtension.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(BvRadii.pill),
        border: Border.all(color: selected ? bv.focus : bv.borderStrong),
      ),
      child: Checkbox(
        value: selected,
        visualDensity: VisualDensity.compact,
        onChanged: (value) => onChanged(value ?? false),
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

class _InlineMetadata extends StatelessWidget {
  const _InlineMetadata({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

BvChipTone _statusTone(GameStatus status) {
  return switch (status) {
    GameStatus.completed => BvChipTone.primary,
    GameStatus.dropped => BvChipTone.warning,
    GameStatus.wishlist ||
    GameStatus.backlog ||
    GameStatus.playing ||
    GameStatus.paused ||
    GameStatus.retired => BvChipTone.neutral,
  };
}

String _limitedNames(Iterable<String> values, {int limit = 2}) {
  final list = values.toList();
  if (list.isEmpty) return '-';
  final visible = list.take(limit).join(', ');
  final remaining = list.length - limit;
  return remaining > 0 ? '$visible +$remaining' : visible;
}
