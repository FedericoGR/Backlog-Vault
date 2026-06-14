import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/privacy/privacy_redactor.dart';
import '../../library/data/library_query_repository.dart';
import '../../library/domain/library_game_row.dart';
import '../../metadata/domain/metadata_provider.dart';
import '../application/bulk_cover_plan_resolver.dart';
import '../application/bulk_metadata_import_providers.dart';
import '../domain/bulk_metadata_import_models.dart';

enum _PreviewFilter {
  all,
  selected,
  safe,
  probable,
  ambiguous,
  errors,
  none,
  withMetadata,
  withCover,
  withReplacements;

  String get label => switch (this) {
    _PreviewFilter.all => 'Todos',
    _PreviewFilter.selected => 'Seleccionados',
    _PreviewFilter.safe => 'Seguros',
    _PreviewFilter.probable => 'Probables',
    _PreviewFilter.ambiguous => 'Ambiguos',
    _PreviewFilter.errors => 'Errores',
    _PreviewFilter.none => 'Sin resultado',
    _PreviewFilter.withMetadata => 'Con metadata',
    _PreviewFilter.withCover => 'Con cover',
    _PreviewFilter.withReplacements => 'Con reemplazos',
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
  BulkImportContentMode _contentMode = BulkImportContentMode.metadataAndCover;
  BulkMetadataImportScope _scope = BulkMetadataImportScope.all;
  BulkMetadataApplyMode _applyMode = BulkMetadataApplyMode.completeMissing;
  BulkCoverProviderMode _coverProviderMode = BulkCoverProviderMode.igdb;
  BulkExistingCoverMode _existingCoverMode = BulkExistingCoverMode.keepExisting;
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
                  contentMode: _contentMode,
                  scope: _scope,
                  applyMode: _applyMode,
                  coverProviderMode: _coverProviderMode,
                  existingCoverMode: _existingCoverMode,
                  busy: _scanning || _applying,
                  onProviderChanged:
                      (value) => setState(() => _providerId = value),
                  onContentModeChanged:
                      (value) => setState(() => _contentMode = value),
                  onScopeChanged: (value) => setState(() => _scope = value),
                  onApplyModeChanged:
                      (value) => setState(() => _applyMode = value),
                  onCoverProviderModeChanged:
                      (value) => setState(() => _coverProviderMode = value),
                  onExistingCoverModeChanged:
                      (value) => setState(() => _existingCoverMode = value),
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
      contentMode: _contentMode,
      applyMode: _applyMode,
      coverProviderMode: _coverProviderMode,
      existingCoverMode: _existingCoverMode,
      includeMetadata: _contentMode != BulkImportContentMode.coverOnly,
      includeMissingCovers:
          _contentMode != BulkImportContentMode.metadataOnly &&
          _coverProviderMode != BulkCoverProviderMode.none,
      replaceExistingCovers:
          _existingCoverMode == BulkExistingCoverMode.allowReplace,
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
            resolveCoverPlan:
                BulkCoverPlanResolver(
                  mediaProviders: ref.read(bulkMediaProviderListProvider),
                ).call,
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
            resolveCoverPlan:
                BulkCoverPlanResolver(
                  mediaProviders: ref.read(bulkMediaProviderListProvider),
                ).call,
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
    final plan = _plan;
    final requiredText =
        plan?.hasReplacements == true ? 'REEMPLAZAR' : 'APLICAR';
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
                        'Se aplicarán solo los juegos, campos y covers seleccionados.',
                      ),
                      if (plan != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Juegos: ${plan.selectedItems}\n'
                          'Campos nuevos: ${plan.selectedNewFieldChanges}\n'
                          'Campos reemplazados: ${plan.selectedReplacementFieldChanges}\n'
                          'Covers nuevos: ${plan.selectedNewCovers}\n'
                          'Covers reemplazados: ${plan.selectedReplacementCovers}',
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text('Escribí $requiredText para confirmar.'),
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
                          controller.text.trim().toUpperCase() == requiredText
                              ? () => Navigator.pop(context, true)
                              : null,
                      child: Text(
                        requiredText == 'REEMPLAZAR' ? 'Reemplazar' : 'Aplicar',
                      ),
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
    required this.contentMode,
    required this.scope,
    required this.applyMode,
    required this.coverProviderMode,
    required this.existingCoverMode,
    required this.busy,
    required this.onProviderChanged,
    required this.onContentModeChanged,
    required this.onScopeChanged,
    required this.onApplyModeChanged,
    required this.onCoverProviderModeChanged,
    required this.onExistingCoverModeChanged,
    required this.onScan,
  });

  final List<MetadataProvider> providers;
  final String selectedProviderId;
  final BulkImportContentMode contentMode;
  final BulkMetadataImportScope scope;
  final BulkMetadataApplyMode applyMode;
  final BulkCoverProviderMode coverProviderMode;
  final BulkExistingCoverMode existingCoverMode;
  final bool busy;
  final ValueChanged<String> onProviderChanged;
  final ValueChanged<BulkImportContentMode> onContentModeChanged;
  final ValueChanged<BulkMetadataImportScope> onScopeChanged;
  final ValueChanged<BulkMetadataApplyMode> onApplyModeChanged;
  final ValueChanged<BulkCoverProviderMode> onCoverProviderModeChanged;
  final ValueChanged<BulkExistingCoverMode> onExistingCoverModeChanged;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1. ¿Qué querés importar?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _ImportModePicker(
              selected: contentMode,
              busy: busy,
              onChanged: onContentModeChanged,
            ),
            const SizedBox(height: 18),
            Text('2. Opciones', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 720;
                final width = compact ? constraints.maxWidth : 320.0;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _OptionBox(
                      width: width,
                      child: DropdownButtonFormField<BulkMetadataImportScope>(
                        initialValue: scope,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Juegos a analizar',
                          helperText: 'Esto no decide qué se pisa.',
                        ),
                        items: [
                          for (final value in BulkMetadataImportScope.values)
                            DropdownMenuItem(
                              value: value,
                              child: Text(
                                value.label,
                                overflow: TextOverflow.ellipsis,
                              ),
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
                    if (contentMode != BulkImportContentMode.coverOnly) ...[
                      _OptionBox(
                        width: width,
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedProviderId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Provider metadata',
                          ),
                          items: [
                            for (final provider in providers)
                              DropdownMenuItem(
                                value: provider.providerId,
                                child: Text(
                                  provider.displayName,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged:
                              busy
                                  ? null
                                  : (value) {
                                    if (value != null) {
                                      onProviderChanged(value);
                                    }
                                  },
                        ),
                      ),
                      _OptionBox(
                        width: width,
                        child: DropdownButtonFormField<BulkMetadataApplyMode>(
                          initialValue: applyMode,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Modo metadata',
                          ),
                          items: [
                            for (final value in BulkMetadataApplyMode.values)
                              DropdownMenuItem(
                                value: value,
                                child: Text(
                                  value.label,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged:
                              busy
                                  ? null
                                  : (value) {
                                    if (value != null) {
                                      onApplyModeChanged(value);
                                    }
                                  },
                        ),
                      ),
                    ],
                    if (contentMode != BulkImportContentMode.metadataOnly) ...[
                      _OptionBox(
                        width: width,
                        child: DropdownButtonFormField<BulkCoverProviderMode>(
                          initialValue: coverProviderMode,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Fuente de portada',
                          ),
                          items: [
                            for (final value in BulkCoverProviderMode.values)
                              DropdownMenuItem(
                                value: value,
                                child: Text(
                                  value.label,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged:
                              busy
                                  ? null
                                  : (value) {
                                    if (value != null) {
                                      onCoverProviderModeChanged(value);
                                    }
                                  },
                        ),
                      ),
                      _OptionBox(
                        width: width,
                        child: DropdownButtonFormField<BulkExistingCoverMode>(
                          initialValue: existingCoverMode,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Portadas existentes',
                          ),
                          items: [
                            for (final value in BulkExistingCoverMode.values)
                              DropdownMenuItem(
                                value: value,
                                child: Text(
                                  value.label,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged:
                              busy
                                  ? null
                                  : (value) {
                                    if (value != null) {
                                      onExistingCoverModeChanged(value);
                                    }
                                  },
                        ),
                      ),
                    ],
                  ],
                );
              },
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

class _ImportModePicker extends StatelessWidget {
  const _ImportModePicker({
    required this.selected,
    required this.busy,
    required this.onChanged,
  });

  final BulkImportContentMode selected;
  final bool busy;
  final ValueChanged<BulkImportContentMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 720;
        final width =
            compact ? constraints.maxWidth : (constraints.maxWidth - 24) / 3;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final mode in BulkImportContentMode.values)
              SizedBox(
                width: width,
                child: _ImportModeCard(
                  mode: mode,
                  selected: selected == mode,
                  enabled: !busy,
                  onTap: () => onChanged(mode),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ImportModeCard extends StatelessWidget {
  const _ImportModeCard({
    required this.mode,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final BulkImportContentMode mode;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? colorScheme.primary : colorScheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
          color:
              selected
                  ? colorScheme.primaryContainer.withValues(alpha: 0.45)
                  : colorScheme.surface,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color:
                    selected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mode.label,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mode.description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionBox extends StatelessWidget {
  const _OptionBox({required this.width, required this.child});

  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final resolvedWidth = width.clamp(240.0, 420.0).toDouble();
    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(width: resolvedWidth),
      child: child,
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
                _statChip('Con match', plan.matchedItems.toString()),
                _statChip('Sin match', plan.withoutMatchItems.toString()),
                _statChip('Seguros', plan.safeItems.toString()),
                _statChip('Probables', plan.probableItems.toString()),
                _statChip('Ambiguos', plan.ambiguousItems.toString()),
                _statChip('Seleccionados', plan.selectedItems.toString()),
                _statChip(
                  'Campos nuevos',
                  plan.selectedNewFieldChanges.toString(),
                ),
                _statChip(
                  'Campos reemplazados',
                  plan.selectedReplacementFieldChanges.toString(),
                ),
                _statChip('Covers nuevos', plan.selectedNewCovers.toString()),
                _statChip(
                  'Covers reemplazados',
                  plan.selectedReplacementCovers.toString(),
                ),
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
      _PreviewFilter.selected => item.canApply,
      _PreviewFilter.safe => item.confidence == BulkMetadataConfidence.safe,
      _PreviewFilter.probable =>
        item.confidence == BulkMetadataConfidence.probable,
      _PreviewFilter.ambiguous =>
        item.confidence == BulkMetadataConfidence.ambiguous,
      _PreviewFilter.errors => item.hasErrorIssue,
      _PreviewFilter.none => item.confidence == BulkMetadataConfidence.none,
      _PreviewFilter.withMetadata => item.fieldPlans.isNotEmpty,
      _PreviewFilter.withCover => item.coverPlan?.canApply == true,
      _PreviewFilter.withReplacements =>
        item.fieldPlans.any((plan) => plan.selected && plan.replacesExisting) ||
            (item.coverPlan?.selected == true &&
                item.coverPlan?.replacesExisting == true),
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
            item.issues.map((issue) => issue.displayMessage).join(' · '),
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
                const Text('No hay campos de metadata para aplicar.')
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
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(item.fieldPlans[index].field.label),
                        ),
                        if (item.fieldPlans[index].replacesExisting)
                          const _Badge(label: 'reemplaza'),
                        if (item.fieldPlans[index].isProtected)
                          const _Badge(label: 'protegido'),
                      ],
                    ),
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
                        ? [
                          item.coverPlan!.asset!.providerName,
                          if (item.coverPlan!.replacesExisting)
                            'reemplaza ${item.coverPlan!.currentProviderName ?? 'portada actual'}',
                        ].join(' · ')
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
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.spaceBetween,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Text(
                '${plan.selectedItems} juegos seleccionados · '
                '${plan.selectedNewFieldChanges} campos a completar · '
                '${plan.selectedReplacementFieldChanges} campos a reemplazar · '
                '${plan.selectedNewCovers} portadas nuevas · '
                '${plan.selectedReplacementCovers} portadas a reemplazar.',
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

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
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
                _chip('Analizados', result.analyzed.toString()),
                _chip('Con match', result.matched.toString()),
                _chip('Sin match', result.withoutMatch.toString()),
                _chip('Seguros', result.safeMatches.toString()),
                _chip('Probables', result.probableMatches.toString()),
                _chip('Ambiguos', result.ambiguousMatches.toString()),
                _chip('Procesados', result.processed.toString()),
                _chip(
                  'Metadata nueva',
                  result.newFieldChangesApplied.toString(),
                ),
                _chip(
                  'Metadata reemplazada',
                  result.replacedFieldChangesApplied.toString(),
                ),
                _chip('Vínculos', result.externalLinksSaved.toString()),
                _chip('Covers nuevos', result.newCoversSaved.toString()),
                _chip(
                  'Covers reemplazados',
                  result.replacedCoversSaved.toString(),
                ),
                _chip('Omitidos', result.skipped.toString()),
                _chip('Warnings', result.warnings.length.toString()),
                _chip('Errores', result.errors.length.toString()),
              ],
            ),
            if (result.warnings.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Warnings', style: Theme.of(context).textTheme.titleSmall),
              for (final warning in result.warnings)
                Text(warning.displayMessage),
            ],
            if (result.errors.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Errores', style: Theme.of(context).textTheme.titleSmall),
              for (final error in result.errors) Text(error.displayMessage),
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
