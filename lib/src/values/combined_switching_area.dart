import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:utiler/src/values/animation/locale_animation_clipper_bridge.dart';
import 'package:utiler/src/values/locale/locale_animation_model.dart';
import 'package:utiler/src/values/theme/theme_animation_model.dart';

/// Internal widget that renders animated theme and locale transitions.
///
/// Mounted automatically by the root scope widget.
/// App code does not need to use this widget directly.
class CombinedSwitchingArea extends StatelessWidget {
  const CombinedSwitchingArea({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final themeModel = ThemeAnimationInherited.of(context);
    final localeModel = LocaleAnimationInherited.of(context);

    final isThemeTransitioning = themeModel.isTransitioning;
    final isLocaleTransitioning = localeModel.isTransitioning;

    if (!isThemeTransitioning && !isLocaleTransitioning) {
      return _wrappedPage(themeModel, localeModel);
    }

    if (isThemeTransitioning) {
      late final Widget firstWidget;
      late final Widget animWidget;

      if (themeModel.isReversed) {
        firstWidget = _wrappedPage(
          themeModel,
          localeModel,
          theme: themeModel.newTheme,
        );
        animWidget = RawImage(image: themeModel.image);
      } else {
        firstWidget = RawImage(image: themeModel.image);
        animWidget = _wrappedPage(
          themeModel,
          localeModel,
          theme: themeModel.newTheme,
        );
      }

      return Directionality(
        textDirection: TextDirection.ltr,
        child: Material(
          child: Stack(
            children: [
              if (themeModel.isAnimating)
                ColoredBox(color: Colors.transparent, child: firstWidget),
              AnimatedBuilder(
                animation: themeModel.controller,
                child: animWidget,
                builder: (_, child) {
                  return ClipPath(
                    clipper: AnimationClipperBridge(
                      clipper: themeModel.clipper,
                      offset: themeModel.animationOrigin,
                      sizeRate: themeModel.controller.value,
                    ),
                    child: child,
                  );
                },
              ),
            ],
          ),
        ),
      );
    }

    // locale transitioning
    late final Widget firstWidget;
    late final Widget animWidget;

    if (localeModel.isReversed) {
      firstWidget = _wrappedPage(
        themeModel,
        localeModel,
        locale: localeModel.newLocale,
      );
      animWidget = RawImage(image: localeModel.image);
    } else {
      firstWidget = RawImage(image: localeModel.image);
      animWidget = _wrappedPage(
        themeModel,
        localeModel,
        locale: localeModel.newLocale,
      );
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        child: Stack(
          children: [
            if (localeModel.isAnimating)
              ColoredBox(color: Colors.transparent, child: firstWidget),
            _getBlurWidgetEase(animWidget, localeModel),
          ],
        ),
      ),
    );
  }

  Widget _wrappedPage(
    ThemeAnimationModel themeModel,
    LocaleAnimationModel localeModel, {
    dynamic theme,
    dynamic locale,
  }) {
    return themeModel.wrapThemedChild(
      theme ?? themeModel.getCurrentTheme(),
      localeModel.wrapLocaledChild(
        locale ?? localeModel.getCurrentLocale(),
        child,
      ),
    );
  }

  Widget _getBlurWidgetEase(Widget widget, LocaleAnimationModel model) {
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
