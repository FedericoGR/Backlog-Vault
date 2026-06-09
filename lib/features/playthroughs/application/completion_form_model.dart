class CompletionFormModel {
  const CompletionFormModel({
    required this.libraryEntryId,
    required this.completedAt,
    this.platformId,
    this.hoursPlayed,
    this.rating,
    this.notes,
  });

  final String libraryEntryId;
  final DateTime completedAt;
  final String? platformId;
  final double? hoursPlayed;
  final int? rating;
  final String? notes;

  void validate() {
    if (rating != null && (rating! < 1 || rating! > 5)) {
      throw ArgumentError('El puntaje debe estar entre 1 y 5.');
    }
    if (hoursPlayed != null && hoursPlayed! < 0) {
      throw ArgumentError('Las horas no pueden ser negativas.');
    }
  }
}
