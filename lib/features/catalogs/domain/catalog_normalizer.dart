String canonicalPlatformName(String value) {
  final trimmed = value.trim();
  final key = _catalogKey(trimmed);
  return _platformAliases[key] ?? trimmed;
}

String canonicalGenreName(String value) {
  final trimmed = value.trim();
  final key = _catalogKey(trimmed);
  return _genreAliases[key] ?? trimmed;
}

String catalogComparisonKey(String value) {
  return _catalogKey(value);
}

String _catalogKey(String value) {
  final lower = value.trim().toLowerCase();
  final withoutAccents = lower
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ü', 'u')
      .replaceAll('ñ', 'n');
  return withoutAccents
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

const _platformAliases = {
  'pc': 'PC',
  'windows': 'PC',
  'microsoft windows': 'PC',
  'pc microsoft windows': 'PC',
  'playstation': 'PS1',
  'playstation 1': 'PS1',
  'ps1': 'PS1',
  'psx': 'PS1',
  'playstation 2': 'PS2',
  'ps2': 'PS2',
  'playstation 3': 'PS3',
  'ps3': 'PS3',
  'playstation 4': 'PS4',
  'ps4': 'PS4',
  'playstation 5': 'PS5',
  'ps5': 'PS5',
  'switch': 'Nintendo Switch',
  'nintendo switch': 'Nintendo Switch',
  'xbox': 'Xbox',
  'xbox 360': 'Xbox 360',
  'xbox one': 'Xbox One',
  'xbox series': 'Xbox Series X|S',
  'xbox series x s': 'Xbox Series X|S',
  'xbox series xs': 'Xbox Series X|S',
  'steam deck': 'Steam Deck',
};

const _genreAliases = {
  'accion': 'Acción',
  'action': 'Acción',
  'aventura': 'Aventura',
  'adventure': 'Aventura',
  'rpg': 'RPG',
  'role playing': 'RPG',
  'role playing rpg': 'RPG',
  'role playing game': 'RPG',
  'puzzle': 'Puzzle',
  'estrategia': 'Estrategia',
  'strategy': 'Estrategia',
  'horror': 'Terror',
  'terror': 'Terror',
  'racing': 'Carreras',
  'carreras': 'Carreras',
  'sports': 'Deportes',
  'deportes': 'Deportes',
  'fighting': 'Lucha',
  'lucha': 'Lucha',
  'platform': 'Plataformas',
  'platformer': 'Plataformas',
  'plataformas': 'Plataformas',
  'simulator': 'Simulación',
  'simulation': 'Simulación',
  'simulacion': 'Simulación',
  'shooter': 'Shooter',
  'indie': 'Indie',
};
