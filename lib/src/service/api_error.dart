import 'package:utiler/utiler.dart';

/// A base class representing a structured API error returned by the server.
///
/// Extend this class to define your app-wide error model that matches
/// your server's error response shape.
///
/// [ApiService] uses [ApiErrorParser] to deserialize server error responses
/// into a concrete subclass of [ApiError], which is then wrapped in [Left]
/// inside [ApiResponse.result].
///
/// Example:
/// ```dart
/// class AppError extends ApiError {
///   const AppError({required this.message, this.code, this.details});
///
///   @override
///   final String message;
///
///   @override
///   final int? code;
///
///   final String? details;
/// }
/// ```
abstract class ApiError {
  const ApiError({required this.code, required this.message});

  /// Optional machine-readable error code returned by the server.
  ///
  /// Example: `403`, `404`
  final int? code;

  /// Human-readable error message returned by the server.
  ///
  /// Example: `'User not found'`, `'Invalid credentials'`
  final String message;

  @override
  String toString() => 'ApiError(code: $code, message: $message)';
}
