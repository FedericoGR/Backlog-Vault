part of '../bulk_metadata_import_page.dart';

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.plan,
    required this.filter,
    required this.onFilterChanged,
    required this.onItemIncludedChanged,
    required this.onFieldChanged,
    required this.onCoverChanged,
    required this.onCoverAssetChanged,
    required this.onBulkSelection,
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
  final void Function(BulkMetadataImportItem item, ExternalMediaAsset asset)
  onCoverAssetChanged;
  final void Function(
    _BulkSelectionAction action,
    List<BulkMetadataImportItem> visibleItems,
  )
  onBulkSelection;
  final void Function(
    BulkMetadataImportItem item,
    BulkMetadataCandidate candidate,
  )
  onCandidateSelected;

  @override
  Widget build(BuildContext context) {
    final visibleItems = plan.items.where(_matchesFilter).toList();
    return BvWizardStep(
      step: context.l10n.stepTwo,
      title: context.l10n.bulkPreviewTitle,
      subtitle: context.l10n.bulkPreviewDescription,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: BvSpacing.xs,
            runSpacing: BvSpacing.xs,
            children: [
              _statChip(
                context.l10n.bulkAnalyzed,
                plan.items.length.toString(),
              ),
              if (plan.options.contentMode !=
                  BulkImportContentMode.coverOnly) ...[
                _statChip(
                  context.l10n.bulkWithMatch,
                  plan.matchedItems.toString(),
                ),
                _statChip(
                  context.l10n.bulkWithoutMatch,
                  plan.withoutMatchItems.toString(),
                ),
                _statChip(context.l10n.bulkSafe, plan.safeItems.toString()),
                _statChip(
                  context.l10n.bulkProbable,
                  plan.probableItems.toString(),
                ),
                _statChip(
                  context.l10n.bulkAmbiguous,
                  plan.ambiguousItems.toString(),
                ),
              ] else ...[
                _statChip(
                  context.l10n.bulkWithCover,
                  plan.items
                      .where((item) => item.coverPlan?.canApply == true)
                      .length
                      .toString(),
                ),
                _statChip(
                  context.l10n.bulkWithoutCover,
                  plan.items
                      .where((item) => item.coverPlan?.canApply != true)
                      .length
                      .toString(),
                ),
              ],
              _statChip(
                context.l10n.bulkSelected,
                plan.selectedItems.toString(),
              ),
              if (plan.options.contentMode !=
                  BulkImportContentMode.coverOnly) ...[
                _statChip(
                  context.l10n.bulkNewFields,
                  plan.selectedNewFieldChanges.toString(),
                ),
                _statChip(
                  context.l10n.bulkReplacedFields,
                  plan.selectedReplacementFieldChanges.toString(),
                ),
              ],
              _statChip(
                context.l10n.bulkNewCovers,
                plan.selectedNewCovers.toString(),
              ),
              _statChip(
                context.l10n.bulkReplacedCovers,
                plan.selectedReplacementCovers.toString(),
              ),
            ],
          ),
          const SizedBox(height: BvSpacing.md),
          Wrap(
            spacing: BvSpacing.xs,
            runSpacing: BvSpacing.xs,
            children: [
              for (final value in _visibleFilters)
                FilterChip(
                  label: Text(_previewFilterLabel(context, value)),
                  selected: filter == value,
                  onSelected: (_) => onFilterChanged(value),
                ),
            ],
          ),
          const SizedBox(height: BvSpacing.md),
          Wrap(
            spacing: BvSpacing.xs,
            runSpacing: BvSpacing.xs,
            children: [
              ActionChip(
                avatar: const Icon(Icons.select_all, size: 18),
                label: Text(context.l10n.bulkSelectVisible),
                onPressed:
                    visibleItems.isEmpty
                        ? null
                        : () => onBulkSelection(
                          _BulkSelectionAction.selectVisible,
                          visibleItems,
                        ),
              ),
              ActionChip(
                avatar: const Icon(Icons.clear_all, size: 18),
                label: Text(context.l10n.bulkDeselectAll),
                onPressed:
                    () => onBulkSelection(
                      _BulkSelectionAction.deselectAll,
                      visibleItems,
                    ),
              ),
              ActionChip(
                label: Text(context.l10n.bulkSelectSafe),
                onPressed:
                    visibleItems.isEmpty
                        ? null
                        : () => onBulkSelection(
                          _BulkSelectionAction.selectSafe,
                          visibleItems,
                        ),
              ),
              ActionChip(
                label: Text(context.l10n.bulkWithCover),
                onPressed:
                    visibleItems.isEmpty
                        ? null
                        : () => onBulkSelection(
                          _BulkSelectionAction.selectWithCover,
                          visibleItems,
                        ),
              ),
              ActionChip(
                label: Text(context.l10n.bulkNewCoverSelection),
                onPressed:
                    visibleItems.isEmpty
                        ? null
                        : () => onBulkSelection(
                          _BulkSelectionAction.selectNewCovers,
                          visibleItems,
                        ),
              ),
              if (plan.options.allowCoverReplacement)
                ActionChip(
                  label: Text(context.l10n.bulkCoverReplacements),
                  onPressed:
                      visibleItems.isEmpty
                          ? null
                          : () => onBulkSelection(
                            _BulkSelectionAction.selectReplacementCovers,
                            visibleItems,
                          ),
                ),
              if (plan.options.shouldImportMetadata)
                ActionChip(
                  label: Text(context.l10n.bulkNewFields),
                  onPressed:
                      visibleItems.isEmpty
                          ? null
                          : () => onBulkSelection(
                            _BulkSelectionAction.selectNewFields,
                            visibleItems,
                          ),
                ),
              if (plan.options.allowMetadataReplacement)
                ActionChip(
                  label: Text(context.l10n.bulkReplaceableFields),
                  onPressed:
                      visibleItems.isEmpty
                          ? null
                          : () => onBulkSelection(
                            _BulkSelectionAction.selectReplacementFields,
                            visibleItems,
                          ),
                ),
            ],
          ),
          const SizedBox(height: BvSpacing.md),
          if (visibleItems.isEmpty)
            BvEmptyState(
              title: context.l10n.bulkNoGamesForFilter,
              message: context.l10n.bulkNoGamesForFilterMessage,
              icon: Icons.filter_alt_off_outlined,
            )
          else
            for (final item in visibleItems)
              _PreviewItemTile(
                item: item,
                contentMode: plan.options.contentMode,
                onIncludedChanged:
                    (value) => onItemIncludedChanged(item, value),
                onFieldChanged:
                    (index, selected) => onFieldChanged(item, index, selected),
                onCoverChanged: (selected) => onCoverChanged(item, selected),
                onCoverAssetChanged:
                    (asset) => onCoverAssetChanged(item, asset),
                onCandidateSelected:
                    (candidate) => onCandidateSelected(item, candidate),
              ),
        ],
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

  List<_PreviewFilter> get _visibleFilters {
    if (plan.options.contentMode != BulkImportContentMode.coverOnly) {
      return _PreviewFilter.values;
    }
    return const [
      _PreviewFilter.all,
      _PreviewFilter.selected,
      _PreviewFilter.errors,
      _PreviewFilter.withCover,
      _PreviewFilter.withReplacements,
    ];
  }

  Widget _statChip(String label, String value) {
    return BvChip(label: '$label: $value');
  }
}

