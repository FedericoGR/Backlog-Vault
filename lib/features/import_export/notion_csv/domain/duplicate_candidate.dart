enum DuplicateSource { csv, database }

class DuplicateCandidate {
  const DuplicateCandidate({
    required this.source,
    required this.reason,
    this.existingTitle,
    this.rowNumber,
  });

  final DuplicateSource source;
  final String reason;
  final String? existingTitle;
  final int? rowNumber;
}
