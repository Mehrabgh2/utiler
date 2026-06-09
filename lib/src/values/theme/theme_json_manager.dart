import 'package:flutter/material.dart';
import 'package:utiler/src/utiler.dart';
import 'package:utiler/src/values/theme/theme_values.dart';

/// An [InheritedWidget] that provides JSON-based theme data to the widget tree.
///
/// [ThemeJsonManager] is responsible for:
/// - holding all available themes (as JSON maps)
/// - providing the currently active theme
/// - exposing a callback to switch themes at runtime
///
/// It is the foundation for dynamic JSON-driven theming.
///
/// Example:
/// ```dart
/// ThemeJsonManager(
///   themes: themes,
///   currentTheme: themes.first,
///   changeAppTheme: (id) {},
///   child: MyApp(),
/// )
/// ```
class ThemeJsonManager extends InheritedWidget {
  /// Creates a [ThemeJsonManager].
  const ThemeJsonManager({
    super.key,
    required super.child,
    required this.themes,
    required this.currentTheme,
    required this.changeAppTheme,
  });

  /// All available themes as JSON maps.
  final List<Map<String, dynamic>> themes;

  /// The currently active theme map.
  final Map<String, dynamic> currentTheme;

  /// Callback used to switch theme by identifier.
  final Function(String) changeAppTheme;

  /// Retrieves the nearest [ThemeJsonManager] from the widget tree.
  static ThemeJsonManager? of<T extends ThemeValues>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeJsonManager>();
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
  /// Triggers rebuild when the current theme map changes.
  @override
  bool updateShouldNotify(ThemeJsonManager oldWidget) {
    return currentTheme != oldWidget.currentTheme;
  }
}
