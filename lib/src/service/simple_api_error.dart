import 'package:utiler/utiler.dart';

/// Internal simple error used when no [ApiErrorParser] is provided.
///
/// Only exposes [message] as a plain string — no extra fields.
class SimpleApiError extends ApiError {
  SimpleApiError({required super.code, required super.message});

  @override
  String toString() => 'SimpleApiError(message: $message)';
}

/// Default error parser used when no custom [ApiErrorParser] is provided.
///
/// Reads only [message] and [code] from the error response body.
/// If [message] is missing, falls back to `'Unknown error'`.
class SimpleApiErrorParser extends ApiErrorParser<ApiError> {
  const SimpleApiErrorParser();

  @override
  ApiError fromJson(Map<String, dynamic> json) {
    return SimpleApiError(
      code: json['code'] as int?,

      /// Falls back to 'Unknown error' if server returns
      /// a non-standard or empty error body.
      message: json['message'] as String? ?? 'Unknown error',
    );
  }
}
