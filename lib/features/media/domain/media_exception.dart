enum MediaErrorType {
  missingApiKey,
  invalidApiKey,
  rateLimited,
  network,
  timeout,
  notFound,
  conflict,
  unsupportedFormat,
  fileSystem,
  unexpectedResponse,
  providerUnavailable,
}

class MediaException implements Exception {
  const MediaException(this.message, {required this.type});

  final String message;
  final MediaErrorType type;

  @override
  String toString() => message;
}
