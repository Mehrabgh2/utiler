import 'package:flutter/material.dart';
import 'package:utiler/src/values/animation/locale_animation_clipper_bridge.dart';
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

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        child: Stack(
          children: [
            if (model.isAnimating)
              ColoredBox(color: Colors.transparent, child: firstWidget),
            AnimatedBuilder(
              animation: model.controller,
              child: animWidget,
              builder: (_, child) {
                return ClipPath(
                  clipper: AnimationClipperBridge(
                    clipper: model.clipper,
                    offset: model.animationOrigin,
                    sizeRate: model.controller.value,
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

  Widget _themedPage(ThemeAnimationModel model, dynamic theme) {
    return model.wrapThemedChild(theme, child);
  }
}
