import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:utiler/src/values/animation/values_animation_type.dart';

/// Renders the animated layer during theme/locale transitions.
///
/// Applies the visual effect for a single [ValuesAnimationType] to [child],
/// driven by [controller] progress. Used internally by [ValuesSwitchingStack].
///
/// Example:
/// ```dart
/// ValuesTransitionBuilder(
///   controller: animationController,
///   type: ValuesAnimationType.circle,
///   origin: tapPosition,
///   child: themedChild,
/// )
/// ```
class ValuesTransitionBuilder extends StatelessWidget {
  /// Creates a transition builder for one animated layer.
  const ValuesTransitionBuilder({
    required this.controller,
    required this.type,
    required this.origin,
    required this.child,
    super.key,
  });

  /// Progress driver for the transition (0.0 → 1.0).
  final Animation<double> controller;

  /// Visual style applied to [child].
  final ValuesAnimationType type;

  /// Screen-space origin for reveal animations (tap point or center).
  final Offset origin;

  /// Content subtree to animate (typically the new theme/locale frame).
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      child: child,
      builder: (context, child) {
        final progress = type.curve.transform(controller.value.clamp(0.0, 1.0));

        Widget result = child!;

        if (type.usesPathReveal) {
          result = ClipPath(
            clipper: _ValuesPathClipper(
              type: type,
              origin: origin,
              progress: progress,
            ),
            child: result,
          );
        } else {
          result = switch (type) {
            ValuesAnimationType.fadeIn ||
            ValuesAnimationType.fade => Opacity(opacity: progress, child: result),
            ValuesAnimationType.fadeOut =>
              Opacity(opacity: 1 - progress, child: result),
            ValuesAnimationType.slideUp => _slide(
              result,
              context,
              begin: const Offset(0, 1),
              progress: progress,
            ),
            ValuesAnimationType.slideDown => _slide(
              result,
              context,
              begin: const Offset(0, -1),
              progress: progress,
            ),
            ValuesAnimationType.slideLeft => _slide(
              result,
              context,
              begin: const Offset(1, 0),
              progress: progress,
            ),
            ValuesAnimationType.slideRight => _slide(
              result,
              context,
              begin: const Offset(-1, 0),
              progress: progress,
            ),
            ValuesAnimationType.scale => Transform.scale(
              scale: progress,
              alignment: _alignmentFor(origin, context),
              child: result,
            ),
            _ => result,
          };
        }

        if (type.usesBlur) {
          final blur = (1 - progress) * 40;
          result = ImageFiltered(
            imageFilter: ui.ImageFilter.blur(
              sigmaX: blur,
              sigmaY: blur,
              tileMode: TileMode.decal,
            ),
            child: result,
          );
        }

        return result;
      },
    );
  }

  Widget _slide(
    Widget child,
    BuildContext context, {
    required Offset begin,
    required double progress,
  }) {
    final size = MediaQuery.sizeOf(context);
    final delta = Offset(
      begin.dx * size.width * (1 - progress),
      begin.dy * size.height * (1 - progress),
    );
    return Transform.translate(offset: delta, child: child);
  }

  Alignment _alignmentFor(Offset origin, BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    if (size.width == 0 || size.height == 0) {
      return Alignment.center;
    }
    return Alignment(
      (origin.dx / size.width) * 2 - 1,
      (origin.dy / size.height) * 2 - 1,
    );
  }
}

class _ValuesPathClipper extends CustomClipper<Path> {
  _ValuesPathClipper({
    required this.type,
    required this.origin,
    required this.progress,
  });

  final ValuesAnimationType type;
  final Offset origin;
  final double progress;

  @override
  Path getClip(Size size) {
    return switch (type) {
      ValuesAnimationType.box => _boxPath(size, origin, progress),
      ValuesAnimationType.zoom => _circlePath(
        size,
        origin,
        Curves.easeOutCubic.transform(progress),
      ),
      ValuesAnimationType.circle ||
      ValuesAnimationType.blurReveal => _circlePath(size, origin, progress),
      _ => Path()..addRect(Offset.zero & size),
    };
  }

  @override
  bool shouldReclip(_ValuesPathClipper oldClipper) {
    return oldClipper.type != type ||
        oldClipper.origin != origin ||
        oldClipper.progress != progress;
  }

  static Path _circlePath(Size size, Offset origin, double rate) {
    final radius = ui.lerpDouble(0, _maxRadius(size, origin), rate)!;
    return Path()..addOval(Rect.fromCircle(center: origin, radius: radius));
  }

  static Path _boxPath(Size size, Offset origin, double rate) {
    return Path()..addRect(
      Rect.fromCenter(
        center: origin,
        width: size.width * 2 * rate,
        height: size.height * 2 * rate,
      ),
    );
  }

  static double _maxRadius(Size size, Offset center) {
    final w = max(center.dx, size.width - center.dx);
    final h = max(center.dy, size.height - center.dy);
    return sqrt(w * w + h * h);
  }
}

/// Stack used by theme/locale switching areas.
///
/// Composites a screenshot ([baseChild] or [transitionChild] depending on
/// [type]) beneath the animated layer rendered by [ValuesTransitionBuilder].
/// Used by [ThemeSwitchingArea], [LocaleSwitchingArea], and
/// [CombinedSwitchingArea].
class ValuesSwitchingStack extends StatelessWidget {
  /// Creates a two-layer switching stack for an in-progress transition.
  const ValuesSwitchingStack({
    required this.controller,
    required this.type,
    required this.origin,
    required this.baseChild,
    required this.transitionChild,
    required this.isAnimating,
    super.key,
  });

  /// Progress driver shared with [ValuesTransitionBuilder].
  final Animation<double> controller;

  /// Transition style for the animated layer.
  final ValuesAnimationType type;

  /// Screen-space origin for path-based reveals.
  final Offset origin;

  /// Static layer shown below the animation (screenshot or wrapped page).
  final Widget baseChild;

  /// Layer passed to [ValuesTransitionBuilder] (screenshot or wrapped page).
  final Widget transitionChild;

  /// When `true`, [baseChild] is included in the stack beneath the animation.
  final bool isAnimating;

  @override
  Widget build(BuildContext context) {
    final below = type == ValuesAnimationType.fadeOut
        ? transitionChild
        : baseChild;
    final above = type == ValuesAnimationType.fadeOut
        ? baseChild
        : transitionChild;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        child: Stack(
          children: [
            if (isAnimating)
              ColoredBox(color: Colors.transparent, child: below),
            ValuesTransitionBuilder(
              controller: controller,
              type: type,
              origin: origin,
              child: above,
            ),
          ],
        ),
      ),
    );
  }
}
