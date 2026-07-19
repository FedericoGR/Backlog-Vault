import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/bv_async_action_button.dart';
import '../../../core/design_system/bv_chip.dart';
import '../../../core/design_system/bv_empty_state.dart';
import '../../../core/design_system/bv_loading_state.dart';
import '../../../core/design_system/bv_layout.dart';
import '../../../core/design_system/bv_page_scaffold.dart';
import '../../../core/design_system/bv_progress_panel.dart';
import '../../../core/design_system/bv_spacing.dart';
import '../../../core/design_system/bv_status_banner.dart';
import '../../../core/design_system/bv_wizard_step.dart';
import '../../../l10n/domain_localizations.dart';
import '../../../l10n/l10n.dart';
import '../../library/application/library_providers.dart';
import '../../library/domain/library_game_row.dart';
import '../../media/domain/media_asset_models.dart';
import '../../metadata/domain/metadata_provider.dart';
import '../application/bulk_metadata_import_providers.dart';
import '../domain/bulk_metadata_import_models.dart';

part 'parts/bulk_apply_confirmation.dart';
part 'parts/bulk_options.dart';
part 'parts/bulk_preview.dart';
part 'parts/bulk_result.dart';

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
  withReplacements,
}

String _previewFilterLabel(BuildContext context, _PreviewFilter filter) =>
    switch (filter) {
      _PreviewFilter.all => context.l10n.bulkFilterAll,
      _PreviewFilter.selected => context.l10n.bulkFilterSelected,
      _PreviewFilter.safe => context.l10n.bulkFilterSafe,
      _PreviewFilter.probable => context.l10n.bulkFilterProbable,
      _PreviewFilter.ambiguous => context.l10n.bulkFilterAmbiguous,
      _PreviewFilter.errors => context.l10n.bulkFilterErrors,
      _PreviewFilter.none => context.l10n.bulkFilterNoResult,
      _PreviewFilter.withMetadata => context.l10n.bulkFilterMetadata,
      _PreviewFilter.withCover => context.l10n.bulkFilterCover,
      _PreviewFilter.withReplacements => context.l10n.bulkFilterReplacements,
    };

enum _BulkSelectionAction {
  selectVisible,
  deselectAll,
  selectSafe,
  selectWithCover,
  selectNewCovers,
  selectReplacementCovers,
  selectNewFields,
  selectReplacementFields,
}

