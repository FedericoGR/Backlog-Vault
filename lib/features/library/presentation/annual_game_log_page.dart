import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/bv_empty_state.dart';
import '../../../core/design_system/bv_error_state.dart';
import '../../../core/design_system/bv_loading_state.dart';
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
                    return LibraryCatalogGrid(rows: visible);
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
        ),
      ),
    );
  }
}