class _PreviewItemTile extends StatelessWidget {
  const _PreviewItemTile({
    required this.item,
    required this.contentMode,
    required this.onIncludedChanged,
    required this.onFieldChanged,
    required this.onCoverChanged,
    required this.onCoverAssetChanged,
    required this.onCandidateSelected,
  });

  final BulkMetadataImportItem item;
  final BulkImportContentMode contentMode;
  final ValueChanged<bool> onIncludedChanged;
  final void Function(int index, bool selected) onFieldChanged;
  final ValueChanged<bool> onCoverChanged;
  final ValueChanged<ExternalMediaAsset> onCoverAssetChanged;
  final ValueChanged<BulkMetadataCandidate> onCandidateSelected;

  @override
  Widget build(BuildContext context) {
    final best = item.candidates.isEmpty ? null : item.candidates.first;
    return Material(
      color: Colors.transparent,
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        leading: Checkbox(
          value: item.included,
          onChanged:
              !_canToggleItem
                  ? null
                  : (value) => onIncludedChanged(value ?? false),
        ),
        title: Text(
          item.row.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          _subtitle(context, best),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 0, 12),
            child: Material(
              color: Colors.transparent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (contentMode != BulkImportContentMode.coverOnly &&
                      item.candidates.isNotEmpty) ...[
                    Text(
                      context.l10n.bulkCandidates,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    for (final candidate in item.candidates.take(4))
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(candidate.candidate.title),
                        subtitle: Text(
                          '${context.l10n.bulkConfidenceLabel(candidate.confidence)} · '
                          '${context.l10n.bulkScoreValue(candidate.score)}'
                          '${candidate.reasons.isEmpty ? '' : ' · ${candidate.reasons.map((reason) => _localizedBulkMatchReason(context, reason)).join(', ')}'}',
                        ),
                        trailing: TextButton(
                          onPressed: () => onCandidateSelected(candidate),
                          child: Text(context.l10n.bulkUse),
                        ),
                      ),
                    const SizedBox(height: 8),
                  ],
                  if (contentMode != BulkImportContentMode.coverOnly &&
                      item.fieldPlans.isEmpty)
                    Text(context.l10n.bulkNoMetadataFields)
                  else if (contentMode != BulkImportContentMode.coverOnly) ...[
                    Text(
                      context.l10n.bulkFields,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    for (var index = 0; index < item.fieldPlans.length; index++)
                      CheckboxListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        value: item.fieldPlans[index].selected,
                        onChanged:
                            item.fieldPlans[index].canApply &&
                                    !item.fieldPlans[index].isProtected
                                ? (value) =>
                                    onFieldChanged(index, value ?? false)
                                : null,
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                context.l10n.metadataFieldLabel(
                                  item.fieldPlans[index].field,
                                ),
                              ),
                            ),
                            if (item.fieldPlans[index].replacesExisting)
                              _Badge(label: context.l10n.metadataReplaces),
                            if (item.fieldPlans[index].isProtected)
                              _Badge(label: context.l10n.metadataProtected),
                          ],
                        ),
                        subtitle: Text(
                          context.l10n.bulkCurrentExternal(
                            item.fieldPlans[index].currentValue,
                            item.fieldPlans[index].externalValue,
                          ),
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
                      title: Text(context.l10n.bulkSaveCover),
                      subtitle: Text(
                        item.coverPlan!.canApply
                            ? [
                              _coverStatusLabel(context, item.coverPlan!),
                              item.coverPlan!.asset!.providerName,
                              if (item.coverPlan!.replacesExisting)
                                context.l10n.bulkReplacesCover(
                                  item.coverPlan!.currentProviderName ??
                                      context.l10n.bulkCurrentCover,
                                ),
                            ].join(' · ')
                            : item.coverPlan!.reason ??
                                context.l10n.notAvailable,
                      ),
                    ),
                    if (item.coverPlan!.canApply &&
                        item.coverPlan!.hasAlternativeAssets)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => _showCoverPicker(context),
                          icon: const Icon(Icons.image_search_outlined),
                          label: Text(context.l10n.bulkChooseCover),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool get _canToggleItem {
    if (item.hasErrorIssue) return false;
    if (item.selectedDetails != null) return true;
    if (item.fieldPlans.any((field) => field.canApply)) return true;
    if (item.coverPlan?.canApply == true) return true;
    return false;
  }

  String _subtitle(BuildContext context, BulkMetadataCandidate? best) {
    final parts = <String>[];
    if (contentMode == BulkImportContentMode.coverOnly) {
      parts.add(_coverOnlyStatus(context));
    } else {
      parts.add(context.l10n.bulkConfidenceLabel(item.confidence));
      if (best != null) parts.add(best.candidate.title);
      if (contentMode == BulkImportContentMode.metadataAndCover &&
          item.coverPlan != null) {
        parts.add(_coverOnlyStatus(context));
      }
    }
    if (item.issues.isNotEmpty) {
      parts.add(
        item.issues
            .map((issue) => _localizedBulkIssue(context, issue))
            .join(' · '),
      );
    }
    return parts.join(' · ');
  }

  String _coverOnlyStatus(BuildContext context) {
    final cover = item.coverPlan;
    if (cover == null) return context.l10n.bulkNoCoverFound;
    if (!cover.canApply) {
      return cover.reason ?? context.l10n.bulkNoCoverFound;
    }
    if (cover.selected && cover.replacesExisting) {
      return context.l10n.bulkCoverReplacementSelected;
    }
    if (cover.selected) return context.l10n.bulkNewCoverSelected;
    if (cover.replacesExisting) return context.l10n.bulkAlreadyHasCover;
    return context.l10n.bulkCoverFound;
  }

  String _coverStatusLabel(BuildContext context, BulkCoverPlan cover) {
    if (!cover.canApply) return context.l10n.bulkNoCoverFound;
    if (cover.selected && cover.replacesExisting) {
      return context.l10n.bulkCoverReplacementSelected;
    }
    if (cover.selected) return context.l10n.bulkNewCoverSelected;
    if (cover.replacesExisting) return context.l10n.bulkAlreadyHasCover;
    return context.l10n.bulkCoverFound;
  }

  Future<void> _showCoverPicker(BuildContext context) async {
    final cover = item.coverPlan;
    if (cover == null) return;
    final assets = cover.availableAssets;
    if (assets.isEmpty) return;
    final selected = await showDialog<ExternalMediaAsset>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(context.l10n.bulkChooseCoverFor(item.row.title)),
            content: SizedBox(
              width: 640,
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: assets.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 160,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.68,
                ),
                itemBuilder: (context, index) {
                  final asset = assets[index];
                  final isSelected =
                      cover.asset?.providerId == asset.providerId &&
                      cover.asset?.externalId == asset.externalId &&
                      cover.asset?.remoteUrl == asset.remoteUrl;
                  return InkWell(
                    key: ValueKey('${asset.providerId}:${asset.externalId}'),
                    onTap: () => Navigator.pop(context, asset),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                              isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).dividerColor,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(7),
                              ),
                              child: Image.network(
                                asset.thumbnailUrl ?? asset.remoteUrl,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => const Icon(
                                      Icons.broken_image_outlined,
                                      size: 40,
                                    ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              asset.providerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(context.l10n.cancel),
              ),
            ],
          ),
    );
    if (selected != null) onCoverAssetChanged(selected);
  }
}
