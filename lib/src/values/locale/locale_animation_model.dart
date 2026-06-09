import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:utiler/src/values/animation/values_animation_type.dart';
import 'package:utiler/src/values/values_runtime.dart';

/// Builds a subtree with a specific locale applied during a transition frame.
///
/// Provided by [LocaleScope] and [LocaleJsonScope] to wrap [child] with
/// [LocaleManager] or [LocaleJsonManager] for each animation frame.
typedef LocalePageWrapper = Widget Function(dynamic locale, Widget child);

/// Holds runtime state for animated locale switching.
///
/// Captures a screenshot of the current UI, applies the new locale, and drives
/// a [ValuesAnimationType] reveal via [controller]. Used internally by
/// [LocaleScope] and [LocaleJsonScope].
class LocaleAnimationModel extends ChangeNotifier {
  /// Creates a locale animation model wired to scope callbacks.
  LocaleAnimationModel({
    required this.controller,
    required this.wrapLocaledChild,
    required this.resolveLocale,
    required this.applyLocale,
    required this.getCurrentLocale,
    required this.fixedDuration,
  });

  /// Drives transition progress from 0.0 to 1.0.
  final AnimationController controller;

  /// Wraps [child] with the locale active for one transition frame.
  final LocalePageWrapper wrapLocaledChild;

  /// Looks up a locale by id; returns `null` when the id is unknown.
  final dynamic Function(String id) resolveLocale;

  /// Commits the new locale id to scope state (may run mid-animation).
  final void Function(String id) applyLocale;

  /// Returns the locale currently applied to the widget tree.
  final dynamic Function() getCurrentLocale;

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

  /// Locale before the switch; non-null while [isTransitioning].
  dynamic oldLocale;

  /// Locale after the switch; non-null while [isTransitioning].
  dynamic newLocale;

  /// Whether an animated locale transition is in progress.
  bool get isTransitioning =>
      oldLocale != null && newLocale != null && oldLocale != newLocale;

  /// Starts a locale switch to [localeId].
  ///
  /// Animation priority:
  /// 1. [animation] passed to this call
  /// 2. [ValuesRuntime.localeAnimation] from [UtilerScope]
  /// 3. Instant change when both are `null`
  ///
  /// [localeId] is the target locale identifier.
  ///
  /// [origin] is the screen-space reveal origin (tap or center).
  ///
  /// [animation] overrides [ValuesRuntime.localeAnimation] for this call only.
  ///
  /// [onAnimationFinish] runs after the switch completes (animated or instant).
  Future<void> changeAppLocale({
    required String localeId,
    required Offset origin,
    bool isReversed = false,
    ValuesAnimationType? animation,
    VoidCallback? onAnimationFinish,
  }) async {
    if (controller.isAnimating) {
      return;
    }

    final resolved = resolveLocale(localeId);
    if (resolved == null) {
      return;
    }

    if (resolved == getCurrentLocale()) {
      return;
    }

    final effectiveAnimation = ValuesRuntime.resolveLocaleAnimation(
      animation: animation,
    );

    if (effectiveAnimation == null) {
      applyLocale(localeId);
      onAnimationFinish?.call();
      notifyListeners();
      return;
    }

    animationType = effectiveAnimation;
    controller.duration = fixedDuration;

    this.isReversed = isReversed;

    oldLocale = getCurrentLocale();
    newLocale = resolved;
    animationOrigin = origin;
    await _saveScreenshot();

    isAnimating = true;
    applyLocale(localeId);

    if (this.isReversed) {
      await controller.reverse(from: 1.0);
    } else {
      await controller.forward(from: 0.0);
    }
    this.isReversed = !this.isReversed;
    isAnimating = false;
    oldLocale = null;
    newLocale = null;
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

/// Provides a [LocaleAnimationModel] to the widget tree.
///
/// Inserted by [LocaleScope] and [LocaleJsonScope] above the repaint boundary.
class LocaleAnimationInherited extends InheritedNotifier<LocaleAnimationModel> {
  /// Creates an inherited notifier around [notifier].
  const LocaleAnimationInherited({
    required super.notifier,
    required super.child,
    super.key,
  });

  /// Returns the nearest [LocaleAnimationModel], rebuilding when it notifies.
  ///
  /// Throws if no [LocaleAnimationInherited] ancestor exists.
  static LocaleAnimationModel of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<LocaleAnimationInherited>()!
        .notifier!;
  }

  /// Returns the nearest [LocaleAnimationModel] without throwing.
  ///
  /// Returns `null` when no locale scope is mounted above [context].
  static LocaleAnimationModel? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<LocaleAnimationInherited>()
        ?.notifier;
  }
}

/// Resolves the animation origin when no tap position is recorded.
///
/// Uses the center of [model.previewContainer]'s render box, or the screen
/// center as a fallback. Called for programmatic locale changes.
Offset localeAnimationOrigin(BuildContext context, LocaleAnimationModel model) {
  final boundary =
      model.previewContainer.currentContext?.findRenderObject() as RenderBox?;
  if (boundary != null && boundary.hasSize) {
    final size = boundary.size;
    return boundary.localToGlobal(Offset(size.width / 2, size.height / 2));
  }

  final size = MediaQuery.sizeOf(context);
  return Offset(size.width / 2, size.height / 2);
}
