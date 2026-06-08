import 'package:flutter/material.dart';
import 'package:utiler/src/values/animation/values_transition_builder.dart';
import 'package:utiler/src/values/theme/theme_animation_model.dart';

/// Internal widget that renders animated theme transitions.
///
/// Mounted automatically by [ThemeScope] and [ThemeJsonScope].
/// App code does not need to use this widget directly.
class ThemeSwitchingArea extends StatelessWidget {
  const ThemeSwitchingArea({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final model = ThemeAnimationInherited.of(context);

    if (!model.isTransitioning) {
      return _themedPage(model, model.getCurrentTheme());
    }

    late final Widget firstWidget;
    late final Widget animWidget;

    if (model.isReversed) {
      firstWidget = _themedPage(model, model.newTheme);
      animWidget = RawImage(image: model.image);
    } else {
      firstWidget = RawImage(image: model.image);
      animWidget = _themedPage(model, model.newTheme);
    }

    return ValuesSwitchingStack(
      controller: model.controller,
      type: model.animationType,
      origin: model.animationOrigin,
      baseChild: firstWidget,
      transitionChild: animWidget,
      isAnimating: model.isAnimating,
    );
  }

  Widget _themedPage(ThemeAnimationModel model, dynamic theme) {
    return model.wrapThemedChild(theme, child);
  }
}
