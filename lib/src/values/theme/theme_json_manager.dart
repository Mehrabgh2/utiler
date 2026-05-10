import 'package:flutter/material.dart';
import 'package:utiler/utiler.dart';

class ThemeJsonManager extends InheritedWidget {
  final List<Map<String, dynamic>> themes;
  final Map<String, dynamic> currentTheme;
  final Function(String, [bool?, Offset?, int?, Duration?]) changeTheme;

  const ThemeJsonManager({
    super.key,
    required super.child,
    required this.themes,
    required this.currentTheme,
    required this.changeTheme,
  });

  static ThemeJsonManager? of<T extends ThemeValues>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeJsonManager>();
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
  bool updateShouldNotify(ThemeJsonManager oldWidget) {
    return currentTheme != oldWidget.currentTheme;
  }
}
