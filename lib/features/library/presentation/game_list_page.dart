import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/formatting/date_formatters.dart';
import '../../catalogs/data/catalog_repository.dart';
import '../../games/data/game_repository.dart';
import '../application/library_default_views.dart';
import '../application/library_table_providers.dart';
import '../application/library_table_state.dart';
import '../data/library_query_repository.dart';
import '../data/saved_library_view_repository.dart';
import '../domain/game_status.dart';
import '../domain/library_column_config.dart';
import '../domain/library_filter_state.dart';
import '../domain/library_game_row.dart';
import '../domain/library_layout_mode.dart';
import '../domain/library_sort_state.dart';
import '../domain/library_table_summary.dart';
import '../domain/rating.dart';
import '../domain/saved_library_view.dart';
import 'widgets/library_cover_thumbnail.dart';

class GameListPage extends ConsumerStatefulWidget {
  const GameListPage({super.key});

  @override
  ConsumerState<GameListPage> createState() => _GameListPageState();
}

class _GameListPageState extends ConsumerState<GameListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(catalogRepositoryProvider).seedDefaultsIfEmpty(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = ref.watch(libraryRowsProvider);
    final platforms = ref
        .watch(platformsProvider)
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
        .watch(genresProvider)
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
    final tableState = ref.watch(libraryTableStateProvider);
    final layoutMode = ref.watch(libraryLayoutModeProvider);
    final processor = ref.watch(libraryTableProcessorProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Backlog Vault')),
      body: rows.when(
        data: (items) {
          final result = processor.apply(
            rows: items,
            filter: tableState.filter,
            sort: tableState.sort,
          );

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              return Column(
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
                  ),
                  _ActiveFilterChips(
                    filter: tableState.filter,
                    platforms: platforms,
                    genres: genres,
                  ),
                  _LibrarySummary(summary: result.summary),
                  Expanded(
                    child:
                        items.isEmpty
                            ? const _EmptyLibraryState()
                            : result.rows.isEmpty
                            ? const _EmptyFilteredState()
                            : layoutMode == LibraryLayoutMode.gallery
                            ? _LibraryGalleryGrid(rows: result.rows)
                            : isWide
                            ? _LibraryDataTable(rows: result.rows)
                            : _LibraryCardList(rows: result.rows),
                  ),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _ErrorState(message: error.toString()),
      ),
    );
  }
}

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
  });

  final List<SavedLibraryView> views;
  final List<SavedLibraryView> customViews;
  final String activeViewId;
  final LibraryFilterState filter;
  final List<LibraryCatalogItem> platforms;
  final List<LibraryCatalogItem> genres;
  final bool isWide;
  final LibraryLayoutMode layoutMode;

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

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: widget.isWide ? 220 : MediaQuery.sizeOf(context).width - 32,
            child: DropdownButtonFormField<String>(
              initialValue: selectedViewId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Vista',
                prefixIcon: Icon(Icons.view_column_outlined),
              ),
              items: [
                for (final view in widget.views)
                  DropdownMenuItem(
                    value: view.id,
                    child: Text(view.name, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (id) {
                if (id == null) return;
                final view = _viewById(widget.views, id);
                if (view == null) return;
                ref
                    .read(libraryTableStateProvider.notifier)
                    .setTableState(LibraryTableState.fromView(view));
              },
            ),
          ),
          if (selectedViewId == defaultCompletedYearViewId)
            SizedBox(
              width:
                  widget.isWide ? 150 : MediaQuery.sizeOf(context).width - 32,
              child: _CompletedYearSelector(filter: widget.filter),
            ),
          SizedBox(
            width: widget.isWide ? 320 : MediaQuery.sizeOf(context).width - 32,
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                final current = ref.read(libraryTableStateProvider);
                ref
                    .read(libraryTableStateProvider.notifier)
                    .setTableState(
                      current.copyWith(
                        filter: current.filter.copyWith(textQuery: value),
                      ),
                    );
              },
            ),
          ),
          OutlinedButton.icon(
            onPressed:
                () => _showFiltersDialog(
                  context,
                  ref,
                  widget.platforms,
                  widget.genres,
                ),
            icon: const Icon(Icons.filter_alt_outlined),
            label: Text('Filtros (${widget.filter.activeCount})'),
          ),
          SegmentedButton<LibraryLayoutMode>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                value: LibraryLayoutMode.table,
                icon: Icon(Icons.table_rows_outlined),
                label: Text('Tabla'),
              ),
              ButtonSegment(
                value: LibraryLayoutMode.gallery,
                icon: Icon(Icons.grid_view_outlined),
                label: Text('Galería'),
              ),
            ],
            selected: {widget.layoutMode},
            onSelectionChanged: (selection) {
              if (selection.isEmpty) return;
              ref
                  .read(libraryLayoutModeProvider.notifier)
                  .setMode(selection.first);
            },
          ),
          OutlinedButton.icon(
            onPressed: () => _showColumnsDialog(context, ref),
            icon: const Icon(Icons.view_week_outlined),
            label: const Text('Columnas'),
          ),
          OutlinedButton.icon(
            onPressed: () => _resetTableState(ref),
            icon: const Icon(Icons.restart_alt),
            label: const Text('Limpiar'),
          ),
          FilledButton.icon(
            onPressed: () => _saveCurrentView(context, ref),
            icon: const Icon(Icons.bookmark_add_outlined),
            label: const Text('Guardar vista'),
          ),
          if (isCustomView)
            PopupMenuButton<String>(
              tooltip: 'Opciones de vista',
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
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
                  (context) => const [
                    PopupMenuItem(
                      value: 'update',
                      child: Text('Actualizar vista'),
                    ),
                    PopupMenuItem(value: 'rename', child: Text('Renombrar')),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Eliminar vista'),
                    ),
                  ],
            ),
          OutlinedButton.icon(
            onPressed: () => context.go('/import/notion-csv'),
            icon: const Icon(Icons.upload_file_outlined),
            label: const Text('Importar CSV'),
          ),
          OutlinedButton.icon(
            onPressed: () => context.go('/metadata/bulk-import'),
            icon: const Icon(Icons.auto_fix_high_outlined),
            label: const Text('Importar metadata'),
          ),
          FilledButton.icon(
            onPressed: () => context.go('/games/new'),
            icon: const Icon(Icons.add),
            label: const Text('Crear juego'),
          ),
        ],
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
      decoration: const InputDecoration(
        labelText: 'Año',
        prefixIcon: Icon(Icons.event_outlined),
      ),
      items: [
        for (final year in years)
          DropdownMenuItem(value: year, child: Text(year.toString())),
      ],
      onChanged: (year) {
        if (year == null) return;
        final current = ref.read(libraryTableStateProvider);
        ref
            .read(libraryTableStateProvider.notifier)
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
        _chip('Estado: ${filter.statuses.map((s) => s.label).join(', ')}'),
      );
    }
    if (filter.platformIds.isNotEmpty) {
      chips.add(
        _chip('Plataforma: ${_namesForIds(filter.platformIds, platforms)}'),
      );
    }
    if (filter.genreIds.isNotEmpty) {
      chips.add(_chip('Género: ${_namesForIds(filter.genreIds, genres)}'));
    }
    if (filter.textQuery.trim().isNotEmpty) {
      chips.add(_chip('Búsqueda: ${filter.textQuery.trim()}'));
    }
    if (filter.missingRating) chips.add(_chip('Sin puntaje'));
    if (filter.missingPlatform) chips.add(_chip('Sin plataforma'));
    if (filter.missingGenre) chips.add(_chip('Sin género'));
    if (filter.missingCompletedDate) chips.add(_chip('Sin fecha completado'));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(spacing: 8, runSpacing: 8, children: chips),
      ),
    );
  }

  Widget _chip(String label) {
    return Chip(label: Text(label));
  }
}

