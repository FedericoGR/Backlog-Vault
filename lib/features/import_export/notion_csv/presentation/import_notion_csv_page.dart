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
      title: 'Importar CSV de Notion',
      body: ListView(
        children: [
          const BvStatusBanner(
            title: 'Flujo de importación',
            message:
                'Este flujo crea juegos nuevos a partir del CSV exportado desde Notion. No actualiza juegos existentes y te deja revisar el mapping antes de aplicar cambios.',
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
      setState(() => _error = 'El mapping necesita una columna para Nombre.');
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
            title: const Text('Confirmar importación'),
            content: Text(
              'Se importarán ${preview.importableCount} juegos. No se actualizarán juegos existentes.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Importar'),
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
      step: 'Paso 1',
      title: 'Elegir archivo',
      subtitle:
          'Seleccioná el CSV exportado desde Notion. La app detecta delimitador, columnas y cantidad de filas antes de avanzar.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (document == null)
            const BvEmptyState(
              title: 'Todavía no hay archivo seleccionado',
              message:
                  'Elegí un CSV para revisar headers, mapping y preview de importación.',
              icon: Icons.upload_file_outlined,
            )
          else
            BvSurface(
              child: Wrap(
                spacing: BvSpacing.sm,
                runSpacing: BvSpacing.sm,
                children: [
                  BvChip(label: document!.fileName, selected: true),
                  BvChip(label: '${document!.rowCount} filas'),
                  BvChip(label: '${document!.headers.length} columnas'),
                  BvChip(label: 'Delimitador "${document!.delimiter}"'),
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
            label: Text(document == null ? 'Seleccionar CSV' : 'Cambiar CSV'),
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
      step: 'Paso 2',
      title: 'Mapping de columnas',
      subtitle:
          'Definí cómo se interpretan los headers del CSV. Solo Nombre es obligatorio para generar preview.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!mapping.hasRequiredFields) ...[
            const BvStatusBanner(
              tone: BvBannerTone.danger,
              message: 'Falta mapear Nombre antes de generar el preview.',
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
                labelText: '${field.label}${field.isRequired ? ' *' : ''}',
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('No importar'),
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
            label: const Text('Generar preview'),
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
      step: 'Paso 3',
      title: 'Preview',
      subtitle:
          'Revisá qué filas se importan, cuáles quedan omitidas y dónde aparecen warnings o duplicados.',
      trailing: FilledButton.icon(
        onPressed: importing || preview.importableCount == 0 ? null : onImport,
        icon:
            importing
                ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : const Icon(Icons.check_circle_outline),
        label: const Text('Confirmar importación'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: BvSpacing.xs,
            runSpacing: BvSpacing.xs,
            children: [
              BvChip(
                label: '${preview.importableCount} importables',
                selected: true,
              ),
              BvChip(label: '${preview.omittedCount} omitidas'),
              BvChip(label: '${preview.warningCount} con warnings'),
              BvChip(label: '${preview.errorCount} con errores'),
              BvChip(label: '${preview.duplicateCount} duplicadas'),
            ],
          ),
          const SizedBox(height: BvSpacing.md),
          if (preview.rows.isEmpty)
            const BvEmptyState(
              title: 'No hay filas para revisar',
              message:
                  'El preview no generó resultados visibles para importar.',
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
                          ? 'Fila ${row.rowNumber} sin nombre'
                          : row.title,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    if (row.hasErrors)
                      const BvChip(
                        label: 'Con errores',
                        tone: BvChipTone.danger,
                      ),
                    if (row.hasWarnings)
                      const BvChip(label: 'Warning', tone: BvChipTone.warning),
                    if (row.hasDuplicates)
                      const BvChip(
                        label: 'Duplicado',
                        tone: BvChipTone.warning,
                      ),
                  ],
                ),
                const SizedBox(height: BvSpacing.xxs),
                Text(
                  [
                    parseGameStatus(row.status.name).label,
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
                          ? 'Omitir duplicado'
                          : 'Crear igual',
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
      step: 'Paso 4',
      title: 'Resultado',
      subtitle: 'Resumen de lo que entró realmente a tu biblioteca local.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: BvSpacing.xs,
            runSpacing: BvSpacing.xs,
            children: [
              BvChip(
                label: 'Importados ${result.importedGames}',
                selected: true,
              ),
              BvChip(label: 'Omitidas ${result.skippedRows}'),
              BvChip(label: 'Duplicados ${result.duplicatesSkipped}'),
              BvChip(label: 'Plataformas ${result.platformsCreated}'),
              BvChip(label: 'Géneros ${result.genresCreated}'),
              BvChip(label: 'Partidas ${result.playthroughsCreated}'),
            ],
          ),
          const SizedBox(height: BvSpacing.md),
          FilledButton.icon(
            onPressed: onBackToLibrary,
            icon: const Icon(Icons.library_books_outlined),
            label: const Text('Volver a biblioteca'),
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
      title: 'No se pudo continuar',
      message: message,
    );
  }
}
