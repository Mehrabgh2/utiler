import 'package:flutter/material.dart';

/// A utility class for responsive UI calculations based on screen size.
///
/// [Responsive] simplifies access to screen dimensions and provides helper
/// methods for scaling UI elements across different device sizes.
///
/// It is typically used to build adaptive layouts without manually calling
/// [MediaQuery] everywhere.
///
/// Example:
/// ```dart
/// final r = Responsive.of(context);
///
/// Container(
///   width: r.halfWidth,
///   height: r.scale(100),
/// )
/// ```
class Responsive {
  /// Creates a [Responsive] instance from a [BuildContext].
  Responsive._({required this.context});

  /// Factory constructor to initialize [Responsive].
  factory Responsive.of(BuildContext context) => Responsive._(context: context);

  /// Build context used for accessing MediaQuery.
  final BuildContext context;

  /// Full screen width.
  double get width => MediaQuery.of(context).size.width;

  /// Full screen height.
  double get height => MediaQuery.of(context).size.height;

  /// Scales a font size based on system text scaling settings.
  double textScale(double fontSize) =>
      MediaQuery.of(context).textScaler.scale(fontSize);

  /// Half of screen width.
  double get halfWidth => width / 2;

  /// One third of screen width.
  double get thirdWidth => width / 3;

  /// One quarter of screen width.
  double get quarterWidth => width / 4;

  /// Half of screen height.
  double get halfHeight => height / 2;

  /// One third of screen height.
  double get thirdHeight => height / 3;

  /// One quarter of screen height.
  double get quarterHeight => height / 4;

  /// Breakpoint for small screens.
  double get small => 320;

  /// Breakpoint for medium screens.
  double get medium => 600;

  /// Breakpoint for large screens.
  double get large => 900;

  /// Returns `true` if the screen is considered small.
  bool get isSmall => width < small;

  /// Returns `true` if the screen is medium-sized.
  bool get isMedium => width >= small && width < medium;

  /// Returns `true` if the screen is large.
  bool get isLarge => width >= medium && width < large;

  /// Returns `true` if the screen is extra large.
  bool get isExtraLarge => width >= large;

  /// Scales a value proportionally based on a 414px design width.
  double scale(double value) => width * value / 414;
}
