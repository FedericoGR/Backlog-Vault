import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/privacy/privacy_redactor.dart';
import '../../library/data/library_query_repository.dart';
import '../../library/domain/library_game_row.dart';
import '../../metadata/domain/metadata_provider.dart';
import '../application/bulk_metadata_import_providers.dart';
import '../domain/bulk_metadata_import_models.dart';

enum _PreviewFilter {
  all,
  safe,
  probable,
  ambiguous,
  errors,
  none,
  withCover;

  String get label => switch (this) {
    _PreviewFilter.all => 'Todos',
    _PreviewFilter.safe => 'Seguros',
    _PreviewFilter.probable => 'Probables',
    _PreviewFilter.ambiguous => 'Ambiguos',
    _PreviewFilter.errors => 'Errores',
    _PreviewFilter.none => 'Sin resultado',
    _PreviewFilter.withCover => 'Con cover',
  };
}

class BulkMetadataImportPage extends ConsumerStatefulWidget {
  const BulkMetadataImportPage({super.key});

  @override
  ConsumerState<BulkMetadataImportPage> createState() =>
      _BulkMetadataImportPageState();
}

class _BulkMetadataImportPageState
    extends ConsumerState<BulkMetadataImportPage> {
  String _providerId = 'igdb';
  BulkMetadataImportScope _scope = BulkMetadataImportScope.onlyIncompleteFields;
  bool _includeMetadata = true;
  bool _includeCovers = true;
  bool _replaceCovers = false;
  bool _scanning = false;
  bool _applying = false;
  bool _cancelRequested = false;
  int _processed = 0;
  int _total = 0;
  String? _currentTitle;
  String? _error;
  BulkMetadataImportPlan? _plan;
  BulkImportResult? _result;
  _PreviewFilter _filter = _PreviewFilter.all;

  @override
  Widget build(BuildContext context) {
    final rows = ref.watch(libraryRowsProvider);
    final providers = ref.watch(bulkMetadataProviderListProvider);
    final selectedProvider = _providerById(providers, _providerId);

    return Scaffold(
      appBar: AppBar(title: const Text('Importar metadata')),
      body: rows.when(
        data:
            (libraryRows) => ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _OptionsCard(
                  providers: providers,
                  selectedProviderId: selectedProvider.providerId,
                  scope: _scope,
                  includeMetadata: _includeMetadata,
                  includeCovers: _includeCovers,
                  replaceCovers: _replaceCovers,
                  busy: _scanning || _applying,
                  onProviderChanged:
                      (value) => setState(() => _providerId = value),
                  onScopeChanged: (value) => setState(() => _scope = value),
                  onIncludeMetadataChanged:
                      (value) => setState(() => _includeMetadata = value),
                  onIncludeCoversChanged:
                      (value) => setState(() => _includeCovers = value),
                  onReplaceCoversChanged:
                      (value) => setState(() => _replaceCovers = value),
                  onScan: () => _scan(libraryRows, selectedProvider),
                ),
                if (_scanning) ...[
                  const SizedBox(height: 12),
                  _ProgressCard(
                    processed: _processed,
                    total: _total,
                    currentTitle: _currentTitle,
                    onCancel: () => setState(() => _cancelRequested = true),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  _ErrorCard(message: _error!),
                ],
                if (_plan != null) ...[
                  const SizedBox(height: 12),
                  _PreviewCard(
                    plan: _plan!,
                    filter: _filter,
                    onFilterChanged: (value) => setState(() => _filter = value),
                    onItemIncludedChanged: _setItemIncluded,
                    onFieldChanged: _setFieldSelected,
                    onCoverChanged: _setCoverSelected,
                    onCandidateSelected:
                        (item, candidate) =>
                            _selectCandidate(item, candidate, selectedProvider),
                  ),
                  const SizedBox(height: 12),
                  _ConfirmCard(
                    plan: _plan!,
                    applying: _applying,
                    onApply: _apply,
                  ),
                ],
                if (_result != null) ...[
                  const SizedBox(height: 12),
                  _ResultCard(result: _result!),
                ],
              ],
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stackTrace) =>
                _ErrorCard(message: privacyRedactor.redact(error.toString())),
      ),
    );
  }

  Future<void> _scan(
    List<LibraryGameRow> rows,
    MetadataProvider provider,
  ) async {
    setState(() {
      _scanning = true;
      _cancelRequested = false;
      _processed = 0;
      _total = 0;
      _currentTitle = null;
      _error = null;
      _plan = null;
      _result = null;
    });

    final options = BulkMetadataImportOptions(
      providerId: provider.providerId,
      scope: _scope,
      includeMetadata: _includeMetadata,
      includeMissingCovers: _includeCovers,
      replaceExistingCovers: _replaceCovers,
      maxConcurrency: 2,
    );

    try {
      final plan = await ref
          .read(buildBulkMetadataPlanUseCaseProvider)
          .call(
            rows: rows,
            provider: provider,
            options: options,
            loadExternalIds:
                ref.read(bulkMetadataRepositoryProvider).externalIdsForGame,
            onProgress: ({required processed, required total, title}) {
              if (!mounted) return;
              setState(() {
                _processed = processed;
                _total = total;
                _currentTitle = title;
              });
            },
            isCancelled: () => _cancelRequested,
          );
      if (!mounted) return;
      setState(() {
        _plan = plan;
        _filter = _PreviewFilter.all;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = privacyRedactor.redact(
          'No se pudo generar el preview. ${error.toString()}',
        );
      });
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  Future<void> _selectCandidate(
    BulkMetadataImportItem item,
    BulkMetadataCandidate candidate,
    MetadataProvider provider,
  ) async {
    final currentPlan = _plan;
    if (currentPlan == null) return;
    setState(() => _scanning = true);
    try {
      final rebuilt = await ref
          .read(buildBulkMetadataPlanUseCaseProvider)
          .buildItemFromCandidate(
            row: item.row,
            provider: provider,
            options: currentPlan.options,
            selectedCandidate: candidate,
            candidates: item.candidates,
            loadExternalIds:
                ref.read(bulkMetadataRepositoryProvider).externalIdsForGame,
          );
      final nextItem =
          rebuilt.hasErrorIssue ? rebuilt : rebuilt.copyWith(included: true);
      _replaceItem(item, nextItem);
    } catch (error) {
      setState(() {
        _error = privacyRedactor.redact(error.toString());
      });
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  Future<void> _apply() async {
    final plan = _plan;
    if (plan == null || plan.selectedItems == 0) return;
    final confirmed = await _confirmApply();
    if (!confirmed || !mounted) return;

    setState(() {
      _applying = true;
      _error = null;
      _result = null;
    });
    try {
      final result = await ref
          .read(applyBulkMetadataPlanUseCaseProvider)
          .call(plan);
      if (!mounted) return;
      setState(() => _result = result);
      ref.invalidate(libraryRowsProvider);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = privacyRedactor.redact(error.toString()));
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }

  Future<bool> _confirmApply() async {
    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: const Text('Confirmar importación masiva'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Se aplicarán solo los juegos y campos seleccionados. Escribí APLICAR para confirmar.',
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          labelText: 'Confirmación',
                        ),
                        onChanged: (_) => setDialogState(() {}),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      onPressed:
                          controller.text.trim().toUpperCase() == 'APLICAR'
                              ? () => Navigator.pop(context, true)
                              : null,
                      child: const Text('Aplicar'),
                    ),
                  ],
                ),
          ),
    );
    controller.dispose();
    return result == true;
  }

  void _setItemIncluded(BulkMetadataImportItem item, bool included) {
    _replaceItem(item, item.copyWith(included: included));
  }

  void _setFieldSelected(
    BulkMetadataImportItem item,
    int fieldIndex,
    bool selected,
  ) {
    final fields = [...item.fieldPlans];
    fields[fieldIndex] = fields[fieldIndex].copyWith(selected: selected);
    _replaceItem(item, item.copyWith(fieldPlans: fields));
  }

  void _setCoverSelected(BulkMetadataImportItem item, bool selected) {
    final cover = item.coverPlan;
    if (cover == null) return;
    _replaceItem(
      item,
      item.copyWith(coverPlan: cover.copyWith(selected: selected)),
    );
  }

  void _replaceItem(
    BulkMetadataImportItem previous,
    BulkMetadataImportItem next,
  ) {
    final currentPlan = _plan;
    if (currentPlan == null) return;
    final items = [...currentPlan.items];
    final index = items.indexWhere(
      (item) => item.row.libraryEntryId == previous.row.libraryEntryId,
    );
    if (index == -1) return;
    items[index] = next;
    setState(() => _plan = currentPlan.copyWith(items: items));
  }

  MetadataProvider _providerById(
    List<MetadataProvider> providers,
    String providerId,
  ) {
    for (final provider in providers) {
      if (provider.providerId == providerId) return provider;
    }
    return providers.first;
  }
}

