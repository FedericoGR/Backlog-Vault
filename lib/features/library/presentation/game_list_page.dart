import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/bv_breakpoints.dart';
import '../../../core/design_system/bv_chip.dart';
import '../../../core/design_system/bv_empty_state.dart';
import '../../../core/design_system/bv_error_state.dart';
import '../../../core/design_system/bv_feedback.dart';
import '../../../core/design_system/bv_loading_state.dart';
import '../../../core/design_system/bv_panel.dart';
import '../../../core/design_system/bv_spacing.dart';
import '../../../core/design_system/bv_theme_extension.dart';
import '../../../core/formatting/date_formatters.dart';
import '../../../l10n/domain_localizations.dart';
import '../../../l10n/l10n.dart';
import '../../catalogs/application/catalog_controller.dart';
import '../application/library_default_views.dart';
import '../application/library_responsive_layout.dart';
import '../application/library_providers.dart';
import '../application/library_table_state.dart';
import '../application/library_view_model.dart';
import '../domain/game_status.dart';
import '../domain/library_column_config.dart';
import '../domain/library_filter_state.dart';
import '../domain/library_game_row.dart';
import '../domain/library_layout_mode.dart';
import '../domain/library_sort_state.dart';
import '../domain/rating.dart';
import '../domain/saved_library_view.dart';
import 'widgets/library_catalog_widgets.dart';
import 'widgets/library_cover_thumbnail.dart';

part 'widgets/library_results.dart';
part 'widgets/library_toolbar.dart';
part 'widgets/library_filter_dialogs.dart';
part 'widgets/library_actions.dart';

/// Responsive library workspace backed by the single [LibraryViewModel] state.
class GameListPage extends ConsumerStatefulWidget {
  const GameListPage({super.key});

  @override
  ConsumerState<GameListPage> createState() => _GameListPageState();
}

