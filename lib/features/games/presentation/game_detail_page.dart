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
import '../../../core/design_system/bv_section.dart';
import '../../../core/design_system/bv_spacing.dart';
import '../../../core/design_system/bv_stat_card.dart';
import '../../../core/design_system/bv_surface.dart';
import '../../../core/design_system/bv_theme_extension.dart';
import '../../../core/design_system/bv_tokens.dart';
import '../../../core/formatting/date_formatters.dart';
import '../../../l10n/domain_localizations.dart';
import '../../../l10n/l10n.dart';
import '../../catalogs/domain/catalog_item.dart';
import '../../library/domain/game_status.dart';
import '../../library/domain/rating.dart';
import '../../library/application/library_providers.dart';
import '../../library/presentation/widgets/library_cover_thumbnail.dart';
import '../../media/application/media_providers.dart';
import '../../media/presentation/media_search_dialog.dart';
import '../../metadata/presentation/metadata_search_dialog.dart';
import '../../playthroughs/application/completion_form_model.dart';
import '../../playthroughs/domain/playthrough_status.dart';
import '../application/game_progress_summary.dart';
import '../application/game_view_models.dart';
import '../application/library_game_details.dart';

part 'parts/game_detail_sections.dart';
part 'parts/game_detail_actions.dart';
part 'parts/playthrough_dialogs.dart';

/// Presents one game and its library and playthrough information.
class GameDetailPage extends ConsumerWidget {
  const GameDetailPage({required this.entryId, super.key});

  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(libraryGameProvider(entryId));

    return detail.when(
      data: (item) {
        if (item == null) {
          return Scaffold(
            appBar: AppBar(title: Text(context.l10n.gameNotFoundTitle)),
            body: Center(child: Text(context.l10n.gameNotFoundMessage)),
          );
        }

        final summary = GameProgressSummary.fromDetails(item);
        return Scaffold(
          appBar: AppBar(
            title: Text(item.game.title),
            actions: [
              IconButton(
                tooltip:
                    item.selectedCover == null
                        ? context.l10n.coverSearch
                        : context.l10n.coverChange,
                onPressed: () => _showMediaDialog(context, ref, item),
                icon: const Icon(Icons.image_search_outlined),
              ),
              IconButton(
                tooltip: context.l10n.metadataSearch,
                onPressed: () => _showMetadataDialog(context, ref, item),
                icon: const Icon(Icons.travel_explore_outlined),
              ),
              IconButton(
                tooltip: context.l10n.gameEditTitle,
                onPressed: () => context.go('/games/${item.entry.id}/edit'),
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: context.l10n.gameDeleteTooltip,
                onPressed: () => _confirmDelete(context, ref, item),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= BvBreakpoints.detailWide;
              final compact = constraints.maxWidth < BvBreakpoints.mobile;
              final padding = compact ? BvSpacing.pageCompact : BvSpacing.page;
              final coverPanel = _GameCoverPanel(item: item);
              final infoPanel = _GameInfoPanel(item: item);
              final progress = _GameProgressSection(
                item: item,
                summary: summary,
              );
              final playthroughs = _PlaythroughSection(item: item);
              final notes = _NotesSection(item: item);

              return ListView(
                padding: padding,
                children: [
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 300,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              coverPanel,
                              const SizedBox(height: 16),
                              progress,
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              infoPanel,
                              const SizedBox(height: 16),
                              playthroughs,
                              const SizedBox(height: 16),
                              notes,
                            ],
                          ),
                        ),
                      ],
                    )
                  else ...[
                    infoPanel,
                    const SizedBox(height: 16),
                    coverPanel,
                    const SizedBox(height: 16),
                    progress,
                    const SizedBox(height: 16),
                    playthroughs,
                    const SizedBox(height: 16),
                    notes,
                  ],
                  const SizedBox(height: 80),
                ],
              );
            },
          ),
        );
      },
      loading:
          () => Scaffold(body: BvLoadingState(label: context.l10n.loading)),
      error:
          (error, stackTrace) => Scaffold(
            appBar: AppBar(title: Text(context.l10n.errorTitle)),
            body: BvErrorState(
              title: context.l10n.gameLoadError,
              message: context.l10n.unexpectedErrorMessage,
              retryLabel: context.l10n.retry,
              onRetry: () => ref.invalidate(libraryGameProvider(entryId)),
            ),
          ),
    );
  }
}
