import 'package:flutter/material.dart';

/// Extensions on [num] to quickly create horizontal and vertical spacing widgets.
///
/// This is commonly used in Flutter UI layouts to reduce boilerplate when
/// adding spacing between widgets.
///
/// Example:
/// ```dart
/// Column(
///   children: [
///     Text('Hello'),
///     16.v,
///     Text('World'),
///   ],
/// )
/// ```
extension GapExtension on num {
  /// Creates a horizontal space with width equal to this value.
  ///
  /// Example:
  /// ```dart
  /// 16.h
  /// ```
  SizedBox get h => SizedBox(width: toDouble());

  /// Creates a vertical space with height equal to this value.
  ///
  /// Example:
  /// ```dart
  /// 16.v
  /// ```
  SizedBox get v => SizedBox(height: toDouble());
}
