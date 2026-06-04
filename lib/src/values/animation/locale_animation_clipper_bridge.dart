import 'package:flutter/material.dart';

import 'package:utiler/src/values/animation/animation_clipper.dart';

/// Bridges a [AnimationClipper] to Flutter's [CustomClipper] API.
///
/// This adapter is used internally by [SwitchingArea] to apply
/// custom clip shapes during the animated transition.
class AnimationClipperBridge extends CustomClipper<Path> {
  /// Creates a clipper bridge for the given animation state.
  AnimationClipperBridge({
    required this.sizeRate,
    required this.offset,
    required this.clipper,
  });

  /// Current animation progress in the range `0.0` to `1.0`.
  final double sizeRate;

  /// Global origin of the animation.
  final Offset offset;

  /// The underlying clipper implementation.
  final AnimationClipper clipper;

  @override
  Path getClip(Size size) {
    return clipper.getClip(size, offset, sizeRate);
  }

  @override
  bool shouldReclip(AnimationClipperBridge oldClipper) {
    return clipper.shouldReclip(oldClipper, offset, sizeRate);
  }
}
