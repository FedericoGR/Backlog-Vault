import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/bv_breakpoints.dart';
import '../../../core/design_system/bv_chip.dart';
import '../../../core/design_system/bv_error_state.dart';
import '../../../core/design_system/bv_feedback.dart';
import '../../../core/design_system/bv_loading_state.dart';
import '../../../core/design_system/bv_panel.dart';
import '../../../core/design_system/bv_section.dart';
import '../../../core/design_system/bv_spacing.dart';
import '../../../core/design_system/bv_theme_extension.dart';
import '../../../core/design_system/bv_tokens.dart';
import '../../../core/formatting/date_formatters.dart';
import '../../../l10n/domain_localizations.dart';
import '../../../l10n/l10n.dart';
import '../../library/domain/game_status.dart';
import '../../library/domain/rating.dart';
import '../../library/application/library_providers.dart';
import '../../library/presentation/widgets/library_cover_thumbnail.dart';
import '../../media/application/media_providers.dart';
import '../../media/presentation/media_search_dialog.dart';
import '../../metadata/presentation/metadata_search_dialog.dart';
import '../application/game_view_models.dart';
import '../application/library_game_details.dart';

part 'parts/game_detail_sections.dart';
part 'parts/game_detail_actions.dart';

/// Presents a game and its authoritative personal record.
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

        return Scaffold(
          appBar: AppBar(
            title: Text(context.l10n.gameMyRecord),
            actions: [
              TextButton.icon(
                onPressed: () => context.go('/games/${item.entry.id}/edit'),
                icon: const Icon(Icons.edit_outlined),
                label: Text(context.l10n.edit),
              ),
              PopupMenuButton<String>(
                tooltip: context.l10n.gameActions,
                onSelected: (_) => _confirmDelete(context, ref, item),
                itemBuilder:
                    (_) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(context.l10n.delete),
                      ),
                    ],
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
              final notes = [
                if (item.entry.personalNotes?.trim().isNotEmpty ?? false) ...[
                  const SizedBox(height: BvSpacing.md),
                  _NotesSection(item: item),
                ],
              ];

              return ListView(
                padding: padding,
                children: [
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 300, child: coverPanel),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [infoPanel, ...notes],
                          ),
                        ),
                      ],
                    )
                  else ...[
                    infoPanel,
                    const SizedBox(height: 16),
                    ...notes,
                    const SizedBox(height: BvSpacing.md),
                    Center(child: SizedBox(width: 300, child: coverPanel)),
                  ],
                  const SizedBox(height: BvSpacing.md),
                  _GameCatalogPanel(item: item),
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
