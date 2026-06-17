import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/design_system/bv_breakpoints.dart';
import '../../../core/design_system/bv_chip.dart';
import '../../../core/design_system/bv_empty_state.dart';
import '../../../core/design_system/bv_panel.dart';
import '../../../core/design_system/bv_section.dart';
import '../../../core/design_system/bv_spacing.dart';
import '../../../core/design_system/bv_surface.dart';
import '../../../core/design_system/bv_theme_extension.dart';
import '../../../core/formatting/date_formatters.dart';
import '../../../core/privacy/privacy_redactor.dart';
import '../../../core/widgets/dropdown_value_guard.dart';
import '../../catalogs/data/catalog_repository.dart';
import '../../library/domain/game_status.dart';
import '../../media/application/media_providers.dart';
import '../../media/data/igdb_media_provider.dart';
import '../../media/domain/media_asset_models.dart';
import '../../metadata/application/get_metadata_details_use_case.dart';
import '../../metadata/application/metadata_providers.dart';
import '../../metadata/application/search_metadata_use_case.dart';
import '../../metadata/domain/external_game_details.dart';
import '../../metadata/domain/metadata_field.dart';
import '../../metadata/domain/metadata_provider.dart';
import '../../metadata/domain/metadata_search_candidate.dart';
import '../../playthroughs/application/completion_form_model.dart';
import '../application/game_form_model.dart';
import '../application/library_game_details.dart';
import '../data/game_repository.dart';

class GameFormPage extends ConsumerStatefulWidget {
  const GameFormPage({this.entryId, super.key});

  final String? entryId;

  @override
  ConsumerState<GameFormPage> createState() => _GameFormPageState();
}

