enum LibrarySortField {
  title,
  status,
  rating,
  releaseDate,
  completedDate,
  hours,
  updatedAt,
}

enum LibrarySortDirection { ascending, descending }

class LibrarySortState {
  const LibrarySortState({
    this.field = LibrarySortField.updatedAt,
    this.direction = LibrarySortDirection.descending,
  });

  final LibrarySortField field;
  final LibrarySortDirection direction;

  bool get ascending => direction == LibrarySortDirection.ascending;

  LibrarySortState toggle(LibrarySortField nextField) {
    if (field != nextField) {
      return LibrarySortState(
        field: nextField,
        direction: LibrarySortDirection.ascending,
      );
    }
    return LibrarySortState(
      field: field,
      direction:
          ascending
              ? LibrarySortDirection.descending
              : LibrarySortDirection.ascending,
    );
  }

  Map<String, Object?> toJson() => {
    'version': 1,
    'field': field.name,
    'direction': direction.name,
  };

  factory LibrarySortState.fromJson(Map<String, Object?> json) {
    return LibrarySortState(
      field: LibrarySortField.values.firstWhere(
        (field) => field.name == json['field'],
        orElse: () => LibrarySortField.updatedAt,
      ),
      direction: LibrarySortDirection.values.firstWhere(
        (direction) => direction.name == json['direction'],
        orElse: () => LibrarySortDirection.descending,
      ),
    );
  }
}
