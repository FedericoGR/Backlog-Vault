import '../../../core/privacy/privacy_redactor.dart';
import '../../library/domain/library_game_row.dart';
import '../../media/data/igdb_media_provider.dart';
import '../../media/domain/media_asset_models.dart';
import '../../media/domain/media_exception.dart';
import '../../media/domain/media_provider.dart';
import '../../metadata/domain/external_game_details.dart';
import '../domain/bulk_metadata_import_models.dart';
import 'bulk_match_scorer.dart';

class BulkCoverPlanResolver {
  const BulkCoverPlanResolver({required this.mediaProviders});

  final List<MediaProvider> mediaProviders;

  Future<BulkCoverPlan?> call({
    required LibraryGameRow row,
    required ExternalGameDetails details,
    required BulkMetadataImportOptions options,
  }) async {
    if (!options.shouldImportCovers) return null;

    final hasExistingCover = row.selectedCoverLocalPath != null;
    if (hasExistingCover && !options.allowCoverReplacement) {
      return BulkCoverPlan(
        asset: null,
        selected: false,
        canApply: false,
        replacesExisting: true,
        currentProviderName: _currentProviderName(row),
        reason: 'Ya tiene portada seleccionada.',
      );
    }

    final order = _providerOrder(options.coverProviderMode);
    if (order.isEmpty) return null;

    final reasons = <String>[];
    for (final providerId in order) {
      try {
        final assets = await _resolveAssets(
          providerId: providerId,
          row: row,
          details: details,
        );
        if (assets.isEmpty) {
          reasons.add('${_providerLabel(providerId)}: sin portada.');
          continue;
        }
        return BulkCoverPlan(
          asset: assets.first,
          candidateAssets: assets.skip(1).toList(growable: false),
          selected: !hasExistingCover,
          canApply: true,
          replacesExisting: hasExistingCover,
          currentProviderName: _currentProviderName(row),
          reason: hasExistingCover ? 'Reemplazo disponible.' : null,
        );
      } on MediaException catch (error) {
        reasons.add(
          '${_providerLabel(providerId)}: ${privacyRedactor.redact(error.message)}',
        );
      } catch (error) {
        reasons.add(
          '${_providerLabel(providerId)}: ${privacyRedactor.redact(error.toString())}',
        );
      }
    }

    return BulkCoverPlan(
      asset: null,
      selected: false,
      canApply: false,
      replacesExisting: hasExistingCover,
      currentProviderName: _currentProviderName(row),
      reason:
          reasons.isEmpty
              ? 'No se encontró portada aplicable.'
              : reasons.join(' '),
    );
  }

  Future<List<ExternalMediaAsset>> _resolveAssets({
    required String providerId,
    required LibraryGameRow row,
    required ExternalGameDetails details,
  }) async {
    if (providerId == 'igdb') {
      final coverFromDetails = externalGameCoverToMediaAsset(details.cover);
      if (details.providerId == 'igdb' && coverFromDetails != null) {
        return [coverFromDetails];
      }
    }

    final provider = _providerById(providerId);
    if (provider == null) return const [];
    final candidates = await provider.searchGames(row.title);
    if (candidates.isEmpty) return const [];
    final candidate = _bestMediaCandidate(row.title, candidates);
    final covers = await provider.searchCoverAssets(candidate.externalId);
    if (covers.isEmpty) return const [];
    return covers;
  }

  MediaSearchCandidate _bestMediaCandidate(
    String localTitle,
    List<MediaSearchCandidate> candidates,
  ) {
    final normalizedLocal = normalizeTitle(localTitle);
    for (final candidate in candidates) {
      if (normalizeTitle(candidate.title) == normalizedLocal) {
        return candidate;
      }
    }
    return candidates.first;
  }

  MediaProvider? _providerById(String providerId) {
    for (final provider in mediaProviders) {
      if (provider.providerId == providerId) return provider;
    }
    return null;
  }

  List<String> _providerOrder(BulkCoverProviderMode mode) {
    return switch (mode) {
      BulkCoverProviderMode.none => const [],
      BulkCoverProviderMode.igdb => const ['igdb'],
      BulkCoverProviderMode.steamgriddb => const ['steamgriddb'],
      BulkCoverProviderMode.igdbThenSteamGridDb => const [
        'igdb',
        'steamgriddb',
      ],
      BulkCoverProviderMode.steamGridDbThenIgdb => const [
        'steamgriddb',
        'igdb',
      ],
    };
  }

  String _providerLabel(String providerId) {
    return switch (providerId) {
      'igdb' => 'IGDB',
      'steamgriddb' => 'SteamGridDB',
      _ => providerId,
    };
  }

  String? _currentProviderName(LibraryGameRow row) {
    return switch (row.selectedCoverProvider) {
      'igdb' => 'IGDB',
      'steamgriddb' => 'SteamGridDB',
      'local' => 'Archivo local',
      final value? when value.trim().isNotEmpty => value,
      _ => null,
    };
  }
}
