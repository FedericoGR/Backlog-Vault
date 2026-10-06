import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/bv_empty_state.dart';
import '../../../core/design_system/bv_error_state.dart';
import '../../../core/design_system/bv_loading_state.dart';
import '../../../core/design_system/bv_theme_extension.dart';
import '../../../l10n/l10n.dart';
import 'package:intl/intl.dart';
import '../../catalogs/application/catalog_controller.dart';
import '../application/annual_game_log.dart';
import '../application/library_providers.dart';
import '../domain/library_game_row.dart';
import 'widgets/library_catalog_widgets.dart';

/// The primary library experience: year, search, add and open a game.
class GameListPage extends ConsumerStatefulWidget {
  const GameListPage({super.key});

  @override
  ConsumerState<GameListPage> createState() => _GameListPageState();
}

class _GameListPageState extends ConsumerState<GameListPage> {
  late final TextEditingController _search;
  bool _desktopFiltersVisible = true;
  bool _compactFiltersVisible = false;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(
      text: ref.read(annualGameLogProvider).query,
    );
    Future.microtask(
      () => ref.read(catalogControllerProvider).seedDefaultsIfEmpty(),
    );
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final log = ref.watch(annualGameLogProvider);
    final controller = ref.read(annualGameLogProvider.notifier);
    final rows = ref.watch(libraryRowsProvider);
    final currentYear = ref.watch(annualLogClockProvider).now().year;
    final years =
        {
            currentYear,
            if (log.year != null) log.year!,
            for (final row in rows.asData?.value ?? <LibraryGameRow>[])
              if (row.playedYear != null) row.playedYear!,
          }.toList()
          ..sort((a, b) => b.compareTo(a));

