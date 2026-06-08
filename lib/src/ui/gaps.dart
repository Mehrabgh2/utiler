import 'package:flutter/material.dart';

/// A collection of predefined spacing widgets (gaps) for consistent UI layout.
///
/// [Gaps] provides commonly used horizontal and vertical spacers to reduce
/// repetitive `SizedBox` declarations throughout the app.
///
/// Example:
/// ```dart
/// Column(
///   children: [
///     Text('Title'),
///     Gaps.v16,
///     Text('Subtitle'),
///   ],
/// )
/// ```
class Gaps {
  /// Prevents instantiation. Use static gap widgets such as [v16] and [h8].
  const Gaps._();

  /// Horizontal gap of 4 logical pixels.
  static const SizedBox h4 = SizedBox(width: 4);

  /// Horizontal gap of 8 logical pixels.
  static const SizedBox h8 = SizedBox(width: 8);

  /// Horizontal gap of 12 logical pixels.
  static const SizedBox h12 = SizedBox(width: 12);

  /// Horizontal gap of 16 logical pixels.
  static const SizedBox h16 = SizedBox(width: 16);

  /// Horizontal gap of 24 logical pixels.
  static const SizedBox h24 = SizedBox(width: 24);

  /// Horizontal gap of 32 logical pixels.
  static const SizedBox h32 = SizedBox(width: 32);

  /// Vertical gap of 4 logical pixels.
  static const SizedBox v4 = SizedBox(height: 4);

  /// Vertical gap of 8 logical pixels.
  static const SizedBox v8 = SizedBox(height: 8);

  /// Vertical gap of 12 logical pixels.
  static const SizedBox v12 = SizedBox(height: 12);

  /// Vertical gap of 16 logical pixels.
  static const SizedBox v16 = SizedBox(height: 16);

  /// Vertical gap of 24 logical pixels.
  static const SizedBox v24 = SizedBox(height: 24);

  /// Vertical gap of 32 logical pixels.
  static const SizedBox v32 = SizedBox(height: 32);
}
