import '../../games/application/library_game_details.dart';
import '../domain/external_game_details.dart';
import '../domain/metadata_diff.dart';
import '../domain/metadata_field.dart';

class BuildMetadataDiffUseCase {
  const BuildMetadataDiffUseCase();

  MetadataDiff call({
    required LibraryGameDetails local,
    required ExternalGameDetails external,
  }) {
    final changes = <MetadataFieldChange>[];
    _addTextChange(
      changes,
      field: MetadataField.title,
      currentValue: local.game.title,
      externalValue: external.title,
      selectedByDefault: false,
    );
    _addDateChange(
      changes,
      field: MetadataField.releaseDate,
      currentValue: local.game.releaseDate,
      externalValue: external.releaseDate,
    );
    _addTextChange(
      changes,
      field: MetadataField.type,
      currentValue: local.game.type,
      externalValue: external.type,
      selectedByDefault: local.game.type.trim().isEmpty,
    );
    _addListChange(
      changes,
      field: MetadataField.genres,
      currentValues: local.genres.map((genre) => genre.name),
      externalValues: external.genres,
    );
    _addListChange(
      changes,
      field: MetadataField.platforms,
      currentValues: local.platforms.map((platform) => platform.name),
      externalValues: external.platforms,
    );
    return MetadataDiff(changes: changes);
  }

  void _addTextChange(
    List<MetadataFieldChange> changes, {
    required MetadataField field,
    required String currentValue,
    required String externalValue,
    required bool selectedByDefault,
  }) {
    final normalizedCurrent = currentValue.trim();
    final normalizedExternal = externalValue.trim();
    if (normalizedExternal.isEmpty ||
        normalizedCurrent.toLowerCase() == normalizedExternal.toLowerCase()) {
      return;
    }
    changes.add(
      MetadataFieldChange(
        field: field,
        currentValue: _displayText(normalizedCurrent),
        externalValue: normalizedExternal,
        selectedByDefault: normalizedCurrent.isEmpty && selectedByDefault,
      ),
    );
  }

  void _addDateChange(
    List<MetadataFieldChange> changes, {
    required MetadataField field,
    required DateTime? currentValue,
    required DateTime? externalValue,
  }) {
    if (externalValue == null || _sameDate(currentValue, externalValue)) {
      return;
    }
    changes.add(
      MetadataFieldChange(
        field: field,
        currentValue: _displayDate(currentValue),
        externalValue: _displayDate(externalValue),
        selectedByDefault: currentValue == null,
      ),
    );
  }

  void _addListChange(
    List<MetadataFieldChange> changes, {
    required MetadataField field,
    required Iterable<String> currentValues,
    required Iterable<String> externalValues,
  }) {
    final current = _uniqueNormalized(currentValues);
    final external = _uniqueNormalized(externalValues);
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
    changes.add(
      MetadataFieldChange(
        field: field,
        currentValue: current.isEmpty ? '-' : current.join(', '),
        externalValue: additions.join(', '),
        selectedByDefault: current.isEmpty,
      ),
    );
  }

  List<String> _uniqueNormalized(Iterable<String> values) {
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
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$day-$month-${value.year}';
  }

  String _displayText(String value) => value.isEmpty ? '-' : value;
}
