import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:utiler/src/values/animation/animation_clipper.dart';

/// A circular clipper that expands from a point to cover the screen.
///
/// This is the default clipper and produces the classic ripple effect.
class AnimationCircleClipper implements AnimationClipper {
  /// Creates a circular  animation clipper.
  const AnimationCircleClipper();

  @override
  Path getClip(Size size, Offset offset, double sizeRate) {
    return Path()..addOval(
      Rect.fromCircle(
        center: offset,
        radius: lerpDouble(0, _calcMaxRadius(size, offset), sizeRate)!,
      ),
    );
  }

  @override
  bool shouldReclip(
    CustomClipper<Path> oldClipper,
    Offset offset,
    double sizeRate,
  ) {
    return true;
  }

  /// Calculates the radius required to fully cover [size] from [center].
  static double _calcMaxRadius(Size size, Offset center) {
    final w = max(center.dx, size.width - center.dx);
    final h = max(center.dy, size.height - center.dy);
    return sqrt(w * w + h * h);
  }
}
