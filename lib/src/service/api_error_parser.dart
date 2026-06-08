import 'package:utiler/utiler.dart';

/// A contract for deserializing server error responses into a typed [ApiError].
///
/// Every [ApiService] instance requires a concrete [ApiErrorParser] that matches
/// the server's error response shape. This is enforced at compile time via the
/// [ApiService] constructor.
///
/// Implement this once per app — your server likely has a single error envelope
/// shared across all endpoints.
///
/// Example server error response:
/// ```json
/// {
///   "message": "User not found",
///   "code": 404,
///   "details": "No user exists with the given ID"
/// }
/// ```
///
/// Implementation:
/// ```dart
/// class AppErrorParser extends ApiErrorParser<AppError> {
///   const AppErrorParser();
///
///   @override
///   AppError fromJson(Map<String, dynamic> json) => AppError(
///         message: json['message'] as String? ?? 'Unknown error',
///         code: json['code'] as int?,
///         details: json['details'] as String?,
///       );
/// }
/// ```
///
/// Registration:
/// ```dart
/// final api = ApiService<AppError>(
///   client: http.Client(),
///   parsers: [PostParser(), UserParser()],
///   errorParser: const AppErrorParser(),
///   baseUrl: 'https://api.example.com',
/// );
/// ```
///
/// Usage:
/// ```dart
/// final response = await api.get<Post>('posts/1');
///
/// response.result.fold(
///   (error) => print('${error.code}: ${error.message}'),
///   (data) => print('$data'),
/// );
/// ```
abstract class ApiErrorParser<E extends ApiError> {
  /// Creates an [ApiErrorParser] instance.
  const ApiErrorParser();

  /// Deserializes a server error response body into a typed [E].
  ///
  /// [json] is the decoded error response body. If the server returns
  /// a non-JSON or empty error body, [ApiService] supplies a fallback map
  /// with `message` and `code` keys, so implementations should handle missing
  /// fields gracefully.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// AppError fromJson(Map<String, dynamic> json) => AppError(
  ///       message: json['message'] as String? ?? 'Unknown error',
  ///       code: json['code'] as int?,
  ///     );
  /// ```
  E fromJson(Map<String, dynamic> json);
}
