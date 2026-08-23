/// Thrown when the remote API call fails (no internet, timeout, server error).
/// The repository catches this specifically to trigger the offline-cache
/// fallback, rather than crashing the app.
class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

/// Thrown when the API responds but the payload is missing/unexpected data.
class DataParsingException implements Exception {
  final String message;
  const DataParsingException(this.message);

  @override
  String toString() => 'DataParsingException: $message';
}

/// Thrown when there is no cached data available to fall back to
/// (e.g. first app launch with no internet).
class NoCachedDataException implements Exception {
  final String message;
  const NoCachedDataException(this.message);

  @override
  String toString() => 'NoCachedDataException: $message';
}
