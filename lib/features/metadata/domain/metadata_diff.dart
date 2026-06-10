import 'metadata_field.dart';

class MetadataDiff {
  const MetadataDiff({required this.changes});

  final List<MetadataFieldChange> changes;

  bool get hasApplicableChanges =>
      changes.any((change) => change.canApply && !change.isProtected);
}

class MetadataFieldChange {
  const MetadataFieldChange({
    required this.field,
    required this.currentValue,
    required this.externalValue,
    required this.selectedByDefault,
    this.canApply = true,
    this.isProtected = false,
  });

  final MetadataField field;
  final String currentValue;
  final String externalValue;
  final bool selectedByDefault;
  final bool canApply;
  final bool isProtected;
}
