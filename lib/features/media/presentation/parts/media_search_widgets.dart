part of '../media_search_dialog.dart';

class _CandidateList extends StatelessWidget {
  const _CandidateList({required this.candidates, required this.onSelected});

  final List<MediaSearchCandidate> candidates;
  final ValueChanged<MediaSearchCandidate> onSelected;

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
                  const Icon(Icons.image_search_outlined),
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
                          '${candidate.providerName} · ID ${candidate.externalId}',
                          maxLines: 1,
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

class _AssetGrid extends StatelessWidget {
  const _AssetGrid({
    required this.assets,
    required this.selectedAsset,
    required this.onSelected,
  });

  final List<ExternalMediaAsset> assets;
  final ExternalMediaAsset? selectedAsset;
  final ValueChanged<ExternalMediaAsset> onSelected;

  @override
  Widget build(BuildContext context) {
    final bv = BvThemeExtension.of(context);
    return GridView.builder(
      itemCount: assets.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 156,
        childAspectRatio: 2 / 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final asset = assets[index];
        final selected = selectedAsset?.externalId == asset.externalId;
        return BvSurface(
          key: ValueKey('${asset.providerId}:${asset.externalId}'),
          padding: EdgeInsets.zero,
          borderRadius: BvRadii.md,
          selected: selected,
          onTap: () => onSelected(asset),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(BvRadii.md),
                child: Image.network(
                  asset.thumbnailUrl ?? asset.remoteUrl,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => const Center(
                        child: Icon(Icons.broken_image_outlined),
                      ),
                ),
              ),
              if (selected)
                Positioned(
                  right: BvSpacing.xs,
                  top: BvSpacing.xs,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: bv.focus,
                      borderRadius: BorderRadius.circular(BvRadii.pill),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.check, size: 16),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _MediaError extends StatelessWidget {
  const _MediaError({
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
