part of '../metadata_search_dialog.dart';

class _CandidateList extends StatelessWidget {
  const _CandidateList({required this.candidates, required this.onSelected});

  final List<MetadataSearchCandidate> candidates;
  final ValueChanged<MetadataSearchCandidate> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final candidate in candidates)
          Padding(
            padding: const EdgeInsets.only(bottom: BvSpacing.xs),
            child: BvSurface(
              padding: const EdgeInsets.all(BvSpacing.sm),
              onTap: () => onSelected(candidate),
              child: Row(
                children: [
                  const Icon(Icons.travel_explore_outlined),
                  const SizedBox(width: BvSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          candidate.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: BvSpacing.xxs),
                        Text(
                          [
                            candidate.providerName,
                            'ID ${candidate.externalId}',
                            formatVisibleDate(candidate.releaseDate),
                            _names(candidate.platforms),
                            _names(candidate.genres),
                          ].where((value) => value != '-').join(' · '),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _DiffPreview extends StatelessWidget {
  const _DiffPreview({
    required this.details,
    required this.diff,
    required this.selectedFields,
    required this.saveIncludedCover,
    required this.hasCurrentCover,
    required this.onChanged,
    required this.onCoverChanged,
  });

  final ExternalGameDetails details;
  final MetadataDiff diff;
  final Set<MetadataField> selectedFields;
  final bool saveIncludedCover;
  final bool hasCurrentCover;
  final void Function(MetadataField field, bool selected) onChanged;
  final ValueChanged<bool> onCoverChanged;

  @override
  Widget build(BuildContext context) {
    return BvPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(details.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            context.l10n.externalIdValue(
              details.providerName,
              details.externalId,
            ),
          ),
          if (details.providerId == 'igdb' && details.cover != null) ...[
            const SizedBox(height: BvSpacing.sm),
            BvSurface(
              padding: const EdgeInsets.all(BvSpacing.xs),
              selected: saveIncludedCover,
              child: Material(
                color: Colors.transparent,
                child: CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: saveIncludedCover,
                  onChanged: (value) => onCoverChanged(value ?? false),
                  title: Text(context.l10n.gameSaveIncludedCover),
                  subtitle: Text(
                    hasCurrentCover
                        ? context.l10n.metadataIncludedCoverExisting
                        : context.l10n.metadataIncludedCoverOffline,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: BvSpacing.md),
          if (diff.changes.isEmpty)
            Text(context.l10n.metadataNoNewFields)
          else
            for (final change in diff.changes)
              Padding(
                padding: const EdgeInsets.only(bottom: BvSpacing.xs),
                child: BvSurface(
                  padding: EdgeInsets.zero,
                  selected: selectedFields.contains(change.field),
                  child: Material(
                    color: Colors.transparent,
                    child: CheckboxListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: BvSpacing.sm,
                        vertical: BvSpacing.xs,
                      ),
                      value: selectedFields.contains(change.field),
                      onChanged:
                          change.canApply && !change.isProtected
                              ? (value) =>
                                  onChanged(change.field, value ?? false)
                              : null,
                      title: Wrap(
                        spacing: BvSpacing.xs,
                        runSpacing: BvSpacing.xs,
                        children: [
                          Text(context.l10n.metadataFieldLabel(change.field)),
                          if (change.currentValue.trim().isNotEmpty &&
                              change.currentValue != '-')
                            BvChip(
                              label: context.l10n.metadataReplaces,
                              tone: BvChipTone.warning,
                            ),
                          if (change.isProtected)
                            BvChip(label: context.l10n.metadataProtected),
                        ],
                      ),
                      subtitle: Text(
                        context.l10n.metadataCurrentExternal(
                          change.currentValue,
                          details.providerName,
                          change.externalValue,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _MetadataError extends StatelessWidget {
  const _MetadataError({
    required this.message,
    required this.onSettings,
    required this.showSettings,
  });

  final String message;
  final VoidCallback onSettings;
  final bool showSettings;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
        if (showSettings) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onSettings,
            icon: const Icon(Icons.settings_outlined),
            label: Text(context.l10n.openSettings),
          ),
        ],
      ],
    );
  }
}

String _names(Iterable<String> values) {
  final list = values.where((value) => value.trim().isNotEmpty).toList();
  if (list.isEmpty) return '-';
  return list.join(', ');
}
