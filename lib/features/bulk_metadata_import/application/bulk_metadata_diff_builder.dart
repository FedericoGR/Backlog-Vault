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
  }) {
    if (!includeMetadata) return const [];
    final plans = <BulkMetadataFieldPlan>[];
    _addText(
      plans,
      field: MetadataField.title,
      currentValue: row.title,
      externalValue: details.title,
      selectedByDefault: false,
    );
    _addDate(
      plans,
      field: MetadataField.releaseDate,
      currentValue: row.releaseDate,
      externalValue: details.releaseDate,
    );
    _addText(
      plans,
      field: MetadataField.type,
      currentValue: row.type,
      externalValue: details.type,
      selectedByDefault: row.type.trim().isEmpty,
    );
    _addList(
      plans,
      field: MetadataField.genres,
      currentValues: row.genres.map((genre) => genre.name),
      externalValues: details.genres,
    );
    _addList(
      plans,
      field: MetadataField.platforms,
      currentValues: row.platforms.map((platform) => platform.name),
      externalValues: details.platforms,
    );
    return plans;
  }

  void _addText(
    List<BulkMetadataFieldPlan> plans, {
    required MetadataField field,
    required String currentValue,
    required String externalValue,
    required bool selectedByDefault,
  }) {
    final current = currentValue.trim();
    final external = externalValue.trim();
    if (external.isEmpty || current.toLowerCase() == external.toLowerCase()) {
      return;
    }
    plans.add(
      BulkMetadataFieldPlan(
        field: field,
        currentValue: current.isEmpty ? '-' : current,
        externalValue: external,
        selected: current.isEmpty && selectedByDefault,
      ),
    );
  }

  void _addDate(
    List<BulkMetadataFieldPlan> plans, {
    required MetadataField field,
    required DateTime? currentValue,
    required DateTime? externalValue,
  }) {
    if (externalValue == null || _sameDate(currentValue, externalValue)) {
      return;
    }
    plans.add(
      BulkMetadataFieldPlan(
        field: field,
        currentValue: _displayDate(currentValue),
        externalValue: _displayDate(externalValue),
        selected: currentValue == null,
      ),
    );
  }

  void _addList(
    List<BulkMetadataFieldPlan> plans, {
    required MetadataField field,
    required Iterable<String> currentValues,
    required Iterable<String> externalValues,
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
    plans.add(
      BulkMetadataFieldPlan(
        field: field,
        currentValue: current.isEmpty ? '-' : current.join(', '),
        externalValue: additions.join(', '),
        selected: current.isEmpty,
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