class _GameFormPageState extends ConsumerState<GameFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _newPlatformController = TextEditingController();
  final _newGenreController = TextEditingController();
  final _completedHoursController = TextEditingController();

  GameStatus _status = GameStatus.backlog;
  String? _type;
  DateTime? _releaseDate;
  int? _rating;
  DateTime? _completedAt;
  double? _completedHours;
  String? _completedPlatformId;
  int? _completedRating;
  bool _loadedExisting = false;
  bool _saving = false;
  final _selectedPlatformIds = <String>{};
  final _selectedGenreIds = <String>{};
  final _pendingPlatformNames = <String>{};
  final _pendingGenreNames = <String>{};
  ExternalMediaAsset? _pendingCoverAsset;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _newPlatformController.dispose();
    _newGenreController.dispose();
    _completedHoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detail =
        widget.entryId == null
            ? const AsyncData<LibraryGameDetails?>(null)
            : ref.watch(libraryGameProvider(widget.entryId!));
    final platforms = ref.watch(catalogRepositoryProvider).watchPlatforms();
    final genres = ref.watch(catalogRepositoryProvider).watchGenres();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entryId == null ? 'Crear juego' : 'Editar juego'),
      ),
      body: detail.when(
        data: (item) {
          if (item != null && !_loadedExisting) {
            _loadExisting(item);
          }

          return StreamBuilder(
            stream: platforms,
            builder: (context, platformSnapshot) {
              return StreamBuilder(
                stream: genres,
                builder: (context, genreSnapshot) {
                  final platformItems = _dedupePlatforms(
                    platformSnapshot.data ?? [],
                  );
                  final genreItems = _dedupeGenres(genreSnapshot.data ?? []);
                  _sanitizeSelections(platformItems, genreItems);
                  final platformMap = {
                    for (final platform in platformItems)
                      platform.id: platform.name,
                  };
                  final genreMap = {
                    for (final genre in genreItems) genre.id: genre.name,
                  };

                  return Form(
                    key: _formKey,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final compact =
                            constraints.maxWidth < BvBreakpoints.mobile;
                        final twoColumns =
                            constraints.maxWidth >= BvBreakpoints.detailWide;
                        final padding =
                            compact ? BvSpacing.pageCompact : BvSpacing.page;
                        final identitySection = _FormSection(
                          title: 'Identidad',
                          subtitle: 'Datos del juego y metadata externa.',
                          child: _FormFieldGrid(
                            twoColumns: twoColumns,
                            children: [
                              TextFormField(
                                controller: _titleController,
                                decoration: const InputDecoration(
                                  labelText: 'Nombre',
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'El nombre es obligatorio.';
                                  }
                                  return null;
                                },
                              ),
                              _MetadataSearchButton(
                                saving: _saving,
                                pendingCoverAsset: _pendingCoverAsset,
                                onSearch:
                                    () => _searchMetadataForForm(
                                      item,
                                      platformItems,
                                      genreItems,
                                    ),
                                onClearCover:
                                    () => setState(
                                      () => _pendingCoverAsset = null,
                                    ),
                              ),
                              _DateField(
                                label: 'Fecha de salida',
                                value: _releaseDate,
                                onChanged:
                                    (value) =>
                                        setState(() => _releaseDate = value),
                              ),
                              DropdownButtonFormField<String?>(
                                initialValue: _type,
                                decoration: const InputDecoration(
                                  labelText: 'Tipo',
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Text('Sin definir'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Un jugador',
                                    child: Text('Un jugador'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Multijugador',
                                    child: Text('Multijugador'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Cooperativo',
                                    child: Text('Cooperativo'),
                                  ),
                                ],
                                onChanged:
                                    (value) => setState(() => _type = value),
                              ),
                            ],
                          ),
                        );
                        final personalSection = _FormSection(
                          title: 'Biblioteca personal',
                          subtitle: 'Estado, puntaje y notas privadas.',
                          child: _FormFieldGrid(
                            twoColumns: twoColumns,
                            children: [
                              DropdownButtonFormField<GameStatus>(
                                initialValue: _status,
                                decoration: const InputDecoration(
                                  labelText: 'Estado',
                                ),
                                items: [
                                  for (final status in GameStatus.values)
                                    DropdownMenuItem(
                                      value: status,
                                      child: Text(status.label),
                                    ),
                                ],
                                onChanged: (value) {
                                  if (value == null) return;
                                  setState(() {
                                    _status = value;
                                    if (value == GameStatus.completed) {
                                      _completedAt ??= DateTime.now();
                                      _completedRating ??= _rating;
                                    }
                                  });
                                },
                              ),
                              DropdownButtonFormField<int?>(
                                initialValue: _rating,
                                decoration: const InputDecoration(
                                  labelText: 'Puntaje personal',
                                ),
                                items: _ratingItems(),
                                onChanged:
                                    (value) => setState(() => _rating = value),
                              ),
                              TextFormField(
                                controller: _notesController,
                                minLines: 4,
                                maxLines: 7,
                                decoration: const InputDecoration(
                                  labelText: 'Notas personales',
                                  alignLabelWithHint: true,
                                ),
                              ),
                            ],
                          ),
                        );
                        final catalogSection = _FormSection(
                          title: 'Catálogos',
                          subtitle: 'Plataformas y géneros asociados.',
                          child: Column(
                            children: [
                              _CatalogSelector(
                                title: 'Plataformas',
                                addLabel: 'Agregar plataforma',
                                controller: _newPlatformController,
                                items: platformMap,
                                selectedIds: _selectedPlatformIds,
                                pendingNames: _pendingPlatformNames,
                                onToggle: (id, selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedPlatformIds.add(id);
                                      _completedPlatformId ??= id;
                                    } else {
                                      _selectedPlatformIds.remove(id);
                                    }
                                  });
                                },
                                onCreate: () async {
                                  final id = await ref
                                      .read(catalogRepositoryProvider)
                                      .createPlatform(
                                        _newPlatformController.text,
                                      );
                                  setState(() {
                                    _selectedPlatformIds.add(id);
                                    _completedPlatformId ??= id;
                                    _newPlatformController.clear();
                                  });
                                },
                                onRemovePending:
                                    (name) => setState(
                                      () => _pendingPlatformNames.remove(name),
                                    ),
                              ),
                              const SizedBox(height: BvSpacing.lg),
                              _CatalogSelector(
                                title: 'Géneros',
                                addLabel: 'Agregar género',
                                controller: _newGenreController,
                                items: genreMap,
                                selectedIds: _selectedGenreIds,
                                pendingNames: _pendingGenreNames,
                                onToggle: (id, selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedGenreIds.add(id);
                                    } else {
                                      _selectedGenreIds.remove(id);
                                    }
                                  });
                                },
                                onCreate: () async {
                                  final id = await ref
                                      .read(catalogRepositoryProvider)
                                      .createGenre(_newGenreController.text);
                                  setState(() {
                                    _selectedGenreIds.add(id);
                                    _newGenreController.clear();
                                  });
                                },
                                onRemovePending:
                                    (name) => setState(
                                      () => _pendingGenreNames.remove(name),
                                    ),
                              ),
                            ],
                          ),
                        );
                        final completionSection =
                            _status == GameStatus.completed
                                ? _FormSection(
                                  title: 'Completado / partida',
                                  subtitle:
                                      'Datos iniciales al marcar como completado.',
                                  child: _CompletionFields(
                                    completedAt: _completedAt ?? DateTime.now(),
                                    hoursController: _completedHoursController,
                                    rating: _completedRating,
                                    platformId: _completedPlatformId,
                                    platforms: platformMap,
                                    twoColumns: twoColumns,
                                    onDateChanged:
                                        (value) => setState(
                                          () => _completedAt = value,
                                        ),
                                    onRatingChanged:
                                        (value) => setState(
                                          () => _completedRating = value,
                                        ),
                                    onPlatformChanged:
                                        (value) => setState(
                                          () => _completedPlatformId = value,
                                        ),
                                  ),
                                )
                                : null;

                        return ListView(
                          padding: padding,
                          children: [
                            if (twoColumns)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        identitySection,
                                        const SizedBox(height: BvSpacing.md),
                                        personalSection,
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: BvSpacing.md),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        catalogSection,
                                        if (completionSection != null) ...[
                                          const SizedBox(height: BvSpacing.md),
                                          completionSection,
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            else ...[
                              identitySection,
                              const SizedBox(height: BvSpacing.md),
                              personalSection,
                              const SizedBox(height: BvSpacing.md),
                              catalogSection,
                              if (completionSection != null) ...[
                                const SizedBox(height: BvSpacing.md),
                                completionSection,
                              ],
                            ],
                            const SizedBox(height: BvSpacing.lg),
                            _SaveActionBar(
                              saving: _saving,
                              onSave: () => _save(item),
                            ),
                            const SizedBox(height: 80),
                          ],
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text(error.toString())),
      ),
    );
  }

  void _loadExisting(LibraryGameDetails item) {
    _loadedExisting = true;
    _titleController.text = item.game.title;
    _releaseDate = item.game.releaseDate;
    _type = _gameTypeForForm(item.game.type);
    _status = parseGameStatus(item.entry.status);
    _rating = item.entry.personalRating;
    _notesController.text = item.entry.personalNotes ?? '';
    _selectedPlatformIds.addAll(item.platforms.map((platform) => platform.id));
    _selectedGenreIds.addAll(item.genres.map((genre) => genre.id));
    _completedPlatformId =
        item.platforms.isEmpty ? null : item.platforms.first.id;
  }

  Future<void> _save(LibraryGameDetails? existing) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final catalogRepository = ref.read(catalogRepositoryProvider);
      final platformIds =
          {
            ..._selectedPlatformIds,
            for (final name in _pendingPlatformNames)
              await catalogRepository.createPlatform(name),
          }.toList();
      final genreIds =
          {
            ..._selectedGenreIds,
            for (final name in _pendingGenreNames)
              await catalogRepository.createGenre(name),
          }.toList();
      final model = GameFormModel(
        entryId: existing?.entry.id,
        gameId: existing?.game.id,
        title: _titleController.text,
        releaseDate: _releaseDate,
        type: _type ?? '',
        status: _status,
        personalRating: _rating,
        personalNotes: _notesController.text,
        platformIds: platformIds,
        genreIds: genreIds,
      );
      final entryId = await ref.read(gameRepositoryProvider).save(model);

      final wasCompleted =
          existing != null &&
          parseGameStatus(existing.entry.status) == GameStatus.completed;
      if (_status == GameStatus.completed && !wasCompleted) {
        _completedHours = double.tryParse(
          _completedHoursController.text.trim().replaceAll(',', '.'),
        );
        await ref
            .read(gameRepositoryProvider)
            .completeGame(
              CompletionFormModel(
                libraryEntryId: entryId,
                completedAt: _completedAt ?? DateTime.now(),
                platformId: _completedPlatformId,
                hoursPlayed: _completedHours,
                rating: _completedRating,
                notes: null,
              ),
            );
      }

      final pendingCover = _pendingCoverAsset;
      if (pendingCover != null) {
        final saved = await ref
            .read(gameRepositoryProvider)
            .getByEntryId(entryId);
        final gameId = saved?.game.id ?? existing?.game.id;
        if (gameId != null) {
          await ref
              .read(saveSelectedMediaAssetUseCaseProvider)
              .fromRemoteCover(gameId: gameId, asset: pendingCover);
        }
      }

      if (!mounted) return;
      context.go('/games/$entryId');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _searchMetadataForForm(
    LibraryGameDetails? existing,
    List<Platform> platformItems,
    List<Genre> genreItems,
  ) async {
    final result = await showDialog<_FormMetadataResult>(
      context: context,
      builder:
          (context) => _GameFormMetadataDialog(
            initialQuery: _titleController.text,
            currentTitle: _titleController.text,
            currentReleaseDate: _releaseDate,
            currentType: _type ?? '',
            currentPlatforms: [
              for (final platform in platformItems)
                if (_selectedPlatformIds.contains(platform.id)) platform.name,
              ..._pendingPlatformNames,
            ],
            currentGenres: [
              for (final genre in genreItems)
                if (_selectedGenreIds.contains(genre.id)) genre.name,
              ..._pendingGenreNames,
            ],
            hasCurrentCover:
                _pendingCoverAsset != null || existing?.selectedCover != null,
          ),
    );
    if (result == null) return;

    setState(() {
      final details = result.details;
      if (result.selectedFields.contains(MetadataField.title)) {
        _titleController.text = details.title;
      }
      if (result.selectedFields.contains(MetadataField.releaseDate)) {
        _releaseDate = details.releaseDate;
      }
      if (result.selectedFields.contains(MetadataField.type)) {
        _type = _gameTypeForForm(details.type) ?? _type;
      }
      if (result.selectedFields.contains(MetadataField.platforms)) {
        _applyCatalogPrefill(
          externalNames: details.platforms,
          existingItems: platformItems,
          selectedIds: _selectedPlatformIds,
          pendingNames: _pendingPlatformNames,
        );
      }
      if (result.selectedFields.contains(MetadataField.genres)) {
        _applyCatalogPrefill(
          externalNames: details.genres,
          existingItems: genreItems,
          selectedIds: _selectedGenreIds,
          pendingNames: _pendingGenreNames,
        );
      }
      if (result.coverAsset != null) {
        _pendingCoverAsset = result.coverAsset;
      }
    });
  }

  void _applyCatalogPrefill<T>({
    required Iterable<String> externalNames,
    required List<T> existingItems,
    required Set<String> selectedIds,
    required Set<String> pendingNames,
  }) {
    final byName = <String, String>{};
    for (final item in existingItems) {
      final id = item is Platform ? item.id : (item as Genre).id;
      final name = item is Platform ? item.name : (item as Genre).name;
      byName[_normalizeName(name)] = id;
    }
    for (final name in externalNames) {
      final normalized = _normalizeName(name);
      if (normalized.isEmpty) continue;
      final existingId = byName[normalized];
      if (existingId != null) {
        selectedIds.add(existingId);
      } else {
        pendingNames.add(name.trim());
      }
    }
  }

  void _sanitizeSelections(List<Platform> platforms, List<Genre> genres) {
    final platformIds = platforms.map((platform) => platform.id).toSet();
    final genreIds = genres.map((genre) => genre.id).toSet();
    final nextPlatformIds =
        _selectedPlatformIds.where(platformIds.contains).toSet();
    final nextGenreIds = _selectedGenreIds.where(genreIds.contains).toSet();
    final nextCompletedPlatformId = safeDropdownValue(_completedPlatformId, [
      null,
      ...platformIds,
    ]);
    if (nextPlatformIds.length == _selectedPlatformIds.length &&
        nextGenreIds.length == _selectedGenreIds.length &&
        nextCompletedPlatformId == _completedPlatformId) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _selectedPlatformIds
          ..clear()
          ..addAll(nextPlatformIds);
        _selectedGenreIds
          ..clear()
          ..addAll(nextGenreIds);
        _completedPlatformId = nextCompletedPlatformId;
      });
    });
  }

  List<Platform> _dedupePlatforms(List<Platform> values) {
    final seen = <String>{};
    final result = <Platform>[];
    for (final value in values) {
      if (seen.add(value.id)) result.add(value);
    }
    return result;
  }

  List<Genre> _dedupeGenres(List<Genre> values) {
    final seen = <String>{};
    final result = <Genre>[];
    for (final value in values) {
      if (seen.add(value.id)) result.add(value);
    }
    return result;
  }
}

