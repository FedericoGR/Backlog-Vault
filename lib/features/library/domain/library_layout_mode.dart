enum LibraryLayoutMode { table, gallery }

extension LibraryLayoutModeLabels on LibraryLayoutMode {
  String get label => switch (this) {
    LibraryLayoutMode.table => 'Tabla',
    LibraryLayoutMode.gallery => 'Galería',
  };
}
