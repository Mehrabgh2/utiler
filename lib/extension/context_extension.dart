import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  Orientation get orientation => MediaQuery.of(this).orientation;

  bool get isPortrait => orientation == Orientation.portrait;

  bool get isLandscape => orientation == Orientation.landscape;

  Size get size => MediaQuery.sizeOf(this);
}
