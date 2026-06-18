import 'dart:async';

/// A utility class for retrying asynchronous operations with a backoff delay.
///
/// The [Retry] helper repeatedly executes a task until it succeeds or the
/// maximum number of attempts is reached.
///
/// Use [call] when a `null` return on exhaustion is acceptable.
/// Use [callOrThrow] when you need the last error to propagate instead.
///
/// Example:
/// ```dart
/// final retry = Retry();
///
/// // Returns null after all retries are exhausted:
/// final result = await retry.call<String>(
///   () async => fetchData(),
///   maxAttempts: 5,
///   delayMilliseconds: 400,
///   onError: (e, attempt) => debugPrint('Attempt $attempt failed: $e'),
/// );
///
/// // Throws the last error instead of returning null:
/// final data = await retry.callOrThrow<String>(
///   () async => fetchData(),
///   maxAttempts: 3,
/// );
/// ```
class Retry {
  /// Creates a [Retry] helper.
  const Retry();

  /// Executes [task] and retries on failure.
  ///
  /// - [maxAttempts] — how many retries are allowed after the first failure.
  /// - [delayMilliseconds] — wait time between attempts.
  /// - [onError] — optional callback invoked after each failed attempt with
  ///   the caught error and the attempt number (1-based).
  ///
  /// Returns the result of [task] on success, or `null` after all retries are
  /// exhausted. Note: `null` is also a valid successful return value — use
  /// [callOrThrow] when you need to distinguish failure from a null result.
  Future<T?> call<T>(
    Future<T?> Function() task, {
    int maxAttempts = 3,
    int delayMilliseconds = 300,
    void Function(Object error, int attempt)? onError,
  }) async {
    var attempts = 0;
    while (true) {
      try {
        return await task();
      } catch (e) {
        attempts++;
        onError?.call(e, attempts);
        if (attempts > maxAttempts) return null;
        await Future.delayed(Duration(milliseconds: delayMilliseconds));
      }
    }
  }

  /// Executes [task] and retries on failure, re-throwing the last error when
  /// all attempts are exhausted.
  ///
  /// - [maxAttempts] — how many retries are allowed after the first failure.
  /// - [delayMilliseconds] — wait time between attempts.
  /// - [onError] — optional callback invoked after each failed attempt with
  ///   the caught error and the attempt number (1-based).
  ///
  /// Returns the result of [task] on success.
  /// Throws the last caught error after exhausting [maxAttempts].
  Future<T> callOrThrow<T>(
    Future<T> Function() task, {
    int maxAttempts = 3,
    int delayMilliseconds = 300,
    void Function(Object error, int attempt)? onError,
  }) async {
    var attempts = 0;
    Object? lastError;
    while (true) {
      try {
        return await task();
      } catch (e) {
        lastError = e;
        attempts++;
        onError?.call(e, attempts);
        if (attempts > maxAttempts) throw lastError;
        await Future.delayed(Duration(milliseconds: delayMilliseconds));
      }
    }
  }
}
