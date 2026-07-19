part of 'library_catalog_widgets.dart';

/// Responsive totals for the currently visible library result.
class LibrarySummaryStrip extends StatelessWidget {
  const LibrarySummaryStrip({required this.summary, super.key});

  final LibraryTableSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _SummaryPill(label: l10n.games, value: summary.visibleGames),
            _SummaryPill(label: l10n.completed, value: summary.completedCount),
            _SummaryPill(
              label: l10n.libraryHours,
              textValue: summary.totalHours.toStringAsFixed(1),
            ),
            _SummaryPill(
              label: l10n.libraryAverage,
              textValue:
                  summary.averageRating == null
                      ? '-'
                      : summary.averageRating!.toStringAsFixed(1),
            ),
            _SummaryPill(
              label: l10n.missingRating,
              value: summary.missingRating,
            ),
            _SummaryPill(
              label: l10n.missingPlatform,
              value: summary.missingPlatform,
            ),
            _SummaryPill(label: l10n.missingGenre, value: summary.missingGenre),
          ],
        ),
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({required this.label, this.value, this.textValue});

  final String label;
  final int? value;
  final String? textValue;

  @override
  Widget build(BuildContext context) {
    return BvChip(
      label: '$label: ${textValue ?? value}',
      tone: BvChipTone.neutral,
    );
  }
}

/// Bulk-selection controls shared by table, list and gallery layouts.
class LibrarySelectionBar extends StatelessWidget {
  const LibrarySelectionBar({
    required this.selectedCount,
    required this.visibleCount,
    required this.totalCount,
    required this.onSelectVisible,
    required this.onSelectAll,
    required this.onClear,
    required this.onDelete,
    super.key,
  });

  final int selectedCount;
  final int visibleCount;
  final int totalCount;
  final VoidCallback onSelectVisible;
  final VoidCallback onSelectAll;
  final VoidCallback onClear;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: BvPanel(
        dense: true,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            BvChip(
              icon: Icons.check_circle_outline,
              label: context.l10n.librarySelectedCount(selectedCount),
              tone: BvChipTone.primary,
              selected: selectedCount > 0,
            ),
            OutlinedButton(
              onPressed: visibleCount == 0 ? null : onSelectVisible,
              child: Text(context.l10n.librarySelectVisible(visibleCount)),
            ),
            OutlinedButton(
              onPressed: totalCount == 0 ? null : onSelectAll,
              child: Text(context.l10n.librarySelectAll(totalCount)),
            ),
            OutlinedButton(
              onPressed: selectedCount == 0 ? null : onClear,
              child: Text(context.l10n.libraryClearSelection),
            ),
            FilledButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
              label: Text(context.l10n.deleteAction),
            ),
          ],
        ),
      ),
    );
  }
}
