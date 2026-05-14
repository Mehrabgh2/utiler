import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A custom SafeArea widget that allows background coloring and fine-grained
/// control over system padding.
///
/// Unlike Flutter's built-in [SafeArea], this widget:
/// - supports a background [color]
/// - allows minimum padding constraints
/// - optionally preserves bottom view padding (useful for keyboards)
///
/// Example:
/// ```dart
/// ColorfulSafearea(
///   color: Colors.white,
///   child: Scaffold(
///     body: Text('Hello'),
///   ),
/// )
/// ```
class ColorfulSafearea extends StatelessWidget {
  /// Creates a [ColorfulSafearea].
  const ColorfulSafearea({
    super.key,
    this.left = true,
    this.top = true,
    this.right = true,
    this.bottom = true,
    this.minimum = EdgeInsets.zero,
    this.maintainBottomViewPadding = false,
    required this.child,
    required this.color,
  });

  /// Background color applied behind the safe area.
  final Color color;

  /// Whether to apply safe padding on the left side.
  final bool left;

  /// Whether to apply safe padding on the top side.
  final bool top;

  /// Whether to apply safe padding on the right side.
  final bool right;

  /// Whether to apply safe padding on the bottom side.
  final bool bottom;

  /// Minimum padding applied regardless of system insets.
  final EdgeInsets minimum;

  /// Whether to preserve bottom view padding (e.g. keyboard inset).
  final bool maintainBottomViewPadding;

  /// The widget below this safe area.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));

    EdgeInsets padding = MediaQuery.paddingOf(context);

    if (maintainBottomViewPadding) {
      padding = padding.copyWith(
        bottom: MediaQuery.viewPaddingOf(context).bottom,
      );
    }

    return Container(
      color: color,
      padding: EdgeInsets.only(
        left: math.max(left ? padding.left : 0.0, minimum.left),
        top: math.max(top ? padding.top : 0.0, minimum.top),
        right: math.max(right ? padding.right : 0.0, minimum.right),
        bottom: math.max(bottom ? padding.bottom : 0.0, minimum.bottom),
      ),
      child: MediaQuery.removePadding(
        context: context,
        removeLeft: left,
        removeTop: top,
        removeRight: right,
        removeBottom: bottom,
        child: child,
      ),
    );
  }

  /// Adds debug information for Flutter inspector.
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties.add(
      FlagProperty('left', value: left, ifTrue: 'avoid left padding'),
    );
    properties.add(
      FlagProperty('top', value: top, ifTrue: 'avoid top padding'),
    );
    properties.add(
      FlagProperty('right', value: right, ifTrue: 'avoid right padding'),
    );
    properties.add(
      FlagProperty('bottom', value: bottom, ifTrue: 'avoid bottom padding'),
    );
  }
}

/// A sliver-safe variant of SafeArea that applies system insets to slivers.
///
/// Useful in [CustomScrollView] layouts where you need proper padding
/// for notched devices or system UI overlays.
///
/// Example:
/// ```dart
/// CustomScrollView(
///   slivers: [
///     SliverSafeArea(
///       sliver: SliverList(...),
///     ),
///   ],
/// )
/// ```
class SliverSafeArea extends StatelessWidget {
  /// Creates a [SliverSafeArea].
  const SliverSafeArea({
    super.key,
    this.left = true,
    this.top = true,
    this.right = true,
    this.bottom = true,
    this.minimum = EdgeInsets.zero,
    required this.sliver,
  });

  /// Whether to apply safe padding on the left side.
  final bool left;

  /// Whether to apply safe padding on the top side.
  final bool top;

  /// Whether to apply safe padding on the right side.
  final bool right;

  /// Whether to apply safe padding on the bottom side.
  final bool bottom;

  /// Minimum padding applied regardless of system insets.
  final EdgeInsets minimum;

  /// The sliver widget to display inside safe area.
  final Widget sliver;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));

    final EdgeInsets padding = MediaQuery.paddingOf(context);

    return SliverPadding(
      padding: EdgeInsets.only(
        left: math.max(left ? padding.left : 0.0, minimum.left),
        top: math.max(top ? padding.top : 0.0, minimum.top),
        right: math.max(right ? padding.right : 0.0, minimum.right),
        bottom: math.max(bottom ? padding.bottom : 0.0, minimum.bottom),
      ),
      sliver: MediaQuery.removePadding(
        context: context,
        removeLeft: left,
        removeTop: top,
        removeRight: right,
        removeBottom: bottom,
        child: sliver,
      ),
    );
  }

  /// Adds debug information for Flutter inspector.
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties.add(
      FlagProperty('left', value: left, ifTrue: 'avoid left padding'),
    );
    properties.add(
      FlagProperty('top', value: top, ifTrue: 'avoid top padding'),
    );
    properties.add(
      FlagProperty('right', value: right, ifTrue: 'avoid right padding'),
    );
    properties.add(
      FlagProperty('bottom', value: bottom, ifTrue: 'avoid bottom padding'),
    );
  }
}