/// Guides the user through previewing and applying bulk metadata changes.
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

    return BvPageScaffold(
      title: context.l10n.bulkTitle,
      maxContentWidth: BvLayout.wideContentWidth,
      body: rows.when(
        data:
            (libraryRows) => ListView(
              children: [
                BvStatusBanner(
                  title: context.l10n.bulkIntroTitle,
                  message: context.l10n.bulkIntroDescription,
                ),
                const SizedBox(height: BvSpacing.md),
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
                  const SizedBox(height: BvSpacing.md),
                  _ProgressCard(
                    processed: _processed,
                    total: _total,
                    currentTitle: _currentTitle,
                    onCancel: () => setState(() => _cancelRequested = true),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: BvSpacing.md),
                  _ErrorCard(message: _error!),
                ],
                if (_plan != null) ...[
                  const SizedBox(height: BvSpacing.md),
                  _PreviewCard(
                    plan: _plan!,
                    filter: _filter,
                    onFilterChanged: (value) => setState(() => _filter = value),
                    onItemIncludedChanged: _setItemIncluded,
                    onFieldChanged: _setFieldSelected,
                    onCoverChanged: _setCoverSelected,
                    onCoverAssetChanged: _setCoverAssetSelected,
                    onBulkSelection: _applyBulkSelection,
                    onCandidateSelected:
                        (item, candidate) =>
                            _selectCandidate(item, candidate, selectedProvider),
                  ),
                  const SizedBox(height: BvSpacing.md),
                  _ConfirmCard(
                    plan: _plan!,
                    applying: _applying,
                    onApply: _apply,
                  ),
                ],
                if (_result != null) ...[
                  const SizedBox(height: BvSpacing.md),
                  _ResultCard(
                    result: _result!,
                    onNewPreview: () => setState(() => _result = null),
                    onBackToLibrary: () => context.go('/'),
                  ),
                ],
              ],
            ),
        loading: () => BvLoadingState(label: context.l10n.bulkLoadingLibrary),
        error:
            (error, stackTrace) =>
                _ErrorCard(message: context.l10n.bulkOperationFailed),
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
          .read(bulkMetadataImportViewModelProvider)
          .scan(
            rows: rows,
            provider: provider,
            options: options,
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
        _error = context.l10n.bulkPreviewFailed;
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
          .read(bulkMetadataImportViewModelProvider)
          .rebuildItem(
            item: item,
            provider: provider,
            options: currentPlan.options,
            candidate: candidate,
          );
      final nextItem =
          rebuilt.hasErrorIssue ? rebuilt : rebuilt.copyWith(included: true);
      _replaceItem(item, nextItem);
    } catch (error) {
      setState(() {
        _error = context.l10n.bulkOperationFailed;
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
          .read(bulkMetadataImportViewModelProvider)
          .apply(plan);
      if (!mounted) return;
      setState(() {
        _result = result;
        _plan = null;
      });
      ref.invalidate(libraryRowsProvider);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = context.l10n.bulkOperationFailed);
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }

  Future<bool> _confirmApply() async {
    final plan = _plan;
    final replaces = plan?.hasReplacements == true;
    final requiredText =
        (replaces ? context.l10n.replace : context.l10n.apply).toUpperCase();
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => _ApplyConfirmationDialog(
            plan: plan,
            requiredText: requiredText,
            replaces: replaces,
          ),
    );
    return result == true;
  }

  void _setItemIncluded(BulkMetadataImportItem item, bool included) {
    if (included) {
      var next = item.copyWith(included: true);
      final cover = next.coverPlan;
      if (_plan?.options.contentMode == BulkImportContentMode.coverOnly &&
          cover != null &&
          cover.canApply) {
        next = next.copyWith(coverPlan: cover.copyWith(selected: true));
      }
      _replaceItem(item, next);
      return;
    }

    _replaceItem(item, _clearItemSelection(item));
  }

  void _setFieldSelected(
    BulkMetadataImportItem item,
    int fieldIndex,
    bool selected,
  ) {
    final fields = [...item.fieldPlans];
    fields[fieldIndex] = fields[fieldIndex].copyWith(selected: selected);
    _replaceItem(item, _syncItemIncluded(item.copyWith(fieldPlans: fields)));
  }

  void _setCoverSelected(BulkMetadataImportItem item, bool selected) {
    final cover = item.coverPlan;
    if (cover == null) return;
    _replaceItem(
      item,
      _syncItemIncluded(
        item.copyWith(coverPlan: cover.copyWith(selected: selected)),
      ),
    );
  }

  void _setCoverAssetSelected(
    BulkMetadataImportItem item,
    ExternalMediaAsset asset,
  ) {
    final cover = item.coverPlan;
    if (cover == null) return;
    _replaceItem(
      item,
      _syncItemIncluded(
        item.copyWith(
          coverPlan: cover.copyWith(
            asset: asset,
            candidateAssets: cover.availableAssets
                .where(
                  (candidate) =>
                      candidate.providerId != asset.providerId ||
                      candidate.externalId != asset.externalId ||
                      candidate.remoteUrl != asset.remoteUrl,
                )
                .toList(growable: false),
            selected: true,
          ),
        ),
      ),
    );
  }

  void _applyBulkSelection(
    _BulkSelectionAction action,
    List<BulkMetadataImportItem> visibleItems,
  ) {
    final currentPlan = _plan;
    if (currentPlan == null) return;
    final visibleIds =
        visibleItems.map((item) => item.row.libraryEntryId).toSet();
    final items =
        currentPlan.items.map((item) {
          final isVisible = visibleIds.contains(item.row.libraryEntryId);
          if (action == _BulkSelectionAction.deselectAll) {
            return _clearItemSelection(item);
          }
          if (!isVisible) return item;
          return _applySelectionActionToItem(item, action, currentPlan.options);
        }).toList();
    setState(() => _plan = currentPlan.copyWith(items: items));
  }

  BulkMetadataImportItem _applySelectionActionToItem(
    BulkMetadataImportItem item,
    _BulkSelectionAction action,
    BulkMetadataImportOptions options,
  ) {
    if (item.hasErrorIssue) return _clearItemSelection(item);

    var fields = [...item.fieldPlans];
    var cover = item.coverPlan;
    var shouldInclude = item.included;

    bool isSafeForDestructiveSelection() {
      return item.confidence == BulkMetadataConfidence.safe;
    }

    void selectNewFields() {
      for (var index = 0; index < fields.length; index++) {
        final field = fields[index];
        if (field.canApply && !field.isProtected && !field.replacesExisting) {
          fields[index] = field.copyWith(selected: true);
          shouldInclude = true;
        }
      }
    }

    void selectReplacementFields() {
      if (options.applyMode != BulkMetadataApplyMode.reviewAndReplace ||
          !isSafeForDestructiveSelection()) {
        return;
      }
      for (var index = 0; index < fields.length; index++) {
        final field = fields[index];
        if (field.canApply && !field.isProtected && field.replacesExisting) {
          fields[index] = field.copyWith(selected: true);
          shouldInclude = true;
        }
      }
    }

    void selectCover({required bool replacements}) {
      final current = cover;
      if (current == null || !current.canApply) return;
      if (current.replacesExisting != replacements) return;
      if (replacements && !options.allowCoverReplacement) return;
      cover = current.copyWith(selected: true);
      shouldInclude = true;
    }

    switch (action) {
      case _BulkSelectionAction.selectVisible:
        selectNewFields();
        selectCover(replacements: false);
      case _BulkSelectionAction.selectSafe:
        if (item.confidence == BulkMetadataConfidence.safe) {
          selectNewFields();
          selectCover(replacements: false);
        }
      case _BulkSelectionAction.selectWithCover:
        selectCover(replacements: false);
      case _BulkSelectionAction.selectNewCovers:
        selectCover(replacements: false);
      case _BulkSelectionAction.selectReplacementCovers:
        selectCover(replacements: true);
      case _BulkSelectionAction.selectNewFields:
        selectNewFields();
      case _BulkSelectionAction.selectReplacementFields:
        selectReplacementFields();
      case _BulkSelectionAction.deselectAll:
        return _clearItemSelection(item);
    }

    return _syncItemIncluded(
      item.copyWith(
        included: shouldInclude,
        fieldPlans: fields,
        coverPlan: cover,
      ),
    );
  }

  BulkMetadataImportItem _clearItemSelection(BulkMetadataImportItem item) {
    return item.copyWith(
      included: false,
      fieldPlans: [
        for (final field in item.fieldPlans) field.copyWith(selected: false),
      ],
      coverPlan: item.coverPlan?.copyWith(selected: false),
    );
  }

  BulkMetadataImportItem _syncItemIncluded(BulkMetadataImportItem item) {
    final hasSelectedField = item.fieldPlans.any((field) => field.selected);
    final hasSelectedCover = item.coverPlan?.selected == true;
    final hasSelectedMetadataLink =
        item.selectedDetails != null && item.included;
    return item.copyWith(
      included: hasSelectedField || hasSelectedCover || hasSelectedMetadataLink,
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
