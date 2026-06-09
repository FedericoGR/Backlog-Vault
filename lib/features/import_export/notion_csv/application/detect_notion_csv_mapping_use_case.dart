import '../domain/csv_column_mapping.dart';
import '../domain/import_field.dart';

class DetectNotionCsvMappingUseCase {
  const DetectNotionCsvMappingUseCase();

  CsvColumnMapping call(List<String> headers) {
    final mapping = <ImportField, String?>{
      for (final field in ImportField.values) field: null,
    };

    for (final header in headers) {
      final normalized = _normalizeHeader(header);
      final field = _fieldBySynonym[normalized];
      if (field != null && mapping[field] == null) {
        mapping[field] = header;
      }
    }

    return CsvColumnMapping(fieldToHeader: mapping);
  }
}

String _normalizeHeader(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[áàäâ]'), 'a')
      .replaceAll(RegExp(r'[éèëê]'), 'e')
      .replaceAll(RegExp(r'[íìïî]'), 'i')
      .replaceAll(RegExp(r'[óòöô]'), 'o')
      .replaceAll(RegExp(r'[úùüû]'), 'u')
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

final _fieldBySynonym = <String, ImportField>{
  'nombre': ImportField.title,
  'name': ImportField.title,
  'juego': ImportField.title,
  'game': ImportField.title,
  'fecha de salida': ImportField.releaseDate,
  'release date': ImportField.releaseDate,
  'fecha de completado': ImportField.completedAt,
  'completed': ImportField.completedAt,
  'duracion': ImportField.hoursPlayed,
  'hours': ImportField.hoursPlayed,
  'puntaje': ImportField.personalRating,
  'rating': ImportField.personalRating,
  'score': ImportField.personalRating,
  'genero': ImportField.genres,
  'genres': ImportField.genres,
  'plataformas': ImportField.platforms,
  'platforms': ImportField.platforms,
  'estatus': ImportField.status,
  'estado': ImportField.status,
  'status': ImportField.status,
  'tipo': ImportField.type,
  'type': ImportField.type,
  'notas': ImportField.personalNotes,
  'notes': ImportField.personalNotes,
};
