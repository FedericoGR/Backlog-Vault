import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/bv_chip.dart';
import '../../../../core/design_system/bv_empty_state.dart';
import '../../../../core/design_system/bv_page_scaffold.dart';
import '../../../../core/design_system/bv_spacing.dart';
import '../../../../core/design_system/bv_status_banner.dart';
import '../../../../core/design_system/bv_surface.dart';
import '../../../../core/design_system/bv_wizard_step.dart';
import '../../../../core/formatting/date_formatters.dart';
import '../../../../l10n/domain_localizations.dart';
import '../../../../l10n/l10n.dart';
import '../../../library/domain/game_status.dart';
import '../../../library/domain/rating.dart';
import '../application/notion_csv_import_providers.dart';
import '../data/notion_csv_import_repository.dart';
import '../domain/csv_column_mapping.dart';
import '../domain/csv_document.dart';
import '../domain/import_field.dart';
import '../domain/import_preview.dart';
import '../domain/import_result.dart';
import '../domain/normalized_import_row.dart';

class ImportNotionCsvPage extends ConsumerStatefulWidget {
  const ImportNotionCsvPage({super.key});

  @override
  ConsumerState<ImportNotionCsvPage> createState() =>
      _ImportNotionCsvPageState();
}

class _ImportNotionCsvPageState extends ConsumerState<ImportNotionCsvPage> {
  CsvDocument? _document;
  CsvColumnMapping? _mapping;
  ImportPreview? _preview;
  ImportResult? _result;
  String? _error;
  bool _loading = false;
  bool _importing = false;

  @override
  Widget build(BuildContext context) {
    return BvPageScaffold(
      title: context.l10n.csvImportTitle,
      body: ListView(
        children: [
          BvStatusBanner(
            title: context.l10n.csvFlowTitle,
            message: context.l10n.csvFlowDescription,
          ),
          if (_error != null) ...[
            const SizedBox(height: BvSpacing.md),
            _ErrorBanner(message: _error!),
          ],
          const SizedBox(height: BvSpacing.md),
          _FileStep(
            document: _document,
            loading: _loading,
            onPickFile: _pickFile,
          ),
          if (_document != null && _mapping != null && _result == null) ...[
            const SizedBox(height: BvSpacing.md),
            CsvMappingStep(
              document: _document!,
              mapping: _mapping!,
              onChanged: (mapping) {
                setState(() {
                  _mapping = mapping;
                  _preview = null;
                });
              },
              onApply: _buildPreview,
            ),
          ],
          if (_preview != null && _result == null) ...[
            const SizedBox(height: BvSpacing.md),
            CsvPreviewStep(
              preview: _preview!,
              importing: _importing,
              onRowChanged: (row) {
                setState(() => _preview = _preview!.replaceRow(row));
              },
              onImport: _confirmImport,
            ),
          ],
          if (_result != null) ...[
            const SizedBox(height: BvSpacing.md),
            ImportResultStep(
              result: _result!,
              onBackToLibrary: () => context.go('/'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });
    try {
      final picked = await ref.read(csvFilePickerServiceProvider).pickCsvFile();
      if (picked == null) return;

      final document = ref
          .read(parseCsvFileUseCaseProvider)
          .call(
            fileName: picked.name,
            sizeBytes: picked.sizeBytes,
            bytes: picked.bytes,
          );
      final mapping = ref
          .read(detectNotionCsvMappingUseCaseProvider)
          .call(document.headers);

      setState(() {
        _document = document;
        _mapping = mapping;
        _preview = null;
      });
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _buildPreview() async {
    final document = _document;
    final mapping = _mapping;
    if (document == null || mapping == null) return;
    if (!mapping.hasRequiredFields) {
      setState(() => _error = context.l10n.csvMappingNeedsName);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final existingGames =
          await ref.read(notionCsvImportRepositoryProvider).loadExistingGames();
      final preview = ref
          .read(buildImportPreviewUseCaseProvider)
          .call(
            document: document,
            mapping: mapping,
            existingGames: existingGames,
          );
      setState(() => _preview = preview);
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmImport() async {
    final preview = _preview;
    if (preview == null || preview.importableCount == 0) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            scrollable: true,
            title: Text(context.l10n.csvConfirmTitle),
            content: Text(
              context.l10n.csvConfirmMessage(preview.importableCount),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(context.l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(context.l10n.csvImportAction),
              ),
            ],
          ),
    );
    if (confirmed != true) return;

    setState(() {
      _importing = true;
      _error = null;
    });
    try {
      final result = await ref
          .read(importNotionCsvUseCaseProvider)
          .call(preview);
      setState(() => _result = result);
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }
}

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
          FilledButton.icon(
            onPressed: loading ? null : onPickFile,
            icon:
                loading
                    ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.upload_file_outlined),
            label: Text(
              document == null
                  ? context.l10n.csvSelect
                  : context.l10n.csvChange,
            ),
          ),
        ],
      ),
    );
  }
}

class CsvMappingStep extends StatelessWidget {
  const CsvMappingStep({
    required this.document,
    required this.mapping,
    required this.onChanged,
    required this.onApply,
    super.key,
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

class CsvPreviewStep extends StatelessWidget {
  const CsvPreviewStep({
    required this.preview,
    required this.importing,
    required this.onRowChanged,
    required this.onImport,
    super.key,
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
      trailing: FilledButton.icon(
        onPressed: importing || preview.importableCount == 0 ? null : onImport,
        icon:
            importing
                ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : const Icon(Icons.check_circle_outline),
        label: Text(context.l10n.csvConfirmImport),
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

class ImportResultStep extends StatelessWidget {
  const ImportResultStep({
    required this.result,
    required this.onBackToLibrary,
    super.key,
  });

  final ImportResult result;
  final VoidCallback onBackToLibrary;

  @override
  Widget build(BuildContext context) {
    return BvWizardStep(
      step: context.l10n.stepFour,
      title: context.l10n.csvResult,
      subtitle: context.l10n.csvResultDescription,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: BvSpacing.xs,
            runSpacing: BvSpacing.xs,
            children: [
              BvChip(
                label: context.l10n.csvImported(result.importedGames),
                selected: true,
              ),
              BvChip(label: context.l10n.csvSkipped(result.skippedRows)),
              BvChip(
                label: context.l10n.csvDuplicateSkipped(
                  result.duplicatesSkipped,
                ),
              ),
              BvChip(
                label: context.l10n.csvPlatformsCreated(
                  result.platformsCreated,
                ),
              ),
              BvChip(
                label: context.l10n.csvGenresCreated(result.genresCreated),
              ),
              BvChip(
                label: context.l10n.csvPlaythroughsCreated(
                  result.playthroughsCreated,
                ),
              ),
            ],
          ),
          const SizedBox(height: BvSpacing.md),
          FilledButton.icon(
            onPressed: onBackToLibrary,
            icon: const Icon(Icons.library_books_outlined),
            label: Text(context.l10n.csvBackToLibrary),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return BvStatusBanner(
      tone: BvBannerTone.danger,
      title: context.l10n.cannotContinue,
      message: message,
    );
  }
}
