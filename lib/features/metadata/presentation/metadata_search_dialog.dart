import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/bv_chip.dart';
import '../../../core/design_system/bv_empty_state.dart';
import '../../../core/design_system/bv_panel.dart';
import '../../../core/design_system/bv_spacing.dart';
import '../../../core/design_system/bv_surface.dart';
import '../../../core/formatting/date_formatters.dart';
import '../../../core/privacy/privacy_redactor.dart';
import '../../../l10n/domain_localizations.dart';
import '../../../l10n/l10n.dart';
import '../../media/application/media_providers.dart';
import '../../media/data/igdb_media_provider.dart';
import '../application/get_metadata_details_use_case.dart';
import '../../games/application/library_game_details.dart';
import '../application/metadata_providers.dart';
import '../application/search_metadata_use_case.dart';
import '../domain/apply_metadata_request.dart';
import '../domain/external_game_details.dart';
import '../domain/metadata_diff.dart';
import '../domain/metadata_exception.dart';
import '../domain/metadata_field.dart';
import '../domain/metadata_provider.dart';
import '../domain/metadata_search_candidate.dart';

class MetadataSearchDialog extends ConsumerStatefulWidget {
  const MetadataSearchDialog({required this.item, super.key});

  final LibraryGameDetails item;

  @override
  ConsumerState<MetadataSearchDialog> createState() =>
      _MetadataSearchDialogState();
}