String _normalizeName(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

String? _gameTypeForForm(String value) {
  final normalized = value.trim().toLowerCase();
  return switch (normalized) {
    'un jugador' || 'single player' || 'single_player' => 'Un jugador',
    'multijugador' || 'multiplayer' => 'Multijugador',
    'cooperativo' || 'co-op' || 'coop' || 'cooperative' => 'Cooperativo',
    _ => null,
  };
}

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
                'Importar metadata',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: BvSpacing.sm),
              TextField(
                controller: _queryController,
                decoration: InputDecoration(
                  labelText: 'Buscar por título',
                  suffixIcon: IconButton(
                    tooltip: 'Buscar',
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
                  decoration: const InputDecoration(labelText: 'Proveedor'),
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
                            title: 'Sin candidatos todavía',
                            message:
                                'Buscá un juego para prellenar campos desde ${provider.displayName}.',
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
                    child: const Text('Cancelar'),
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
                      label: const Text('Aplicar al formulario'),
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
      final candidates = await SearchMetadataUseCase(
        provider,
      ).call(_queryController.text);
      if (!mounted) return;
      setState(() {
        _candidates = candidates;
        _error =
            candidates.isEmpty
                ? '${provider.displayName} no devolvió candidatos.'
                : null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = privacyRedactor.redact(error.toString()));
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
      final details = await GetMetadataDetailsUseCase(
        provider,
      ).call(candidate.externalId);
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
      setState(() => _error = privacyRedactor.redact(error.toString()));
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
          Text('${details.providerName} · ID ${details.externalId}'),
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
                      title: Text(field.label),
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
                  title: const Text('Guardar portada incluida'),
                  subtitle: Text(
                    hasCurrentCover
                        ? 'Reemplazará la portada al guardar el juego.'
                        : 'Se guardará localmente después de guardar el juego.',
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

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BvPanel(
      child: BvSection(
        title: title,
        subtitle: subtitle,
        padding: EdgeInsets.zero,
        child: child,
      ),
    );
  }
}

class _FormFieldGrid extends StatelessWidget {
  const _FormFieldGrid({required this.children, required this.twoColumns});

  final List<Widget> children;
  final bool twoColumns;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!twoColumns || constraints.maxWidth < 560) {
          return Column(
            children: [
              for (final child in children) ...[
                child,
                if (child != children.last)
                  const SizedBox(height: BvSpacing.sm),
              ],
            ],
          );
        }
        return Wrap(
          spacing: BvSpacing.sm,
          runSpacing: BvSpacing.sm,
          children: [
            for (final child in children)
              SizedBox(
                width: (constraints.maxWidth - BvSpacing.sm) / 2,
                child: child,
              ),
          ],
        );
      },
    );
  }
}

