import 'package:flutter/foundation.dart';

/// Shared visibility state for [LoggerConsole] and [PerformanceMonitor].
///
/// Each overlay reads the other's notifier to decide whether to hide its FAB,
/// and writes its own notifier when it opens or closes. This keeps the two
/// widgets decoupled — neither imports the other.
class OverlayCoordinator {
  OverlayCoordinator._();

  /// `true` while the [PerformanceMonitor] panel is open.
  static final ValueNotifier<bool> performanceOpen = ValueNotifier(false);

  /// `true` while the [LoggerConsole] panel is open.
  static final ValueNotifier<bool> loggerOpen = ValueNotifier(false);
}
