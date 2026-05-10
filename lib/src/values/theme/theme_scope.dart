import 'package:flutter/material.dart';

import 'theme_manager.dart';
import 'theme_values.dart';

class ThemeScope<T extends ThemeValues> extends StatefulWidget {
  final Widget child;
  final List<T> themes;
  final String initialTheme;
  final Function(String)? themeChanged;

  const ThemeScope({
    required this.child,
    required this.initialTheme,
    this.themes = const [],
    this.themeChanged,
    super.key,
  });

  static void changeTheme(BuildContext context, String id) {
    final inheritedWidget = ThemeManager.of(context);
    if (inheritedWidget != null) {
      inheritedWidget.changeTheme(id);
    }
  }

  static ThemeValues? getCurrentTheme(BuildContext context) {
    return ThemeManager.of(context)?.currentTheme;
  }

  static List<ThemeValues>? getAllThemes(BuildContext context) {
    return ThemeManager.of(context)?.themes;
  }

  @override
  State<ThemeScope<T>> createState() => _ThemeScope<T>();
}

class _ThemeScope<T extends ThemeValues> extends State<ThemeScope<T>> {
  late T _currentTheme;

  @override
  void initState() {
    super.initState();
    int index = widget.themes.indexWhere(
      (element) => element.id == widget.initialTheme,
    );
    if (index == -1) {
      index = 0;
    }
    _currentTheme = widget.themes[index];
  }

  void _changeTheme(String id) {
    final index = widget.themes.indexWhere((theme) => theme.id == id);
    if (index != -1) {
      setState(() {
        _currentTheme = widget.themes[index];
        if (widget.themeChanged != null) {
          widget.themeChanged!(widget.themes[index].id);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemeManager<ThemeValues>(
      themes: widget.themes,
      currentTheme: _currentTheme,
      changeTheme: _changeTheme,
      child: widget.child,
    );
  }
}
