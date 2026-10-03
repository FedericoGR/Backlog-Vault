import 'package:backlog_vault/features/library/domain/game_status.dart';
import 'package:test/test.dart';

void main() {
  test('only pending and completed are product states', () {
    expect(GameStatus.values, [GameStatus.pending, GameStatus.completed]);
    expect(GameStatus.pending.label, 'Pendiente');
    expect(GameStatus.completed.label, 'Completado');
  });
  test('legacy saved filters normalize at the compatibility boundary', () {
    for (final legacy in [
      'wishlist',
      'backlog',
      'playing',
      'paused',
      'dropped',
      'retired',
      'pending',
      'unknown',
    ]) {
      expect(parseGameStatus(legacy), GameStatus.pending);
    }
    expect(parseGameStatus('completed'), GameStatus.completed);
  });
}