class _LibrarySummary extends StatelessWidget {
  const _LibrarySummary({required this.summary});

  final LibraryTableSummary summary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _summaryChip('Juegos', summary.visibleGames.toString()),
            _summaryChip('Completados', summary.completedCount.toString()),
            _summaryChip('Horas', summary.totalHours.toStringAsFixed(1)),
            _summaryChip(
              'Promedio',
              summary.averageRating == null
                  ? '-'
                  : summary.averageRating!.toStringAsFixed(1),
            ),
            _summaryChip('Sin puntaje', summary.missingRating.toString()),
            _summaryChip('Sin plataforma', summary.missingPlatform.toString()),
            _summaryChip('Sin género', summary.missingGenre.toString()),
          ],
        ),
      ),
    );
  }

  Widget _summaryChip(String label, String value) {
    return InputChip(onPressed: null, label: Text('$label: $value'));
  }
}

class _LibraryDataTable extends ConsumerWidget {
  const _LibraryDataTable({required this.rows});

  final List<LibraryGameRow> rows;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(libraryTableStateProvider);
    final visibleColumns = state.columnConfig.visibleColumns;
    final sortedColumnIndex = visibleColumns.indexWhere(
      (column) => _sortFieldForColumn(column) == state.sort.field,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: DataTable2(
        minWidth: 1150,
        fixedLeftColumns: 1,
        sortColumnIndex: sortedColumnIndex == -1 ? null : sortedColumnIndex,
        sortAscending: state.sort.ascending,
        columns: [
          for (final column in visibleColumns)
            DataColumn2(
              label: Text(column.label),
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
          const DataColumn2(label: Text('Acciones'), fixedWidth: 132),
        ],
        rows: [
          for (final row in rows)
            DataRow(
              cells: [
                for (final column in visibleColumns)
                  DataCell(
                    _tableCell(context, row, column),
                    onTap:
                        column == LibraryColumnKey.title
                            ? () => context.go('/games/${row.libraryEntryId}')
                            : null,
                  ),
                DataCell(LibraryRowActions(row: row)),
              ],
            ),
        ],
      ),
    );
  }
}

