enum LibraryColumnKey {
  cover,
  title,
  status,
  platforms,
  genres,
  rating,
  releaseDate,
  completedDate,
  hours,
  type,
  notes,
  updatedAt,
  playthroughs,
}

extension LibraryColumnKeyLabels on LibraryColumnKey {
  String get label => switch (this) {
    LibraryColumnKey.cover => 'Portada',
    LibraryColumnKey.title => 'Título',
    LibraryColumnKey.status => 'Estado',
    LibraryColumnKey.platforms => 'Plataformas',
    LibraryColumnKey.genres => 'Géneros',
    LibraryColumnKey.rating => 'Puntaje',
    LibraryColumnKey.releaseDate => 'Fecha salida',
    LibraryColumnKey.completedDate => 'Fecha completado',
    LibraryColumnKey.hours => 'Horas',
    LibraryColumnKey.type => 'Tipo',
    LibraryColumnKey.notes => 'Notas',
    LibraryColumnKey.updatedAt => 'Actualizado',
    LibraryColumnKey.playthroughs => 'Playthroughs',
  };
}

class LibraryColumnConfig {
  LibraryColumnConfig({List<LibraryColumnKey>? visibleColumns})
    : visibleColumns = _normalize(visibleColumns ?? defaultColumns);

  factory LibraryColumnConfig.fromJson(Map<String, Object?> json) {
    final rawVisible = json['visibleColumns'];
    final visibleColumns =
        rawVisible is List
            ? rawVisible
                .whereType<String>()
                .map(
                  (name) => LibraryColumnKey.values.firstWhere(
                    (column) => column.name == name,
                    orElse: () => LibraryColumnKey.title,
                  ),
                )
                .toList()
            : defaultColumns;
    return LibraryColumnConfig(visibleColumns: visibleColumns);
  }

  static const defaultColumns = [
    LibraryColumnKey.title,
    LibraryColumnKey.status,
    LibraryColumnKey.platforms,
    LibraryColumnKey.genres,
    LibraryColumnKey.rating,
    LibraryColumnKey.releaseDate,
    LibraryColumnKey.completedDate,
    LibraryColumnKey.hours,
  ];

  static const allColumns = [
    LibraryColumnKey.title,
    LibraryColumnKey.cover,
    LibraryColumnKey.status,
    LibraryColumnKey.platforms,
    LibraryColumnKey.genres,
    LibraryColumnKey.rating,
    LibraryColumnKey.releaseDate,
    LibraryColumnKey.completedDate,
    LibraryColumnKey.hours,
    LibraryColumnKey.type,
    LibraryColumnKey.notes,
    LibraryColumnKey.updatedAt,
    LibraryColumnKey.playthroughs,
  ];

  final List<LibraryColumnKey> visibleColumns;

  bool isVisible(LibraryColumnKey column) => visibleColumns.contains(column);

  LibraryColumnConfig toggle(LibraryColumnKey column) {
    if (column == LibraryColumnKey.title) return this;
    final visible = visibleColumns.toSet();
    if (!visible.add(column)) {
      visible.remove(column);
    }
    return LibraryColumnConfig(
      visibleColumns:
          allColumns.where((column) => visible.contains(column)).toList(),
    );
  }

  Map<String, Object?> toJson() => {
    'version': 1,
    'visibleColumns': visibleColumns.map((column) => column.name).toList(),
  };

  static List<LibraryColumnKey> _normalize(List<LibraryColumnKey> columns) {
    final visible = columns.toSet()..add(LibraryColumnKey.title);
    return allColumns.where((column) => visible.contains(column)).toList();
  }
}
