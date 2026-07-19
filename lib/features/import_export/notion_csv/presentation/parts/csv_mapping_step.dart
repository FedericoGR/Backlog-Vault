part of '../import_notion_csv_page.dart';

class _CsvMappingStep extends StatelessWidget {
  const _CsvMappingStep({
    required this.document,
    required this.mapping,
    required this.onChanged,
    required this.onApply,
  });

  final CsvDocument document;
  final CsvColumnMapping mapping;
  final ValueChanged<CsvColumnMapping> onChanged;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return BvWizardStep(
      step: context.l10n.stepTwo,
      title: context.l10n.csvColumnMapping,
      subtitle: context.l10n.csvColumnMappingDescription,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!mapping.hasRequiredFields) ...[
            BvStatusBanner(
              tone: BvBannerTone.danger,
              message: context.l10n.csvMissingNameMapping,
            ),
            const SizedBox(height: BvSpacing.md),
          ],
          for (final field in ImportField.values) ...[
            DropdownButtonFormField<String?>(
              key: ValueKey(
                '${field.name}-${mapping.headerFor(field) ?? 'none'}',
              ),
              initialValue: mapping.headerFor(field),
              decoration: InputDecoration(
                labelText:
                    '${context.l10n.importFieldLabel(field)}${field.isRequired ? ' *' : ''}',
              ),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(context.l10n.csvDoNotImport),
                ),
                for (final header in document.headers)
                  DropdownMenuItem<String?>(value: header, child: Text(header)),
              ],
              onChanged:
                  (header) => onChanged(mapping.copyWithField(field, header)),
            ),
            const SizedBox(height: BvSpacing.sm),
          ],
          FilledButton.icon(
            onPressed: mapping.hasRequiredFields ? onApply : null,
            icon: const Icon(Icons.preview_outlined),
            label: Text(context.l10n.csvGeneratePreview),
          ),
        ],
      ),
    );
  }
}
