import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:utiler/src/values/animation/values_animation_type.dart';
import 'package:utiler/src/values/values_runtime.dart';

/// Builds a subtree with a specific theme applied during a transition frame.
typedef ThemePageWrapper = Widget Function(dynamic theme, Widget child);

/// Holds runtime state for animated theme switching.
///
/// Used internally by [ThemeScope] and [ThemeJsonScope].
class ThemeAnimationModel extends ChangeNotifier {
  ThemeAnimationModel({
    required this.controller,
    required this.wrapThemedChild,
    required this.resolveTheme,
    required this.applyTheme,
    required this.getCurrentTheme,
    required this.fixedDuration,
  });

  final AnimationController controller;
  final ThemePageWrapper wrapThemedChild;
  final dynamic Function(String id) resolveTheme;
  final void Function(String id) applyTheme;
  final dynamic Function() getCurrentTheme;
  final Duration fixedDuration;

  final previewContainer = GlobalKey();

  ui.Image? image;
  ValuesAnimationType animationType = ValuesAnimationType.circle;
  bool isAnimating = false;
  bool isReversed = false;
  Offset animationOrigin = Offset.zero;

  Offset? lastPointerDown;

  dynamic oldTheme;
  dynamic newTheme;

  bool get isTransitioning =>
      oldTheme != null && newTheme != null && oldTheme != newTheme;

  /// Starts a theme switch to [themeId].
  ///
  /// Animation priority:
  /// 1. [animation] passed to this call
  /// 2. [ValuesRuntime.themeAnimation] from [UtilerScope]
  /// 3. Instant change when both are `null`
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
class ThemeAnimationInherited extends InheritedNotifier<ThemeAnimationModel> {
  const ThemeAnimationInherited({
    required super.notifier,
    required super.child,
    super.key,
  });

  static ThemeAnimationModel of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ThemeAnimationInherited>()!
        .notifier!;
  }

  static ThemeAnimationModel? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ThemeAnimationInherited>()
        ?.notifier;
  }
}

/// Resolves the center of the repaint boundary as the animation origin.
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
