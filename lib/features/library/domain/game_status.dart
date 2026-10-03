enum GameStatus {
  wishlist,
  backlog,
  playing,
  paused,
  completed,
  dropped,
  retired,
}

extension GameStatusLabels on GameStatus {
  String get label => switch (this) {
    GameStatus.wishlist => 'Lista de deseos',
    GameStatus.backlog => 'Pendiente',
    GameStatus.playing => 'Jugando',
    GameStatus.paused => 'Pausado',
    GameStatus.completed => 'Completado',
    GameStatus.dropped => 'Abandonado',
    GameStatus.retired => 'Retirado',
  };
}

GameStatus parseGameStatus(String value) {
  return GameStatus.values.firstWhere(
    (status) => status.name == value,
    orElse: () => GameStatus.backlog,
  );
}

/// Only these states are offered by the product. Other enum values remain
/// available for interpreting legacy status values and external imports.
const personalGameStatuses = [GameStatus.backlog, GameStatus.completed];

GameStatus personalGameStatus(GameStatus legacy) =>
    legacy == GameStatus.completed ? GameStatus.completed : GameStatus.backlog;

bool canTransitionGameStatus(GameStatus from, GameStatus to) =>
    personalGameStatuses.contains(to);
