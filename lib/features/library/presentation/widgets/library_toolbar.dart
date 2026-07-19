part of '../game_list_page.dart';

class _LibraryToolbar extends ConsumerStatefulWidget {
  const _LibraryToolbar({
    required this.views,
    required this.customViews,
    required this.activeViewId,
    required this.filter,
    required this.platforms,
    required this.genres,
    required this.isWide,
    required this.layoutMode,
    required this.filtersVisible,
    required this.canUseFilterSidebar,
    required this.onToggleFilters,
  });

  final List<SavedLibraryView> views;
  final List<SavedLibraryView> customViews;
  final String activeViewId;
  final LibraryFilterState filter;
  final List<LibraryCatalogItem> platforms;
  final List<LibraryCatalogItem> genres;
  final bool isWide;
  final LibraryLayoutMode layoutMode;
  final bool filtersVisible;
  final bool canUseFilterSidebar;
  final VoidCallback onToggleFilters;

  @override
  ConsumerState<_LibraryToolbar> createState() => _LibraryToolbarState();
}

class _LibraryToolbarState extends ConsumerState<_LibraryToolbar> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.filter.textQuery);
  }

  @override
  void didUpdateWidget(covariant _LibraryToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filter.textQuery != _searchController.text) {
      _searchController.text = widget.filter.textQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeView = _viewById(widget.views, widget.activeViewId);
    final selectedViewId = activeView?.id ?? defaultAllGamesViewId;
    final isCustomView = activeView?.isDefault == false;
    final bv = BvThemeExtension.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: BvPanel(
        dense: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 760;
            final fieldWidth = compact ? constraints.maxWidth : 220.0;
            final searchWidth =
                compact
                    ? constraints.maxWidth
                    : (constraints.maxWidth * 0.25).clamp(280.0, 420.0);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: fieldWidth,
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedViewId,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: context.l10n.view,
                          prefixIcon: const Icon(Icons.view_column_outlined),
                        ),
                        items: [
                          for (final view in widget.views)
                            DropdownMenuItem(
                              value: view.id,
                              child: Text(
                                _localizedViewName(context, view),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: (id) {
                          if (id == null) return;
                          final view = _viewById(widget.views, id);
                          if (view == null) return;
                          ref
                              .read(libraryViewModelProvider.notifier)
                              .setTableState(LibraryTableState.fromView(view));
                        },
                      ),
                    ),
                    if (selectedViewId == defaultCompletedYearViewId)
                      SizedBox(
                        width: compact ? constraints.maxWidth : 150,
                        child: _CompletedYearSelector(filter: widget.filter),
                      ),
                    SizedBox(
                      width: searchWidth,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: context.l10n.search,
                          prefixIcon: const Icon(Icons.search),
                        ),
                        onChanged: (value) {
                          final current =
                              ref.read(libraryViewModelProvider).table;
                          ref
                              .read(libraryViewModelProvider.notifier)
                              .setTableState(
                                current.copyWith(
                                  filter: current.filter.copyWith(
                                    textQuery: value,
                                  ),
                                ),
                              );
                        },
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: widget.onToggleFilters,
                      icon: Icon(
                        widget.canUseFilterSidebar && widget.filtersVisible
                            ? Icons.filter_alt
                            : Icons.filter_alt_outlined,
                      ),
                      label: Text(
                        context.l10n.libraryFiltersCount(
                          widget.filter.activeCount,
                        ),
                      ),
                    ),
                    SegmentedButton<LibraryLayoutMode>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(
                          value: LibraryLayoutMode.table,
                          icon: const Icon(Icons.table_rows_outlined),
                          label: compact ? null : Text(context.l10n.table),
                          tooltip: context.l10n.table,
                        ),
                        ButtonSegment(
                          value: LibraryLayoutMode.gallery,
                          icon: const Icon(Icons.grid_view_outlined),
                          label: compact ? null : Text(context.l10n.gallery),
                          tooltip: context.l10n.gallery,
                        ),
                        ButtonSegment(
                          value: LibraryLayoutMode.list,
                          icon: const Icon(Icons.view_list_outlined),
                          label: compact ? null : Text(context.l10n.list),
                          tooltip: context.l10n.list,
                        ),
                      ],
                      selected: {widget.layoutMode},
                      onSelectionChanged: (selection) {
                        if (selection.isEmpty) return;
                        ref
                            .read(libraryViewModelProvider.notifier)
                            .setLayoutMode(selection.first);
                      },
                    ),
                    FilledButton.icon(
                      onPressed: () => context.go('/games/new'),
                      icon: const Icon(Icons.add),
                      label: Text(context.l10n.homeCreateGame),
                    ),
                  ],
                ),
                const SizedBox(height: BvSpacing.xs),
                Divider(color: bv.border),
                const SizedBox(height: BvSpacing.xs),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (widget.layoutMode == LibraryLayoutMode.table)
                      OutlinedButton.icon(
                        onPressed: () => _showColumnsDialog(context, ref),
                        icon: const Icon(Icons.view_week_outlined),
                        label: Text(context.l10n.columns),
                      ),
                    OutlinedButton.icon(
                      onPressed: () => _resetTableState(ref),
                      icon: const Icon(Icons.restart_alt),
                      label: Text(context.l10n.clear),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => _saveCurrentView(context, ref),
                      icon: const Icon(Icons.bookmark_add_outlined),
                      label: Text(context.l10n.saveView),
                    ),
                    PopupMenuButton<String>(
                      tooltip: context.l10n.libraryActions,
                      icon: const Icon(Icons.more_horiz),
                      onSelected: (value) {
                        if (value == 'csv') context.go('/import/notion-csv');
                        if (value == 'metadata') {
                          context.go('/metadata/bulk-import');
                        }
                        if (activeView == null) return;
                        if (value == 'update') {
                          _updateCurrentView(context, ref, activeView);
                        }
                        if (value == 'rename') {
                          _renameCurrentView(context, ref, activeView);
                        }
                        if (value == 'delete') {
                          _deleteCurrentView(context, ref, activeView);
                        }
                      },
                      itemBuilder:
                          (context) => [
                            PopupMenuItem(
                              value: 'csv',
                              child: Text(context.l10n.importCsv),
                            ),
                            PopupMenuItem(
                              value: 'metadata',
                              child: Text(context.l10n.importMetadata),
                            ),
                            if (isCustomView) ...[
                              const PopupMenuDivider(),
                              PopupMenuItem(
                                value: 'update',
                                child: Text(context.l10n.libraryUpdateView),
                              ),
                              PopupMenuItem(
                                value: 'rename',
                                child: Text(context.l10n.libraryRenameView),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(context.l10n.libraryDeleteView),
                              ),
                            ],
                          ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CompletedYearSelector extends ConsumerWidget {
  const _CompletedYearSelector({required this.filter});

  final LibraryFilterState filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentYear = DateTime.now().year;
    final selectedYear = filter.completedDateFrom?.year ?? currentYear;
    final years = [
      for (var year = currentYear + 1; year >= currentYear - 20; year--) year,
    ];
    final safeYear = years.contains(selectedYear) ? selectedYear : currentYear;

    return DropdownButtonFormField<int>(
      initialValue: safeYear,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: context.l10n.libraryYear,
        prefixIcon: const Icon(Icons.event_outlined),
      ),
      items: [
        for (final year in years)
          DropdownMenuItem(value: year, child: Text(year.toString())),
      ],
      onChanged: (year) {
        if (year == null) return;
        final current = ref.read(libraryViewModelProvider).table;
        ref
            .read(libraryViewModelProvider.notifier)
            .setTableState(
              current.copyWith(
                filter: current.filter.copyWith(
                  statuses: const {GameStatus.completed},
                  completedDateFrom: DateTime(year),
                  completedDateTo: DateTime(year, 12, 31),
                ),
              ),
            );
      },
    );
  }
}

