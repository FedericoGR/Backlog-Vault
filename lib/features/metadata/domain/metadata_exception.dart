enum MetadataErrorType {
  missingApiKey,
  invalidApiKey,
  rateLimited,
  network,
  timeout,
  notFound,
  conflict,
  unexpectedResponse,
  providerUnavailable,
}

class MetadataException implements Exception {
  const MetadataException(this.message, {required this.type});

  final String message;
  final MetadataErrorType type;

  @override
  String toString() => message;
}
