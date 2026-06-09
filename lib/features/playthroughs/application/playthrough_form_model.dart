import '../domain/playthrough_status.dart';

class PlaythroughFormModel {
  const PlaythroughFormModel({
    required this.libraryEntryId,
    this.platformId,
    required this.status,
    this.startedAt,
    this.completedAt,
    this.hoursPlayed,
    this.rating,
    this.notes,
  });

  final String libraryEntryId;
  final String? platformId;
  final PlaythroughStatus status;
  final DateTime? startedAt;
  final DateTime? completedAt;
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
    if (status == PlaythroughStatus.completed && completedAt == null) {
      throw ArgumentError('La fecha de completado es obligatoria.');
    }
  }
}
