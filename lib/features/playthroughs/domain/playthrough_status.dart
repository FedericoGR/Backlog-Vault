enum PlaythroughStatus { planned, active, paused, completed, dropped }

extension PlaythroughStatusLabels on PlaythroughStatus {
  String get label => switch (this) {
    PlaythroughStatus.planned => 'Planeada',
    PlaythroughStatus.active => 'Activa',
    PlaythroughStatus.paused => 'Pausada',
    PlaythroughStatus.completed => 'Completada',
    PlaythroughStatus.dropped => 'Abandonada',
  };
}

PlaythroughStatus parsePlaythroughStatus(String value) {
  return PlaythroughStatus.values.firstWhere(
    (status) => status.name == value,
    orElse: () => PlaythroughStatus.active,
  );
}
