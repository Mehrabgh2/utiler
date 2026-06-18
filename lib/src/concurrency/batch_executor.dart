import 'dart:async';

import 'package:utiler/src/core/async_guard.dart';

/// Executes a list of asynchronous functions sequentially, capturing errors
/// as `null` results rather than letting them break the execution flow.
///
/// Each operation is wrapped in [AsyncGuard] so that both synchronous and
/// asynchronous errors are caught; failed tasks produce `null` at their
/// respective index.
///
/// Example:
/// ```dart
/// const executor = BatchExecutor();
///
/// final results = await executor.execute([
///   () async => await fetchUser(),
///   () async => await fetchPosts(),
///   () async => await fetchComments(),
/// ]);
///
/// print(results); // [user, posts, null] — third task failed safely
/// ```
class BatchExecutor {
  /// Creates a constant [BatchExecutor].
  const BatchExecutor();

  /// Executes [functions] one after another.
  ///
  /// Each function is wrapped in [AsyncGuard] to safely handle errors.
  /// The returned list preserves the order of the input functions, with
  /// `null` at the index of any task that threw an error.
  Future<List<dynamic>> execute(
    List<Future<dynamic> Function()> functions,
  ) async {
    final results = List<dynamic>.filled(functions.length, null);
    for (var i = 0; i < functions.length; i++) {
      results[i] = await AsyncGuard<dynamic>()(() => functions[i]());
    }
    return results;
  }
}
