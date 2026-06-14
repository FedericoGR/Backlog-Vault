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
    BulkMetadataImportScope.all => 'Todos los juegos activos',
    BulkMetadataImportScope.onlyWithoutMetadata => 'Solo sin metadata',
    BulkMetadataImportScope.onlyWithoutCover => 'Solo sin portada',
    BulkMetadataImportScope.onlyIncompleteFields => 'Solo datos incompletos',
  };
}

enum BulkImportContentMode {
  metadataOnly,
  coverOnly,
  metadataAndCover;

  String get label => switch (this) {
    BulkImportContentMode.metadataOnly => 'Solo metadata',
    BulkImportContentMode.coverOnly => 'Solo cover art',
    BulkImportContentMode.metadataAndCover => 'Metadata + cover art',
  };

  String get description => switch (this) {
    BulkImportContentMode.metadataOnly =>
      'Completar o revisar campos de metadata sin descargar portadas.',
    BulkImportContentMode.coverOnly =>
      'Buscar portadas para juegos existentes sin aplicar campos de metadata.',
    BulkImportContentMode.metadataAndCover =>
      'Revisar metadata y portadas en el mismo preview antes de aplicar.',
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

enum BulkMetadataApplyMode {
  completeMissing,
  reviewAndReplace;

  String get label => switch (this) {
    BulkMetadataApplyMode.completeMissing => 'Completar faltantes',
    BulkMetadataApplyMode.reviewAndReplace => 'Revisar y reemplazar',
  };
}

enum BulkCoverProviderMode {
  none,
  igdb,
  steamgriddb,
  igdbThenSteamGridDb,
  steamGridDbThenIgdb;

  String get label => switch (this) {
    BulkCoverProviderMode.none => 'No importar covers',
    BulkCoverProviderMode.igdb => 'IGDB',
    BulkCoverProviderMode.steamgriddb => 'SteamGridDB',
    BulkCoverProviderMode.igdbThenSteamGridDb =>
      'IGDB primero + SteamGridDB fallback',
    BulkCoverProviderMode.steamGridDbThenIgdb =>
      'SteamGridDB primero + IGDB fallback',
  };
}

enum BulkExistingCoverMode {
  keepExisting,
  allowReplace;

  String get label => switch (this) {
    BulkExistingCoverMode.keepExisting => 'Mantener portadas existentes',
    BulkExistingCoverMode.allowReplace => 'Permitir reemplazo con confirmación',
  };
}

class BulkMetadataImportOptions {
  const BulkMetadataImportOptions({
    required this.providerId,
    this.scope = BulkMetadataImportScope.all,
    this.contentMode = BulkImportContentMode.metadataAndCover,
    this.applyMode = BulkMetadataApplyMode.completeMissing,
    this.coverProviderMode = BulkCoverProviderMode.igdb,
    this.existingCoverMode = BulkExistingCoverMode.keepExisting,
    this.includeMetadata = true,
    this.includeMissingCovers = true,
    this.replaceExistingCovers = false,
    this.maxConcurrency = 2,
  });

  final String providerId;
  final BulkMetadataImportScope scope;
  final BulkImportContentMode contentMode;
  final BulkMetadataApplyMode applyMode;
  final BulkCoverProviderMode coverProviderMode;
  final BulkExistingCoverMode existingCoverMode;
  final bool includeMetadata;
  final bool includeMissingCovers;
  final bool replaceExistingCovers;
  final int maxConcurrency;

  bool get shouldImportMetadata =>
      includeMetadata && contentMode != BulkImportContentMode.coverOnly;

  bool get shouldImportCovers =>
      contentMode != BulkImportContentMode.metadataOnly &&
      includeMissingCovers &&
      coverProviderMode != BulkCoverProviderMode.none;

  bool get allowCoverReplacement =>
      replaceExistingCovers ||
      existingCoverMode == BulkExistingCoverMode.allowReplace;

  bool get allowMetadataReplacement =>
      applyMode == BulkMetadataApplyMode.reviewAndReplace;
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
    this.replacesExisting = false,
  });

  final MetadataField field;
  final String currentValue;
  final String externalValue;
  final bool selected;
  final bool canApply;
  final bool isProtected;
  final bool replacesExisting;

  BulkMetadataFieldPlan copyWith({bool? selected}) {
    return BulkMetadataFieldPlan(
      field: field,
      currentValue: currentValue,
      externalValue: externalValue,
      selected: selected ?? this.selected,
      canApply: canApply,
      isProtected: isProtected,
      replacesExisting: replacesExisting,
    );
  }
}

class BulkCoverPlan {
  const BulkCoverPlan({
    required this.asset,
    required this.selected,
    required this.canApply,
    this.candidateAssets = const [],
    this.replacesExisting = false,
    this.currentProviderName,
    this.reason,
  });

