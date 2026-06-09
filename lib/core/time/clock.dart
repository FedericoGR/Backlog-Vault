class Clock {
  const Clock();

  DateTime now() => DateTime.now();
}

const systemClock = Clock();
