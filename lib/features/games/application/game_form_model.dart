import '../../library/domain/game_status.dart';
import '../../library/domain/rating.dart';

class GameFormModel {
  const GameFormModel({
    this.entryId,
    this.gameId,
    required this.title,
    this.sortTitle,
    this.releaseDate,
    this.type = 'game',
    required this.status,
    this.personalRating,
    this.personalNotes,
    this.platformIds = const [],
    this.genreIds = const [],
  });

  final String? entryId;
  final String? gameId;
  final String title;
  final String? sortTitle;
  final DateTime? releaseDate;
  final String type;
  final GameStatus status;
  final int? personalRating;
  final String? personalNotes;
  final List<String> platformIds;
  final List<String> genreIds;

  void validate() {
    if (title.trim().isEmpty) {
      throw ArgumentError('El nombre es obligatorio.');
    }
    if (!isValidStarRating(personalRating)) {
      throw ArgumentError('El puntaje debe estar entre 1 y 5.');
    }
    if (platformIds.toSet().length != platformIds.length) {
      throw ArgumentError('No se puede repetir una plataforma.');
    }
    if (genreIds.toSet().length != genreIds.length) {
      throw ArgumentError('No se puede repetir un género.');
    }
  }
}
