enum ImportIssueSeverity { warning, error }

class ImportRowIssue {
  const ImportRowIssue({
    required this.severity,
    required this.message,
    this.field,
  });

  final ImportIssueSeverity severity;
  final String message;
  final String? field;

  bool get isError => severity == ImportIssueSeverity.error;
  bool get isWarning => severity == ImportIssueSeverity.warning;
}
