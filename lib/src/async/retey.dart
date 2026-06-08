import 'dart:async';

/// A utility class for retrying asynchronous operations with backoff delay.
///
/// The [Retry] helper repeatedly executes a task until it succeeds or the
/// maximum number of attempts is reached. If all attempts fail, it returns
/// `null`.
///
/// This is useful for:
/// - unstable network requests
/// - flaky APIs
/// - transient I/O operations
///
/// Example:
/// ```dart
/// final retry = Retry();
///
/// final result = await retry.call<String>(
///   () async {
///     // Simulated request
///     return await fetchData();
///   },
///   maxAttempts: 5,
///   delayMilliseconds: 500,
/// );
///
/// if (result == null) {
///   print('Request failed after retries');
/// } else {
///   print('Success: $result');
/// }
/// ```
class Retry {
  /// Creates a [Retry] helper with default retry settings.
  const Retry();

  /// Executes [task] and retries it if it throws an exception.
  ///
  /// - [maxAttempts] defines how many retries are allowed after the first failure.
  /// - [delayMilliseconds] defines the wait time between attempts.
  ///
  /// Returns the result of [task] if successful, otherwise `null`
  /// after all retries are exhausted.
  Future<T?> call<T>(
    Future<T?> Function() task, {
    int maxAttempts = 3,
    int delayMilliseconds = 300,
  }) async {
    int attempts = 0;

    while (true) {
      try {
        return await task();
      } catch (_) {
        attempts++;
        if (attempts > maxAttempts) {
          return null;
        }
        await Future.delayed(Duration(milliseconds: delayMilliseconds));
      }
    }
  }
}
