import 'package:flutter/material.dart';
import 'package:utiler/src/values/animation/values_transition_builder.dart';
import 'package:utiler/src/values/locale/locale_animation_model.dart';

/// Internal widget that renders animated locale transitions.
///
/// Mounted automatically by [LocaleScope] and [LocaleJsonScope] when used
/// without a theme scope. App code does not need to use this widget directly.
class LocaleSwitchingArea extends StatelessWidget {
  /// Creates a locale transition layer around [child].
  const LocaleSwitchingArea({required this.child, super.key});

  /// The widget tree that receives the active locale.
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

    return ValuesSwitchingStack(
      controller: localeModel.controller,
      type: localeModel.animationType,
      origin: localeModel.animationOrigin,
      baseChild: firstWidget,
      transitionChild: animWidget,
      isAnimating: localeModel.isAnimating,
    );
  }

  Widget _localedPage(LocaleAnimationModel model, dynamic locale) {
    return model.wrapLocaledChild(locale, child);
  }
}
