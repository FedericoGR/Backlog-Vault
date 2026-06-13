import '../../library/domain/library_game_row.dart';
import '../../media/domain/media_asset_models.dart';
import '../../metadata/domain/external_game_details.dart';
import '../../metadata/domain/metadata_field.dart';
import '../../metadata/domain/metadata_search_candidate.dart';

enum BulkMetadataImportScope {
  all,
  onlyWithoutMetadata,
  onlyWithoutCover,
  onlyIncompleteFields;

  String get label => switch (this) {
    BulkMetadataImportScope.all => 'Toda la biblioteca',
    BulkMetadataImportScope.onlyWithoutMetadata => 'Solo sin metadata',
    BulkMetadataImportScope.onlyWithoutCover => 'Solo sin portada',
    BulkMetadataImportScope.onlyIncompleteFields => 'Solo campos incompletos',
  };
}

enum BulkMetadataConfidence {
  safe,
  probable,
  ambiguous,
  none;

  String get label => switch (this) {
    BulkMetadataConfidence.safe => 'Seguro',
    BulkMetadataConfidence.probable => 'Probable',
    BulkMetadataConfidence.ambiguous => 'Ambiguo',
    BulkMetadataConfidence.none => 'Sin match',
  };
}

enum BulkImportIssueSeverity {
  info,
  warning,
  error;

  String get label => switch (this) {
    BulkImportIssueSeverity.info => 'Info',
    BulkImportIssueSeverity.warning => 'Warning',
    BulkImportIssueSeverity.error => 'Error',
  };
}

class BulkMetadataImportOptions {
  const BulkMetadataImportOptions({
    required this.providerId,
    this.scope = BulkMetadataImportScope.onlyIncompleteFields,
    this.includeMetadata = true,
    this.includeMissingCovers = true,
    this.replaceExistingCovers = false,
    this.maxConcurrency = 2,
  });

  final String providerId;
  final BulkMetadataImportScope scope;
  final bool includeMetadata;
  final bool includeMissingCovers;
  final bool replaceExistingCovers;
  final int maxConcurrency;
}

class BulkImportIssue {
  const BulkImportIssue({
    required this.message,
    this.severity = BulkImportIssueSeverity.warning,
    this.gameTitle,
    this.providerId,
    this.providerName,
    this.isGlobal = false,
  });

  final String message;
  final BulkImportIssueSeverity severity;
  final String? gameTitle;
  final String? providerId;
  final String? providerName;
  final bool isGlobal;

  String get displayMessage {
    if (isGlobal) return 'Global: $message';
    final parts = [
      if (gameTitle != null && gameTitle!.trim().isNotEmpty) gameTitle!.trim(),
      if (providerName != null && providerName!.trim().isNotEmpty)
        providerName!.trim()
      else if (providerId != null && providerId!.trim().isNotEmpty)
        providerId!.trim(),
      message,
    ];
    return parts.join(' · ');
  }
}

class BulkMetadataCandidate {
  const BulkMetadataCandidate({
    required this.candidate,
    required this.confidence,
    required this.score,
    this.reasons = const [],
  });

  final MetadataSearchCandidate candidate;
  final BulkMetadataConfidence confidence;
  final int score;
  final List<String> reasons;
}

class BulkMetadataFieldPlan {
  const BulkMetadataFieldPlan({
    required this.field,
    required this.currentValue,
    required this.externalValue,
    required this.selected,
    this.canApply = true,
    this.isProtected = false,
  });

  final MetadataField field;
  final String currentValue;
  final String externalValue;
  final bool selected;
  final bool canApply;
  final bool isProtected;

  BulkMetadataFieldPlan copyWith({bool? selected}) {
    return BulkMetadataFieldPlan(
      field: field,
      currentValue: currentValue,
      externalValue: externalValue,
      selected: selected ?? this.selected,
      canApply: canApply,
      isProtected: isProtected,
    );
  }
}

class BulkCoverPlan {
  const BulkCoverPlan({
    required this.asset,
    required this.selected,
    required this.canApply,
    this.reason,
  });

  final ExternalMediaAsset? asset;
  final bool selected;
  final bool canApply;
  final String? reason;

  BulkCoverPlan copyWith({bool? selected}) {
    return BulkCoverPlan(
      asset: asset,
      selected: selected ?? this.selected,
      canApply: canApply,
      reason: reason,
    );
  }
}

class BulkMetadataImportItem {
  const BulkMetadataImportItem({
    required this.row,
    required this.included,
    this.candidates = const [],
    this.selectedDetails,
    this.fieldPlans = const [],
    this.coverPlan,
    this.issues = const [],
  });

  final LibraryGameRow row;
  final bool included;
  final List<BulkMetadataCandidate> candidates;
  final ExternalGameDetails? selectedDetails;
  final List<BulkMetadataFieldPlan> fieldPlans;
  final BulkCoverPlan? coverPlan;
  final List<BulkImportIssue> issues;

  BulkMetadataConfidence get confidence =>
      candidates.isEmpty
          ? BulkMetadataConfidence.none
          : candidates.first.confidence;

  bool get hasErrorIssue =>
      issues.any((issue) => issue.severity == BulkImportIssueSeverity.error);

  bool get hasSelectedMetadata => fieldPlans.any(
    (plan) => plan.selected && plan.canApply && !plan.isProtected,
  );

  bool get hasSelectedCover =>
      coverPlan != null && coverPlan!.selected && coverPlan!.canApply;

  bool get canApply => included && selectedDetails != null && !hasErrorIssue;

  BulkMetadataImportItem copyWith({
    bool? included,
    List<BulkMetadataCandidate>? candidates,
    ExternalGameDetails? selectedDetails,
    List<BulkMetadataFieldPlan>? fieldPlans,
    BulkCoverPlan? coverPlan,
    List<BulkImportIssue>? issues,
  }) {
    return BulkMetadataImportItem(
      row: row,
      included: included ?? this.included,
      candidates: candidates ?? this.candidates,
      selectedDetails: selectedDetails ?? this.selectedDetails,
      fieldPlans: fieldPlans ?? this.fieldPlans,
      coverPlan: coverPlan ?? this.coverPlan,
      issues: issues ?? this.issues,
    );
  }
}

class BulkMetadataImportPlan {
  const BulkMetadataImportPlan({
    required this.options,
    required this.items,
    this.globalIssues = const [],
  });

  final BulkMetadataImportOptions options;
  final List<BulkMetadataImportItem> items;
  final List<BulkImportIssue> globalIssues;

  int get selectedItems => items.where((item) => item.canApply).length;

  int get selectedFieldChanges => items.fold(
    0,
    (sum, item) => sum + item.fieldPlans.where((plan) => plan.selected).length,
  );

  int get selectedCovers => items.where((item) => item.hasSelectedCover).length;

  BulkMetadataImportPlan copyWith({
    List<BulkMetadataImportItem>? items,
    List<BulkImportIssue>? globalIssues,
  }) {
    return BulkMetadataImportPlan(
      options: options,
      items: items ?? this.items,
      globalIssues: globalIssues ?? this.globalIssues,
    );
  }
}

class BulkImportResult {
  const BulkImportResult({
    required this.processed,
    required this.metadataApplied,
    this.fieldChangesApplied = 0,
    this.externalLinksSaved = 0,
    required this.coversSaved,
    required this.skipped,
    this.warnings = const [],
    required this.errors,
  });

  final int processed;
  final int metadataApplied;
  final int fieldChangesApplied;
  final int externalLinksSaved;
  final int coversSaved;
  final int skipped;
  final List<BulkImportIssue> warnings;
  final List<BulkImportIssue> errors;
}
