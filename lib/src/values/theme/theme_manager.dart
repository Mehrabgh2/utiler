import 'package:flutter/material.dart';

import 'theme_values.dart';

class ThemeManager<T extends ThemeValues> extends InheritedWidget {
  final List<T> themes;
  final T currentTheme;
  final Function(String, [Offset?, int?, Duration?]) changeTheme;

  const ThemeManager({
    super.key,
    required super.child,
    required this.themes,
    required this.currentTheme,
    required this.changeTheme,
  });

  static ThemeManager<T>? of<T extends ThemeValues>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeManager<T>>();
  }

  @override
  bool updateShouldNotify(ThemeManager<T> oldWidget) {
    return currentTheme != oldWidget.currentTheme;
  }
}
