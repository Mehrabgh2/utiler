import 'package:utiler/utiler.dart';

/// Represents a standardized HTTP API response.
///
/// [ApiResponse] wraps the raw HTTP result and provides:
/// - Strongly typed parsed data ([T]) or typed error ([E]) via [Either]
/// - HTTP status code
/// - Optional raw response body for debugging or logging
/// - Optional per-item parse failures for list endpoints
///
/// - [Right] holds successful parsed data
/// - [Left] holds a typed error of type [E]
///
/// Returned by all HTTP methods on [ApiService].
///
/// Example:
/// ```dart
/// final response = await api.get<Post>('posts/1');
///
/// response.result.fold(
///   (error) => print(error.message),
///   (data) => print('$data'),
/// );
/// ```
class ApiResponse<T, E extends ApiError> {
  /// Creates an [ApiResponse] instance.
  ///
  /// - [statusCode] is the HTTP response status code.
  /// - [result] is [Right<T>] on success or [Left<E>] on error.
  /// - [rawBody] is the original response body as a string (optional).
  /// - [parseErrors] holds items that failed parsing in list responses.
  const ApiResponse({
    required this.statusCode,
    required this.result,
    this.rawBody,
    this.parseErrors,
  });

  /// HTTP status code returned by the server.
  ///
  /// Example: `200`, `201`, `404`, `500`
  final int statusCode;

  /// Either a typed error [E] ([Left]) or parsed data [T] ([Right]).
  ///
  /// Example:
  /// ```dart
  /// response.result.fold(
  ///   (error) => showError(error.message),
  ///   (data) => showData(data),
  /// );
  /// ```
  final Either<E, T> result;

  /// Raw response body returned by the server.
  ///
  /// Useful for debugging, logging, or inspecting unparsed responses.
  final String? rawBody;

  /// Per-item parse failures for list responses.
  ///
  /// When [ApiService] receives a JSON array, each element is parsed
  /// individually. Items that fail are skipped and recorded here with their
  /// index, error, and stack trace. `null` for non-list responses.
  ///
  /// Example:
  /// ```dart
  /// if (response.hasParseErrors) {
  ///   for (final failure in response.parseErrors!) {
  ///     print('Item ${failure.index} failed: ${failure.error}');
  ///   }
  /// }
  /// ```
  final List<({int index, Object error, StackTrace stack})>? parseErrors;

  /// Whether the request completed with parsed data.
  ///
  /// Returns `true` when [result] is [Right].
  bool get isSuccess => result.isRight;

  /// Whether the request failed with a typed server error.
  ///
  /// Returns `true` when [result] is [Left].
  bool get isFailure => result.isLeft;

  /// Whether any list items failed to parse.
  ///
  /// Returns `true` when [parseErrors] is non-null and non-empty.
  bool get hasParseErrors => parseErrors?.isNotEmpty ?? false;
}
