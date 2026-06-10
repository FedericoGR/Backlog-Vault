enum MetadataField {
  title,
  releaseDate,
  type,
  genres,
  platforms;

  String get label {
    return switch (this) {
      MetadataField.title => 'Título',
      MetadataField.releaseDate => 'Fecha de salida',
      MetadataField.type => 'Tipo',
      MetadataField.genres => 'Géneros',
      MetadataField.platforms => 'Plataformas',
    };
  }
}
