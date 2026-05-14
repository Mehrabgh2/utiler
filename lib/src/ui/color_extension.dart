import 'package:flutter/material.dart';

/// Extension on [String] to convert hex color strings into [Color].
///
/// Supports formats like:
/// - `#RRGGBB`
/// - `RRGGBB`
/// - `#AARRGGBB`
/// - `AARRGGBB`
///
/// If alpha is not provided, it defaults to `FF` (fully opaque).
extension ColorExtension on String {
  /// Converts a hex color string into a Flutter [Color].
  ///
  /// Example:
  /// ```dart
  /// final color = '#FF5733'.toColor;
  /// final color2 = 'FF5733'.toColor;
  /// final color3 = '#80FF5733'.toColor; // with alpha
  /// ```
  Color get toColor {
    final hexColor = replaceAll('#', '').padLeft(8, 'FF');
    final intColor = int.parse(hexColor, radix: 16);
    return Color(intColor);
  }
}
