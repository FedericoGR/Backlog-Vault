part of '../game_form_page.dart';

class _FormMetadataResult {
  const _FormMetadataResult({
    required this.details,
    required this.selectedFields,
    this.coverAsset,
  });

  final ExternalGameDetails details;
  final Set<MetadataField> selectedFields;
  final ExternalMediaAsset? coverAsset;
}

class _GameFormMetadataDialog extends ConsumerStatefulWidget {
  const _GameFormMetadataDialog({
    required this.initialQuery,
    required this.currentTitle,
    required this.currentReleaseDate,
    required this.currentType,
    required this.currentPlatforms,
    required this.currentGenres,
    required this.hasCurrentCover,
  });

  final String initialQuery;
  final String currentTitle;
  final DateTime? currentReleaseDate;
  final String currentType;
  final List<String> currentPlatforms;
  final List<String> currentGenres;
  final bool hasCurrentCover;

  @override
  ConsumerState<_GameFormMetadataDialog> createState() =>
      _GameFormMetadataDialogState();
}

class _GameFormMetadataDialogState
    extends ConsumerState<_GameFormMetadataDialog> {
  late final TextEditingController _queryController;
  bool _loading = false;
  String? _error;
  String _selectedProviderId = 'igdb';
  List<MetadataSearchCandidate> _candidates = const [];
  ExternalGameDetails? _details;
  Set<MetadataField> _selectedFields = {};
  bool _saveCover = false;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final providers = ref.watch(metadataProviderListProvider);
    final provider = _providerById(providers, _selectedProviderId);
    final size = MediaQuery.sizeOf(context);
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 860,
          maxHeight: size.height * 0.88,
        ),
        child: Padding(
          padding: const EdgeInsets.all(BvSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.gameImportMetadata,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: BvSpacing.sm),
              TextField(
                controller: _queryController,
                decoration: InputDecoration(
                  labelText: context.l10n.gameSearchByTitle,
                  suffixIcon: IconButton(
                    tooltip: context.l10n.search,
                    onPressed: _loading ? null : _search,
                    icon: const Icon(Icons.search),
                  ),
                ),
                onSubmitted: (_) => _loading ? null : _search(),
              ),
              const SizedBox(height: BvSpacing.sm),
              SizedBox(
                width: 280,
                child: DropdownButtonFormField<String>(
                  initialValue: provider.providerId,
                  decoration: InputDecoration(labelText: context.l10n.provider),
                  items: [
                    for (final item in providers)
                      DropdownMenuItem(
                        value: item.providerId,
                        child: Text(item.displayName),
                      ),
                  ],
                  onChanged:
                      _loading
                          ? null
                          : (value) {
                            if (value == null) return;
                            setState(() {
                              _selectedProviderId = value;
                              _error = null;
                              _candidates = const [];
                              _details = null;
                              _selectedFields = {};
                              _saveCover = false;
                            });
                          },
                ),
              ),
              const SizedBox(height: BvSpacing.md),
              Expanded(
                child: SingleChildScrollView(
                  child:
                      _loading
                          ? const Padding(
                            padding: EdgeInsets.all(BvSpacing.xl),
                            child: Center(child: CircularProgressIndicator()),
                          )
                          : _error != null
                          ? _FormMetadataError(message: _error!)
                          : _details != null
                          ? _FormMetadataPreview(
                            details: _details!,
                            selectedFields: _selectedFields,
                            saveCover: _saveCover,
                            hasCurrentCover: widget.hasCurrentCover,
                            availableFields: _availableFields(_details!),
                            onFieldChanged: (field, selected) {
                              setState(() {
                                selected
                                    ? _selectedFields.add(field)
                                    : _selectedFields.remove(field);
                              });
                            },
                            onCoverChanged: (selected) {
                              setState(() => _saveCover = selected);
                            },
                          )
                          : _candidates.isEmpty
                          ? BvEmptyState(
                            title: context.l10n.gameNoCandidates,
                            message: context.l10n.gameNoCandidatesMessage(
                              provider.displayName,
                            ),
                            icon: Icons.travel_explore_outlined,
                          )
                          : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (final candidate in _candidates)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: BvSpacing.xs,
                                  ),
                                  child: BvSurface(
                                    padding: const EdgeInsets.all(BvSpacing.sm),
                                    onTap: () => _selectCandidate(candidate),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.travel_explore_outlined,
                                        ),
                                        const SizedBox(width: BvSpacing.sm),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                candidate.title,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style:
                                                    Theme.of(
                                                      context,
                                                    ).textTheme.titleMedium,
                                              ),
                                              const SizedBox(
                                                height: BvSpacing.xxs,
                                              ),
                                              Text(
                                                [
                                                      candidate.providerName,
                                                      formatVisibleDate(
                                                        candidate.releaseDate,
                                                      ),
                                                      _joinNames(
                                                        candidate.platforms,
                                                      ),
                                                      _joinNames(
                                                        candidate.genres,
                                                      ),
                                                    ]
                                                    .where(
                                                      (value) => value != '-',
                                                    )
                                                    .join(' · '),
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
                          ),
                ),
              ),
              const SizedBox(height: BvSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(context.l10n.cancel),
                  ),
                  if (_details != null) ...[
                    const SizedBox(width: BvSpacing.xs),
                    FilledButton.icon(
                      onPressed:
                          () => Navigator.pop(
                            context,
                            _FormMetadataResult(
                              details: _details!,
                              selectedFields: _selectedFields,
                              coverAsset:
                                  _saveCover
                                      ? externalGameCoverToMediaAsset(
                                        _details!.cover,
                                      )
                                      : null,
                            ),
                          ),
                      icon: const Icon(Icons.check),
                      label: Text(context.l10n.gameApplyToForm),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _search() async {
    setState(() {
      _loading = true;
      _error = null;
      _candidates = const [];
      _details = null;
      _selectedFields = {};
      _saveCover = false;
    });
    try {
      final provider = _providerById(
        ref.read(metadataProviderListProvider),
        _selectedProviderId,
      );
      final candidates = await ref
          .read(metadataSearchViewModelProvider)
          .search(provider, _queryController.text);
      if (!mounted) return;
      setState(() {
        _candidates = candidates;
        _error =
            candidates.isEmpty
                ? context.l10n.providerNoCandidates(provider.displayName)
                : null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = context.l10n.metadataOperationFailed);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _selectCandidate(MetadataSearchCandidate candidate) async {
    setState(() {
      _loading = true;
      _error = null;
      _details = null;
      _selectedFields = {};
      _saveCover = false;
    });
    try {
      final provider = _providerById(
        ref.read(metadataProviderListProvider),
        candidate.providerId,
      );
      final details = await ref
          .read(metadataSearchViewModelProvider)
          .details(provider, candidate.externalId);
      if (!mounted) return;
      setState(() {
        _details = details;
        _selectedFields = _defaultSelectedFields(details);
        _saveCover =
            details.providerId == 'igdb' &&
            details.cover != null &&
            !widget.hasCurrentCover;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = context.l10n.metadataOperationFailed);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Set<MetadataField> _defaultSelectedFields(ExternalGameDetails details) {
    return {
      if (widget.currentReleaseDate == null && details.releaseDate != null)
        MetadataField.releaseDate,
      if (widget.currentType.trim().isEmpty && details.type.trim().isNotEmpty)
        MetadataField.type,
      if (widget.currentPlatforms.isEmpty && details.platforms.isNotEmpty)
        MetadataField.platforms,
      if (widget.currentGenres.isEmpty && details.genres.isNotEmpty)
        MetadataField.genres,
    };
  }

  Set<MetadataField> _availableFields(ExternalGameDetails details) {
    return {
      if (details.title.trim().isNotEmpty &&
          details.title.trim().toLowerCase() !=
              widget.currentTitle.trim().toLowerCase())
        MetadataField.title,
      if (details.releaseDate != null) MetadataField.releaseDate,
      if (details.type.trim().isNotEmpty) MetadataField.type,
      if (details.platforms.isNotEmpty) MetadataField.platforms,
      if (details.genres.isNotEmpty) MetadataField.genres,
    };
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

class _FormMetadataPreview extends StatelessWidget {
  const _FormMetadataPreview({
    required this.details,
    required this.selectedFields,
    required this.saveCover,
    required this.hasCurrentCover,
    required this.availableFields,
    required this.onFieldChanged,
    required this.onCoverChanged,
  });

  final ExternalGameDetails details;
  final Set<MetadataField> selectedFields;
  final bool saveCover;
  final bool hasCurrentCover;
  final Set<MetadataField> availableFields;
  final void Function(MetadataField field, bool selected) onFieldChanged;
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
          const SizedBox(height: BvSpacing.md),
          for (final field in MetadataField.values)
            if (availableFields.contains(field))
              Padding(
                padding: const EdgeInsets.only(bottom: BvSpacing.xs),
                child: BvSurface(
                  padding: EdgeInsets.zero,
                  selected: selectedFields.contains(field),
                  child: Material(
                    color: Colors.transparent,
                    child: CheckboxListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: BvSpacing.sm,
                        vertical: BvSpacing.xs,
                      ),
                      value: selectedFields.contains(field),
                      onChanged:
                          (value) => onFieldChanged(field, value ?? false),
                      title: Text(context.l10n.metadataFieldLabel(field)),
                      subtitle: Text(_fieldValue(details, field)),
                    ),
                  ),
                ),
              ),
          if (details.providerId == 'igdb' && details.cover != null)
            BvSurface(
              padding: EdgeInsets.zero,
              selected: saveCover,
              child: Material(
                color: Colors.transparent,
                child: CheckboxListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: BvSpacing.sm,
                    vertical: BvSpacing.xs,
                  ),
                  value: saveCover,
                  onChanged: (value) => onCoverChanged(value ?? false),
                  title: Text(context.l10n.gameSaveIncludedCover),
                  subtitle: Text(
                    hasCurrentCover
                        ? context.l10n.gameIncludedCoverReplace
                        : context.l10n.gameIncludedCoverSave,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _fieldValue(ExternalGameDetails details, MetadataField field) {
    return switch (field) {
      MetadataField.title => details.title,
      MetadataField.releaseDate => formatVisibleDate(details.releaseDate),
      MetadataField.type => details.type,
      MetadataField.genres => _joinNames(details.genres),
      MetadataField.platforms => _joinNames(details.platforms),
    };
  }
}

class _FormMetadataError extends StatelessWidget {
  const _FormMetadataError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return BvPanel(
      child: Text(
        message,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}