    final yearRows =
        (rows.asData?.value ?? <LibraryGameRow>[])
            .where((row) => row.playedYear == log.year)
            .toList();
    final hours =
        yearRows.map((row) => row.hoursPlayed).whereType<double>().toList();
    final totalHours = hours.isEmpty ? null : hours.reduce((a, b) => a + b);
    return Scaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 28, 16, 28),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final yearNavigation = Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          key: const ValueKey('previous-year'),
                          tooltip: l10n.logPreviousYear,
                          onPressed:
                              log.year == null || log.year! <= 1
                                  ? null
                                  : () => controller.selectYear(log.year! - 1),
                          icon: const Icon(Icons.chevron_left),
                        ),
                        SizedBox(
                          width: 132,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              key: const ValueKey('selected-year'),
                              isExpanded: true,
                              value: log.year?.toString() ?? 'unknown',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                              items: [
                                for (final year in years)
                                  DropdownMenuItem(
                                    value: '$year',
                                    child: Text('$year'),
                                  ),
                                DropdownMenuItem(
                                  value: 'unknown',
                                  child: Text(l10n.logUnknownYear),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  controller.selectYear(int.tryParse(value));
                                }
                              },
                            ),
                          ),
                        ),
                        IconButton(
                          key: const ValueKey('next-year'),
                          tooltip: l10n.logNextYear,
                          onPressed:
                              log.year == null || log.year! >= 9999
                                  ? null
                                  : () => controller.selectYear(log.year! + 1),
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    );
                    final search = TextField(
                      key: const ValueKey('annual-search'),
                      controller: _search,
                      decoration: InputDecoration(
                        hintText: l10n.search,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon:
                            log.query.isEmpty
                                ? null
                                : IconButton(
                                  tooltip: l10n.clear,
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    _search.clear();
                                    controller.search('');
                                  },
                                ),
                      ),
                      onChanged: controller.search,
                    );
                    final add = FilledButton.icon(
                      key: const ValueKey('add-game'),
                      onPressed:
                          () => context.go(
                            '/games/new?year=${log.year ?? 'unknown'}',
                          ),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.logAddGame),
                    );
                    final identity = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.logCollectionHeading.toUpperCase(),
                          style: Theme.of(
                            context,
                          ).textTheme.labelSmall?.copyWith(
                            letterSpacing: 1.6,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        yearNavigation,
                        const SizedBox(height: 4),
                        Text(
                          '${yearRows.length} ${l10n.games.toLowerCase()}${totalHours == null ? '' : ' · ${l10n.hoursShort(NumberFormat('0.#', l10n.localeName).format(totalHours))}'}',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    );
                    if (constraints.maxWidth >= 760) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          identity,
                          const Spacer(),
                          SizedBox(width: 240, child: search),
                          const SizedBox(width: 16),
                          add,
                        ],
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        identity,
                        const SizedBox(height: 16),
                        search,
                        const SizedBox(height: 12),
                        add,
                      ],
                    );
                  },
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 1200;
                    final filtersVisible =
                        compact
                            ? _compactFiltersVisible
                            : _desktopFiltersVisible;
                    return rows.when(
                      data: (items) {
                        final yearRows =
                            items
                                .where((row) => row.playedYear == log.year)
                                .toList();
                        final searchRows = log.yearSearchRows(items);
                        final visible = log.visibleRows(items);
                        final platforms = <String, String>{};
                        for (final row in yearRows) {
                          final id = row.playedPlatformId;
                          if (id != null) {
                            platforms[id] = row.playedPlatformName ?? id;
                          }
                        }
                        final platformOptions =
                            platforms.entries.toList()..sort(
                              (a, b) => a.value.toLowerCase().compareTo(
                                b.value.toLowerCase(),
                              ),
                            );

                        Widget content;
                        if (visible.isNotEmpty) {
                          content = LibraryCatalogGrid(rows: visible);
                        } else if (log.hasActiveFilters &&
                            searchRows.isNotEmpty) {
                          content = BvEmptyState(
                            title: l10n.logFilteredEmpty,
                            icon: Icons.filter_alt_off_outlined,
                            action: TextButton(
                              key: const ValueKey(
                                'clear-library-filters-empty',
                              ),
                              onPressed: controller.clearFilters,
                              child: Text(l10n.logClearFilters),
                            ),
                          );
                        } else {
                          content = BvEmptyState(
                            title:
                                log.query.trim().isNotEmpty
                                    ? l10n.logNoSearchResults
                                    : l10n.logEmptyYear,
                            message:
                                log.query.trim().isNotEmpty
                                    ? l10n.logSearchHint
                                    : l10n.logEmptyYearHint,
                            icon: Icons.sports_esports_outlined,
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (filtersVisible)
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: 218,
                                child: _LibraryFilters(
                                  state: log,
                                  platforms: platformOptions,
                                  showClear: visible.isNotEmpty,
                                  onClose:
                                      () => setState(() {
                                        if (compact) {
                                          _compactFiltersVisible = false;
                                        } else {
                                          _desktopFiltersVisible = false;
                                        }
                                      }),
                                  onCompletionChanged:
                                      controller.setCompletionFilter,
                                  onPlatformToggled:
                                      controller.togglePlayedPlatform,
                                  onRatingChanged: controller.setRatingFilter,
                                  onClear: controller.clearFilters,
                                ),
                              ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (!filtersVisible)
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          16,
                                          0,
                                          16,
                                          8,
                                        ),
                                        child: TextButton.icon(
                                          key: const ValueKey(
                                            'library-filters-toggle',
                                          ),
                                          onPressed:
                                              () => setState(() {
                                                if (compact) {
                                                  _compactFiltersVisible = true;
                                                } else {
                                                  _desktopFiltersVisible = true;
                                                }
                                              }),
                                          icon: const Icon(
                                            Icons.tune,
                                            size: 17,
                                          ),
                                          label: Text(l10n.logShowFilters),
                                        ),
                                      ),
                                    ),
                                  Expanded(child: content),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => BvLoadingState(label: l10n.libraryLoading),
                      error:
                          (_, _) => BvErrorState(
                            title: l10n.libraryLoadError,
                            message: l10n.unexpectedErrorMessage,
                            retryLabel: l10n.retry,
                            onRetry: () => ref.invalidate(libraryRowsProvider),
                          ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LibraryFilters extends StatelessWidget {
  const _LibraryFilters({
    required this.state,
    required this.platforms,
    required this.showClear,
    required this.onClose,
    required this.onCompletionChanged,
    required this.onPlatformToggled,
    required this.onRatingChanged,
    required this.onClear,
  });

  final AnnualGameLogState state;
  final List<MapEntry<String, String>> platforms;
  final bool showClear;
  final VoidCallback onClose;
  final ValueChanged<LibraryCompletionFilter> onCompletionChanged;
  final ValueChanged<String> onPlatformToggled;
  final ValueChanged<LibraryRatingFilter> onRatingChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final bv = BvThemeExtension.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: bv.border)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 14, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.logFilters,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                IconButton(
                  key: const ValueKey('hide-library-filters'),
                  tooltip: l10n.logHideFilters,
                  onPressed: onClose,
                  icon: const Icon(Icons.chevron_left),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _FilterHeading(l10n.logFilterStatus),
            _FilterChoice(
              label: l10n.logFilterAll,
              selected: state.completionFilter == LibraryCompletionFilter.all,
              onTap: () => onCompletionChanged(LibraryCompletionFilter.all),
            ),
            _FilterChoice(
              label: l10n.logFilterCompleted,
              selected:
                  state.completionFilter == LibraryCompletionFilter.completed,
              onTap:
                  () => onCompletionChanged(LibraryCompletionFilter.completed),
            ),
            _FilterChoice(
              label: l10n.logFilterUnfinished,
              selected:
                  state.completionFilter == LibraryCompletionFilter.unfinished,
              onTap:
                  () => onCompletionChanged(LibraryCompletionFilter.unfinished),
            ),
            const SizedBox(height: 16),
            _FilterHeading(l10n.logFilterPlatform),
            if (platforms.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  l10n.logFilterNoPlatforms,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: bv.textMuted,
                  ),
                ),
              )
            else
              for (final platform in platforms)
                _PlatformFilterChoice(
                  id: platform.key,
                  label: platform.value,
                  selected: state.playedPlatformIds.contains(platform.key),
                  onTap: () => onPlatformToggled(platform.key),
                ),
            const SizedBox(height: 16),
            _FilterHeading(l10n.logFilterRating),
            _FilterChoice(
              label: l10n.logFilterAnyRating,
              selected: state.ratingFilter == LibraryRatingFilter.any,
              onTap: () => onRatingChanged(LibraryRatingFilter.any),
            ),
            _FilterChoice(
              label: l10n.logFilterFourPlus,
              selected: state.ratingFilter == LibraryRatingFilter.fourPlus,
              onTap: () => onRatingChanged(LibraryRatingFilter.fourPlus),
            ),
            _FilterChoice(
              label: l10n.logFilterThreePlus,
              selected: state.ratingFilter == LibraryRatingFilter.threePlus,
              onTap: () => onRatingChanged(LibraryRatingFilter.threePlus),
            ),
            _FilterChoice(
              label: l10n.logFilterUnrated,
              selected: state.ratingFilter == LibraryRatingFilter.unrated,
              onTap: () => onRatingChanged(LibraryRatingFilter.unrated),
            ),
            if (state.hasActiveFilters && showClear) ...[
              const SizedBox(height: 16),
              TextButton(
                key: const ValueKey('clear-library-filters'),
                onPressed: onClear,
                child: Text(l10n.logClearFilters),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FilterHeading extends StatelessWidget {
  const _FilterHeading(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        letterSpacing: 1.1,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    ),
  );
}

class _FilterChoice extends StatelessWidget {
  const _FilterChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 32,
        child: Row(
          children: [
            SizedBox(
              width: 22,
              child:
                  selected
                      ? Icon(
                        Icons.check,
                        size: 16,
                        color: theme.colorScheme.primary,
                      )
                      : const SizedBox.shrink(),
            ),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color:
                      selected
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlatformFilterChoice extends StatelessWidget {
  const _PlatformFilterChoice({
    required this.id,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String id;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    key: ValueKey('played-platform-filter-$id'),
    onTap: onTap,
    child: SizedBox(
      height: 32,
      child: Row(
        children: [
          SizedBox(
            width: 22,
            height: 32,
            child: Checkbox(
              value: selected,
              onChanged: (_) => onTap(),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 0),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    ),
  );
}
