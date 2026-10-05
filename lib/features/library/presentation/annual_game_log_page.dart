import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/bv_empty_state.dart';
import '../../../core/design_system/bv_error_state.dart';
import '../../../core/design_system/bv_loading_state.dart';
import '../../../l10n/l10n.dart';
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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navigationLibrary)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
                          style: Theme.of(context).textTheme.titleLarge,
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
                    labelText: l10n.search,
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
                return Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    yearNavigation,
                    SizedBox(
                      width:
                          constraints.maxWidth < 700
                              ? constraints.maxWidth
                              : (constraints.maxWidth - 450).clamp(200, 440),
                      child: search,
                    ),
                    add,
                  ],
                );
              },
            ),
          ),
          Expanded(
            child: rows.when(
              data: (items) {
                final visible = log.visibleRows(items);
                if (visible.isEmpty) {
                  return Center(
                    child: BvEmptyState(
                      title:
                          log.query.trim().isNotEmpty
                              ? l10n.logNoSearchResults
                              : l10n.logEmptyYear,
                      message:
                          log.query.trim().isNotEmpty
                              ? l10n.logSearchHint
                              : l10n.logEmptyYearHint,
                      icon: Icons.sports_esports_outlined,
                    ),
                  );
                }
                return LibraryCatalogGrid(
                  rows: visible,
                  selectionMode: false,
                  selectedIds: const {},
                  onSelectionChanged: (_, _) {},
                  rowActionsBuilder: (_, _) => const SizedBox.shrink(),
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
            ),
          ),
        ],
      ),
    );
  }
}
