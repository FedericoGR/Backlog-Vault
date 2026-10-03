import 'package:backlog_vault/features/games/application/game_form_model.dart';
import 'package:test/test.dart';

void main() {
  group('GameFormModel', () {
    test('accepts a minimal valid manual game', () {
      final model = GameFormModel(title: 'Hades', isCompleted: false);

      expect(model.validate, returnsNormally);
    });

    test('rejects empty title', () {
      final model = GameFormModel(title: '   ', isCompleted: false);

      expect(model.validate, throwsArgumentError);
    });

    test('rejects rating outside 1 to 5', () {
      final model = GameFormModel(
        title: 'Hades',
        isCompleted: false,
        personalRating: 6,
      );

      expect(model.validate, throwsArgumentError);
    });

    test('rejects duplicated platforms and genres', () {
      final model = GameFormModel(
        title: 'Hades',
        isCompleted: false,
        platformIds: ['pc', 'pc'],
        genreIds: ['roguelite', 'roguelite'],
      );

      expect(model.validate, throwsArgumentError);
    });
  });
}
