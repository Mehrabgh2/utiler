import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:utiler/src/values/animation/animation_circle_clipper.dart';
import 'package:utiler/src/values/animation/animation_clipper.dart';

/// Builds a subtree with a specific Locale applied during a transition frame.
typedef LocalePageWrapper = Widget Function(dynamic locale, Widget child);

/// Holds runtime state for animated Locale switching.
///
/// Used internally by [LocaleScope] and [LocaleJsonScope].
class LocaleAnimationModel extends ChangeNotifier {
  LocaleAnimationModel({
    required this.controller,
    required this.wrapLocaledChild,
    required this.resolveLocale,
    required this.applyLocale,
    required this.getCurrentLocale,
    required this.fixedDuration,
    required AnimationClipper? clipper,
  }) : clipper = clipper ?? AnimationCircleClipper();

  final AnimationController controller;
  final LocalePageWrapper wrapLocaledChild;
  final dynamic Function(String id) resolveLocale;
  final void Function(String id) applyLocale;
  final dynamic Function() getCurrentLocale;
  final Duration fixedDuration;

  final previewContainer = GlobalKey();

  ui.Image? image;
  AnimationClipper clipper;
  bool isAnimating = false;
  bool isReversed = false;
  Offset animationOrigin = Offset.zero;

  Offset? lastPointerDown;

  dynamic oldLocale;
  dynamic newLocale;

  bool get isTransitioning =>
      oldLocale != null && newLocale != null && oldLocale != newLocale;

  /// Starts an animated Locale switch to [LocaleId].
  ///
  /// [origin] is the global position where the reveal animation expands from.
  /// If an animation is already running, this call is ignored.
  Future<void> changeLocale({
    required String localeId,
    required Offset origin,
    bool isReversed = false,
    bool? withAnimation,
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

    if (withAnimation ?? true) {
      controller.duration = fixedDuration;
    } else {
      controller.duration = const Duration(milliseconds: 10);
    }

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
class LocaleAnimationInherited extends InheritedNotifier<LocaleAnimationModel> {
  const LocaleAnimationInherited({
    required super.notifier,
    required super.child,
    super.key,
  });

  static LocaleAnimationModel of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<LocaleAnimationInherited>()!
        .notifier!;
  }

  static LocaleAnimationModel? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<LocaleAnimationInherited>()
        ?.notifier;
  }
}

/// Resolves the center of the repaint boundary as the animation origin.
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
