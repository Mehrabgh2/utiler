/// A simple error-safe wrapper for executing synchronous functions.
///
/// The [Guard] utility catches any exception thrown by [task] and returns
/// `null` instead of propagating the error.
///
/// This is useful when you want to safely execute a function without
/// interrupting program flow due to exceptions.
///
/// Example:
/// ```dart
/// final guard = Guard<int>();
///
/// final result = guard(() {
///   return int.parse('123');
/// });
///
/// print(result); // 123
///
/// final failed = guard(() {
///   return int.parse('abc'); // throws
/// });
///
/// print(failed); // null
/// ```
class Guard<T> {
  /// Creates a [Guard] for safely executing functions of type [T].
  const Guard();

  /// Executes [task] safely and returns its result.
  ///
  /// If [task] throws an exception, `null` is returned instead.
  T? call(T Function() task) {
    try {
      return task();
    } catch (_) {
      return null;
    }
  }
}
