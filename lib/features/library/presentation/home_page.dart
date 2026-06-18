import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/bv_action_card.dart';
import '../../../core/design_system/bv_chip.dart';
import '../../../core/design_system/bv_empty_state.dart';
import '../../../core/design_system/bv_error_state.dart';
import '../../../core/design_system/bv_loading_state.dart';
import '../../../core/design_system/bv_page_scaffold.dart';
import '../../../core/design_system/bv_panel.dart';
import '../../../core/design_system/bv_section.dart';
import '../../../core/design_system/bv_spacing.dart';
import '../../../core/design_system/bv_stat_card.dart';
import '../../../core/design_system/bv_surface.dart';
import '../../../core/formatting/date_formatters.dart';
import '../../../l10n/domain_localizations.dart';
import '../../../l10n/l10n.dart';
import '../application/library_home_summary.dart';
import '../data/library_query_repository.dart';
import '../domain/library_game_row.dart';
import 'widgets/library_cover_thumbnail.dart';
import 'widgets/rating_stars.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final rows = ref.watch(libraryRowsProvider);

    return BvPageScaffold(
      title: l10n.navigationHome,
      actions: [
        TextButton.icon(
          onPressed: () => context.go('/statistics'),
          icon: const Icon(Icons.bar_chart_outlined),
          label: Text(l10n.navigationStatistics),
        ),
      ],
      body: rows.when(
        data: (items) {
          final data = buildLibraryHomeData(items);
          if (items.isEmpty) return const _EmptyHomeState();
          return ListView(
            children: [
              _HomeHero(data: data),
              const SizedBox(height: BvSpacing.md),
              _HomeCounters(data: data),
              const SizedBox(height: BvSpacing.md),
              _HomeSection(
                title: l10n.homeNowPlaying,
                description: l10n.homeNowPlayingDescription,
                rows: data.playingNow,
                emptyText: l10n.homeNowPlayingEmpty,
              ),
              const SizedBox(height: BvSpacing.md),
              _HomeSection(
                title: l10n.backlog,
                description: l10n.homeBacklogDescription,
                rows: data.backlog,
                emptyText: l10n.homeBacklogEmpty,
              ),
              const SizedBox(height: BvSpacing.md),
              _HomeSection(
                title: l10n.homeRecentCompleted,
                description: l10n.homeRecentCompletedDescription,
                rows: data.recentlyCompleted,
                emptyText: l10n.homeRecentCompletedEmpty,
                subtitleFor: (row) => formatVisibleDate(row.completedAt),
              ),
              const SizedBox(height: BvSpacing.md),
              _HomeSection(
                title: l10n.missingCover,
                description: l10n.homeMissingCoverDescription,
                rows: data.missingCover,
                emptyText: l10n.homeMissingCoverEmpty,
              ),
              const SizedBox(height: BvSpacing.md),
              _HomeSection(
                title: l10n.missingMetadata,
                description: l10n.homeMissingMetadataDescription,
                rows: data.missingMetadata,
                emptyText: l10n.homeMissingMetadataEmpty,
              ),
              const SizedBox(height: BvSpacing.md),
              _HomeSection(
                title: l10n.homeRecentlyUpdated,
                description: l10n.homeRecentlyUpdatedDescription,
                rows: data.recentlyUpdated,
                emptyText: l10n.homeRecentlyUpdatedEmpty,
                subtitleFor: (row) => formatVisibleDate(row.updatedAt),
              ),
            ],
          );
        },
        loading: () => BvLoadingState(label: l10n.homeLoading),
        error:
            (error, stackTrace) => BvErrorState(
              title: l10n.homeLoadError,
              message: error.toString(),
            ),
      ),
    );
  }
}

class _HomeHero extends StatelessWidget {
  const _HomeHero({required this.data});

