import 'package:backlog_vault/features/library/domain/game_status.dart';
import 'package:test/test.dart';

void main() {
  test('product offers only pending and completed from every legacy state', () {
    expect(personalGameStatuses, [GameStatus.backlog, GameStatus.completed]);
    for (final legacy in GameStatus.values) {
      expect(canTransitionGameStatus(legacy, GameStatus.completed), isTrue);
      expect(canTransitionGameStatus(legacy, GameStatus.backlog), isTrue);
      expect(canTransitionGameStatus(legacy, GameStatus.playing), isFalse);
      expect(
        personalGameStatus(legacy),
        legacy == GameStatus.completed
            ? GameStatus.completed
            : GameStatus.backlog,
      );
      expect(parseGameStatus(legacy.name), legacy);
    }
  });
}
