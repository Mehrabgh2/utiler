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
  String get toPersianNumber {
    return toString().replaceAllMapped(
      RegExp(r'[0-9]'),
      (match) => _persianDigits[match.group(0)!]!,
    );
  }

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

/// Mapping of Latin digits to Persian numerals.
///
/// Used internally by [NumExtensions.toPersianNumber].
const Map<String, String> _persianDigits = {
  '0': '۰',
  '1': '۱',
  '2': '۲',
  '3': '۳',
  '4': '۴',
  '5': '۵',
  '6': '۶',
  '7': '۷',
  '8': '۸',
  '9': '۹',
};
