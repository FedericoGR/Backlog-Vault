import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../media/application/media_providers.dart';
import '../../media/domain/media_provider.dart';
import '../../metadata/application/metadata_providers.dart';
import '../../metadata/data/metadata_repository.dart';
import '../../metadata/domain/metadata_provider.dart';
import '../../library/domain/library_game_row.dart';
import '../domain/bulk_metadata_import_models.dart';
import 'apply_bulk_metadata_plan_use_case.dart';
import 'bulk_cover_plan_resolver.dart';
import 'build_bulk_metadata_plan_use_case.dart';

final buildBulkMetadataPlanUseCaseProvider =
    Provider<BuildBulkMetadataPlanUseCase>((ref) {
      return const BuildBulkMetadataPlanUseCase();
    });

final applyBulkMetadataPlanUseCaseProvider =
    Provider<ApplyBulkMetadataPlanUseCase>((ref) {
      return ApplyBulkMetadataPlanUseCase(
        applyMetadata: ref.watch(applyMetadataUseCaseProvider).call,
        saveCover:
            ({required gameId, required asset}) => ref
                .watch(saveSelectedMediaAssetUseCaseProvider)
                .fromRemoteCover(gameId: gameId, asset: asset),
      );
    });

final bulkMetadataProviderListProvider = metadataProviderListProvider;

final bulkMetadataImportViewModelProvider =
    Provider<BulkMetadataImportViewModel>((ref) {
      return BulkMetadataImportViewModel(
        builder: ref.watch(buildBulkMetadataPlanUseCaseProvider),
        applier: ref.watch(applyBulkMetadataPlanUseCaseProvider),
        repository: ref.watch(metadataRepositoryProvider),
        mediaProviders: ref.watch(mediaProviderListProvider),
      );
    });

/// Coordinates plan construction, candidate replacement and atomic apply.
class BulkMetadataImportViewModel {
  const BulkMetadataImportViewModel({
    required BuildBulkMetadataPlanUseCase builder,
    required ApplyBulkMetadataPlanUseCase applier,
    required MetadataRepository repository,
    required List<MediaProvider> mediaProviders,
  }) : _builder = builder,
       _applier = applier,
       _repository = repository,
       _mediaProviders = mediaProviders;

  final BuildBulkMetadataPlanUseCase _builder;
  final ApplyBulkMetadataPlanUseCase _applier;
  final MetadataRepository _repository;
  final List<MediaProvider> _mediaProviders;

  Future<BulkMetadataImportPlan> scan({
    required List<LibraryGameRow> rows,
    required MetadataProvider provider,
    required BulkMetadataImportOptions options,
    BulkPlanProgress? onProgress,
    BulkCancelCheck? isCancelled,
  }) {
    return _builder.call(
      rows: rows,
      provider: provider,
      options: options,
      loadExternalIds: _repository.externalIdsForGame,
      resolveCoverPlan:
          BulkCoverPlanResolver(mediaProviders: _mediaProviders).call,
      onProgress: onProgress,
      isCancelled: isCancelled,
    );
  }

  Future<BulkMetadataImportItem> rebuildItem({
    required BulkMetadataImportItem item,
    required BulkMetadataCandidate candidate,
    required MetadataProvider provider,
    required BulkMetadataImportOptions options,
  }) {
    return _builder.buildItemFromCandidate(
      row: item.row,
      provider: provider,
      options: options,
      selectedCandidate: candidate,
      candidates: item.candidates,
      loadExternalIds: _repository.externalIdsForGame,
      resolveCoverPlan:
          BulkCoverPlanResolver(mediaProviders: _mediaProviders).call,
    );
  }

  Future<BulkImportResult> apply(BulkMetadataImportPlan plan) =>
      _applier.call(plan);
}
