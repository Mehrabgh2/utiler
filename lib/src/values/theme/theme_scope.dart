import 'package:flutter/material.dart';
import 'package:utiler/src/values/theme/theme_manager.dart';
import 'package:utiler/src/values/theme/theme_values.dart';

/// A stateful theme controller that manages typed theme switching.
///
/// [ThemeScope] is responsible for:
/// - holding a list of available themes
/// - selecting an initial theme
/// - switching themes at runtime
/// - exposing the active theme via [ThemeManager]
///
/// This is the runtime controller layer for strongly typed theming.
///
/// Example:
/// ```dart
/// ThemeScope<AppTheme>(
///   initialTheme: 'light',
///   themes: themes,
///   child: MyApp(),
/// )
/// ```
class ThemeScope<T extends ThemeValues> extends StatefulWidget {
  /// Creates a [ThemeScope].
  const ThemeScope({
    required this.child,
    required this.initialTheme,
    this.themes = const [],
    this.themeChanged,
    super.key,
  });

  /// The widget below this scope.
  final Widget child;

  /// The ID of the initial theme to apply.
  final String initialTheme;

  /// List of available typed themes.
  final List<T> themes;

  /// Optional callback triggered when theme changes.
  final Function(String)? themeChanged;

  /// Changes the active theme by its ID.
  static void changeTheme(BuildContext context, String id) {
    final inheritedWidget = ThemeManager.of(context);
    if (inheritedWidget != null) {
      inheritedWidget.changeTheme(id);
    }
  }

  /// Returns the currently active theme.
  static ThemeValues? getCurrentTheme(BuildContext context) {
    return ThemeManager.of(context)?.currentTheme;
  }

  /// Returns all available themes.
  static List<ThemeValues>? getAllThemes(BuildContext context) {
    return ThemeManager.of(context)?.themes;
  }

  @override
  State<ThemeScope<T>> createState() => _ThemeScope<T>();
}

/// Internal state for [ThemeScope].
///
/// Handles initialization and runtime switching of themes.
class _ThemeScope<T extends ThemeValues> extends State<ThemeScope<T>> {
  /// Currently selected theme instance.
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

  /// Updates the active theme by ID.
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
