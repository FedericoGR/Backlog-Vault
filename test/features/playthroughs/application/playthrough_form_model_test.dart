import 'package:backlog_vault/features/playthroughs/application/playthrough_form_model.dart';
import 'package:backlog_vault/features/playthroughs/domain/playthrough_status.dart';
import 'package:test/test.dart';

void main() {
  group('PlaythroughFormModel', () {
    test('accepts a valid active playthrough', () {
      final model = PlaythroughFormModel(
        libraryEntryId: 'entry-1',
        status: PlaythroughStatus.active,
        startedAt: DateTime(2026, 6, 9),
      );

      expect(model.validate, returnsNormally);
    });

    test('rejects invalid rating', () {
      final model = PlaythroughFormModel(
        libraryEntryId: 'entry-1',
        status: PlaythroughStatus.active,
        rating: 6,
      );

      expect(model.validate, throwsArgumentError);
    });

    test('rejects negative hours', () {
      final model = PlaythroughFormModel(
        libraryEntryId: 'entry-1',
        status: PlaythroughStatus.active,
        hoursPlayed: -0.5,
      );

      expect(model.validate, throwsArgumentError);
    });

    test('requires completedAt for completed playthrough', () {
      final model = PlaythroughFormModel(
        libraryEntryId: 'entry-1',
        status: PlaythroughStatus.completed,
      );

      expect(model.validate, throwsArgumentError);
    });

    test('rejects startedAt after completedAt', () {
      final model = PlaythroughFormModel(
        libraryEntryId: 'entry-1',
        status: PlaythroughStatus.completed,
        startedAt: DateTime(2026, 6, 10),
        completedAt: DateTime(2026, 6, 9),
      );

      expect(model.validate, throwsArgumentError);
    });
  });
}
