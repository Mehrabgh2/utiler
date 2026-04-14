import 'dart:async';

import '../core/guard.dart';

class ParallelExecutor {
  ParallelExecutor({required this.indexImportant});
  final bool indexImportant;
  int counter = 0;

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
