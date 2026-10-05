import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/bv_async_action_button.dart';
import '../../../core/design_system/bv_breakpoints.dart';
import '../../../core/design_system/bv_chip.dart';
import '../../../core/design_system/bv_empty_state.dart';
import '../../../core/design_system/bv_error_state.dart';
import '../../../core/design_system/bv_feedback.dart';
import '../../../core/design_system/bv_loading_state.dart';
import '../../../core/design_system/bv_panel.dart';
import '../../../core/design_system/bv_section.dart';
import '../../../core/design_system/bv_spacing.dart';
import '../../../core/design_system/bv_surface.dart';
import '../../../core/design_system/bv_theme_extension.dart';
import '../../../core/formatting/date_formatters.dart';
import '../../../core/widgets/dropdown_value_guard.dart';
import '../../../l10n/domain_localizations.dart';
import '../../../l10n/l10n.dart';
import '../../catalogs/application/catalog_controller.dart';
import '../../catalogs/domain/catalog_item.dart';
import '../../media/domain/igdb_cover_mapper.dart';
import '../../media/domain/media_asset_models.dart';
import '../../metadata/application/metadata_providers.dart';
import '../../metadata/domain/external_game_details.dart';
import '../../metadata/domain/metadata_field.dart';
import '../../metadata/domain/metadata_provider.dart';
import '../../metadata/domain/metadata_search_candidate.dart';
import '../application/game_form_model.dart';
import '../application/game_view_models.dart';
import '../application/library_game_details.dart';

part 'parts/game_form_metadata.dart';
part 'parts/game_form_sections.dart';

/// Creates or edits a game while delegating all persistence to its view model.
class GameFormPage extends ConsumerStatefulWidget {
  const GameFormPage({
    this.entryId,
    this.initialPlayedYear,
    this.initialYearUnknown = false,
    super.key,
  });

  final String? entryId;
  final int? initialPlayedYear;
  final bool initialYearUnknown;

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
  final _playedYearController = TextEditingController();

  bool _isCompleted = false;
  String? _type;
  DateTime? _releaseDate;
  int? _rating;
  DateTime? _completedAt;
  String? _completedPlatformId;
  bool _loadedExisting = false;
  bool _saving = false;
  final _selectedPlatformIds = <String>{};
  final _selectedGenreIds = <String>{};
  final _pendingPlatformNames = <String>{};
  final _pendingGenreNames = <String>{};
  ExternalMediaAsset? _pendingCoverAsset;

