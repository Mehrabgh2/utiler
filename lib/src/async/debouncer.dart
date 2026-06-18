import 'dart:async';

/// A utility class that prevents a function from being called too frequently.
///
/// The [Debouncer] delays execution of an action until a specified period
/// of inactivity has passed. If [call] is invoked again before the timer
/// completes, the previous timer is cancelled and restarted.
///
/// Use [flush] to execute the pending action immediately without waiting for
/// the timer (useful before form submission or on widget dispose).
///
/// Example:
/// ```dart
/// final debouncer = Debouncer(300);
///
/// void onTextChanged(String value) {
///   debouncer(() => fetchResults(value));
/// }
///
/// // Execute immediately (e.g. on submit):
/// debouncer.flush();
///
/// // Remember to dispose when no longer needed:
/// debouncer.dispose();
/// ```
class Debouncer {
  /// Creates a [Debouncer] with a delay of [milliseconds].
  Debouncer(this.milliseconds);

  /// The delay in milliseconds before the action is executed.
  final int milliseconds;

  Timer? _timer;
  void Function()? _pendingAction;

  /// Schedules [action] to run after the debounce delay.
  ///
  /// If this method is called again before the delay completes,
  /// the previous scheduled action is discarded.
  void call(void Function() action) {
    dispose();
    _pendingAction = action;
    _timer = Timer(Duration(milliseconds: milliseconds), () {
      _pendingAction?.call();
      _pendingAction = null;
    });
  }

  /// Cancels the pending timer and executes the action immediately.
  ///
  /// Does nothing if no action is pending.
  void flush() {
    _timer?.cancel();
    _timer = null;
    final action = _pendingAction;
    _pendingAction = null;
    action?.call();
  }

  /// Cancels any pending scheduled action without executing it.
  ///
  /// Safe to call even if no timer is active.
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _pendingAction = null;
  }
}
