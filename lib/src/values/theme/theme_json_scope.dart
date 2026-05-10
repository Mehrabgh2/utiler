import 'package:flutter/material.dart';

import 'theme_json_manager.dart';

class ThemeJsonScope extends StatefulWidget {
  final Widget child;
  final List<Map<String, dynamic>> themes;
  final String initialTheme;
  final Function(String)? themeChanged;

  const ThemeJsonScope({
    required this.child,
    required this.initialTheme,
    this.themes = const [],
    this.themeChanged,
    super.key,
  });

  static void changeTheme(BuildContext context, String id) {
    final inheritedWidget = ThemeJsonManager.of(context);
    if (inheritedWidget != null) {
      inheritedWidget.changeTheme(id);
    }
  }

  static Map<String, dynamic>? getCurrentTheme(BuildContext context) {
    return ThemeJsonManager.of(context)?.currentTheme;
  }

  static List<Map<String, dynamic>>? getAllThemes(BuildContext context) {
    return ThemeJsonManager.of(context)?.themes;
  }

  @override
  State<ThemeJsonScope> createState() => _ThemeJsonScope();
}

class _ThemeJsonScope extends State<ThemeJsonScope> {
  late Map<String, dynamic> _currentTheme;

  @override
  void initState() {
    super.initState();
    int index = widget.themes.indexWhere(
      (element) => element.keys.first == widget.initialTheme,
    );
    if (index == -1) {
      index = 0;
    }
    _currentTheme = widget.themes[index];
  }

  void _changeTheme(String id) {
    final index = widget.themes.indexWhere(
      (element) => element.keys.first == id,
    );
    if (index != -1) {
      setState(() {
        _currentTheme = widget.themes[index];
        if (widget.themeChanged != null) {
          widget.themeChanged!(id);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemeJsonManager(
      themes: widget.themes,
      currentTheme: _currentTheme,
      changeTheme: _changeTheme,
      child: widget.child,
    );
  }
}
