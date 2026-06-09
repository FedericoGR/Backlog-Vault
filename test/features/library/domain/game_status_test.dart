import 'package:backlog_vault/features/library/domain/game_status.dart';
import 'package:test/test.dart';

void main() {
  group('GameStatus', () {
    test('allows configured MVP transitions', () {
      expect(
        canTransitionGameStatus(GameStatus.backlog, GameStatus.playing),
        isTrue,
      );
      expect(
        canTransitionGameStatus(GameStatus.playing, GameStatus.completed),
        isTrue,
      );
      expect(
        canTransitionGameStatus(GameStatus.retired, GameStatus.backlog),
        isTrue,
      );
    });

    test('rejects invalid transitions', () {
      expect(
        canTransitionGameStatus(GameStatus.wishlist, GameStatus.completed),
        isFalse,
      );
      expect(
        canTransitionGameStatus(GameStatus.retired, GameStatus.completed),
        isFalse,
      );
    });

    test('exposes Spanish UI labels', () {
      expect(GameStatus.wishlist.label, 'Lista de deseos');
      expect(GameStatus.completed.label, 'Completado');
    });
  });
}