  final LibraryHomeData data;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        final primary = BvActionCard(
          title: l10n.navigationLibrary,
          subtitle: l10n.homeLibrarySummary(
            data.totalGames,
            data.completedCount,
            data.playingCount,
          ),
          icon: Icons.library_books_outlined,
          emphasized: true,
          actions: [
            FilledButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.library_books_outlined),
              label: Text(l10n.homeOpenLibrary),
            ),
          ],
        );
        final secondary = BvActionCard(
          title: l10n.homeQuickPanel,
          subtitle: l10n.homeQuickPanelDescription,
          icon: Icons.dashboard_customize_outlined,
          actions: [
            OutlinedButton.icon(
              onPressed: () => context.go('/statistics'),
              icon: const Icon(Icons.bar_chart_outlined),
              label: Text(l10n.homeViewStatistics),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go('/games/new'),
              icon: const Icon(Icons.add),
              label: Text(l10n.homeCreateGame),
            ),
          ],
        );

        if (compact) {
          return Column(
            children: [
              primary,
              const SizedBox(height: BvSpacing.md),
              secondary,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: primary),
            const SizedBox(width: BvSpacing.md),
            Expanded(flex: 2, child: secondary),
          ],
        );
      },
    );
  }
}

class _HomeCounters extends StatelessWidget {
  const _HomeCounters({required this.data});

  final LibraryHomeData data;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: BvSpacing.sm,
      runSpacing: BvSpacing.sm,
      children: [
        _CounterCard(label: l10n.games, value: data.totalGames),
        _CounterCard(label: l10n.backlog, value: data.backlogCount),
        _CounterCard(label: l10n.playing, value: data.playingCount),
        _CounterCard(label: l10n.completed, value: data.completedCount),
        _CounterCard(label: l10n.missingCover, value: data.missingCoverCount),
      ],
    );
  }
}

class _CounterCard extends StatelessWidget {
  const _CounterCard({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return BvStatCard(label: label, value: value.toString(), minWidth: 136);
  }
}

class _HomeSection extends StatelessWidget {
  const _HomeSection({
    required this.title,
    required this.description,
    required this.rows,
    required this.emptyText,
    this.subtitleFor,
  });

  final String title;
  final String description;
  final List<LibraryGameRow> rows;
  final String emptyText;
  final String Function(LibraryGameRow row)? subtitleFor;

  @override
  Widget build(BuildContext context) {
    return BvPanel(
      child: BvSection(
        title: title,
        subtitle: description,
        padding: EdgeInsets.zero,
        trailing: TextButton(
          onPressed: () => context.go('/'),
          child: Text(context.l10n.homeViewLibrary),
        ),
        child:
            rows.isEmpty
                ? BvEmptyState(
                  title: title,
                  message: emptyText,
                  icon: Icons.inbox_outlined,
                )
                : SizedBox(
                  height: 280,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: rows.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(width: BvSpacing.sm),
                    itemBuilder:
                        (context, index) => _HomeGameCard(
                          row: rows[index],
                          subtitle: subtitleFor?.call(rows[index]),
                        ),
                  ),
                ),
      ),
    );
  }
}

class _HomeGameCard extends StatelessWidget {
  const _HomeGameCard({required this.row, this.subtitle});

  final LibraryGameRow row;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 176,
      child: BvSurface(
        padding: EdgeInsets.zero,
        onTap: () => context.go('/games/${row.libraryEntryId}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LibraryCoverThumbnail(
              localPath: row.selectedCoverLocalPath,
              width: 176,
              height: 122,
              borderRadius: 0,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(BvSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: BvSpacing.xs),
                    Wrap(
                      spacing: BvSpacing.xs,
                      runSpacing: BvSpacing.xs,
                      children: [
                        BvChip(
                          label: context.l10n.gameStatusLabel(row.status),
                          selected: true,
                        ),
                        if (row.personalRating != null)
                          BvSurface(
                            padding: const EdgeInsets.symmetric(
                              horizontal: BvSpacing.xs,
                              vertical: BvSpacing.xxs,
                            ),
                            child: RatingStars(rating: row.personalRating),
                          ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      subtitle ??
                          [
                            if (row.platforms.isNotEmpty)
                              row.platforms.first.name,
                            if (row.hoursPlayed != null)
                              context.l10n.hoursShort(
                                row.hoursPlayed!.toStringAsFixed(1),
                              ),
                          ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHomeState extends StatelessWidget {
  const _EmptyHomeState();

  @override
  Widget build(BuildContext context) {
    return BvEmptyState(
      title: context.l10n.homeEmptyTitle,
      message: context.l10n.homeEmptyMessage,
      icon: Icons.home_outlined,
      action: FilledButton.icon(
        onPressed: () => context.go('/games/new'),
        icon: const Icon(Icons.add),
        label: Text(context.l10n.homeCreateFirstGame),
      ),
    );
  }
}