class _MetadataSearchButton extends StatelessWidget {
  const _MetadataSearchButton({
    required this.saving,
    required this.pendingCoverAsset,
    required this.onSearch,
    required this.onClearCover,
  });

  final bool saving;
  final ExternalMediaAsset? pendingCoverAsset;
  final VoidCallback onSearch;
  final VoidCallback onClearCover;

  @override
  Widget build(BuildContext context) {
    return BvSurface(
      padding: const EdgeInsets.all(BvSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OutlinedButton.icon(
            onPressed: saving ? null : onSearch,
            icon: const Icon(Icons.auto_fix_high_outlined),
            label: const Text('Buscar metadata'),
          ),
          if (pendingCoverAsset != null) ...[
            const SizedBox(height: BvSpacing.xs),
            BvChip(
              icon: Icons.image_outlined,
              label: 'Portada pendiente: ${pendingCoverAsset!.providerName}',
              tone: BvChipTone.primary,
              onDeleted: onClearCover,
            ),
          ],
        ],
      ),
    );
  }
}

class _SaveActionBar extends StatelessWidget {
  const _SaveActionBar({required this.saving, required this.onSave});

  final bool saving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return BvPanel(
      dense: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 180),
            child: FilledButton.icon(
              onPressed: saving ? null : onSave,
              icon:
                  saving
                      ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.save_outlined),
              label: const Text('Guardar'),
            ),
          ),
        ],
      ),
    );
  }
}

