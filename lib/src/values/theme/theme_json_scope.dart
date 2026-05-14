import 'package:flutter/material.dart';
import 'package:utiler/src/values/theme/theme_json_manager.dart';

/// A stateful scope widget that manages JSON-based theme state.
///
/// [ThemeJsonScope] is responsible for:
/// - storing all available JSON themes
/// - tracking the currently selected theme
/// - switching themes at runtime using [setState]
/// - providing theme data through [ThemeJsonManager]
///
/// This widget acts as the controller layer for dynamic JSON theming.
///
/// Example:
/// ```dart
/// ThemeJsonScope(
///   initialTheme: 'light',
///   themes: [
///     {'light': {...}},
///     {'dark': {...}},
///   ],
///   child: MyApp(),
/// )
/// ```
class ThemeJsonScope extends StatefulWidget {
  /// Creates a [ThemeJsonScope].
  const ThemeJsonScope({
    required this.child,
    required this.initialTheme,
    this.themes = const [],
    this.themeChanged,
    super.key,
  });

  /// The widget below this scope.
  final Widget child;

  /// The initial theme identifier (e.g. `"light"`, `"dark"`).
  final String initialTheme;

  /// List of available JSON theme maps.
  final List<Map<String, dynamic>> themes;

  /// Optional callback triggered when theme changes.
  final Function(String)? themeChanged;

  /// Changes the current theme by its identifier.
  ///
  /// Looks up the nearest [ThemeJsonManager] and triggers a change.
  static void changeTheme(BuildContext context, String id) {
    final inheritedWidget = ThemeJsonManager.of(context);
    if (inheritedWidget != null) {
      inheritedWidget.changeTheme(id);
    }
  }

  /// Returns the currently active theme map.
  static Map<String, dynamic>? getCurrentTheme(BuildContext context) {
    return ThemeJsonManager.of(context)?.currentTheme;
  }

  /// Returns all available JSON themes.
  static List<Map<String, dynamic>>? getAllThemes(BuildContext context) {
    return ThemeJsonManager.of(context)?.themes;
  }

  @override
  State<ThemeJsonScope> createState() => _ThemeJsonScope();
}

/// Internal state for [ThemeJsonScope].
///
/// Handles initialization and switching of JSON themes.
class _ThemeJsonScope extends State<ThemeJsonScope> {
  /// Currently active theme map.
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

  /// Updates the active theme by its ID.
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
