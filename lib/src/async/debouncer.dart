import 'dart:async';

/// A utility class that prevents a function from being called too frequently.
///
/// The [Debouncer] delays execution of an action until a specified period
/// of inactivity has passed. If [call] is invoked again before the timer
/// completes, the previous timer is cancelled and restarted.
///
/// This is commonly used for:
/// - search input fields
/// - API request throttling
/// - live validation
///
/// Example:
/// ```dart
/// final debouncer = Debouncer(300);
///
/// void onTextChanged(String value) {
///   debouncer(() {
///     print('Searching for: $value');
///   });
/// }
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

  /// Schedules [action] to run after the debounce delay.
  ///
  /// If this method is called again before the delay completes,
  /// the previous scheduled action is cancelled.
  void call(void Function() action) {
    dispose();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  /// Cancels any pending scheduled action.
  ///
  /// Safe to call even if no timer is active.
  void dispose() {
    _timer?.cancel();
  }
}
