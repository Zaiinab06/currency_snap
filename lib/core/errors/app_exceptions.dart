/// Thrown when a remote API call fails due to network, timeout, or server errors.
class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

/// Thrown when the API response payload is invalid or cannot be parsed.
class DataParsingException implements Exception {
  final String message;
  const DataParsingException(this.message);

  @override
  String toString() => 'DataParsingException: $message';
}

/// Thrown when no cached data is available locally as a fallback.
class NoCachedDataException implements Exception {
  final String message;
  const NoCachedDataException(this.message);

  @override
  String toString() => 'NoCachedDataException: $message';
}
