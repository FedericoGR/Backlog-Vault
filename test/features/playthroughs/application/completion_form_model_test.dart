import 'package:backlog_vault/features/playthroughs/application/completion_form_model.dart';
import 'package:test/test.dart';

void main() {
  group('CompletionFormModel', () {
    test('accepts completion without hours or rating', () {
      final model = CompletionFormModel(
        libraryEntryId: 'entry-1',
        completedAt: DateTime(2026, 6, 9),
      );

      expect(model.validate, returnsNormally);
    });

    test('rejects invalid rating', () {
      final model = CompletionFormModel(
        libraryEntryId: 'entry-1',
        completedAt: DateTime(2026, 6, 9),
        rating: 0,
      );

      expect(model.validate, throwsArgumentError);
    });

    test('rejects negative hours', () {
      final model = CompletionFormModel(
        libraryEntryId: 'entry-1',
        completedAt: DateTime(2026, 6, 9),
        hoursPlayed: -1,
      );

      expect(model.validate, throwsArgumentError);
    });
  });
}
