enum ImportField {
  title,
  releaseDate,
  completedAt,
  hoursPlayed,
  personalRating,
  genres,
  platforms,
  status,
  type,
  personalNotes,
}

extension ImportFieldLabel on ImportField {
  String get label => switch (this) {
    ImportField.title => 'Nombre',
    ImportField.releaseDate => 'Fecha de salida',
    ImportField.completedAt => 'Fecha de completado',
    ImportField.hoursPlayed => 'Duración',
    ImportField.personalRating => 'Puntaje',
    ImportField.genres => 'Géneros',
    ImportField.platforms => 'Plataformas',
    ImportField.status => 'Estado',
    ImportField.type => 'Tipo',
    ImportField.personalNotes => 'Notas',
  };

  bool get isRequired => this == ImportField.title;
}