class _LibraryCardList extends ConsumerWidget {
  const _LibraryCardList({required this.rows});

  final List<LibraryGameRow> rows;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      itemCount: rows.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final row = rows[index];
        return ListTile(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          leading: LibraryCoverThumbnail(
            localPath: row.selectedCoverLocalPath,
            width: 48,
            height: 64,
          ),
          title: Text(row.title),
          subtitle: Text(
            [
              row.status.label,
              if (row.platforms.isNotEmpty)
                _names(row.platforms.map((p) => p.name)),
              if (row.genres.isNotEmpty) _names(row.genres.map((g) => g.name)),
              formatStarRating(row.personalRating),
              if (row.hoursPlayed != null)
                '${row.hoursPlayed!.toStringAsFixed(1)} h',
            ].join(' · '),
          ),
          onTap: () => context.go('/games/${row.libraryEntryId}'),
          trailing: LibraryRowActions(row: row, compact: true),
        );
      },
    );
  }
}

class _LibraryGalleryGrid extends StatelessWidget {
  const _LibraryGalleryGrid({required this.rows});

  final List<LibraryGameRow> rows;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
        mainAxisExtent: 390,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: rows.length,
      itemBuilder: (context, index) => _LibraryGameCard(row: rows[index]),
    );
  }
}

class _LibraryGameCard extends StatelessWidget {
  const _LibraryGameCard({required this.row});

