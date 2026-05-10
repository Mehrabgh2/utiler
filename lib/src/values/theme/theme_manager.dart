import 'package:flutter/material.dart';
import 'package:utiler/utiler.dart';

class ThemeManager<T extends ThemeValues> extends InheritedWidget {
  final List<T> themes;
  final T currentTheme;
  final Function(String) changeTheme;

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
  Widget get child {
    return Builder(
      builder: (context) {
        UtilerScope.themeContext = context;
        return super.child;
      },
    );
  }

  @override
  bool updateShouldNotify(ThemeManager<T> oldWidget) {
    return currentTheme != oldWidget.currentTheme;
  }
}
