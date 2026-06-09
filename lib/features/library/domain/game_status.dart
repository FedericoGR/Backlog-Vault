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

const validGameStatusTransitions = <GameStatus, Set<GameStatus>>{
  GameStatus.wishlist: {GameStatus.backlog, GameStatus.retired},
  GameStatus.backlog: {
    GameStatus.playing,
    GameStatus.completed,
    GameStatus.dropped,
    GameStatus.retired,
  },
  GameStatus.playing: {
    GameStatus.paused,
    GameStatus.completed,
    GameStatus.dropped,
    GameStatus.backlog,
  },
  GameStatus.paused: {
    GameStatus.playing,
    GameStatus.completed,
    GameStatus.dropped,
    GameStatus.backlog,
  },
  GameStatus.completed: {
    GameStatus.playing,
    GameStatus.backlog,
    GameStatus.retired,
  },
  GameStatus.dropped: {
    GameStatus.backlog,
    GameStatus.playing,
    GameStatus.retired,
  },
  GameStatus.retired: {GameStatus.wishlist, GameStatus.backlog},
};

bool canTransitionGameStatus(GameStatus from, GameStatus to) {
  if (from == to) return true;
  return validGameStatusTransitions[from]?.contains(to) ?? false;
}
