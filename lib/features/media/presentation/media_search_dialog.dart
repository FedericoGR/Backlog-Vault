import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/bv_async_action_button.dart';
import '../../../core/design_system/bv_chip.dart';
import '../../../core/design_system/bv_empty_state.dart';
import '../../../core/design_system/bv_spacing.dart';
import '../../../core/design_system/bv_surface.dart';
import '../../../core/design_system/bv_theme_extension.dart';
import '../../../core/design_system/bv_tokens.dart';
import '../../../core/privacy/privacy_redactor.dart';
import '../../../l10n/l10n.dart';
import '../../games/application/library_game_details.dart';
import '../application/media_providers.dart';
import '../domain/media_asset_models.dart';
import '../domain/media_exception.dart';
import '../domain/media_provider.dart';

part 'parts/media_search_widgets.dart';

/// Searches configured media providers and lets the user choose an asset.
class MediaSearchDialog extends ConsumerStatefulWidget {
  const MediaSearchDialog({required this.item, super.key});

  final LibraryGameDetails item;

  @override
  ConsumerState<MediaSearchDialog> createState() => _MediaSearchDialogState();
}

class _MediaSearchDialogState extends ConsumerState<MediaSearchDialog> {
  late final TextEditingController _queryController;
  bool _loading = false;
  bool _saving = false;
  String? _error;
  String _selectedProviderId = 'steamgriddb';
  List<MediaSearchCandidate> _candidates = const [];
  MediaSearchCandidate? _selectedCandidate;
  List<ExternalMediaAsset> _assets = const [];
  ExternalMediaAsset? _selectedAsset;

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
    final providers = ref.watch(mediaProviderListProvider);
    final selectedProvider = _providerById(providers, _selectedProviderId);
    final providerName = selectedProvider.displayName;
    final size = MediaQuery.sizeOf(context);
    return Dialog(
      insetPadding: const EdgeInsets.all(BvSpacing.sm),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: size.width > 960 ? 900 : size.width * 0.94,
          maxHeight: size.height * 0.88,
        ),
        child: Padding(
          padding: const EdgeInsets.all(BvSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.item.selectedCover == null
                    ? context.l10n.coverDialogSearchTitle
                    : context.l10n.coverDialogChangeTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: BvSpacing.sm),
              TextField(
                controller: _queryController,
                decoration: InputDecoration(
                  labelText: context.l10n.coverSearchIn(providerName),
                  suffixIcon: IconButton(
                    tooltip: context.l10n.search,
                    onPressed: _loading || _saving ? null : _searchGames,
                    icon: const Icon(Icons.search),
                  ),
                ),
                onSubmitted: (_) {
                  if (!_loading && !_saving) _searchGames();
                },
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
                      _loading || _saving
                          ? null
                          : (value) {
                            if (value == null) return;
                            setState(() {
                              _selectedProviderId = value;
                              _error = null;
                              _candidates = const [];
                              _selectedCandidate = null;
                              _assets = const [];
                              _selectedAsset = null;
                            });
                          },
                ),
              ),
              const SizedBox(height: BvSpacing.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: _saving ? null : _pickLocalFile,
                    icon: const Icon(Icons.folder_open_outlined),
                    label: Text(context.l10n.coverUseLocalFile),
                  ),
                  if (_selectedCandidate != null)
                    BvChip(
                      label: _selectedCandidate!.title,
                      icon: Icons.image_search_outlined,
                      tone: BvChipTone.primary,
                      onDeleted:
                          _loading || _saving
                              ? null
                              : () {
                                setState(() {
                                  _selectedCandidate = null;
                                  _assets = const [];
                                  _selectedAsset = null;
                                });
                              },
                    ),
                ],
              ),
              const SizedBox(height: BvSpacing.md),
              Expanded(
                child:
                    _loading
                        ? const Center(child: CircularProgressIndicator())
                        : _error != null
                        ? SingleChildScrollView(
                          child: _MediaError(
                            message: _error!,
                            onSettings: _goToSettings,
                            showSettings:
                                _error!.contains('API key') ||
                                _error!.contains('Client ID') ||
                                _error!.contains('Client Secret'),
                          ),
                        )
                        : _assets.isNotEmpty
                        ? _AssetGrid(
                          assets: _assets,
                          selectedAsset: _selectedAsset,
                          onSelected:
                              (asset) => setState(() => _selectedAsset = asset),
                        )
                        : _candidates.isNotEmpty
                        ? SingleChildScrollView(
                          child: _CandidateList(
                            candidates: _candidates,
                            onSelected: _selectCandidate,
                          ),
                        )
                        : BvEmptyState(
                          title: context.l10n.coverNoResults,
                          message: context.l10n.coverNoResultsMessage(
                            providerName,
                          ),
                          icon: Icons.image_search_outlined,
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
                        _saving ? null : () => Navigator.pop(context, false),
                    child: Text(context.l10n.close),
                  ),
                  if (_selectedAsset != null)
                    BvAsyncActionButton(
                      label: context.l10n.coverSave,
                      icon: Icons.save_alt_outlined,
                      onPressed: _saveRemoteAsset,
                      busy: _saving,
                      busyLabel: context.l10n.loading,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _searchGames() async {
    setState(() {
      _loading = true;
      _error = null;
      _candidates = const [];
      _selectedCandidate = null;
      _assets = const [];
      _selectedAsset = null;
    });
    try {
      final provider = _providerById(
        ref.read(mediaProviderListProvider),
        _selectedProviderId,
      );
      final result = await ref
          .read(mediaSearchViewModelProvider)
          .searchGames(provider, _queryController.text);
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

  Future<void> _selectCandidate(MediaSearchCandidate candidate) async {
    setState(() {
      _loading = true;
      _error = null;
      _selectedCandidate = candidate;
      _assets = const [];
      _selectedAsset = null;
    });
    try {
      final provider = _providerById(
        ref.read(mediaProviderListProvider),
        candidate.providerId,
      );
      final result = await ref
          .read(mediaSearchViewModelProvider)
          .searchCovers(provider, candidate.externalId);
      if (!mounted) return;
      setState(() {
        _assets = result;
        _error =
            result.isEmpty
                ? context.l10n.providerNoCovers(provider.displayName)
                : null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _safeMessage(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveRemoteAsset() async {
    final asset = _selectedAsset;
    if (asset == null) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(mediaSearchViewModelProvider)
          .saveRemote(gameId: widget.item.game.id, asset: asset);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _safeMessage(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickLocalFile() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final saved = await ref
          .read(mediaSearchViewModelProvider)
          .pickAndSaveLocal(widget.item.game.id);
      if (!saved) {
        if (mounted) setState(() => _saving = false);
        return;
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _safeMessage(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _goToSettings() {
    Navigator.pop(context, false);
    context.go('/settings');
  }

  String _safeMessage(Object error) {
    if (error is MediaException) return privacyRedactor.redact(error.message);
    return privacyRedactor.redact(context.l10n.coverOperationFailed);
  }

  MediaProvider _providerById(
    List<MediaProvider> providers,
    String providerId,
  ) {
    for (final provider in providers) {
      if (provider.providerId == providerId) return provider;
    }
    return providers.first;
  }
}
