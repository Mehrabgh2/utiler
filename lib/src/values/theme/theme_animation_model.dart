import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:utiler/src/values/animation/values_animation_type.dart';
import 'package:utiler/src/values/values_runtime.dart';

/// Builds a subtree with a specific theme applied during a transition frame.
///
/// Provided by [ThemeScope] and [ThemeJsonScope] to wrap [child] with
/// [ThemeManager] or [ThemeJsonManager] for each animation frame.
typedef ThemePageWrapper = Widget Function(dynamic theme, Widget child);

/// Holds runtime state for animated theme switching.
///
/// Captures a screenshot of the current UI, applies the new theme, and drives
/// a [ValuesAnimationType] reveal via [controller]. Used internally by
/// [ThemeScope] and [ThemeJsonScope].
class ThemeAnimationModel extends ChangeNotifier {
  /// Creates a theme animation model wired to scope callbacks.
  ThemeAnimationModel({
    required this.controller,
    required this.wrapThemedChild,
    required this.resolveTheme,
    required this.applyTheme,
    required this.getCurrentTheme,
    required this.fixedDuration,
  });

  /// Drives transition progress from 0.0 to 1.0.
  final AnimationController controller;

  /// Wraps [child] with the theme active for one transition frame.
  final ThemePageWrapper wrapThemedChild;

  /// Looks up a theme by id; returns `null` when the id is unknown.
  final dynamic Function(String id) resolveTheme;

  /// Commits the new theme id to scope state (may run mid-animation).
  final void Function(String id) applyTheme;

  /// Returns the theme currently applied to the widget tree.
  final dynamic Function() getCurrentTheme;

  /// Default duration used when [controller.duration] is reset per switch.
  final Duration fixedDuration;

  /// [GlobalKey] on the [RepaintBoundary] used for screenshots.
  final previewContainer = GlobalKey();

  /// Screenshot of the UI before the switch, shown during the reveal.
  ui.Image? image;

  /// Resolved [ValuesAnimationType] for the active or last transition.
  ValuesAnimationType animationType = ValuesAnimationType.circle;

  /// Whether a reveal animation is currently playing.
  bool isAnimating = false;

  /// Alternates layer order between forward and reverse passes.
  bool isReversed = false;

  /// Screen-space origin for path-based reveals.
  Offset animationOrigin = Offset.zero;

  /// Last pointer-down position; used as reveal origin when set.
  Offset? lastPointerDown;

  /// Theme before the switch; non-null while [isTransitioning].
  dynamic oldTheme;

  /// Theme after the switch; non-null while [isTransitioning].
  dynamic newTheme;

  /// Whether an animated theme transition is in progress.
  bool get isTransitioning =>
      oldTheme != null && newTheme != null && oldTheme != newTheme;

  /// Starts a theme switch to [themeId].
  ///
  /// Animation priority:
  /// 1. [animation] passed to this call
  /// 2. [ValuesRuntime.themeAnimation] from [UtilerScope]
  /// 3. Instant change when both are `null`
  ///
  /// [themeId] is the target theme identifier.
  ///
  /// [origin] is the screen-space reveal origin (tap or center).
  ///
  /// [animation] overrides [ValuesRuntime.themeAnimation] for this call only.
  ///
  /// [onAnimationFinish] runs after the switch completes (animated or instant).
  Future<void> changeTheme({
    required String themeId,
    required Offset origin,
    bool? isReversed,
    ValuesAnimationType? animation,
    VoidCallback? onAnimationFinish,
  }) async {
    if (controller.isAnimating) {
      return;
    }

    final resolved = resolveTheme(themeId);
    if (resolved == null) {
      return;
    }

    if (resolved == getCurrentTheme()) {
      return;
    }

    final effectiveAnimation = ValuesRuntime.resolveThemeAnimation(
      animation: animation,
    );

    if (effectiveAnimation == null) {
      applyTheme(themeId);
      onAnimationFinish?.call();
      notifyListeners();
      return;
    }

    animationType = effectiveAnimation;
    controller.duration = fixedDuration;

    if (isReversed != null) {
      this.isReversed = isReversed;
    }
    oldTheme = getCurrentTheme();
    newTheme = resolved;
    animationOrigin = origin;
    await _saveScreenshot();

    isAnimating = true;
    applyTheme(themeId);

    if (this.isReversed) {
      await controller.reverse(from: 1.0);
    } else {
      await controller.forward(from: 0.0);
    }
    this.isReversed = !this.isReversed;
    isAnimating = false;
    oldTheme = null;
    newTheme = null;
    image?.dispose();
    image = null;
    onAnimationFinish?.call();
    notifyListeners();
  }

  Future<void> _saveScreenshot() async {
    final boundary =
        previewContainer.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) {
      notifyListeners();
      return;
    }

    final pixelRatio =
        ui.PlatformDispatcher.instance.views.first.devicePixelRatio;
    image = await boundary.toImage(pixelRatio: pixelRatio);
    notifyListeners();
  }

  @override
  void dispose() {
    image?.dispose();
    super.dispose();
  }
}

/// Provides a [ThemeAnimationModel] to the widget tree.
///
/// Inserted by [ThemeScope] and [ThemeJsonScope] above the repaint boundary.
class ThemeAnimationInherited extends InheritedNotifier<ThemeAnimationModel> {
  /// Creates an inherited notifier around [notifier].
  const ThemeAnimationInherited({
    required super.notifier,
    required super.child,
    super.key,
  });

  /// Returns the nearest [ThemeAnimationModel], rebuilding when it notifies.
  ///
  /// Throws if no [ThemeAnimationInherited] ancestor exists.
  static ThemeAnimationModel of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ThemeAnimationInherited>()!
        .notifier!;
  }

  /// Returns the nearest [ThemeAnimationModel] without throwing.
  ///
  /// Returns `null` when no theme scope is mounted above [context].
  static ThemeAnimationModel? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ThemeAnimationInherited>()
        ?.notifier;
  }
}

/// Resolves the animation origin when no tap position is recorded.
///
/// Uses the center of [model.previewContainer]'s render box, or the screen
/// center as a fallback. Called for programmatic theme changes.
Offset themeAnimationOrigin(BuildContext context, ThemeAnimationModel model) {
  final boundary =
      model.previewContainer.currentContext?.findRenderObject() as RenderBox?;
  if (boundary != null && boundary.hasSize) {
    final size = boundary.size;
    return boundary.localToGlobal(Offset(size.width / 2, size.height / 2));
  }

  final size = MediaQuery.sizeOf(context);
  return Offset(size.width / 2, size.height / 2);
}
