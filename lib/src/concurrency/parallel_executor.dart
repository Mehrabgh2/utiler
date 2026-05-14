import 'dart:async';

import 'package:utiler/src/core/guard.dart';

/// Executes multiple asynchronous functions in parallel and collects results.
///
/// The [ParallelExecutor] runs all provided async tasks concurrently using
/// `Future.wait`. It supports two modes of result ordering:
///
/// - If [indexImportant] is `true`, results are stored in the same index
///   as the input functions.
/// - If `false`, results are stored in completion order using an internal
///   counter.
///
/// Each operation is wrapped in [Guard] to prevent exceptions from breaking
/// the execution of other tasks.
///
/// Example:
/// ```dart
/// final executor = ParallelExecutor(indexImportant: true);
///
/// final results = await executor.execute<String>([
///   () async => await fetchUser(),
///   () async => await fetchPosts(),
///   () async => await fetchComments(),
/// ]);
///
/// print(results);
/// ```
class ParallelExecutor {
  /// Creates a [ParallelExecutor].
  ///
  /// If [indexImportant] is `true`, results preserve input order.
  /// If `false`, results are stored based on completion order.
  ParallelExecutor({required this.indexImportant});

  /// Whether result order should match input index order.
  final bool indexImportant;

  /// Internal counter used when [indexImportant] is `false`.
  int counter = 0;

  /// Executes all [functions] concurrently and collects their results.
  ///
  /// Each function is executed in parallel and wrapped with [Guard] to
  /// safely handle errors.
  ///
  /// Returns a list of results in either:
  /// - input order (if [indexImportant] is true)
  /// - completion order (if false)
  Future<List<T?>> execute<T>(List<Future<T> Function()> functions) async {
    final List<T?> results = List.filled(functions.length, null);
    final List<Future<T?>> futures = [];

    for (int i = 0; i < functions.length; i++) {
      final future = Future.sync(() async {
        final Function() operation = functions[i];
        final T? result = await Guard()(() async => await operation());
        if (indexImportant) {
          results[i] = result;
        } else {
          results[counter] = result;
        }
        counter++;
      });
      futures.add(future);
    }
    await Future.wait(futures);
    return results;
  }
}
