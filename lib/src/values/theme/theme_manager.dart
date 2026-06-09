import 'package:flutter/material.dart';
import 'package:utiler/src/utiler.dart';
import 'package:utiler/src/values/theme/theme_values.dart';

/// A generic [InheritedWidget] that provides strongly typed theme data
/// to the widget tree.
///
/// [ThemeManager] is the typed counterpart of JSON-based theming, offering
/// compile-time safety through [ThemeValues].
///
/// It provides:
/// - a list of available typed themes
/// - the currently active theme
/// - a callback to switch themes
///
/// Example:
/// ```dart
/// ThemeManager<AppTheme>(
///   themes: themes,
///   currentTheme: themes.first,
///   changeAppTheme: (id) {},
///   child: MyApp(),
/// )
/// ```
class ThemeManager<T extends ThemeValues> extends InheritedWidget {
  /// Creates a [ThemeManager].
  const ThemeManager({
    super.key,
    required super.child,
    required this.themes,
    required this.currentTheme,
    required this.changeAppTheme,
  });

  /// All available typed themes.
  final List<T> themes;

  /// The currently active theme.
  final T currentTheme;

  /// Callback used to change theme by identifier.
  final Function(String) changeAppTheme;

  /// Retrieves the nearest [ThemeManager] of type [T].
  static ThemeManager<T>? of<T extends ThemeValues>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeManager<T>>();
  }

  /// Wraps the child widget and updates [Utiler.themeContext].
  ///
  /// This allows global access to the current theme context.
  @override
  Widget get child {
    return Builder(
      builder: (context) {
        Utiler.themeContext = context;
        return super.child;
      },
    );
  }

  /// Determines whether dependents should rebuild when theme changes.
  ///
  /// Triggers rebuild when the current theme instance changes.
  @override
  bool updateShouldNotify(ThemeManager<T> oldWidget) {
    return currentTheme != oldWidget.currentTheme;
  }
}
