import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:utiler/src/values/animation/locale_animation_clipper_bridge.dart';
import 'package:utiler/src/values/locale/locale_animation_model.dart';

/// Internal widget that renders animated locale transitions.
///
/// Mounted automatically by [LocaleScope] and [LocaleJsonScope] when used
/// without a theme scope. App code does not need to use this widget directly.
class LocaleSwitchingArea extends StatelessWidget {
  const LocaleSwitchingArea({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final localeModel = LocaleAnimationInherited.of(context);

    if (!localeModel.isTransitioning) {
      return _localedPage(localeModel, localeModel.getCurrentLocale());
    }

    late final Widget firstWidget;
    late final Widget animWidget;

    if (localeModel.isReversed) {
      firstWidget = _localedPage(localeModel, localeModel.newLocale);
      animWidget = RawImage(image: localeModel.image);
    } else {
      firstWidget = RawImage(image: localeModel.image);
      animWidget = _localedPage(localeModel, localeModel.newLocale);
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        child: Stack(
          children: [
            if (localeModel.isAnimating)
              ColoredBox(color: Colors.transparent, child: firstWidget),
            _blurReveal(animWidget, localeModel),
          ],
        ),
      ),
    );
  }

  Widget _localedPage(LocaleAnimationModel model, dynamic locale) {
    return model.wrapLocaledChild(locale, child);
  }

  Widget _blurReveal(Widget widget, LocaleAnimationModel model) {
    return AnimatedBuilder(
      animation: model.controller,
      child: widget,
      builder: (_, child) {
        final curved = CurvedAnimation(
          parent: model.controller,
          curve: Curves.easeInOutCubic,
        ).value;
        final blur = (1.0 - curved) * 40;
        return ImageFiltered(
          imageFilter: ui.ImageFilter.blur(
            sigmaX: blur,
            sigmaY: blur,
            tileMode: TileMode.decal,
          ),
          child: ClipPath(
            clipper: AnimationClipperBridge(
              clipper: model.clipper,
              offset: model.animationOrigin,
              sizeRate: curved,
            ),
            child: child,
          ),
        );
      },
    );
  }
}
