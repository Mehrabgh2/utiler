import 'dart:async';

import 'package:utiler/src/core/guard.dart';

/// Executes a batch of asynchronous functions sequentially while safely
/// capturing errors.
///
/// The [BatchExecutor] (likely intended as *BatchExecutor*) runs a list of
/// async operations one after another. Each operation is wrapped in [Guard]
/// to prevent exceptions from breaking the execution flow.
///
/// Instead of throwing, each result is stored in a list in the same order
/// as the input functions. Failed operations typically return `null`
/// (depending on [Guard]'s implementation).
///
/// Example:
/// ```dart
/// final executor = BatchExecutor();
///
/// final results = await executor.execute([
///   () async => await fetchUser(),
///   () async => await fetchPosts(),
///   () async => await fetchComments(),
/// ]);
///
/// print(results);
/// ```
class BatchExecutor {
  /// Creates a constant [BatchExecutor].
  const BatchExecutor();

  /// Executes a list of asynchronous functions sequentially.
  ///
  /// Each function is wrapped in [Guard] to safely handle exceptions.
  /// The returned list preserves the order of the input functions.
  ///
  /// Returns a list of results where each index corresponds to the
  /// respective function's output (or `null` on failure).
  Future<List> execute(List<Future Function()> functions) async {
    final List results = List.filled(functions.length, null);

    for (var i = 0; i < functions.length; i++) {
      final Function() operation = functions[i];
      final result = await Guard()(() async => await operation());
      results[i] = result;
    }

    return results;
  }
}