class _ActiveFilterChips extends ConsumerWidget {
  const _ActiveFilterChips({
    required this.filter,
    required this.platforms,
    required this.genres,
  });

  final LibraryFilterState filter;
  final List<LibraryCatalogItem> platforms;
  final List<LibraryCatalogItem> genres;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (filter.isEmpty) return const SizedBox.shrink();

    final chips = <Widget>[];
    if (filter.statuses.isNotEmpty) {
      chips.add(
        _chip(
          context.l10n.libraryFilterStatus(
            filter.statuses.map(context.l10n.gameStatusLabel).join(', '),
          ),
        ),
      );
    }
    if (filter.platformIds.isNotEmpty) {
      chips.add(
        _chip(
          context.l10n.libraryFilterPlatform(
            _namesForIds(filter.platformIds, platforms),
          ),
        ),
      );
    }
    if (filter.genreIds.isNotEmpty) {
      chips.add(
        _chip(
          context.l10n.libraryFilterGenre(
            _namesForIds(filter.genreIds, genres),
          ),
        ),
      );
    }
    if (filter.textQuery.trim().isNotEmpty) {
      chips.add(
        _chip(context.l10n.libraryFilterSearch(filter.textQuery.trim())),
      );
    }
    if (filter.missingRating) chips.add(_chip(context.l10n.missingRating));
    if (filter.missingPlatform) chips.add(_chip(context.l10n.missingPlatform));
    if (filter.missingGenre) chips.add(_chip(context.l10n.missingGenre));
    if (filter.missingCompletedDate) {
      chips.add(_chip(context.l10n.libraryMissingCompletedDate));
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(spacing: 8, runSpacing: 8, children: chips),
      ),
    );
  }

  Widget _chip(String label) {
    return BvChip(label: label, tone: BvChipTone.primary);
  }
}
