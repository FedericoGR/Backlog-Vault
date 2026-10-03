part of 'library_catalog_widgets.dart';

/// Wide-screen summary and quick controls for active library filters.
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
                    context.l10n.filters,
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
              title: context.l10n.libraryStatus,
              children: [
                for (final status in GameStatus.values)
                  Material(
                    color: Colors.transparent,
                    child: CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      value: filter.statuses.contains(status),
                      onChanged: (_) => onToggleStatus(status),
                      title: Text(context.l10n.gameStatusLabel(status)),
                    ),
                  ),
              ],
            ),
            _SidebarSection(
              title: context.l10n.libraryPlatforms,
              children: [
                _FilterChipWrap(
                  items: platforms.take(10).toList(),
                  selectedIds: filter.platformIds,
                  onToggle: onTogglePlatform,
                ),
              ],
            ),
            _SidebarSection(
              title: context.l10n.libraryGenres,
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
              label: Text(context.l10n.libraryAdvancedFilters),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: filter.isEmpty ? null : onClearFilters,
              icon: const Icon(Icons.restart_alt),
              label: Text(context.l10n.libraryClearFilters),
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
      return Text(
        context.l10n.libraryNoOptionsShort,
        style: Theme.of(context).textTheme.bodySmall,
      );
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

BvChipTone _statusTone(GameStatus status) =>
    status == GameStatus.completed ? BvChipTone.primary : BvChipTone.neutral;

String _limitedNames(Iterable<String> values, {int limit = 2}) {
  final list = values.toList();
  if (list.isEmpty) return '-';
  final visible = list.take(limit).join(', ');
  final remaining = list.length - limit;
  return remaining > 0 ? '$visible +$remaining' : visible;
}
