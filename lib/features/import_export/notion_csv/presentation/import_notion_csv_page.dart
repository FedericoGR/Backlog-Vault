import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/bv_async_action_button.dart';
import '../../../../core/design_system/bv_chip.dart';
import '../../../../core/design_system/bv_empty_state.dart';
import '../../../../core/design_system/bv_layout.dart';
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
import '../domain/csv_column_mapping.dart';
import '../domain/csv_document.dart';
import '../domain/import_field.dart';
import '../domain/import_preview.dart';
import '../domain/import_result.dart';
import '../domain/normalized_import_row.dart';

part 'parts/csv_file_step.dart';
part 'parts/csv_mapping_step.dart';
part 'parts/csv_preview_step.dart';
part 'parts/csv_result_step.dart';

/// Guides the user through the existing Notion CSV import workflow.
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
      maxContentWidth: BvLayout.readableContentWidth,
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
            _CsvMappingStep(
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
            _CsvPreviewStep(
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
            _ImportResultStep(
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
      final selection =
          await ref.read(notionCsvImportViewModelProvider).pickAndParse();
      if (selection == null) return;

      setState(() {
        _document = selection.document;
        _mapping = selection.mapping;
        _preview = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = context.l10n.csvOperationFailed);
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
      final preview = await ref
          .read(notionCsvImportViewModelProvider)
          .buildPreview(document: document, mapping: mapping);
      setState(() => _preview = preview);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = context.l10n.csvOperationFailed);
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
          .read(notionCsvImportViewModelProvider)
          .import(preview);
      setState(() => _result = result);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = context.l10n.csvOperationFailed);
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }
}