String _joinNames(Iterable<String> values) {
  final list = values.where((value) => value.trim().isNotEmpty).toList();
  if (list.isEmpty) return '-';
  return list.join(', ');
}

List<DropdownMenuItem<int?>> _ratingItems() {
  return const [
    DropdownMenuItem(value: null, child: Text('Sin puntaje')),
    DropdownMenuItem(value: 1, child: Text('1 estrella')),
    DropdownMenuItem(value: 2, child: Text('2 estrellas')),
    DropdownMenuItem(value: 3, child: Text('3 estrellas')),
    DropdownMenuItem(value: 4, child: Text('4 estrellas')),
    DropdownMenuItem(value: 5, child: Text('5 estrellas')),
  ];
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: Row(
        children: [
          Expanded(child: Text(formatVisibleDate(value))),
          TextButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: value ?? DateTime.now(),
                firstDate: DateTime(1970),
                lastDate: DateTime(2100),
              );
              if (picked != null) onChanged(picked);
            },
            child: const Text('Elegir'),
          ),
          if (value != null)
            IconButton(
              tooltip: 'Limpiar',
              onPressed: () => onChanged(null),
              icon: const Icon(Icons.clear),
            ),
        ],
      ),
    );
  }
}

class _CatalogSelector extends StatelessWidget {
  const _CatalogSelector({
    required this.title,
    required this.addLabel,
    required this.controller,
    required this.items,
    required this.selectedIds,
    required this.pendingNames,
    required this.onToggle,
    required this.onCreate,
    required this.onRemovePending,
  });