  @override
  void initState() {
    super.initState();
    if (widget.entryId == null && !widget.initialYearUnknown) {
      _playedYearController.text =
          (widget.initialPlayedYear ?? DateTime.now().year).toString();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _newPlatformController.dispose();
    _newGenreController.dispose();
    _completedHoursController.dispose();
    _playedYearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detail =
        widget.entryId == null
            ? const AsyncData<LibraryGameDetails?>(null)
            : ref.watch(libraryGameProvider(widget.entryId!));
    final platforms = ref.watch(catalogControllerProvider).watchPlatforms();
    final genres = ref.watch(catalogControllerProvider).watchGenres();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.entryId == null
              ? context.l10n.gameCreateTitle
              : context.l10n.gameEditTitle,
        ),
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
                  if (platformSnapshot.hasData && genreSnapshot.hasData) {
                    _sanitizeSelections(platformItems, genreItems);
                  }
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
                          title: context.l10n.gameIdentity,
                          subtitle: context.l10n.gameIdentitySubtitle,
                          child: _FormFieldGrid(
                            twoColumns: twoColumns,
                            children: [
                              TextFormField(
                                controller: _titleController,
                                decoration: InputDecoration(
                                  labelText: context.l10n.gameName,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return context.l10n.gameNameRequired;
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
                                label: context.l10n.gameReleaseDate,
                                value: _releaseDate,
                                onChanged:
                                    (value) =>
                                        setState(() => _releaseDate = value),
                              ),
                              DropdownButtonFormField<String?>(
                                initialValue: _type,
                                decoration: InputDecoration(
                                  labelText: context.l10n.libraryType,
                                ),
                                items: [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Text(context.l10n.gameTypeUndefined),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Un jugador',
                                    child: Text(
                                      context.l10n.gameTypeSinglePlayer,
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Multijugador',
                                    child: Text(
                                      context.l10n.gameTypeMultiplayer,
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Cooperativo',
                                    child: Text(
                                      context.l10n.gameTypeCooperative,
                                    ),
                                  ),
                                ],
                                onChanged:
                                    (value) => setState(() => _type = value),
                              ),
                            ],
                          ),
                        );
                        final personalSection = _FormSection(
                          title: context.l10n.gamePersonalLibrary,
                          subtitle: context.l10n.gamePersonalLibrarySubtitle,
                          child: _FormFieldGrid(
                            twoColumns: twoColumns,
                            children: [
                              Material(
                                type: MaterialType.transparency,
                                child: SwitchListTile(
                                  title: Text(context.l10n.statusCompleted),
                                  value: _isCompleted,
                                  onChanged:
                                      (value) =>
                                          setState(() => _isCompleted = value),
                                ),
                              ),
                              TextFormField(
                                key: const ValueKey('played-year-field'),
                                controller: _playedYearController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: context.l10n.logPlayedYear,
                                  hintText: context.l10n.logUnknownYear,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return null;
                                  }
                                  final year = int.tryParse(value.trim());
                                  return year == null || year < 1 || year > 9999
                                      ? context.l10n.logInvalidYear
                                      : null;
                                },
                              ),
                              DropdownButtonFormField<int?>(
                                initialValue: _rating,
                                decoration: InputDecoration(
                                  labelText: context.l10n.gamePersonalRating,
                                ),
                                items: _ratingItems(context),
                                onChanged:
                                    (value) => setState(() => _rating = value),
                              ),
                              TextFormField(
                                controller: _notesController,
                                minLines: 4,
                                maxLines: 7,
                                decoration: InputDecoration(
                                  labelText: context.l10n.gamePersonalNotes,
                                  alignLabelWithHint: true,
                                ),
                              ),
                            ],
                          ),
                        );
                        final catalogSection = _FormSection(
                          title: context.l10n.gameCatalogs,
                          subtitle: context.l10n.gameCatalogsSubtitle,
                          child: Column(
                            children: [
                              _CatalogSelector(
                                title: context.l10n.libraryPlatforms,
                                addLabel: context.l10n.gameAddPlatform,
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
                                      .read(catalogControllerProvider)
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
                                title: context.l10n.libraryGenres,
                                addLabel: context.l10n.gameAddGenre,
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
                                      .read(catalogControllerProvider)
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
                        final completionSection = _FormSection(
                          title: context.l10n.gameCompletionSection,
                          subtitle: context.l10n.gameCompletionSectionSubtitle,
                          child: _PersonalTrackingFields(
                            completedAt: _completedAt,
                            hoursController: _completedHoursController,
                            platformId: _completedPlatformId,
                            platforms: {
                              ...platformMap,
                              if (_completedPlatformId != null &&
                                  !platformMap.containsKey(
                                    _completedPlatformId,
                                  ))
                                _completedPlatformId!:
                                    item?.playedPlatform?.name ??
                                    _completedPlatformId!,
                            },
                            twoColumns: twoColumns,
                            onDateChanged:
                                (value) => setState(() => _completedAt = value),
                            onPlatformChanged:
                                (value) => setState(
                                  () => _completedPlatformId = value,
                                ),
                          ),
                        );

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
                                        ...[
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
                              ...[
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
        loading: () => BvLoadingState(label: context.l10n.loading),
        error:
            (error, stackTrace) => BvErrorState(
              title: context.l10n.gameLoadError,
              message: context.l10n.unexpectedErrorMessage,
              retryLabel: context.l10n.retry,
              onRetry:
                  widget.entryId == null
                      ? null
                      : () =>
                          ref.invalidate(libraryGameProvider(widget.entryId!)),
            ),
      ),
    );
  }

  void _loadExisting(LibraryGameDetails item) {
    _loadedExisting = true;
    _titleController.text = item.game.title;
    _releaseDate = item.game.releaseDate;
    _type = _gameTypeForForm(item.game.type);
    _isCompleted = item.entry.isCompleted;
    _rating = item.entry.personalRating;
    _notesController.text = item.entry.personalNotes ?? '';
    _selectedPlatformIds.addAll(item.platforms.map((platform) => platform.id));
    _selectedGenreIds.addAll(item.genres.map((genre) => genre.id));
    _completedPlatformId = item.entry.playedPlatformId;
    _completedAt = item.entry.completedAt;
    _playedYearController.text = item.entry.playedYear?.toString() ?? '';
    _completedHoursController.text = item.entry.hoursPlayed?.toString() ?? '';
  }

  Future<void> _save(LibraryGameDetails? existing) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final model = GameFormModel(
        entryId: existing?.entry.id,
        gameId: existing?.game.id,
        title: _titleController.text,
        releaseDate: _releaseDate,
        type: _type ?? '',
        isCompleted: _isCompleted,
        completedAt: _completedAt,
        playedYear: int.tryParse(_playedYearController.text.trim()),
        hoursPlayed: double.tryParse(
          _completedHoursController.text.trim().replaceAll(',', '.'),
        ),
        playedPlatformId: _completedPlatformId,
        personalRating: _rating,
        personalNotes: _notesController.text,
        platformIds: _selectedPlatformIds.toList(),
        genreIds: _selectedGenreIds.toList(),
      );

      final entryId = await ref
          .read(gameFormViewModelProvider)
          .save(
            GameFormSaveRequest(
              model: model,
              pendingPlatformNames: _pendingPlatformNames,
              pendingGenreNames: _pendingGenreNames,
              cover: _pendingCoverAsset,
            ),
          );

      if (!mounted) return;
      context.go('/games/$entryId');
    } catch (error) {
      if (!mounted) return;
      BvFeedback.show(context, context.l10n.gameSaveFailed);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _searchMetadataForForm(
    LibraryGameDetails? existing,
    List<CatalogItem> platformItems,
    List<CatalogItem> genreItems,
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

  void _applyCatalogPrefill({
    required Iterable<String> externalNames,
    required List<CatalogItem> existingItems,
    required Set<String> selectedIds,
    required Set<String> pendingNames,
  }) {
    final byName = <String, String>{};
    for (final item in existingItems) {
      byName[_normalizeName(item.name)] = item.id;
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

  void _sanitizeSelections(
    List<CatalogItem> platforms,
    List<CatalogItem> genres,
  ) {
    final platformIds = platforms.map((platform) => platform.id).toSet();
    final genreIds = genres.map((genre) => genre.id).toSet();
    final nextPlatformIds =
        _selectedPlatformIds.where(platformIds.contains).toSet();
    final nextGenreIds = _selectedGenreIds.where(genreIds.contains).toSet();
    if (nextPlatformIds.length == _selectedPlatformIds.length &&
        nextGenreIds.length == _selectedGenreIds.length) {
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
      });
    });
  }

  List<CatalogItem> _dedupePlatforms(List<CatalogItem> values) {
    final seen = <String>{};
    final result = <CatalogItem>[];
    for (final value in values) {
      if (seen.add(value.id)) result.add(value);
    }
    return result;
  }

  List<CatalogItem> _dedupeGenres(List<CatalogItem> values) {
    final seen = <String>{};
    final result = <CatalogItem>[];
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
