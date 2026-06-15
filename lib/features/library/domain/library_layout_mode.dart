enum LibraryLayoutMode { table, gallery, list }

extension LibraryLayoutModeLabels on LibraryLayoutMode {
  String get label => switch (this) {
    LibraryLayoutMode.table => 'Tabla',
    LibraryLayoutMode.gallery => 'Galería',
    LibraryLayoutMode.list => 'Lista',
  };
}
