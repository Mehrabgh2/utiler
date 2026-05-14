import 'package:flutter/material.dart';

/// Callback used to listen for app lifecycle state changes.
typedef LifecycleListener = Function(AppLifecycleState state);

/// A widget that observes and forwards app lifecycle changes.
///
/// [LifecycleHandler] wraps a [child] widget and listens to Flutter's
/// application lifecycle events (via [WidgetsBindingObserver]).
///
/// It reports changes such as:
/// - resumed
/// - paused
/// - inactive
/// - detached
/// - hidden (on newer platforms)
///
/// This is useful for:
/// - pausing animations or timers
/// - saving state when app goes to background
/// - resuming network or streams when app returns
///
/// Example:
/// ```dart
/// LifecycleHandler(
///   lifecycleListener: (state) {
///     print('App state: $state');
///   },
///   child: MyApp(),
/// )
/// ```
class LifecycleHandler extends StatefulWidget {
  /// Creates a [LifecycleHandler].
  const LifecycleHandler({
    required this.lifecycleListener,
    required this.child,
    super.key,
  });

  /// The widget subtree that will be wrapped.
  final Widget child;

  /// Callback triggered whenever the app lifecycle state changes.
  final LifecycleListener lifecycleListener;

  @override
  State<LifecycleHandler> createState() => _LifecycleHandlerState();
}

class _LifecycleHandlerState extends State<LifecycleHandler>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Called whenever the app lifecycle state changes.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    widget.lifecycleListener(state);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
