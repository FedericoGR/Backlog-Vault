import '../../../library/domain/game_status.dart';
import 'duplicate_candidate.dart';
import 'import_issue.dart';

class NormalizedImportRow {
  const NormalizedImportRow({
    required this.rowNumber,
    required this.title,
    required this.releaseDate,
    required this.completedAt,
    required this.hoursPlayed,
    required this.personalRating,
    required this.genres,
    required this.platforms,
    required this.status,
    required this.type,
    required this.personalNotes,
    required this.issues,
    required this.duplicates,
    required this.include,
    required this.forceCreateDuplicate,
  });

  final int rowNumber;
  final String title;
  final DateTime? releaseDate;
  final DateTime? completedAt;
  final double? hoursPlayed;
  final int? personalRating;
  final List<String> genres;
  final List<String> platforms;
  final GameStatus status;
  final String type;
  final String? personalNotes;
  final List<ImportRowIssue> issues;
  final List<DuplicateCandidate> duplicates;
  final bool include;
  final bool forceCreateDuplicate;

  bool get hasErrors => issues.any((issue) => issue.isError);
  bool get hasWarnings => issues.any((issue) => issue.isWarning);
  bool get hasDuplicates => duplicates.isNotEmpty;
  bool get canImport =>
      include && !hasErrors && (!hasDuplicates || forceCreateDuplicate);

  NormalizedImportRow copyWith({
    List<ImportRowIssue>? issues,
    List<DuplicateCandidate>? duplicates,
    bool? include,
    bool? forceCreateDuplicate,
  }) {
    return NormalizedImportRow(
      rowNumber: rowNumber,
      title: title,
      releaseDate: releaseDate,
      completedAt: completedAt,
      hoursPlayed: hoursPlayed,
      personalRating: personalRating,
      genres: genres,
      platforms: platforms,
      status: status,
      type: type,
      personalNotes: personalNotes,
      issues: issues ?? this.issues,
      duplicates: duplicates ?? this.duplicates,
      include: include ?? this.include,
      forceCreateDuplicate: forceCreateDuplicate ?? this.forceCreateDuplicate,
    );
  }
}