class _OptionsCard extends StatelessWidget {
  const _OptionsCard({
    required this.providers,
    required this.selectedProviderId,
    required this.scope,
    required this.includeMetadata,
    required this.includeCovers,
    required this.replaceCovers,
    required this.busy,
    required this.onProviderChanged,
    required this.onScopeChanged,
    required this.onIncludeMetadataChanged,
    required this.onIncludeCoversChanged,
    required this.onReplaceCoversChanged,
    required this.onScan,
  });

  final List<MetadataProvider> providers;
  final String selectedProviderId;
  final BulkMetadataImportScope scope;
  final bool includeMetadata;
  final bool includeCovers;
  final bool replaceCovers;
  final bool busy;
  final ValueChanged<String> onProviderChanged;
  final ValueChanged<BulkMetadataImportScope> onScopeChanged;
  final ValueChanged<bool> onIncludeMetadataChanged;
  final ValueChanged<bool> onIncludeCoversChanged;
  final ValueChanged<bool> onReplaceCoversChanged;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Opciones', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 260,
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedProviderId,
                    decoration: const InputDecoration(labelText: 'Proveedor'),
                    items: [
                      for (final provider in providers)
                        DropdownMenuItem(
                          value: provider.providerId,
                          child: Text(provider.displayName),
                        ),
                    ],
                    onChanged:
                        busy
                            ? null
                            : (value) {
                              if (value != null) onProviderChanged(value);
                            },
                  ),
                ),
                SizedBox(
                  width: 280,
                  child: DropdownButtonFormField<BulkMetadataImportScope>(
                    initialValue: scope,
                    decoration: const InputDecoration(labelText: 'Alcance'),
                    items: [
                      for (final value in BulkMetadataImportScope.values)
                        DropdownMenuItem(
                          value: value,
                          child: Text(value.label),
                        ),
                    ],
                    onChanged:
                        busy
                            ? null
                            : (value) {
                              if (value != null) onScopeChanged(value);
                            },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 0,
              children: [
                FilterChip(
                  label: const Text('Metadata'),
                  selected: includeMetadata,
                  onSelected: busy ? null : onIncludeMetadataChanged,
                ),
                FilterChip(
                  label: const Text('Covers faltantes'),
                  selected: includeCovers,
                  onSelected: busy ? null : onIncludeCoversChanged,
                ),
                FilterChip(
                  label: const Text('Reemplazar covers existentes'),
                  selected: replaceCovers,
                  onSelected: busy ? null : onReplaceCoversChanged,
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: busy ? null : onScan,
              icon: const Icon(Icons.manage_search_outlined),
              label: const Text('Generar preview'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.processed,
    required this.total,
    required this.currentTitle,
    required this.onCancel,
  });

  final int processed;
  final int total;
  final String? currentTitle;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? null : processed / total;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Escaneando biblioteca',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 8),
            Text(
              '$processed / $total${currentTitle == null ? '' : ' · $currentTitle'}',
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onCancel,
              icon: const Icon(Icons.stop_circle_outlined),
              label: const Text('Cancelar próximas consultas'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.plan,
    required this.filter,
    required this.onFilterChanged,
    required this.onItemIncludedChanged,
    required this.onFieldChanged,
    required this.onCoverChanged,
    required this.onCandidateSelected,
  });

  final BulkMetadataImportPlan plan;
  final _PreviewFilter filter;
  final ValueChanged<_PreviewFilter> onFilterChanged;
  final void Function(BulkMetadataImportItem item, bool included)
  onItemIncludedChanged;
  final void Function(
    BulkMetadataImportItem item,
    int fieldIndex,
    bool selected,
  )
  onFieldChanged;
  final void Function(BulkMetadataImportItem item, bool selected)
  onCoverChanged;
  final void Function(
    BulkMetadataImportItem item,
    BulkMetadataCandidate candidate,
  )
  onCandidateSelected;

  @override
  Widget build(BuildContext context) {
    final visibleItems = plan.items.where(_matchesFilter).toList();
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
                _statChip('Analizados', plan.items.length.toString()),
                _statChip('Seleccionados', plan.selectedItems.toString()),
                _statChip('Campos', plan.selectedFieldChanges.toString()),
                _statChip('Covers', plan.selectedCovers.toString()),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final value in _PreviewFilter.values)
                  FilterChip(
                    label: Text(value.label),
                    selected: filter == value,
                    onSelected: (_) => onFilterChanged(value),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (visibleItems.isEmpty)
              const Text('No hay juegos para este filtro.')
            else
              for (final item in visibleItems)
                _PreviewItemTile(
                  item: item,
                  onIncludedChanged:
                      (value) => onItemIncludedChanged(item, value),
                  onFieldChanged:
                      (index, selected) =>
                          onFieldChanged(item, index, selected),
                  onCoverChanged: (selected) => onCoverChanged(item, selected),
                  onCandidateSelected:
                      (candidate) => onCandidateSelected(item, candidate),
                ),
          ],
        ),
      ),
    );
  }

  bool _matchesFilter(BulkMetadataImportItem item) {
    return switch (filter) {
      _PreviewFilter.all => true,
      _PreviewFilter.safe => item.confidence == BulkMetadataConfidence.safe,
      _PreviewFilter.probable =>
        item.confidence == BulkMetadataConfidence.probable,
      _PreviewFilter.ambiguous =>
        item.confidence == BulkMetadataConfidence.ambiguous,
      _PreviewFilter.errors => item.hasErrorIssue,
      _PreviewFilter.none => item.confidence == BulkMetadataConfidence.none,
      _PreviewFilter.withCover => item.coverPlan?.canApply == true,
    };
  }

  Widget _statChip(String label, String value) {
    return InputChip(onPressed: null, label: Text('$label: $value'));
  }
}

