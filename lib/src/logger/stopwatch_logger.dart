import 'dart:async';

import 'package:utiler/src/logger/pretty_logger.dart';

/// A utility that measures and logs the execution time of a [Future].
///
/// [StopwatchLogger] automatically starts timing when created and logs:
/// - when the operation starts
/// - when the operation completes
/// - total elapsed time in milliseconds
///
/// It is useful for:
/// - performance profiling
/// - debugging slow async operations
/// - monitoring API or database calls
///
/// Example:
/// ```dart
/// StopwatchLogger(
///   'fetchUsers',
///   fetchUsersFromApi(),
/// );
/// ```
class StopwatchLogger {
  /// Creates a stopwatch logger that measures the duration of [future].
  ///
  /// - [label] is used as a log tag/identifier
  /// - [future] is the asynchronous operation being measured
  /// - [printAddress] optionally includes file/line info in logs
  StopwatchLogger(this.label, Future future, {bool? printAddress}) {
    unawaited(PrettyLogger.v('⏱ started', label, printAddress: printAddress));

    _stopwatch.start();

    unawaited(
      future.then((_) {
        _stopwatch.stop();

        unawaited(
          PrettyLogger.v(
            '⏱ finished in ${_stopwatch.elapsedMilliseconds} ms',
            label,
            printAddress: printAddress,
          ),
        );
      }),
    );
  }

  /// Label used to identify this timed operation in logs.
  final String label;

  /// Internal stopwatch used to measure elapsed time.
  final Stopwatch _stopwatch = Stopwatch();
}
