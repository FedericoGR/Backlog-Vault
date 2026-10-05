/// Active product state, derived from LibraryEntry.isCompleted.
enum GameStatus { pending, completed }

extension GameStatusLabels on GameStatus {
  String get label =>
      this == GameStatus.completed ? 'Terminado' : 'No terminado';
}

/// Backward-compatible interpretation of persisted filters and external values.
/// The legacy lifecycle states all mean pending. Database entries must instead
/// derive their state from isCompleted, never from their archived status string.
GameStatus parseGameStatus(String value) =>
    value == 'completed' ? GameStatus.completed : GameStatus.pending;
