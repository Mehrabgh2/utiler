/// A safe wrapper for executing asynchronous functions.
///
/// Unlike [Guard], which only intercepts synchronous throws, [AsyncGuard]
/// correctly awaits the result and catches both synchronous and asynchronous
/// errors, returning `null` instead of propagating them.
///
/// Always prefer [AsyncGuard] when the wrapped function is `async` or
/// returns a [Future].
///
/// Example:
/// ```dart
/// final result = await AsyncGuard<String>()(() async => fetchData());
///
/// if (result == null) {
///   print('Fetch failed');
/// } else {
///   print('Got: $result');
/// }
/// ```
class AsyncGuard<T> {
  /// Creates an [AsyncGuard] for safely executing async functions of type [T].
  const AsyncGuard();

  /// Executes [task] safely and returns its result.
  ///
  /// If [task] throws — synchronously or asynchronously — `null` is returned
  /// instead of propagating the error.
  Future<T?> call(Future<T> Function() task) async {
    try {
      return await task();
    } catch (_) {
      return null;
    }
  }
}
