/// Base interface for API-related exceptions.
///
/// All API-specific errors should implement this interface so they can be
/// handled in a unified way by networking layers or error mappers.
abstract interface class ApiException implements Exception {}

/// Represents a server-side API failure.
///
/// This exception is typically thrown when the server returns an error,
/// or when an unexpected response is received.
///
/// Contains:
/// - [exception]: the original error object
/// - [stackTrace]: stack trace for debugging purposes
class ApiServerException implements ApiException {
  /// Creates a [ApiServerException] with the original [exception]
  /// and [stackTrace].
  ApiServerException(this.exception, this.stackTrace);

  /// Original exception thrown by the server or HTTP client.
  Object exception;

  /// Stack trace associated with the failure.
  StackTrace stackTrace;
}

/// Represents a timeout error during an API request.
///
/// This exception is thrown when a request exceeds the allowed duration.
///
/// Contains:
/// - [time]: the timeout duration in milliseconds
class ApiTimeoutException implements ApiException {
  /// Creates a [ApiTimeoutException] with the timeout [time].
  ApiTimeoutException(this.time);

  /// Duration (in milliseconds) after which the request timed out.
  int time;
}
