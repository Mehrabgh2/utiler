import 'package:flutter/material.dart';

/// Extensions on [BuildContext] to simplify common UI queries.
extension ContextExtensions on BuildContext {
  /// Current device orientation derived from [MediaQuery].
  ///
  /// Example:
  /// ```dart
  /// if (context.orientation == Orientation.portrait) {
  ///   // do something
  /// }
  /// ```
  Orientation get orientation => MediaQuery.of(this).orientation;

  /// Returns `true` if the current orientation is portrait.
  bool get isPortrait => orientation == Orientation.portrait;

  /// Returns `true` if the current orientation is landscape.
  bool get isLandscape => orientation == Orientation.landscape;

  /// Returns the current screen size from [MediaQuery].
  ///
  /// Example:
  /// ```dart
  /// final width = context.size.width;
  /// final height = context.size.height;
  /// ```
  Size get size => MediaQuery.sizeOf(this);
}
