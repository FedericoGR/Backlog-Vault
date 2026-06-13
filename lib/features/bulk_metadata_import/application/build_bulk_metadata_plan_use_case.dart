import '../../../core/database/app_database.dart';
import '../../../core/privacy/privacy_redactor.dart';
import '../../library/domain/library_game_row.dart';
import '../../media/domain/media_asset_models.dart';
import '../../metadata/domain/external_game_details.dart';
import '../../metadata/domain/metadata_exception.dart';
import '../../metadata/domain/metadata_provider.dart';
import '../domain/bulk_metadata_import_models.dart';
import 'bulk_import_scope_filter.dart';
import 'bulk_match_scorer.dart';
import 'bulk_metadata_diff_builder.dart';

typedef BulkPlanProgress =
    void Function({required int processed, required int total, String? title});

typedef BulkCancelCheck = bool Function();

typedef BulkExternalIdsLoader =
    Future<List<ExternalGameId>> Function(String gameId);

typedef BulkCoverPlanResolve =
    Future<BulkCoverPlan?> Function({
      required LibraryGameRow row,
      required ExternalGameDetails details,
      required BulkMetadataImportOptions options,
    });

class BuildBulkMetadataPlanUseCase {
  const BuildBulkMetadataPlanUseCase({
    this.scopeFilter = const BulkImportScopeFilter(),
    this.matchScorer = const BulkMatchScorer(),
    this.diffBuilder = const BulkMetadataDiffBuilder(),
  });

  final BulkImportScopeFilter scopeFilter;
  final BulkMatchScorer matchScorer;
  final BulkMetadataDiffBuilder diffBuilder;

  Future<BulkMetadataImportPlan> call({
    required List<LibraryGameRow> rows,
    required MetadataProvider provider,
    required BulkMetadataImportOptions options,
    BulkExternalIdsLoader? loadExternalIds,
    BulkCoverPlanResolve? resolveCoverPlan,
    BulkPlanProgress? onProgress,
    BulkCancelCheck? isCancelled,
  }) async {
    final scopedRows = scopeFilter.apply(rows: rows, scope: options.scope);
    final total = scopedRows.length;
    final items = <BulkMetadataImportItem>[];
    final maxConcurrency = options.maxConcurrency.clamp(1, 3);
    var processed = 0;

    for (var index = 0; index < scopedRows.length; index += maxConcurrency) {
      if (isCancelled?.call() ?? false) break;
      final batch = scopedRows.skip(index).take(maxConcurrency).toList();
      final batchItems = await Future.wait(
        batch.map(
          (row) => _buildItem(
            row: row,
            provider: provider,
            options: options,
            loadExternalIds: loadExternalIds,
            resolveCoverPlan: resolveCoverPlan,
          ),
        ),
      );
      for (final item in batchItems) {
        items.add(item);
        processed++;
        onProgress?.call(
          processed: processed,
          total: total,
          title: item.row.title,
        );
      }
    }

    return BulkMetadataImportPlan(options: options, items: items);
  }

  Future<BulkMetadataImportItem> _buildItem({
    required LibraryGameRow row,
    required MetadataProvider provider,
    required BulkMetadataImportOptions options,
    required BulkExternalIdsLoader? loadExternalIds,
    required BulkCoverPlanResolve? resolveCoverPlan,
  }) async {
    try {
      final externalIds =
          loadExternalIds == null
              ? const <ExternalGameId>[]
              : await loadExternalIds(row.gameId);
      final existingForSelectedProvider = _existingExternalIdForProvider(
        externalIds,
        options.providerId,
      );
      final candidates = await provider.searchGames(row.title);
      if (candidates.isEmpty) {
        return BulkMetadataImportItem(
          row: row,
          included: false,
          issues: const [
            BulkImportIssue(
              message: 'El proveedor no devolvió candidatos.',
              severity: BulkImportIssueSeverity.info,
            ),
          ],
        );
      }

      final scored = matchScorer.scoreCandidates(
        row: row,
        candidates: candidates,
        existingExternalId: existingForSelectedProvider?.externalId,
      );
      final best = scored.first;
      if (best.confidence != BulkMetadataConfidence.safe) {
        return BulkMetadataImportItem(
          row: row,
          included: false,
          candidates: scored,
          issues: [
            BulkImportIssue(
              message:
                  best.confidence == BulkMetadataConfidence.probable
                      ? 'Match probable: revisar antes de aplicar.'
                      : 'Match ambiguo: requiere revisión manual.',
              severity: BulkImportIssueSeverity.warning,
            ),
          ],
        );
      }

      return buildItemFromCandidate(
        row: row,
        provider: provider,
        options: options,
        selectedCandidate: best,
        candidates: scored,
        externalIds: externalIds,
        resolveCoverPlan: resolveCoverPlan,
      );
    } catch (error) {
      return BulkMetadataImportItem(
        row: row,
        included: false,
        issues: [
          BulkImportIssue(
            message: privacyRedactor.redact(_messageForError(error)),
            severity: BulkImportIssueSeverity.error,
          ),
        ],
      );
    }
  }

