class ExistingGameSummary {
  const ExistingGameSummary({
    required this.title,
    required this.releaseYear,
    required this.platforms,
  });

  final String title;
  final int? releaseYear;
  final List<String> platforms;
}