class _PreviewItemTile extends StatelessWidget {
  const _PreviewItemTile({
    required this.item,
    required this.onIncludedChanged,
    required this.onFieldChanged,
    required this.onCoverChanged,
    required this.onCandidateSelected,
  });

  final BulkMetadataImportItem item;
  final ValueChanged<bool> onIncludedChanged;
  final void Function(int index, bool selected) onFieldChanged;
  final ValueChanged<bool> onCoverChanged;
  final ValueChanged<BulkMetadataCandidate> onCandidateSelected;

  @override
  Widget build(BuildContext context) {
    final best = item.candidates.isEmpty ? null : item.candidates.first;
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      leading: Checkbox(
        value: item.included,
        onChanged:
            item.selectedDetails == null || item.hasErrorIssue
                ? null
                : (value) => onIncludedChanged(value ?? false),
      ),
      title: Text(item.row.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        [
          item.confidence.label,
          if (best != null) best.candidate.title,
          if (item.issues.isNotEmpty)
            item.issues.map((issue) => issue.message).join(' · '),
        ].join(' · '),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 0, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.candidates.isNotEmpty) ...[
                Text(
                  'Candidatos',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                for (final candidate in item.candidates.take(4))
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(candidate.candidate.title),
                    subtitle: Text(
                      '${candidate.confidence.label} · score ${candidate.score}'
                      '${candidate.reasons.isEmpty ? '' : ' · ${candidate.reasons.join(', ')}'}',
                    ),
                    trailing: TextButton(
                      onPressed: () => onCandidateSelected(candidate),
                      child: const Text('Usar'),
                    ),
                  ),
                const SizedBox(height: 8),
              ],
              if (item.fieldPlans.isEmpty)
                const Text('No hay campos nuevos seleccionables.')
              else ...[
                Text('Campos', style: Theme.of(context).textTheme.titleSmall),
                for (var index = 0; index < item.fieldPlans.length; index++)
                  CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    value: item.fieldPlans[index].selected,
                    onChanged:
                        item.fieldPlans[index].canApply &&
                                !item.fieldPlans[index].isProtected
                            ? (value) => onFieldChanged(index, value ?? false)
                            : null,
                    title: Text(item.fieldPlans[index].field.label),
                    subtitle: Text(
                      'Actual: ${item.fieldPlans[index].currentValue}\nExterno: ${item.fieldPlans[index].externalValue}',
                    ),
                  ),
              ],
              if (item.coverPlan != null) ...[
                const SizedBox(height: 8),
                CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  value: item.coverPlan!.selected,
                  onChanged:
                      item.coverPlan!.canApply
                          ? (value) => onCoverChanged(value ?? false)
                          : null,
                  title: const Text('Guardar portada'),
                  subtitle: Text(
                    item.coverPlan!.canApply
                        ? item.coverPlan!.asset!.providerName
                        : item.coverPlan!.reason ?? 'No disponible',
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ConfirmCard extends StatelessWidget {
  const _ConfirmCard({
    required this.plan,
    required this.applying,
    required this.onApply,
  });

  final BulkMetadataImportPlan plan;
  final bool applying;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${plan.selectedItems} juegos seleccionados, ${plan.selectedFieldChanges} campos y ${plan.selectedCovers} covers.',
              ),
            ),
            FilledButton.icon(
              onPressed: applying || plan.selectedItems == 0 ? null : onApply,
              icon:
                  applying
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.check),
              label: const Text('Aplicar cambios'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final BulkImportResult result;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resultado', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip('Procesados', result.processed.toString()),
                _chip('Metadata', result.metadataApplied.toString()),
                _chip('Covers', result.coversSaved.toString()),
                _chip('Omitidos', result.skipped.toString()),
                _chip('Warnings', result.warnings.length.toString()),
                _chip('Errores', result.errors.length.toString()),
              ],
            ),
            if (result.warnings.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Warnings', style: Theme.of(context).textTheme.titleSmall),
              for (final warning in result.warnings) Text(warning.message),
            ],
            if (result.errors.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Errores', style: Theme.of(context).textTheme.titleSmall),
              for (final error in result.errors) Text(error.message),
            ],
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, String value) {
    return InputChip(onPressed: null, label: Text('$label: $value'));
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          message,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
    );
  }
}