  final String title;
  final String addLabel;
  final TextEditingController controller;
  final Map<String, String> items;
  final Set<String> selectedIds;
  final Set<String> pendingNames;
  final void Function(String id, bool selected) onToggle;
  final Future<void> Function() onCreate;
  final ValueChanged<String> onRemovePending;

  @override
  Widget build(BuildContext context) {
    final bv = BvThemeExtension.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: BvSpacing.xs),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final item in items.entries)
              FilterChip(
                label: Text(item.value),
                selected: selectedIds.contains(item.key),
                onSelected: (selected) => onToggle(item.key, selected),
              ),
            for (final name in pendingNames)
              BvChip(
                label: name,
                icon: Icons.auto_fix_high_outlined,
                tone: BvChipTone.primary,
                onDeleted: () => onRemovePending(name),
              ),
          ],
        ),
        const SizedBox(height: BvSpacing.xs),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(labelText: addLabel),
              ),
            ),
            const SizedBox(width: BvSpacing.xs),
            IconButton.filledTonal(
              tooltip: addLabel,
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(
                backgroundColor: bv.surfaceHighest,
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CompletionFields extends StatelessWidget {
  const _CompletionFields({
    required this.completedAt,
    required this.hoursController,
    required this.rating,
    required this.platformId,
    required this.platforms,
    required this.twoColumns,
    required this.onDateChanged,
    required this.onRatingChanged,
    required this.onPlatformChanged,
  });

  final DateTime completedAt;
  final TextEditingController hoursController;
  final int? rating;
  final String? platformId;
  final Map<String, String> platforms;
  final bool twoColumns;
  final ValueChanged<DateTime?> onDateChanged;
  final ValueChanged<int?> onRatingChanged;
  final ValueChanged<String?> onPlatformChanged;

  @override
  Widget build(BuildContext context) {
    final safePlatformId = safeDropdownValue<String?>(platformId, [
      null,
      ...platforms.keys,
    ]);
    return _FormFieldGrid(
      twoColumns: twoColumns,
      children: [
        _DateField(
          label: 'Fecha de completado',
          value: completedAt,
          onChanged: onDateChanged,
        ),
        TextFormField(
          controller: hoursController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Horas jugadas'),
        ),
        DropdownButtonFormField<int?>(
          initialValue: rating,
          decoration: const InputDecoration(labelText: 'Puntaje de partida'),
          items: _ratingItems(),
          onChanged: onRatingChanged,
        ),
        DropdownButtonFormField<String?>(
          initialValue: safePlatformId,
          decoration: const InputDecoration(labelText: 'Plataforma'),
          items: [
            const DropdownMenuItem(value: null, child: Text('Sin plataforma')),
            for (final platform in platforms.entries)
              DropdownMenuItem(
                value: platform.key,
                child: Text(platform.value),
              ),
          ],
          onChanged: onPlatformChanged,
        ),
      ],
    );
  }
}