  Future<BulkMetadataImportItem> buildItemFromCandidate({
    required LibraryGameRow row,
    required MetadataProvider provider,
    required BulkMetadataImportOptions options,
    required BulkMetadataCandidate selectedCandidate,
    required List<BulkMetadataCandidate> candidates,
    BulkExternalIdsLoader? loadExternalIds,
    BulkCoverPlanResolve? resolveCoverPlan,
    List<ExternalGameId>? externalIds,
  }) async {
    try {
      final details = await provider.getGameDetails(
        selectedCandidate.candidate.externalId,
      );
      final issues = <BulkImportIssue>[];
      final loadedExternalIds =
          externalIds ??
          (loadExternalIds == null
              ? const <ExternalGameId>[]
              : await loadExternalIds(row.gameId));
      final existingForProvider = _existingExternalIdForProvider(
        loadedExternalIds,
        details.providerId,
      );
      final hasDifferentExternalId =
          existingForProvider != null &&
          existingForProvider.externalId != details.externalId;
      if (hasDifferentExternalId) {
        issues.add(
          BulkImportIssue(
            message:
                options.allowMetadataReplacement
                    ? 'Este juego ya tiene otro match externo para el proveedor. Se reemplaza solo si incluís este juego y confirmás REEMPLAZAR.'
                    : 'Este juego ya tiene otro match externo para el proveedor. Cambiá a Revisar y reemplazar para permitir el reemplazo.',
            severity:
                options.allowMetadataReplacement
                    ? BulkImportIssueSeverity.warning
                    : BulkImportIssueSeverity.error,
          ),
        );
      }

      final fieldPlans = diffBuilder.build(
        row: row,
        details: details,
        includeMetadata: options.includeMetadata,
        applyMode: options.applyMode,
      );
      final coverPlan =
          resolveCoverPlan == null
              ? await _coverPlan(row: row, details: details, options: options)
              : await resolveCoverPlan(
                row: row,
                details: details,
                options: options,
              );
      final selectedByDefault =
          !hasDifferentExternalId &&
          selectedCandidate.confidence == BulkMetadataConfidence.safe &&
          (fieldPlans.any((plan) => plan.selected) ||
              coverPlan?.selected == true ||
              existingForProvider == null);

      return BulkMetadataImportItem(
        row: row,
        included: selectedByDefault,
        candidates: candidates,
        selectedDetails: details,
        fieldPlans: fieldPlans,
        coverPlan: coverPlan,
        issues: issues,
      );
    } catch (error) {
      return BulkMetadataImportItem(
        row: row,
        included: false,
        candidates: candidates,
        issues: [
          BulkImportIssue(
            message: privacyRedactor.redact(_messageForError(error)),
            severity: BulkImportIssueSeverity.error,
          ),
        ],
      );
    }
  }

  ExternalGameId? _existingExternalIdForProvider(
    List<ExternalGameId> externalIds,
    String providerId,
  ) {
    for (final externalId in externalIds) {
      if (externalId.provider == providerId) return externalId;
    }
    return null;
  }

  Future<BulkCoverPlan?> _coverPlan({
    required LibraryGameRow row,
    required ExternalGameDetails details,
    required BulkMetadataImportOptions options,
  }) async {
    if (!options.shouldImportCovers) return null;
    if (row.selectedCoverLocalPath != null && !options.allowCoverReplacement) {
      return const BulkCoverPlan(
        asset: null,
        selected: false,
        canApply: false,
        reason: 'Ya tiene portada seleccionada.',
      );
    }
    final cover = details.cover;
    if (details.providerId != 'igdb' || cover == null) {
      return const BulkCoverPlan(
        asset: null,
        selected: false,
        canApply: false,
        reason: 'El proveedor no ofrece portada aplicable en este flujo.',
      );
    }
    return BulkCoverPlan(
      asset: ExternalMediaAsset(
        providerId: details.providerId,
        providerName: details.providerName,
        externalId: cover.externalId,
        kind: MediaAssetKind.cover,
        remoteUrl: cover.remoteUrl,
        thumbnailUrl: cover.thumbnailUrl,
        mimeType: 'image/jpeg',
        width: cover.width,
        height: cover.height,
        attribution: details.providerName,
      ),
      selected: row.selectedCoverLocalPath == null,
      canApply: true,
      replacesExisting: row.selectedCoverLocalPath != null,
      currentProviderName: row.selectedCoverProvider,
    );
  }

  String _messageForError(Object error) {
    if (error is MetadataException) return error.message;
    return 'No se pudo analizar este juego con el proveedor seleccionado.';
  }
}
