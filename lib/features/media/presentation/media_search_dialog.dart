import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/bv_chip.dart';
import '../../../core/design_system/bv_empty_state.dart';
import '../../../core/design_system/bv_spacing.dart';
import '../../../core/design_system/bv_surface.dart';
import '../../../core/design_system/bv_theme_extension.dart';
import '../../../core/design_system/bv_tokens.dart';
import '../../../core/privacy/privacy_redactor.dart';
import '../../games/application/library_game_details.dart';
import '../application/media_providers.dart';
import '../application/media_use_cases.dart';
import '../domain/media_asset_models.dart';
import '../domain/media_exception.dart';
import '../domain/media_provider.dart';

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
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 900,
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
                    ? 'Buscar portada'
                    : 'Cambiar portada',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: BvSpacing.sm),
              TextField(
                controller: _queryController,
                decoration: InputDecoration(
                  labelText: 'Buscar en $providerName',
                  suffixIcon: IconButton(
                    tooltip: 'Buscar',
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
                  decoration: const InputDecoration(labelText: 'Proveedor'),
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
                    label: const Text('Usar archivo local'),
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
                          title: 'Sin portadas todavía',
                          message:
                              'Buscá un juego en $providerName o elegí un archivo local.',
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
                    child: const Text('Cerrar'),
                  ),
                  if (_selectedAsset != null)
                    FilledButton.icon(
                      onPressed: _saving ? null : _saveRemoteAsset,
                      icon:
                          _saving
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(Icons.save_alt_outlined),
                      label: const Text('Guardar portada'),
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
      final result = await _searchMediaGamesUseCase(
        provider,
      ).call(_queryController.text);
      if (!mounted) return;
      setState(() {
        _candidates = result;
        _error =
            result.isEmpty
                ? '${provider.displayName} no devolvió candidatos.'
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
      final result = await _searchCoverAssetsUseCase(
        provider,
      ).call(candidate.externalId);
      if (!mounted) return;
      setState(() {
        _assets = result;
        _error =
            result.isEmpty
                ? '${provider.displayName} no devolvió portadas.'
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
          .read(saveSelectedMediaAssetUseCaseProvider)
          .fromRemoteCover(gameId: widget.item.game.id, asset: asset);
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
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
        allowMultiple: false,
      );
      final path = result?.files.single.path;
      if (path == null || path.trim().isEmpty) {
        if (mounted) setState(() => _saving = false);
        return;
      }
      await ref
          .read(saveSelectedMediaAssetUseCaseProvider)
          .fromLocalFile(gameId: widget.item.game.id, sourcePath: path);
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
    return privacyRedactor.redact(
      'No se pudo completar la operación de portada.',
    );
  }

  SearchMediaGamesUseCase _searchMediaGamesUseCase(MediaProvider provider) {
    return SearchMediaGamesUseCase(provider);
  }

  SearchCoverAssetsUseCase _searchCoverAssetsUseCase(MediaProvider provider) {
    return SearchCoverAssetsUseCase(provider);
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
            label: const Text('Abrir ajustes'),
          ),
        ],
      ],
    );
  }
}
