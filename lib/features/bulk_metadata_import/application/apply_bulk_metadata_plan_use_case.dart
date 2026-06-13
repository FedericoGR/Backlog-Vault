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
    var coversSaved = 0;
    var skipped = 0;
    final warnings = <BulkImportIssue>[];
    final errors = <BulkImportIssue>[];

    for (final item in plan.items) {
      if (!item.canApply) {
        skipped++;
        warnings.addAll(
          item.issues.where(
            (issue) => issue.severity != BulkImportIssueSeverity.error,
          ),
        );
        continue;
      }
      warnings.addAll(
        item.issues.where(
          (issue) => issue.severity != BulkImportIssueSeverity.error,
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
        metadataApplied++;
      } catch (error) {
        errors.add(
          BulkImportIssue(
            message:
                '${item.row.title}: ${privacyRedactor.redact(error.toString())}',
            severity: BulkImportIssueSeverity.error,
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
                  '${item.row.title}: portada no guardada. ${privacyRedactor.redact(error.toString())}',
              severity: BulkImportIssueSeverity.error,
            ),
          );
        }
      }
    }

    return BulkImportResult(
      processed: processed,
      metadataApplied: metadataApplied,
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
}
