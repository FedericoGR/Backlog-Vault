import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../games/application/library_game_details.dart';
import '../application/media_providers.dart';
import '../domain/media_asset_models.dart';
import '../domain/media_exception.dart';

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
    return AlertDialog(
      title: Text(
        widget.item.selectedCover == null
            ? 'Buscar portada'
            : 'Cambiar portada',
      ),
      content: SizedBox(
        width: 760,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _queryController,
                decoration: InputDecoration(
                  labelText: 'Buscar en SteamGridDB',
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
              const SizedBox(height: 12),
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
                    InputChip(
                      label: Text(_selectedCandidate!.title),
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
              const SizedBox(height: 12),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else if (_error != null)
                _MediaError(
                  message: _error!,
                  onSettings: _goToSettings,
                  showSettings: _error!.contains('API key'),
                )
              else if (_assets.isNotEmpty)
                _AssetGrid(
                  assets: _assets,
                  selectedAsset: _selectedAsset,
                  onSelected: (asset) => setState(() => _selectedAsset = asset),
                )
              else if (_candidates.isNotEmpty)
                _CandidateList(
                  candidates: _candidates,
                  onSelected: _selectCandidate,
                )
              else
                const Text(
                  'Buscá un juego para ver portadas, o elegí un archivo local.',
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
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
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.save_alt_outlined),
            label: const Text('Guardar portada'),
          ),
      ],
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
      final result = await ref
          .read(searchMediaGamesUseCaseProvider)
          .call(_queryController.text);
      if (!mounted) return;
      setState(() {
        _candidates = result;
        _error = result.isEmpty ? 'SteamGridDB no devolvió candidatos.' : null;
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
      final result = await ref
          .read(searchCoverAssetsUseCaseProvider)
          .call(candidate.externalId);
      if (!mounted) return;
      setState(() {
        _assets = result;
        _error = result.isEmpty ? 'SteamGridDB no devolvió portadas.' : null;
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
    if (error is MediaException) return error.message;
    return 'No se pudo completar la operación de portada.';
  }
}

class _CandidateList extends StatelessWidget {
  const _CandidateList({required this.candidates, required this.onSelected});

  final List<MediaSearchCandidate> candidates;
  final ValueChanged<MediaSearchCandidate> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final candidate in candidates)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.image_search_outlined),
            title: Text(candidate.title),
            subtitle: Text(
              '${candidate.providerName} · ID ${candidate.externalId}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => onSelected(candidate),
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
    return SizedBox(
      height: 420,
      child: GridView.builder(
        itemCount: assets.length,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 150,
          childAspectRatio: 2 / 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          final asset = assets[index];
          final selected = selectedAsset?.externalId == asset.externalId;
          return InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => onSelected(asset),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      selected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).dividerColor,
                  width: selected ? 3 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Image.network(
                  asset.thumbnailUrl ?? asset.remoteUrl,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => const Center(
                        child: Icon(Icons.broken_image_outlined),
                      ),
                ),
              ),
            ),
          );
        },
      ),
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