class _MetadataSearchDialogState extends ConsumerState<MetadataSearchDialog> {
  late final TextEditingController _queryController;
  bool _loading = false;
  bool _applying = false;
  String? _error;
  String _selectedProviderId = 'rawg';
  List<MetadataSearchCandidate> _candidates = const [];
  ExternalGameDetails? _details;
  MetadataDiff? _diff;
  Set<MetadataField> _selectedFields = {};
  bool _saveIncludedCover = false;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController(text: widget.item.game.title);
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final providers = ref.watch(metadataProviderListProvider);
    final selectedProvider = _providerById(providers, _selectedProviderId);
    final providerName = selectedProvider.displayName;
    final size = MediaQuery.sizeOf(context);
    return Dialog(
      insetPadding: const EdgeInsets.all(BvSpacing.sm),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: size.width > 920 ? 860 : size.width * 0.94,
          maxHeight: size.height * 0.88,
        ),
        child: Padding(
          padding: const EdgeInsets.all(BvSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.metadataDialogTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: BvSpacing.sm),
              TextField(
                controller: _queryController,
                decoration: InputDecoration(
                  labelText: context.l10n.metadataTitleField,
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
                  initialValue: selectedProvider.providerId,
                  decoration: InputDecoration(labelText: context.l10n.provider),
                  items: [
                    for (final provider in providers)
                      DropdownMenuItem(
                        value: provider.providerId,
                        child: Text(provider.displayName),
                      ),
                  ],
                  onChanged:
                      _loading || _applying
                          ? null
                          : (value) {
                            if (value == null) return;
                            setState(() {
                              _selectedProviderId = value;
                              _error = null;
                              _candidates = const [];
                              _details = null;
                              _diff = null;
                              _selectedFields = {};
                              _saveIncludedCover = false;
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
                          ? _MetadataError(
                            message: _error!,
                            onSettings: _goToSettings,
                            showSettings:
                                _error!.contains('API key') ||
                                _error!.contains('Client ID') ||
                                _error!.contains('Client Secret'),
                          )
                          : _details != null && _diff != null
                          ? _DiffPreview(
                            details: _details!,
                            diff: _diff!,
                            selectedFields: _selectedFields,
                            saveIncludedCover: _saveIncludedCover,
                            hasCurrentCover: widget.item.selectedCover != null,
                            onChanged: (field, selected) {
                              setState(() {
                                selected
                                    ? _selectedFields.add(field)
                                    : _selectedFields.remove(field);
                              });
                            },
                            onCoverChanged: (selected) {
                              setState(() => _saveIncludedCover = selected);
                            },
                          )
                          : _candidates.isEmpty
                          ? BvEmptyState(
                            title: context.l10n.metadataNoCandidates,
                            message: context.l10n.metadataNoCandidatesMessage(
                              providerName,
                            ),
                            icon: Icons.travel_explore_outlined,
                          )
                          : _CandidateList(
                            candidates: _candidates,
                            onSelected: _selectCandidate,
                          ),
                ),
              ),
              const SizedBox(height: BvSpacing.sm),
              OverflowBar(
                alignment: MainAxisAlignment.end,
                spacing: BvSpacing.xs,
                overflowSpacing: BvSpacing.xs,
                children: [
                  TextButton(
                    onPressed:
                        _applying ? null : () => Navigator.pop(context, false),
                    child: Text(context.l10n.close),
                  ),
                  if (_details != null && _diff != null)
                    FilledButton.icon(
                      onPressed:
                          _applying ? null : () => _apply(replace: false),
                      icon:
                          _applying
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(Icons.check),
                      label: Text(
                        _selectedFields.isEmpty
                            ? context.l10n.metadataSaveLink
                            : context.l10n.metadataApply,
                      ),
                    ),
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
      _diff = null;
      _selectedFields = {};
      _saveIncludedCover = false;
    });
    try {
      final provider = _providerById(
        ref.read(metadataProviderListProvider),
        _selectedProviderId,
      );
      final result = await SearchMetadataUseCase(
        provider,
      ).call(_queryController.text);
      if (!mounted) return;
      setState(() {
        _candidates = result;
        _error =
            result.isEmpty
                ? context.l10n.providerNoCandidates(provider.displayName)
                : null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _safeMessage(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _selectCandidate(MetadataSearchCandidate candidate) async {
    setState(() {
      _loading = true;
      _error = null;
      _details = null;
      _diff = null;
      _selectedFields = {};
      _saveIncludedCover = false;
    });
    try {
      final provider = _providerById(
        ref.read(metadataProviderListProvider),
        candidate.providerId,
      );
      final details = await GetMetadataDetailsUseCase(
        provider,
      ).call(candidate.externalId);
      final diff = ref
          .read(buildMetadataDiffUseCaseProvider)
          .call(local: widget.item, external: details);
      if (!mounted) return;
      setState(() {
        _details = details;
        _diff = diff;
        _selectedFields =
            diff.changes
                .where((change) => change.selectedByDefault && change.canApply)
                .map((change) => change.field)
                .toSet();
        _saveIncludedCover =
            details.providerId == 'igdb' &&
            details.cover != null &&
            widget.item.selectedCover == null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _safeMessage(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _apply({required bool replace}) async {
    final details = _details;
    if (details == null) return;
    if (_shouldSaveIncludedCover(details) &&
        widget.item.selectedCover != null &&
        !await _confirmReplaceCover()) {
      return;
    }
    setState(() {
      _applying = true;
      _error = null;
    });
    try {
      await ref
          .read(applyMetadataUseCaseProvider)
          .call(
            ApplyMetadataRequest(
              gameId: widget.item.game.id,
              libraryEntryId: widget.item.entry.id,
              details: details,
              selectedFields: _selectedFields,
              replaceExistingExternalId: replace,
            ),
          );
      final coverAsset = externalGameCoverToMediaAsset(details.cover);
      if (_shouldSaveIncludedCover(details) && coverAsset != null) {
        try {
          await ref
              .read(saveSelectedMediaAssetUseCaseProvider)
              .fromRemoteCover(gameId: widget.item.game.id, asset: coverAsset);
        } catch (error) {
          if (!mounted) return;
          setState(
            () =>
                _error = context.l10n.metadataCoverSaveFailed(
                  privacyRedactor.redact(error.toString()),
                ),
          );
          return;
        }
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      final message = _safeMessage(error);
      if (_canConfirmReplacement(message)) {
        final confirmed = await _confirmReplace();
        if (confirmed && mounted) {
          await _apply(replace: true);
          return;
        }
      }
      if (mounted) setState(() => _error = message);
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }

  bool _shouldSaveIncludedCover(ExternalGameDetails details) {
    return _saveIncludedCover &&
        details.providerId == 'igdb' &&
        details.cover != null;
  }

  Future<bool> _confirmReplaceCover() async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            scrollable: true,
            title: Text(context.l10n.metadataReplaceCoverTitle),
            content: Text(context.l10n.metadataReplaceCoverMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(context.l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(context.l10n.metadataReplaceCoverTitle),
              ),
            ],
          ),
    );
    return result == true;
  }

  bool _canConfirmReplacement(String message) {
    return message.contains('otro match externo');
  }

  Future<bool> _confirmReplace() async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            scrollable: true,
            title: Text(context.l10n.metadataReplaceExternalTitle),
            content: Text(context.l10n.metadataReplaceExternalMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(context.l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(context.l10n.replace),
              ),
            ],
          ),
    );
    return result == true;
  }

  void _goToSettings() {
    Navigator.pop(context, false);
    context.go('/settings');
  }

  String _safeMessage(Object error) {
    if (error is MetadataException) {
      return privacyRedactor.redact(error.message);
    }
    return privacyRedactor.redact(context.l10n.metadataOperationFailed);
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
          Text('${details.providerName} · ID ${details.externalId}'),
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
