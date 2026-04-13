import 'package:flutter/material.dart';

extension ColorExtension on String {
  Color get toColor {
    final hexColor = replaceAll('#', '').padLeft(8, 'FF');
    final intColor = int.parse(hexColor, radix: 16);
    return Color(intColor);
  }
}
