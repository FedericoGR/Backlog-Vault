import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../media/application/media_providers.dart';
import '../../metadata/application/metadata_providers.dart';
import '../../metadata/data/metadata_repository.dart';
import 'apply_bulk_metadata_plan_use_case.dart';
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

final bulkMetadataRepositoryProvider = metadataRepositoryProvider;

final bulkMediaProviderListProvider = mediaProviderListProvider;
