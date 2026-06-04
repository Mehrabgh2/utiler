import 'package:flutter/material.dart';

/// Defines a custom clip shape used during animated  transitions.
///
/// Implementations control how the new  is revealed on screen
/// (for example, as a circle or a rectangle expanding from a tap point).
///
/// See also:
/// - [AnimationCircleClipper]
/// - [AnimationBoxClipper]
abstract class AnimationClipper {
  /// Returns the clip [Path] for the given animation progress.
  ///
  /// [size] is the size of the clipped widget.
  /// [offset] is the global origin of the animation (usually the tap point).
  /// [sizeRate] is the animation progress in the range `0.0` to `1.0`.
  Path getClip(Size size, Offset offset, double sizeRate);

  /// Whether the clipper should be recalculated for the new parameters.
  bool shouldReclip(
    CustomClipper<Path> oldClipper,
    Offset offset,
    double sizeRate,
  );
}
