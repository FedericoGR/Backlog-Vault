import 'package:backlog_vault/features/games/application/game_form_model.dart';
import 'package:backlog_vault/features/library/domain/game_status.dart';
import 'package:test/test.dart';

void main() {
  group('GameFormModel', () {
    test('accepts a minimal valid manual game', () {
      final model = GameFormModel(title: 'Hades', status: GameStatus.backlog);

      expect(model.validate, returnsNormally);
    });

    test('rejects empty title', () {
      final model = GameFormModel(title: '   ', status: GameStatus.backlog);

      expect(model.validate, throwsArgumentError);
    });

    test('rejects rating outside 1 to 5', () {
      final model = GameFormModel(
        title: 'Hades',
        status: GameStatus.backlog,
        personalRating: 6,
      );

      expect(model.validate, throwsArgumentError);
    });

    test('rejects duplicated platforms and genres', () {
      final model = GameFormModel(
        title: 'Hades',
        status: GameStatus.backlog,
        platformIds: ['pc', 'pc'],
        genreIds: ['roguelite', 'roguelite'],
      );

      expect(model.validate, throwsArgumentError);
    });
  });
}