  final LibraryGameRow row;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => context.go('/games/${row.libraryEntryId}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 210,
              width: double.infinity,
              child: LayoutBuilder(
                builder:
                    (context, constraints) => LibraryCoverThumbnail(
                      localPath: row.selectedCoverLocalPath,
                      width: constraints.maxWidth,
                      height: 210,
                      borderRadius: 0,
                    ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
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
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        LibraryRowActions(row: row, compact: true),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _compactChip(context, row.status.label),
                        if (row.personalRating != null)
                          _compactChip(
                            context,
                            formatStarRating(row.personalRating),
                          ),
                        if (row.hoursPlayed != null)
                          _compactChip(
                            context,
                            '${row.hoursPlayed!.toStringAsFixed(1)} h',
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _metadataLine(
                      context,
                      Icons.sports_esports_outlined,
                      _limitedNames(
                        row.platforms.map((platform) => platform.name),
                      ),
                    ),
                    const SizedBox(height: 4),
                    _metadataLine(
                      context,
                      Icons.category_outlined,
                      _limitedNames(row.genres.map((genre) => genre.name)),
                    ),
                    if (row.completedAt != null) ...[
                      const SizedBox(height: 4),
                      _metadataLine(
                        context,
                        Icons.emoji_events_outlined,
                        formatVisibleDate(row.completedAt),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _compactChip(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Theme.of(context).colorScheme.secondaryContainer,
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }

  Widget _metadataLine(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
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
              tooltip: 'Abrir detalle',
              onPressed: () => context.go('/games/${row.libraryEntryId}'),
              icon: const Icon(Icons.open_in_new),
            ),
            IconButton(
              tooltip: 'Editar',
              onPressed: () => context.go('/games/${row.libraryEntryId}/edit'),
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: 'Eliminar',
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
        tooltip: 'Acciones',
        onSelected: (value) {
          if (value == 'open') context.go('/games/${row.libraryEntryId}');
          if (value == 'edit') context.go('/games/${row.libraryEntryId}/edit');
          if (value == 'delete') _confirmDelete(context, ref, row);
        },
        itemBuilder:
            (context) => const [
              PopupMenuItem(value: 'open', child: Text('Abrir detalle')),
              PopupMenuItem(value: 'edit', child: Text('Editar')),
              PopupMenuItem(value: 'delete', child: Text('Eliminar')),
            ],
      ),
    );
  }
}

class _FiltersDialog extends StatefulWidget {
  const _FiltersDialog({
    required this.initialFilter,
    required this.platforms,
    required this.genres,
  });

  final LibraryFilterState initialFilter;
  final List<LibraryCatalogItem> platforms;
  final List<LibraryCatalogItem> genres;

  @override
  State<_FiltersDialog> createState() => _FiltersDialogState();
}

class _FiltersDialogState extends State<_FiltersDialog> {
  late Set<GameStatus> _statuses;
  late Set<String> _platformIds;
  late Set<String> _genreIds;
  int? _minRating;
  int? _maxRating;
  DateTime? _releaseDateFrom;
  DateTime? _releaseDateTo;
  DateTime? _completedDateFrom;
  DateTime? _completedDateTo;
  late bool _hasRating;
  late bool _missingRating;
  late bool _hasPlatform;
  late bool _missingPlatform;
  late bool _hasGenre;
  late bool _missingGenre;
  late bool _hasCompletedDate;
  late bool _missingCompletedDate;
  late final TextEditingController _minHoursController;
  late final TextEditingController _maxHoursController;
  late final TextEditingController _typeController;

  @override
  void initState() {
    super.initState();
    final filter = widget.initialFilter;
    _statuses = {...filter.statuses};
    _platformIds = {...filter.platformIds};
    _genreIds = {...filter.genreIds};
    _minRating = filter.minRating;
    _maxRating = filter.maxRating;
    _releaseDateFrom = filter.releaseDateFrom;
    _releaseDateTo = filter.releaseDateTo;
    _completedDateFrom = filter.completedDateFrom;
    _completedDateTo = filter.completedDateTo;
    _hasRating = filter.hasRating;
    _missingRating = filter.missingRating;
    _hasPlatform = filter.hasPlatform;
    _missingPlatform = filter.missingPlatform;
    _hasGenre = filter.hasGenre;
    _missingGenre = filter.missingGenre;
    _hasCompletedDate = filter.hasCompletedDate;
    _missingCompletedDate = filter.missingCompletedDate;
    _minHoursController = TextEditingController(
      text: filter.minHours?.toString() ?? '',
    );
    _maxHoursController = TextEditingController(
      text: filter.maxHours?.toString() ?? '',
    );
    _typeController = TextEditingController(text: filter.type ?? '');
  }

  @override
  void dispose() {
    _minHoursController.dispose();
    _maxHoursController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filtros'),
      content: SizedBox(
        width: 720,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _sectionTitle(context, 'Estado'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final status in GameStatus.values)
                    FilterChip(
                      label: Text(status.label),
                      selected: _statuses.contains(status),
                      onSelected: (selected) {
                        setState(() {
                          selected
                              ? _statuses.add(status)
                              : _statuses.remove(status);
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
              _sectionTitle(context, 'Plataformas'),
              _catalogChips(widget.platforms, _platformIds),
              const SizedBox(height: 16),
              _sectionTitle(context, 'Géneros'),
              _catalogChips(widget.genres, _genreIds),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ratingDropdown(
                      label: 'Puntaje mínimo',
                      value: _minRating,
                      onChanged: (value) => setState(() => _minRating = value),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ratingDropdown(
                      label: 'Puntaje máximo',
                      value: _maxRating,
                      onChanged: (value) => setState(() => _maxRating = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _minHoursController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Horas mínimas',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _maxHoursController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Horas máximas',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _typeController,
                decoration: const InputDecoration(labelText: 'Tipo'),
              ),
              const SizedBox(height: 12),
              _DateFilterTile(
                label: 'Salida desde',
                value: _releaseDateFrom,
                onChanged: (value) => setState(() => _releaseDateFrom = value),
              ),
              _DateFilterTile(
                label: 'Salida hasta',
                value: _releaseDateTo,
                onChanged: (value) => setState(() => _releaseDateTo = value),
              ),
              _DateFilterTile(
                label: 'Completado desde',
                value: _completedDateFrom,
                onChanged:
                    (value) => setState(() => _completedDateFrom = value),
              ),
              _DateFilterTile(
                label: 'Completado hasta',
                value: _completedDateTo,
                onChanged: (value) => setState(() => _completedDateTo = value),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 0,
                children: [
                  _flag(
                    'Con puntaje',
                    _hasRating,
                    (value) => _hasRating = value,
                  ),
                  _flag(
                    'Sin puntaje',
                    _missingRating,
                    (value) => _missingRating = value,
                  ),
                  _flag(
                    'Con plataforma',
                    _hasPlatform,
                    (value) => _hasPlatform = value,
                  ),
                  _flag(
                    'Sin plataforma',
                    _missingPlatform,
                    (value) => _missingPlatform = value,
                  ),
                  _flag('Con género', _hasGenre, (value) => _hasGenre = value),
                  _flag(
                    'Sin género',
                    _missingGenre,
                    (value) => _missingGenre = value,
                  ),
                  _flag(
                    'Con fecha completado',
                    _hasCompletedDate,
                    (value) => _hasCompletedDate = value,
                  ),
                  _flag(
                    'Sin fecha completado',
                    _missingCompletedDate,
                    (value) => _missingCompletedDate = value,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, const LibraryFilterState()),
          child: const Text('Limpiar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _buildFilter()),
          child: const Text('Aplicar'),
        ),
      ],
    );
  }

  Widget _catalogChips(
    List<LibraryCatalogItem> items,
    Set<String> selectedIds,
  ) {
    if (items.isEmpty) return const Text('No hay opciones disponibles.');
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in items)
          FilterChip(
            label: Text(item.name),
            selected: selectedIds.contains(item.id),
            onSelected: (selected) {
              setState(() {
                selected
                    ? selectedIds.add(item.id)
                    : selectedIds.remove(item.id);
              });
            },
          ),
      ],
    );
  }

  Widget _flag(String label, bool value, ValueChanged<bool> onChanged) {
    return FilterChip(
      label: Text(label),
      selected: value,
      onSelected: (selected) => setState(() => onChanged(selected)),
    );
  }

  LibraryFilterState _buildFilter() {
    return widget.initialFilter.copyWith(
      statuses: _statuses,
      platformIds: _platformIds,
      genreIds: _genreIds,
      minRating: _minRating,
      maxRating: _maxRating,
      releaseDateFrom: _releaseDateFrom,
      releaseDateTo: _releaseDateTo,
      completedDateFrom: _completedDateFrom,
      completedDateTo: _completedDateTo,
      minHours: _parseDouble(_minHoursController.text),
      maxHours: _parseDouble(_maxHoursController.text),
      type: _blankToNull(_typeController.text),
      hasRating: _hasRating,
      missingRating: _missingRating,
      hasPlatform: _hasPlatform,
      missingPlatform: _missingPlatform,
      hasGenre: _hasGenre,
      missingGenre: _missingGenre,
      hasCompletedDate: _hasCompletedDate,
      missingCompletedDate: _missingCompletedDate,
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _DateFilterTile extends StatelessWidget {
  const _DateFilterTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(formatVisibleDate(value)),
      trailing: Wrap(
        children: [
          IconButton(
            tooltip: 'Limpiar fecha',
            onPressed: value == null ? null : () => onChanged(null),
            icon: const Icon(Icons.clear),
          ),
          IconButton(
            tooltip: 'Elegir fecha',
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: value ?? DateTime.now(),
                firstDate: DateTime(1970),
                lastDate: DateTime(2100),
              );
              if (picked != null) onChanged(picked);
            },
            icon: const Icon(Icons.calendar_today_outlined),
          ),
        ],
      ),
    );
  }
}

class _ColumnsDialog extends StatefulWidget {
  const _ColumnsDialog({required this.initialConfig});

  final LibraryColumnConfig initialConfig;

  @override
  State<_ColumnsDialog> createState() => _ColumnsDialogState();
}

class _ColumnsDialogState extends State<_ColumnsDialog> {
  late LibraryColumnConfig _config;

  @override
  void initState() {
    super.initState();
    _config = widget.initialConfig;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Columnas visibles'),
      content: SizedBox(
        width: 360,
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final column in LibraryColumnConfig.allColumns)
              CheckboxListTile(
                value: _config.isVisible(column),
                onChanged:
                    column == LibraryColumnKey.title
                        ? null
                        : (value) =>
                            setState(() => _config = _config.toggle(column)),
                title: Text(column.label),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _config),
          child: const Text('Aplicar'),
        ),
      ],
    );
  }
}

class _EmptyLibraryState extends StatelessWidget {
  const _EmptyLibraryState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.library_add_outlined, size: 48),
            const SizedBox(height: 16),
            Text(
              'Todavía no hay juegos en tu biblioteca.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.go('/games/new'),
              icon: const Icon(Icons.add),
              label: const Text('Crear primer juego'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFilteredState extends ConsumerWidget {
  const _EmptyFilteredState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off_outlined, size: 48),
          const SizedBox(height: 16),
          Text(
            'No hay juegos que coincidan con la vista actual.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _resetTableState(ref),
            icon: const Icon(Icons.restart_alt),
            label: const Text('Limpiar filtros'),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text('No se pudo cargar la biblioteca.\n$message'),
      ),
    );
  }
}

Future<void> _showFiltersDialog(
  BuildContext context,
  WidgetRef ref,
  List<LibraryCatalogItem> platforms,
  List<LibraryCatalogItem> genres,
) async {
  final current = ref.read(libraryTableStateProvider);
  final result = await showDialog<LibraryFilterState>(
    context: context,
    builder:
        (context) => _FiltersDialog(
          initialFilter: current.filter,
          platforms: platforms,
          genres: genres,
        ),
  );
  if (result == null) return;
  ref
      .read(libraryTableStateProvider.notifier)
      .setTableState(current.copyWith(filter: result));
}

Future<void> _showColumnsDialog(BuildContext context, WidgetRef ref) async {
  final current = ref.read(libraryTableStateProvider);
  final result = await showDialog<LibraryColumnConfig>(
    context: context,
    builder: (context) => _ColumnsDialog(initialConfig: current.columnConfig),
  );
  if (result == null) return;
  ref
      .read(libraryTableStateProvider.notifier)
      .setTableState(current.copyWith(columnConfig: result));
}

Future<void> _saveCurrentView(BuildContext context, WidgetRef ref) async {
  final name = await _askViewName(context, title: 'Guardar vista');
  if (name == null) return;
  final state = ref.read(libraryTableStateProvider);
  final id = await ref
      .read(savedLibraryViewRepositoryProvider)
      .create(
        name: name,
        filter: state.filter,
        sort: state.sort,
        columnConfig: state.columnConfig,
      );
  ref
      .read(libraryTableStateProvider.notifier)
      .setTableState(state.copyWith(activeViewId: id));
}

Future<void> _updateCurrentView(
  BuildContext context,
  WidgetRef ref,
  SavedLibraryView view,
) async {
  final state = ref.read(libraryTableStateProvider);
  await ref
      .read(savedLibraryViewRepositoryProvider)
      .update(
        view.copyWith(
          filter: state.filter,
          sort: state.sort,
          columnConfig: state.columnConfig,
        ),
      );
  if (context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Vista actualizada.')));
  }
}

Future<void> _renameCurrentView(
  BuildContext context,
  WidgetRef ref,
  SavedLibraryView view,
) async {
  final name = await _askViewName(
    context,
    title: 'Renombrar vista',
    initialName: view.name,
  );
  if (name == null) return;
  await ref
      .read(savedLibraryViewRepositoryProvider)
      .update(view.copyWith(name: name));
}

Future<void> _deleteCurrentView(
  BuildContext context,
  WidgetRef ref,
  SavedLibraryView view,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('Eliminar vista'),
          content: Text('Se eliminará la vista "${view.name}".'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar'),
            ),
          ],
        ),
  );
  if (confirmed != true) return;
  await ref.read(savedLibraryViewRepositoryProvider).softDelete(view.id);
  _resetTableState(ref);
}

