import 'package:flutter/material.dart';
import 'package:utiler/src/values/animation/values_transition_builder.dart';
import 'package:utiler/src/values/locale/locale_animation_model.dart';
import 'package:utiler/src/values/theme/theme_animation_model.dart';

/// Internal widget that renders animated theme and locale transitions.
///
/// Mounted automatically by [ValuesScope] when both theme and locale scopes
/// are active. Coordinates [ThemeAnimationModel] and [LocaleAnimationModel],
/// preferring theme transitions when both are in progress.
///
/// App code does not need to use this widget directly.
class CombinedSwitchingArea extends StatelessWidget {
  /// Creates a combined switching area around [child].
  const CombinedSwitchingArea({required this.child, super.key});

  /// App content wrapped with the current theme and locale.
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

      return ValuesSwitchingStack(
        controller: themeModel.controller,
        type: themeModel.animationType,
        origin: themeModel.animationOrigin,
        baseChild: firstWidget,
        transitionChild: animWidget,
        isAnimating: themeModel.isAnimating,
      );
    }

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

    return ValuesSwitchingStack(
      controller: localeModel.controller,
      type: localeModel.animationType,
      origin: localeModel.animationOrigin,
      baseChild: firstWidget,
      transitionChild: animWidget,
      isAnimating: localeModel.isAnimating,
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
}
