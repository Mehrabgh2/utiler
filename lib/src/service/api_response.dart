import 'package:utiler/utiler.dart';

/// Represents a standardized HTTP API response.
///
/// [ApiResponse] wraps the raw HTTP result and provides:
/// - Strongly typed parsed data ([T]) or typed error ([E]) via [Either]
/// - HTTP status code
/// - Optional raw response body for debugging or logging
///
/// - [Right] holds successful parsed data
/// - [Left] holds a typed error of type [E]
///
/// This class is returned by all methods in [ApiService].
///
/// Example:
/// ```dart
/// final response = await api.get<Post>('posts');
///
/// response.result.fold(
///   (error) => print(error.message),
///   (data)  => print(data),
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

  /// Either a typed error [E] (Left) or parsed data [T] (Right).
  ///
  /// Use [result.fold] to handle both cases:
  /// ```dart
  /// response.result.fold(
  ///   (error) => print(error.message),
  ///   (data)  => print(data),
  /// );
  /// ```
  final Either<E, T> result;

  /// Raw response body returned by the server.
  ///
  /// Useful for debugging, logging, or inspecting unparsed responses.
  final String? rawBody;

  /// Items that failed parsing — null if not a list response.
  final List<({int index, Object error, StackTrace stack})>? parseErrors;

  /// Indicates whether the request was successful.
  ///
  /// Returns `true` if [result] is [Right].
  bool get isSuccess => result.isRight;

  /// Indicates whether the request failed with a typed error.
  ///
  /// Returns `true` if [result] is [Left].
  bool get isFailure => result.isLeft;

  /// Indicates whether the response has any item-level parse errors.
  bool get hasParseErrors => parseErrors?.isNotEmpty ?? false;
}
