import 'package:utiler/src/extension/string_extension.dart';

/// Extensions on [num] providing numeric utilities, formatting helpers,
/// and conversions.
///
/// Includes:
/// - Persian number formatting
/// - range checking
/// - degree ↔ radian conversion
extension NumExtensions on num {
  /// Converts this number to a Persian numeral string.
  ///
  /// Example:
  /// ```dart
  /// print(123.toPersianNumber); // ۱۲۳
  /// ```
  String get toPersianNumber => toString().toPersianDigits();

  /// Returns `true` if this number is within the inclusive range
  /// defined by [min] and [max].
  ///
  /// Example:
  /// ```dart
  /// print(5.isBetween(1, 10)); // true
  /// ```
  bool isBetween(num min, num max) => this >= min && this <= max;

  /// Converts degrees to radians.
  ///
  /// Example:
  /// ```dart
  /// print(180.toRadians); // 3.14159...
  /// ```
  double get toRadians => this * (3.141592653589793 / 180);

  /// Converts radians to degrees.
  ///
  /// Example:
  /// ```dart
  /// print(3.14159.toDegrees); // 180
  /// ```
  double get toDegrees => this * (180 / 3.141592653589793);
}
