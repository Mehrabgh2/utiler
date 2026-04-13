import 'dart:async';

import '../core/guard.dart';

class BactchExecutor {
  const BactchExecutor();

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