Future<String?> _askViewName(
  BuildContext context, {
  required String title,
  String? initialName,
}) async {
  final controller = TextEditingController(text: initialName ?? '');
  final result = await showDialog<String>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isEmpty) return;
                Navigator.pop(context, name);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
  );
  controller.dispose();
  return result;
}

Future<void> _confirmDelete(
  BuildContext context,
  WidgetRef ref,
  LibraryGameRow row,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('Eliminar juego'),
          content: Text('Se ocultará "${row.title}" de la biblioteca.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar'),
            ),
          ],
        ),
  );
  if (confirmed != true || !context.mounted) return;
  await ref.read(gameRepositoryProvider).softDelete(row.libraryEntryId);
}

Widget _tableCell(
  BuildContext context,
  LibraryGameRow row,
  LibraryColumnKey column,
) {
  if (column == LibraryColumnKey.cover) {
    return Center(
      child: LibraryCoverThumbnail(
        localPath: row.selectedCoverLocalPath,
        width: 36,
        height: 48,
      ),
    );
  }

  final text = switch (column) {
    LibraryColumnKey.title => row.title,
    LibraryColumnKey.status => row.status.label,
    LibraryColumnKey.platforms => _names(
      row.platforms.map((platform) => platform.name),
    ),
    LibraryColumnKey.genres => _names(row.genres.map((genre) => genre.name)),
    LibraryColumnKey.rating => formatStarRating(row.personalRating),
    LibraryColumnKey.releaseDate => formatVisibleDate(row.releaseDate),
    LibraryColumnKey.completedDate => formatVisibleDate(row.completedAt),
    LibraryColumnKey.hours =>
      row.hoursPlayed == null ? '-' : row.hoursPlayed!.toStringAsFixed(1),
    LibraryColumnKey.type => row.type,
    LibraryColumnKey.notes =>
      row.personalNotes?.trim().isEmpty ?? true
          ? '-'
          : row.personalNotes!.trim(),
    LibraryColumnKey.updatedAt => formatVisibleDate(row.updatedAt),
    LibraryColumnKey.playthroughs => row.playthroughCount.toString(),
    LibraryColumnKey.cover => '',
  };

  return Tooltip(
    message: text,
    waitDuration: const Duration(milliseconds: 500),
    child: Text(
      text,
      maxLines: column == LibraryColumnKey.notes ? 2 : 1,
      overflow: TextOverflow.ellipsis,
    ),
  );
}

