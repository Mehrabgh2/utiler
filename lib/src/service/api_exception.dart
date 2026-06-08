/// Base interface for API-related exceptions.
///
/// Thrown by [ApiService] for transport-layer failures such as timeouts and
/// unexpected runtime errors. Distinct from [ApiError], which represents
/// structured server error responses returned inside [ApiResponse.result].
///
/// Example:
/// ```dart
/// try {
///   await api.get<User>('users/1');
/// } on ApiTimeoutException catch (e) {
///   print('Request timed out after ${e.time}s');
/// } on ApiServerException catch (e) {
///   print('Unexpected error: ${e.exception}');
/// }
/// ```
abstract interface class ApiException implements Exception {}

/// Represents an unexpected failure while executing an API request.
///
/// Thrown by [ApiService] when a non-timeout error occurs outside the normal
/// HTTP error-response path (for example, JSON shape mismatches or client bugs).
///
/// Example:
/// ```dart
/// throw ApiServerException(
///   FormatException('Invalid JSON'),
///   StackTrace.current,
/// );
/// ```
class ApiServerException implements ApiException {
  /// Creates an [ApiServerException] with the original [exception]
  /// and [stackTrace].
  ApiServerException(this.exception, this.stackTrace);

  /// The original exception thrown during the request.
  Object exception;

  /// The stack trace captured when the failure occurred.
  StackTrace stackTrace;
}

/// Represents a timeout error during an API request.
///
/// Thrown by [ApiService] when a request exceeds the configured [ApiService]
/// timeout duration.
///
/// Example:
/// ```dart
/// throw ApiTimeoutException(20); // 20 seconds
/// ```
class ApiTimeoutException implements ApiException {
  /// Creates an [ApiTimeoutException] with the timeout duration in [time].
  ApiTimeoutException(this.time);

  /// The configured timeout duration in seconds.
  int time;
}