class _GameListPageState extends ConsumerState<GameListPage> {
  bool _selectionMode = false;
  bool _filtersVisible = true;
  final _selectedEntryIds = <String>{};

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(catalogControllerProvider).seedDefaultsIfEmpty(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final rows = ref.watch(libraryRowsProvider);
    final platforms = ref
        .watch(platformCatalogProvider)
        .maybeWhen(
          data:
              (items) =>
                  items
                      .map(
                        (platform) => LibraryCatalogItem(
                          id: platform.id,
                          name: platform.name,
                        ),
                      )
                      .toList(),
          orElse: () => const <LibraryCatalogItem>[],
        );
    final genres = ref
        .watch(genreCatalogProvider)
        .maybeWhen(
          data:
              (items) =>
                  items
                      .map(
                        (genre) =>
                            LibraryCatalogItem(id: genre.id, name: genre.name),
                      )
                      .toList(),
          orElse: () => const <LibraryCatalogItem>[],
        );
    final customViews = ref
        .watch(customLibraryViewsProvider)
        .maybeWhen(
          data: (items) => items,
          orElse: () => const <SavedLibraryView>[],
        );
    final defaultViews = buildDefaultLibraryViews(platforms: platforms);
    final views = [...defaultViews, ...customViews];
    final viewState = ref.watch(libraryViewModelProvider);
    final tableState = viewState.table;
    final layoutMode = viewState.layoutMode;
    final processor = ref.watch(libraryTableProcessorProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            tooltip:
                _selectionMode
                    ? l10n.libraryExitSelection
                    : l10n.librarySelectMultiple,
            onPressed: () {
              setState(() {
                _selectionMode = !_selectionMode;
                if (!_selectionMode) _selectedEntryIds.clear();
              });
            },
            icon: Icon(
              _selectionMode ? Icons.close : Icons.checklist_rtl_outlined,
            ),
          ),
        ],
      ),
      body: rows.when(
        data: (items) {
          final result = processor.apply(
            rows: items,
            filter: tableState.filter,
            sort: tableState.sort,
          );
          final visibleIds =
              result.rows.map((row) => row.libraryEntryId).toSet();
          final allIds = items.map((row) => row.libraryEntryId).toSet();
          if (_selectionMode) {
            _selectedEntryIds.removeWhere((id) => !allIds.contains(id));
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= BvBreakpoints.libraryWide;
              final showFilterSidebar = shouldShowLibraryFilterSidebar(
                width: constraints.maxWidth,
                layoutMode: layoutMode,
                filtersVisible: _filtersVisible,
              );
              final content = Column(
                children: [
                  _LibraryToolbar(
                    views: views,
                    customViews: customViews,
                    activeViewId: tableState.activeViewId,
                    filter: tableState.filter,
                    platforms: platforms,
                    genres: genres,
                    isWide: isWide,
                    layoutMode: layoutMode,
                    filtersVisible: _filtersVisible,
                    canUseFilterSidebar: showFilterSidebar,
                    onToggleFilters:
                        constraints.maxWidth >= BvBreakpoints.desktop
                            ? () => setState(
                              () => _filtersVisible = !_filtersVisible,
                            )
                            : () => _showFiltersPanel(
                              context,
                              ref,
                              platforms,
                              genres,
                            ),
                  ),
                  _ActiveFilterChips(
                    filter: tableState.filter,
                    platforms: platforms,
                    genres: genres,
                  ),
                  LibrarySummaryStrip(summary: result.summary),
                  if (_selectionMode)
                    LibrarySelectionBar(
                      selectedCount: _selectedEntryIds.length,
                      visibleCount: visibleIds.length,
                      totalCount: allIds.length,
                      onSelectVisible:
                          () => setState(
                            () => _selectedEntryIds.addAll(visibleIds),
                          ),
                      onSelectAll:
                          () =>
                              setState(() => _selectedEntryIds.addAll(allIds)),
                      onClear: () => setState(() => _selectedEntryIds.clear()),
                      onDelete:
                          _selectedEntryIds.isEmpty
                              ? null
                              : () => _confirmDeleteSelected(context),
                    ),
                  Expanded(
                    child: _LibraryContent(
                      items: items,
                      rows: result.rows,
                      layoutMode: layoutMode,
                      isWide: isWide,
                      selectionMode: _selectionMode,
                      selectedIds: _selectedEntryIds,
                      onSelectionChanged: _setRowSelected,
                    ),
                  ),
                ],
              );

              if (!showFilterSidebar) return content;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 0, 16),
                    child: LibraryFilterSidebar(
                      filter: tableState.filter,
                      platforms: platforms,
                      genres: genres,
                      onEditFilters:
                          () => _showFiltersPanel(
                            context,
                            ref,
                            platforms,
                            genres,
                          ),
                      onClearFilters: () => _resetTableState(ref),
                      onToggleStatus: _toggleStatusFilter,
                      onTogglePlatform: _togglePlatformFilter,
                      onToggleGenre: _toggleGenreFilter,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: content),
                ],
              );
            },
          );
        },
        loading: () => BvLoadingState(label: l10n.libraryLoading),
        error:
            (error, stackTrace) => BvErrorState(
              title: l10n.libraryLoadError,
              message: l10n.unexpectedErrorMessage,
              retryLabel: l10n.retry,
              onRetry: () => ref.invalidate(libraryRowsProvider),
            ),
      ),
    );
  }

  void _setRowSelected(String entryId, bool selected) {
    setState(() {
      if (selected) {
        _selectedEntryIds.add(entryId);
      } else {
        _selectedEntryIds.remove(entryId);
      }
    });
  }

  void _toggleStatusFilter(GameStatus status) {
    final current = ref.read(libraryViewModelProvider).table;
    final statuses = {...current.filter.statuses};
    statuses.contains(status) ? statuses.remove(status) : statuses.add(status);
    ref
        .read(libraryViewModelProvider.notifier)
        .setTableState(
          current.copyWith(filter: current.filter.copyWith(statuses: statuses)),
        );
  }

  void _togglePlatformFilter(String platformId) {
    final current = ref.read(libraryViewModelProvider).table;
    final platformIds = {...current.filter.platformIds};
    platformIds.contains(platformId)
        ? platformIds.remove(platformId)
        : platformIds.add(platformId);
    ref
        .read(libraryViewModelProvider.notifier)
        .setTableState(
          current.copyWith(
            filter: current.filter.copyWith(platformIds: platformIds),
          ),
        );
  }

  void _toggleGenreFilter(String genreId) {
    final current = ref.read(libraryViewModelProvider).table;
    final genreIds = {...current.filter.genreIds};
    genreIds.contains(genreId)
        ? genreIds.remove(genreId)
        : genreIds.add(genreId);
    ref
        .read(libraryViewModelProvider.notifier)
        .setTableState(
          current.copyWith(filter: current.filter.copyWith(genreIds: genreIds)),
        );
  }

  Future<void> _confirmDeleteSelected(BuildContext context) async {
    final l10n = context.l10n;
    final count = _selectedEntryIds.length;
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  scrollable: true,
                  title: Text(l10n.libraryDeleteSelectedTitle),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.libraryDeleteSelectedMessage(count)),
                      const SizedBox(height: 12),
                      Text(l10n.libraryTypeDeleteConfirmation),
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: l10n.libraryConfirmation,
                        ),
                        onChanged: (_) => setDialogState(() {}),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(l10n.cancel),
                    ),
                    FilledButton(
                      onPressed:
                          controller.text.trim().toUpperCase() ==
                                  l10n.libraryDeleteKeyword
                              ? () => Navigator.pop(context, true)
                              : null,
                      child: Text(l10n.libraryDeleteSelected),
                    ),
                  ],
                ),
          ),
    );
    controller.dispose();
    if (confirmed != true || !mounted) return;

    await ref
        .read(libraryViewModelProvider.notifier)
        .deleteGames(_selectedEntryIds);
    ref.invalidate(libraryRowsProvider);
    if (!mounted) return;
    setState(() {
      _selectedEntryIds.clear();
      _selectionMode = false;
    });
  }
}
