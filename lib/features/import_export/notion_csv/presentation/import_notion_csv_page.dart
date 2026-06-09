import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/formatting/date_formatters.dart';
import '../../../library/domain/game_status.dart';
import '../../../library/domain/rating.dart';
import '../application/notion_csv_import_providers.dart';
import '../domain/csv_column_mapping.dart';
import '../domain/csv_document.dart';
import '../domain/import_field.dart';
import '../domain/import_preview.dart';
import '../domain/import_result.dart';
import '../domain/normalized_import_row.dart';
import '../data/notion_csv_import_repository.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Importar CSV de Notion')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_error != null) ...[
            _ErrorBanner(message: _error!),
            const SizedBox(height: 16),
          ],
          _FileStep(
            document: _document,
            loading: _loading,
            onPickFile: _pickFile,
          ),
          if (_document != null && _mapping != null && _result == null) ...[
            const SizedBox(height: 24),
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
            const SizedBox(height: 24),
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
            const SizedBox(height: 24),
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
            title: const Text('Confirmar importación'),
            content: Text(
              'Se importarán ${preview.importableCount} juegos. '
              'No se actualizarán juegos existentes.',
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Archivo CSV', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            if (document == null)
              const Text('Seleccioná un CSV exportado desde Notion.')
            else
              Text(
                '${document!.fileName} · ${document!.rowCount} filas · '
                '${document!.headers.length} columnas · delimitador "${document!.delimiter}"',
              ),
            const SizedBox(height: 12),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mapping de columnas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (!mapping.hasRequiredFields)
              const Text(
                'Falta mapear Nombre.',
                style: TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 8),
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
                    DropdownMenuItem<String?>(
                      value: header,
                      child: Text(header),
                    ),
                ],
                onChanged:
                    (header) => onChanged(mapping.copyWithField(field, header)),
              ),
              const SizedBox(height: 12),
            ],
            FilledButton.icon(
              onPressed: mapping.hasRequiredFields ? onApply : null,
              icon: const Icon(Icons.preview_outlined),
              label: const Text('Generar preview'),
            ),
          ],
        ),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Preview', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text('${preview.importableCount} importables')),
                Chip(label: Text('${preview.omittedCount} omitidas')),
                Chip(label: Text('${preview.warningCount} con warnings')),
                Chip(label: Text('${preview.errorCount} con errores')),
                Chip(label: Text('${preview.duplicateCount} duplicadas')),
              ],
            ),
            const SizedBox(height: 12),
            for (final row in preview.rows)
              _PreviewRowTile(row: row, onChanged: onRowChanged),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed:
                  importing || preview.importableCount == 0 ? null : onImport,
              icon:
                  importing
                      ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.check_circle_outline),
              label: const Text('Confirmar importación'),
            ),
          ],
        ),
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

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Checkbox(
        value: row.include,
        onChanged:
            row.hasErrors
                ? null
                : (value) => onChanged(row.copyWith(include: value ?? false)),
      ),
      title: Text(
        row.title.isEmpty ? 'Fila ${row.rowNumber} sin nombre' : row.title,
      ),
      subtitle: Text(
        [
          parseGameStatus(row.status.name).label,
          if (row.platforms.isNotEmpty) row.platforms.join(', '),
          if (row.genres.isNotEmpty) row.genres.join(', '),
          if (row.completedAt != null) formatVisibleDate(row.completedAt),
          formatStarRating(row.personalRating),
          if (issueTexts.isNotEmpty) issueTexts.join(' | '),
        ].join(' · '),
      ),
      trailing:
          row.hasDuplicates
              ? TextButton(
                onPressed:
                    () => onChanged(
                      row.copyWith(
                        include: true,
                        forceCreateDuplicate: !row.forceCreateDuplicate,
                      ),
                    ),
                child: Text(
                  row.forceCreateDuplicate ? 'Omitir dup.' : 'Crear igual',
                ),
              )
              : null,
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Importación finalizada',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text('Juegos importados: ${result.importedGames}'),
            Text('Filas omitidas: ${result.skippedRows}'),
            Text('Duplicados omitidos: ${result.duplicatesSkipped}'),
            Text('Plataformas creadas: ${result.platformsCreated}'),
            Text('Géneros creados: ${result.genresCreated}'),
            Text('Playthroughs creados: ${result.playthroughsCreated}'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onBackToLibrary,
              icon: const Icon(Icons.library_books_outlined),
              label: const Text('Volver a biblioteca'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
        ),
      ),
    );
  }
}
