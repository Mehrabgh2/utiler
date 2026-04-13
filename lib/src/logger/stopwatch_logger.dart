import 'pretty_logger.dart';

class StopwatchLogger {
  final String label;
  final Stopwatch _stopwatch = Stopwatch();

  StopwatchLogger(this.label, Future future, {bool? printAddress}) {
    PrettyLogger.v("⏱ started", label, printAddress: printAddress);
    _stopwatch.start();
    future.then((_) {
      _stopwatch.stop();
      PrettyLogger.v(
        "⏱ finished in ${_stopwatch.elapsedMilliseconds} ms",
        label,
        printAddress: printAddress,
      );
    });
  }
}