  final ExternalMediaAsset? asset;
  final List<ExternalMediaAsset> candidateAssets;
  final bool selected;
  final bool canApply;
  final bool replacesExisting;
  final String? currentProviderName;
  final String? reason;

  List<ExternalMediaAsset> get availableAssets {
    final assets = <ExternalMediaAsset>[];

    void addUnique(ExternalMediaAsset asset) {
      final exists = assets.any(
        (existing) =>
            existing.providerId == asset.providerId &&
            existing.externalId == asset.externalId &&
            existing.remoteUrl == asset.remoteUrl,
      );
      if (!exists) {
        assets.add(asset);
      }
    }

    final selectedAsset = asset;
    if (selectedAsset != null) {
      addUnique(selectedAsset);
    }
    for (final candidate in candidateAssets) {
      addUnique(candidate);
    }
    return assets;
  }

  bool get hasAlternativeAssets => availableAssets.length > 1;

  BulkCoverPlan copyWith({
    ExternalMediaAsset? asset,
    List<ExternalMediaAsset>? candidateAssets,
    bool? selected,
  }) {
    return BulkCoverPlan(
      asset: asset ?? this.asset,
      candidateAssets: candidateAssets ?? this.candidateAssets,
      selected: selected ?? this.selected,
      canApply: canApply,
      replacesExisting: replacesExisting,
      currentProviderName: currentProviderName,
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

  bool get canApply =>
      included &&
      !hasErrorIssue &&
      (selectedDetails != null || hasSelectedCover);

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

  int get matchedItems =>
      items.where((item) => item.candidates.isNotEmpty).length;

  int get withoutMatchItems =>
      items
          .where((item) => item.confidence == BulkMetadataConfidence.none)
          .length;

  int get safeItems =>
      items
          .where((item) => item.confidence == BulkMetadataConfidence.safe)
          .length;

  int get probableItems =>
      items
          .where((item) => item.confidence == BulkMetadataConfidence.probable)
          .length;

  int get ambiguousItems =>
      items
          .where((item) => item.confidence == BulkMetadataConfidence.ambiguous)
          .length;

  int get itemsWithMetadata =>
      items.where((item) => item.fieldPlans.isNotEmpty).length;

  int get itemsWithCover =>
      items.where((item) => item.coverPlan != null).length;

  int get selectedFieldChanges => items.fold(
    0,
    (sum, item) => sum + item.fieldPlans.where((plan) => plan.selected).length,
  );

  int get selectedNewFieldChanges => items.fold(
    0,
    (sum, item) =>
        sum +
        item.fieldPlans
            .where((plan) => plan.selected && !plan.replacesExisting)
            .length,
  );

  int get selectedReplacementFieldChanges => items.fold(
    0,
    (sum, item) =>
        sum +
        item.fieldPlans
            .where((plan) => plan.selected && plan.replacesExisting)
            .length,
  );

  int get selectedCovers => items.where((item) => item.hasSelectedCover).length;

  int get selectedNewCovers =>
      items
          .where(
            (item) =>
                item.hasSelectedCover && !item.coverPlan!.replacesExisting,
          )
          .length;

  int get selectedReplacementCovers =>
      items
          .where(
            (item) => item.hasSelectedCover && item.coverPlan!.replacesExisting,
          )
          .length;

  bool get hasReplacements =>
      selectedReplacementFieldChanges > 0 || selectedReplacementCovers > 0;

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
    this.analyzed = 0,
    this.matched = 0,
    this.withoutMatch = 0,
    this.safeMatches = 0,
    this.probableMatches = 0,
    this.ambiguousMatches = 0,
    required this.processed,
    required this.metadataApplied,
    this.fieldChangesApplied = 0,
    this.newFieldChangesApplied = 0,
    this.replacedFieldChangesApplied = 0,
    this.externalLinksSaved = 0,
    required this.coversSaved,
    this.newCoversSaved = 0,
    this.replacedCoversSaved = 0,
    required this.skipped,
    this.warnings = const [],
    required this.errors,
  });

  final int analyzed;
  final int matched;
  final int withoutMatch;
  final int safeMatches;
  final int probableMatches;
  final int ambiguousMatches;
  final int processed;
  final int metadataApplied;
  final int fieldChangesApplied;
  final int newFieldChangesApplied;
  final int replacedFieldChangesApplied;
  final int externalLinksSaved;
  final int coversSaved;
  final int newCoversSaved;
  final int replacedCoversSaved;
  final int skipped;
  final List<BulkImportIssue> warnings;
  final List<BulkImportIssue> errors;
}
