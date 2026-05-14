import 'dart:async';

/// A utility that limits how frequently an action can be executed.
///
/// The [Throttler] ensures that [call] is only executed once per defined
/// interval. Any calls made during the cooldown period are ignored.
///
/// This is useful for:
/// - button spam prevention
/// - scroll or resize event handling
/// - rate-limiting UI interactions
///
/// Example:
/// ```dart
/// final throttler = Throttler(1000);
///
/// void onTap() {
///   throttler(() {
///     print('Button tapped');
///   });
/// }
/// ```
class Throttler {
  /// Creates a [Throttler] with a minimum interval between executions.
  Throttler(this.intervalMilliseconds);

  /// The minimum time (in milliseconds) between allowed executions.
  final int intervalMilliseconds;

  bool _ready = true;

  /// Executes [action] if the throttle interval has passed.
  ///
  /// If called again before [intervalMilliseconds] has elapsed,
  /// the action is ignored.
  void call(void Function() action) {
    if (!_ready) return;
    _ready = false;
    action();
    Timer(Duration(milliseconds: intervalMilliseconds), () => _ready = true);
  }
}
