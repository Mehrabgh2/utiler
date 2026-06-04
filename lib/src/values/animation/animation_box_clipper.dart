import 'package:flutter/material.dart';
import 'package:utiler/src/values/animation/animation_clipper.dart';

/// A rectangular clipper that expands from a point to cover the screen.
///
/// Internal rectangular clipper used during  transitions.
class AnimationBoxClipper implements AnimationClipper {
  /// Creates a box-shaped  animation clipper.
  const AnimationBoxClipper();

  @override
  Path getClip(Size size, Offset offset, double sizeRate) {
    return Path()..addRect(
      Rect.fromCenter(
        center: offset,
        width: size.width * 2 * sizeRate,
        height: size.height * 2 * sizeRate,
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
}