DropdownButtonFormField<int?> _ratingDropdown({
  required String label,
  required int? value,
  required ValueChanged<int?> onChanged,
}) {
  return DropdownButtonFormField<int?>(
    initialValue: value,
    decoration: InputDecoration(labelText: label),
    items: const [
      DropdownMenuItem(value: null, child: Text('Sin límite')),
      DropdownMenuItem(value: 1, child: Text('1')),
      DropdownMenuItem(value: 2, child: Text('2')),
      DropdownMenuItem(value: 3, child: Text('3')),
      DropdownMenuItem(value: 4, child: Text('4')),
      DropdownMenuItem(value: 5, child: Text('5')),
    ],
    onChanged: onChanged,
  );
}

void _toggleSort(WidgetRef ref, LibraryColumnKey column) {
  final sortField = _sortFieldForColumn(column);
  if (sortField == null) return;
  final current = ref.read(libraryTableStateProvider);
  ref
      .read(libraryTableStateProvider.notifier)
      .setTableState(current.copyWith(sort: current.sort.toggle(sortField)));
}

LibrarySortField? _sortFieldForColumn(LibraryColumnKey column) {
  return switch (column) {
    LibraryColumnKey.title => LibrarySortField.title,
    LibraryColumnKey.status => LibrarySortField.status,
    LibraryColumnKey.rating => LibrarySortField.rating,
    LibraryColumnKey.releaseDate => LibrarySortField.releaseDate,
    LibraryColumnKey.completedDate => LibrarySortField.completedDate,
    LibraryColumnKey.hours => LibrarySortField.hours,
    LibraryColumnKey.updatedAt => LibrarySortField.updatedAt,
    LibraryColumnKey.cover ||
    LibraryColumnKey.platforms ||
    LibraryColumnKey.genres ||
    LibraryColumnKey.type ||
    LibraryColumnKey.notes ||
    LibraryColumnKey.playthroughs => null,
  };
}

void _resetTableState(WidgetRef ref) {
  ref
      .read(libraryTableStateProvider.notifier)
      .setTableState(LibraryTableState.initial());
}

SavedLibraryView? _viewById(List<SavedLibraryView> views, String id) {
  for (final view in views) {
    if (view.id == id) return view;
  }
  return null;
}

String _names(Iterable<String> values) {
  final list = values.toList();
  if (list.isEmpty) return '-';
  return list.join(', ');
}

String _limitedNames(Iterable<String> values, {int limit = 2}) {
  final list = values.toList();
  if (list.isEmpty) return '-';
  final visible = list.take(limit).join(', ');
  final remaining = list.length - limit;
  return remaining > 0 ? '$visible +$remaining' : visible;
}

String _namesForIds(Set<String> ids, List<LibraryCatalogItem> items) {
  final namesById = {for (final item in items) item.id: item.name};
  final names = ids.map((id) => namesById[id] ?? id).toList();
  return names.isEmpty ? '-' : names.join(', ');
}

double? _parseDouble(String value) {
  final normalized = value.trim().replaceAll(',', '.');
  if (normalized.isEmpty) return null;
  return double.tryParse(normalized);
}

String? _blankToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
