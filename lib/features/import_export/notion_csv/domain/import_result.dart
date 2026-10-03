class ImportResult {
  const ImportResult({
    required this.importedGames,
    required this.skippedRows,
    required this.duplicatesSkipped,
    required this.platformsCreated,
    required this.genresCreated,
  });

  final int importedGames;
  final int skippedRows;
  final int duplicatesSkipped;
  final int platformsCreated;
  final int genresCreated;
}
