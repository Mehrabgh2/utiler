import 'dart:async';

import 'package:utiler/src/core/async_guard.dart';

/// Executes multiple asynchronous functions concurrently and collects results.
///
/// Each task is wrapped in [AsyncGuard] so errors are captured as `null`
/// rather than breaking the execution of other tasks.
///
/// When [indexImportant] is `true` (the default), results are stored at
/// the same index as their input function.
/// When `false`, results are stored in completion order.
///
/// Example:
/// ```dart
/// final executor = ParallelExecutor();
///
/// final results = await executor.execute<String>([
///   () async => await fetchUser(),
///   () async => await fetchPosts(),
///   () async => await fetchComments(),
/// ]);
///
/// print(results); // [user, posts, comments] in input order
/// ```
class ParallelExecutor {
  /// Creates a [ParallelExecutor].
  ///
  /// Set [indexImportant] to `false` to store results in completion order
  /// instead of input order.
  const ParallelExecutor({this.indexImportant = true});

  /// Whether results are placed at the same index as their input function.
  ///
  /// When `false`, the first task to complete occupies index `0`, and so on.
  final bool indexImportant;

  /// Executes all [functions] concurrently and returns their results.
  ///
  /// Each function is wrapped in [AsyncGuard]; a failing task produces `null`
  /// at its position without affecting the others.
  Future<List<T?>> execute<T>(List<Future<T> Function()> functions) async {
    final results = List<T?>.filled(functions.length, null);
    var completionIndex = 0;

    await Future.wait([
      for (var i = 0; i < functions.length; i++)
        () async {
          final taskIndex = i;
          final result = await AsyncGuard<T>()(() => functions[taskIndex]());
          if (indexImportant) {
            results[taskIndex] = result;
          } else {
            results[completionIndex++] = result;
          }
        }(),
    ]);

    return results;
  }
}
