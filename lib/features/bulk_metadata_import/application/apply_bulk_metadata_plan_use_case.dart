import '../../../core/privacy/privacy_redactor.dart';
import '../../media/domain/media_asset_models.dart';
import '../../metadata/domain/apply_metadata_request.dart';
import '../../metadata/domain/metadata_field.dart';
import '../domain/bulk_metadata_import_models.dart';

typedef BulkMetadataApplier =
    Future<void> Function(ApplyMetadataRequest request);

typedef BulkCoverSaver =
    Future<void> Function({
      required String gameId,
      required ExternalMediaAsset asset,
    });

class ApplyBulkMetadataPlanUseCase {
  const ApplyBulkMetadataPlanUseCase({
    required BulkMetadataApplier applyMetadata,
    required BulkCoverSaver saveCover,
  }) : _applyMetadata = applyMetadata,
       _saveCover = saveCover;

  final BulkMetadataApplier _applyMetadata;
  final BulkCoverSaver _saveCover;

  Future<BulkImportResult> call(BulkMetadataImportPlan plan) async {
    var processed = 0;
    var metadataApplied = 0;
    var fieldChangesApplied = 0;
    var externalLinksSaved = 0;
    var coversSaved = 0;
    var skipped = 0;
    final warnings = <BulkImportIssue>[
      for (final issue in plan.globalIssues)
        _withContext(
          issue,
          providerId: plan.options.providerId,
          isGlobal: true,
        ),
    ];
    final errors = <BulkImportIssue>[];

    for (final item in plan.items) {
      if (!item.canApply) {
        skipped++;
        warnings.addAll(
          item.issues
              .where((issue) => issue.severity != BulkImportIssueSeverity.error)
              .map(
                (issue) => _withContext(
                  issue,
                  item: item,
                  providerId: plan.options.providerId,
                ),
              ),
        );
        errors.addAll(
          item.issues
              .where((issue) => issue.severity == BulkImportIssueSeverity.error)
              .map(
                (issue) => _withContext(
                  issue,
                  item: item,
                  providerId: plan.options.providerId,
                ),
              ),
        );
        continue;
      }
      warnings.addAll(
        item.issues
            .where((issue) => issue.severity != BulkImportIssueSeverity.error)
            .map(
              (issue) => _withContext(
                issue,
                item: item,
                providerId: plan.options.providerId,
              ),
            ),
      );
      processed++;
      final details = item.selectedDetails!;
      final selectedFields = _selectedFields(item);
      try {
        await _applyMetadata(
          ApplyMetadataRequest(
            gameId: item.row.gameId,
            libraryEntryId: item.row.libraryEntryId,
            details: details,
            selectedFields: selectedFields,
          ),
        );
        if (selectedFields.isNotEmpty) metadataApplied++;
        fieldChangesApplied += selectedFields.length;
        externalLinksSaved++;
      } catch (error) {
        errors.add(
          BulkImportIssue(
            message: privacyRedactor.redact(error.toString()),
            severity: BulkImportIssueSeverity.error,
            gameTitle: item.row.title,
            providerId: details.providerId,
            providerName: details.providerName,
          ),
        );
        continue;
      }

      final coverAsset = item.coverPlan?.asset;
      if (item.hasSelectedCover && coverAsset != null) {
        try {
          await _saveCover(gameId: item.row.gameId, asset: coverAsset);
          coversSaved++;
        } catch (error) {
          errors.add(
            BulkImportIssue(
              message:
                  'portada no guardada. ${privacyRedactor.redact(error.toString())}',
              severity: BulkImportIssueSeverity.error,
              gameTitle: item.row.title,
              providerId: coverAsset.providerId,
              providerName: coverAsset.providerName,
            ),
          );
        }
      }
    }

    return BulkImportResult(
      processed: processed,
      metadataApplied: metadataApplied,
      fieldChangesApplied: fieldChangesApplied,
      externalLinksSaved: externalLinksSaved,
      coversSaved: coversSaved,
      skipped: skipped,
      warnings: warnings,
      errors: errors,
    );
  }

  Set<MetadataField> _selectedFields(BulkMetadataImportItem item) {
    return {
      for (final plan in item.fieldPlans)
        if (plan.selected && plan.canApply && !plan.isProtected) plan.field,
    };
  }

  BulkImportIssue _withContext(
    BulkImportIssue issue, {
    BulkMetadataImportItem? item,
    String? providerId,
    bool isGlobal = false,
  }) {
    final details = item?.selectedDetails;
    return BulkImportIssue(
      message: privacyRedactor.redact(issue.message),
      severity: issue.severity,
      gameTitle: issue.gameTitle ?? item?.row.title,
      providerId: issue.providerId ?? details?.providerId ?? providerId,
      providerName: issue.providerName ?? details?.providerName,
      isGlobal: issue.isGlobal || isGlobal,
    );
  }
}
