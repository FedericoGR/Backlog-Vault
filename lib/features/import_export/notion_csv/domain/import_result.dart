class ImportResult {
  const ImportResult({
    required this.importedGames,
    required this.skippedRows,
    required this.duplicatesSkipped,
    required this.platformsCreated,
    required this.genresCreated,
    required this.playthroughsCreated,
  });

  final int importedGames;
  final int skippedRows;
  final int duplicatesSkipped;
  final int platformsCreated;
  final int genresCreated;
  final int playthroughsCreated;
}
