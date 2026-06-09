import 'import_field.dart';

class CsvColumnMapping {
  const CsvColumnMapping({required this.fieldToHeader});

  final Map<ImportField, String?> fieldToHeader;

  String? headerFor(ImportField field) => fieldToHeader[field];

  CsvColumnMapping copyWithField(ImportField field, String? header) {
    final next = Map<ImportField, String?>.from(fieldToHeader);
    if (header != null) {
      for (final entry in next.entries) {
        if (entry.key != field && entry.value == header) {
          next[entry.key] = null;
        }
      }
    }
    next[field] = header;
    return CsvColumnMapping(fieldToHeader: next);
  }

  bool get hasRequiredFields {
    return ImportField.values
        .where((field) => field.isRequired)
        .every((field) => headerFor(field) != null);
  }
}
