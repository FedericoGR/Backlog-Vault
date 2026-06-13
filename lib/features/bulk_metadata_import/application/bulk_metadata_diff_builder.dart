import '../../library/domain/library_game_row.dart';
import '../../metadata/domain/external_game_details.dart';
import '../../metadata/domain/metadata_field.dart';
import '../domain/bulk_metadata_import_models.dart';

class BulkMetadataDiffBuilder {
  const BulkMetadataDiffBuilder();

  List<BulkMetadataFieldPlan> build({
    required LibraryGameRow row,
    required ExternalGameDetails details,
    required bool includeMetadata,
    BulkMetadataApplyMode applyMode = BulkMetadataApplyMode.completeMissing,
  }) {
    if (!includeMetadata) return const [];
    final allowReplacement = applyMode.allowReplacement;
    final plans = <BulkMetadataFieldPlan>[];
    _addText(
      plans,
      field: MetadataField.title,
      currentValue: row.title,
      externalValue: details.title,
      selectedByDefault: false,
      allowReplacement: allowReplacement,
    );
    _addDate(
      plans,
      field: MetadataField.releaseDate,
      currentValue: row.releaseDate,
      externalValue: details.releaseDate,
      allowReplacement: allowReplacement,
    );
    _addText(
      plans,
      field: MetadataField.type,
      currentValue: row.type,
      externalValue: details.type,
      selectedByDefault: row.type.trim().isEmpty,
      allowReplacement: allowReplacement,
    );
    _addList(
      plans,
      field: MetadataField.genres,
      currentValues: row.genres.map((genre) => genre.name),
      externalValues: details.genres,
      allowReplacement: allowReplacement,
    );
    _addList(
      plans,
      field: MetadataField.platforms,
      currentValues: row.platforms.map((platform) => platform.name),
      externalValues: details.platforms,
      allowReplacement: allowReplacement,
    );
    return plans;
  }

  void _addText(
    List<BulkMetadataFieldPlan> plans, {
    required MetadataField field,
    required String currentValue,
    required String externalValue,
    required bool selectedByDefault,
    required bool allowReplacement,
  }) {
    final current = currentValue.trim();
    final external = externalValue.trim();
    if (external.isEmpty || current.toLowerCase() == external.toLowerCase()) {
      return;
    }
    final hasCurrent = current.isNotEmpty;
    plans.add(
      BulkMetadataFieldPlan(
        field: field,
        currentValue: current.isEmpty ? '-' : current,
        externalValue: external,
        selected: !hasCurrent && selectedByDefault,
        canApply: !hasCurrent || allowReplacement,
        isProtected: hasCurrent && !allowReplacement,
        replacesExisting: hasCurrent,
      ),
    );
  }

  void _addDate(
    List<BulkMetadataFieldPlan> plans, {
    required MetadataField field,
    required DateTime? currentValue,
    required DateTime? externalValue,
    required bool allowReplacement,
  }) {
    if (externalValue == null || _sameDate(currentValue, externalValue)) {
      return;
    }
    final hasCurrent = currentValue != null;
    plans.add(
      BulkMetadataFieldPlan(
        field: field,
        currentValue: _displayDate(currentValue),
        externalValue: _displayDate(externalValue),
        selected: !hasCurrent,
        canApply: !hasCurrent || allowReplacement,
        isProtected: hasCurrent && !allowReplacement,
        replacesExisting: hasCurrent,
      ),
    );
  }

  void _addList(
    List<BulkMetadataFieldPlan> plans, {
    required MetadataField field,
    required Iterable<String> currentValues,
    required Iterable<String> externalValues,
    required bool allowReplacement,
  }) {
    final current = _unique(currentValues);
    final external = _unique(externalValues);
    if (external.isEmpty) return;
    final additions =
        external
            .where(
              (externalValue) =>
                  !current.any(
                    (currentValue) =>
                        currentValue.toLowerCase() ==
                        externalValue.toLowerCase(),
                  ),
            )
            .toList();
    if (additions.isEmpty) return;
    final hasCurrent = current.isNotEmpty;
    plans.add(
      BulkMetadataFieldPlan(
        field: field,
        currentValue: current.isEmpty ? '-' : current.join(', '),
        externalValue:
            hasCurrent && allowReplacement
                ? external.join(', ')
                : additions.join(', '),
        selected: !hasCurrent,
        canApply: !hasCurrent || allowReplacement,
        isProtected: hasCurrent && !allowReplacement,
        replacesExisting: hasCurrent && allowReplacement,
      ),
    );
  }

  List<String> _unique(Iterable<String> values) {
    final seen = <String>{};
    final result = <String>[];
    for (final value in values) {
      final trimmed = value.trim();
      final key = trimmed.toLowerCase();
      if (trimmed.isEmpty || seen.contains(key)) continue;
      seen.add(key);
      result.add(trimmed);
    }
    result.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return result;
  }

  bool _sameDate(DateTime? a, DateTime b) {
    return a != null &&
        a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  String _displayDate(DateTime? value) {
    if (value == null) return '-';
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day-$month-${value.year}';
  }
}

extension on BulkMetadataApplyMode {
  bool get allowReplacement => this == BulkMetadataApplyMode.reviewAndReplace;
}
