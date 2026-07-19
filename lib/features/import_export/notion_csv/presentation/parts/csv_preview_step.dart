part of '../import_notion_csv_page.dart';

class _CsvPreviewStep extends StatelessWidget {
  const _CsvPreviewStep({
    required this.preview,
    required this.importing,
    required this.onRowChanged,
    required this.onImport,
  });

  final ImportPreview preview;
  final bool importing;
  final ValueChanged<NormalizedImportRow> onRowChanged;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    return BvWizardStep(
      step: context.l10n.stepThree,
      title: context.l10n.bulkPreviewTitle,
      subtitle: context.l10n.csvPreviewDescription,
      trailing: BvAsyncActionButton(
        label: context.l10n.csvConfirmImport,
        icon: Icons.check_circle_outline,
        onPressed: preview.importableCount == 0 ? null : onImport,
        busy: importing,
        busyLabel: context.l10n.loading,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: BvSpacing.xs,
            runSpacing: BvSpacing.xs,
            children: [
              BvChip(
                label: context.l10n.csvImportable(preview.importableCount),
                selected: true,
              ),
              BvChip(label: context.l10n.csvOmitted(preview.omittedCount)),
              BvChip(label: context.l10n.csvWithWarnings(preview.warningCount)),
              BvChip(label: context.l10n.csvWithErrors(preview.errorCount)),
              BvChip(label: context.l10n.csvDuplicates(preview.duplicateCount)),
            ],
          ),
          const SizedBox(height: BvSpacing.md),
          if (preview.rows.isEmpty)
            BvEmptyState(
              title: context.l10n.csvNoRows,
              message: context.l10n.csvNoRowsMessage,
              icon: Icons.inbox_outlined,
            )
          else
            for (final row in preview.rows)
              Padding(
                padding: const EdgeInsets.only(bottom: BvSpacing.sm),
                child: _PreviewRowTile(row: row, onChanged: onRowChanged),
              ),
        ],
      ),
    );
  }
}

class _PreviewRowTile extends StatelessWidget {
  const _PreviewRowTile({required this.row, required this.onChanged});

  final NormalizedImportRow row;
  final ValueChanged<NormalizedImportRow> onChanged;

  @override
  Widget build(BuildContext context) {
    final issueTexts = [
      ...row.issues.map((issue) => issue.message),
      ...row.duplicates.map((duplicate) => duplicate.reason),
    ];

    return BvSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: row.include,
            onChanged:
                row.hasErrors
                    ? null
                    : (value) =>
                        onChanged(row.copyWith(include: value ?? false)),
          ),
          const SizedBox(width: BvSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: BvSpacing.xs,
                  runSpacing: BvSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      row.title.isEmpty
                          ? context.l10n.csvUnnamedRow(row.rowNumber)
                          : row.title,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    if (row.hasErrors)
                      BvChip(
                        label: context.l10n.csvHasErrors,
                        tone: BvChipTone.danger,
                      ),
                    if (row.hasWarnings)
                      BvChip(
                        label: context.l10n.csvWarning,
                        tone: BvChipTone.warning,
                      ),
                    if (row.hasDuplicates)
                      BvChip(
                        label: context.l10n.csvDuplicate,
                        tone: BvChipTone.warning,
                      ),
                  ],
                ),
                const SizedBox(height: BvSpacing.xxs),
                Text(
                  [
                    context.l10n.gameStatusLabel(
                      parseGameStatus(row.status.name),
                    ),
                    if (row.platforms.isNotEmpty) row.platforms.join(', '),
                    if (row.genres.isNotEmpty) row.genres.join(', '),
                    if (row.completedAt != null)
                      formatVisibleDate(row.completedAt),
                    formatStarRating(row.personalRating),
                  ].join(' · '),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (issueTexts.isNotEmpty) ...[
                  const SizedBox(height: BvSpacing.xxs),
                  Text(
                    issueTexts.join(' | '),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (row.hasDuplicates) ...[
                  const SizedBox(height: BvSpacing.xs),
                  TextButton(
                    onPressed:
                        () => onChanged(
                          row.copyWith(
                            include: true,
                            forceCreateDuplicate: !row.forceCreateDuplicate,
                          ),
                        ),
                    child: Text(
                      row.forceCreateDuplicate
                          ? context.l10n.csvSkipDuplicate
                          : context.l10n.csvCreateAnyway,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
