part of '../import_notion_csv_page.dart';

class _FileStep extends StatelessWidget {
  const _FileStep({
    required this.document,
    required this.loading,
    required this.onPickFile,
  });

  final CsvDocument? document;
  final bool loading;
  final VoidCallback onPickFile;

  @override
  Widget build(BuildContext context) {
    return BvWizardStep(
      step: context.l10n.stepOne,
      title: context.l10n.csvChooseFile,
      subtitle: context.l10n.csvChooseFileDescription,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (document == null)
            BvEmptyState(
              title: context.l10n.csvNoFile,
              message: context.l10n.csvNoFileMessage,
              icon: Icons.upload_file_outlined,
            )
          else
            BvSurface(
              child: Wrap(
                spacing: BvSpacing.sm,
                runSpacing: BvSpacing.sm,
                children: [
                  BvChip(label: document!.fileName, selected: true),
                  BvChip(label: context.l10n.csvRows(document!.rowCount)),
                  BvChip(
                    label: context.l10n.csvColumns(document!.headers.length),
                  ),
                  BvChip(label: context.l10n.csvDelimiter(document!.delimiter)),
                ],
              ),
            ),
          const SizedBox(height: BvSpacing.md),
          BvAsyncActionButton(
            label:
                document == null
                    ? context.l10n.csvSelect
                    : context.l10n.csvChange,
            icon: Icons.upload_file_outlined,
            onPressed: onPickFile,
            busy: loading,
            busyLabel: context.l10n.loading,
          ),
        ],
      ),
    );
  }
}
