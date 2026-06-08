import 'package:utiler/utiler.dart';

/// A minimal [ApiError] used when no custom [ApiErrorParser] is provided.
///
/// Exposes only [ApiError.code] and [ApiError.message] with no extra fields.
/// [ApiService] falls back to [SimpleApiErrorParser] when [errorParser] is
/// omitted at construction time.
///
/// Example:
/// ```dart
/// const error = SimpleApiError(code: 404, message: 'Not found');
/// ```
class SimpleApiError extends ApiError {
  /// Creates a [SimpleApiError] with the given [code] and [message].
  SimpleApiError({required super.code, required super.message});

  /// A debug representation of this error.
  @override
  String toString() => 'SimpleApiError(message: $message)';
}

/// Default error parser used when no custom [ApiErrorParser] is provided.
///
/// Reads [message] and [code] from the error response body.
/// If [message] is missing, falls back to `'Unknown error'`.
///
/// Example:
/// ```dart
/// const parser = SimpleApiErrorParser();
/// final error = parser.fromJson({'code': 500, 'message': 'Server error'});
/// ```
class SimpleApiErrorParser extends ApiErrorParser<ApiError> {
  /// Creates a const [SimpleApiErrorParser] instance.
  const SimpleApiErrorParser();

  /// Deserializes [json] into a [SimpleApiError].
  ///
  /// Falls back to `'Unknown error'` when `message` is absent or null.
  @override
  ApiError fromJson(Map<String, dynamic> json) {
    return SimpleApiError(
      code: json['code'] as int?,
      message: json['message'] as String? ?? 'Unknown error',
    );
  }
}
