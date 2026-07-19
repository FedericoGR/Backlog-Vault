part of '../bulk_metadata_import_page.dart';

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
    return BvWizardStep(
      step: context.l10n.stepOne,
      title: context.l10n.bulkWhatImport,
      subtitle: context.l10n.bulkWhatImportDescription,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ImportModePicker(
            selected: contentMode,
            busy: busy,
            onChanged: onContentModeChanged,
          ),
          const SizedBox(height: BvSpacing.md),
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
                      decoration: InputDecoration(
                        labelText: context.l10n.bulkGamesToAnalyze,
                        helperText: context.l10n.bulkGamesToAnalyzeHelper,
                      ),
                      items: [
                        for (final value in BulkMetadataImportScope.values)
                          DropdownMenuItem(
                            value: value,
                            child: Text(
                              context.l10n.bulkScopeLabel(value),
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
                        decoration: InputDecoration(
                          labelText: context.l10n.bulkMetadataProvider,
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
                                  if (value != null) onProviderChanged(value);
                                },
                      ),
                    ),
                    _OptionBox(
                      width: width,
                      child: DropdownButtonFormField<BulkMetadataApplyMode>(
                        initialValue: applyMode,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: context.l10n.bulkMetadataMode,
                        ),
                        items: [
                          for (final value in BulkMetadataApplyMode.values)
                            DropdownMenuItem(
                              value: value,
                              child: Text(
                                context.l10n.bulkApplyModeLabel(value),
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
                        decoration: InputDecoration(
                          labelText: context.l10n.bulkCoverSource,
                        ),
                        items: [
                          for (final value in BulkCoverProviderMode.values)
                            DropdownMenuItem(
                              value: value,
                              child: Text(
                                context.l10n.bulkCoverProviderLabel(value),
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
                        decoration: InputDecoration(
                          labelText: context.l10n.bulkExistingCovers,
                        ),
                        items: [
                          for (final value in BulkExistingCoverMode.values)
                            DropdownMenuItem(
                              value: value,
                              child: Text(
                                context.l10n.bulkExistingCoverModeLabel(value),
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
          const SizedBox(height: BvSpacing.md),
          FilledButton.icon(
            onPressed: busy ? null : onScan,
            icon: const Icon(Icons.manage_search_outlined),
            label: Text(context.l10n.csvGeneratePreview),
          ),
        ],
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
                      context.l10n.bulkContentModeLabel(mode),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.bulkContentModeDescription(mode),
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
    return BvProgressPanel(
      title: context.l10n.bulkScanning,
      progress: progress,
      trailing: '$processed / $total',
      subtitle: currentTitle,
      onCancel: onCancel,
      cancelLabel: context.l10n.cancel,
    );
  }
}
