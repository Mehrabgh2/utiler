import 'package:flutter/material.dart';
import 'package:utiler/src/utiler_scope.dart';
import 'package:utiler/src/values/animation/values_animation_type.dart';
import 'package:utiler/src/values/theme/theme_json_manager.dart';
import 'package:utiler/src/values/theme/theme_json_scope.dart';
import 'package:utiler/src/values/theme/theme_manager.dart';
import 'package:utiler/src/values/theme/theme_scope.dart';
import 'package:utiler/src/values/theme/theme_values.dart';
import 'package:utiler/src/values/values_scope.dart';

/// Extensions on [BuildContext] for accessing and switching app themes.
///
/// Supports both:
/// - strongly typed theme models ([ThemeValues])
/// - JSON-based theme maps
///
/// Provides unified API for theme access and switching.
///
/// Example:
/// ```dart
/// final theme = context.appTheme;
/// context.changeAppTheme('dark');
/// ```
extension ThemeExtension on BuildContext {
  /// Returns the current typed theme if available.
  ///
  /// Returns `null` if theme system is not initialized.
  ThemeValues? get appTheme {
    final inheritedWidget = ThemeManager.of<ThemeValues>(this);
    if (inheritedWidget == null) return null;
    return inheritedWidget.currentTheme;
  }

  /// Returns the current JSON-based theme map.
  Map<String, dynamic>? get appJsonTheme {
    final inheritedWidget = ThemeJsonManager.of(this);
    if (inheritedWidget == null) return null;
    return inheritedWidget.currentTheme.values.first as Map<String, dynamic>;
  }

  /// Changes the current app theme by its identifier with an animated reveal.
  ///
  /// Automatically selects JSON or typed theme system based on configuration.
  /// The animation origin is the last tap position, or the screen center
  /// when the theme is changed programmatically.
  ///
  /// Animation priority: [animation] → [UtilerScope.themeAnimation] → instant.
  void changeAppTheme(String id, [ValuesAnimationType? animation]) {
    if (ValuesScope.isJsonTheme) {
      ThemeJsonScope.changeTheme(this, id, animation);
    } else {
      ThemeScope.changeTheme(this, id, animation);
    }
  }

  /// Returns the currently active theme ID.
  ///
  /// Returns `null` if no theme is active.
  String? get currentThemeId {
    if (ValuesScope.isJsonTheme) {
      final inheritedWidget = ThemeJsonManager.of(this);
      return inheritedWidget?.currentTheme.keys.first;
    } else {
      return appTheme?.id;
    }
  }

  /// Returns all available typed themes.
  List<ThemeValues>? get allThemes => ThemeScope.getAllThemes(this);

  /// Returns all available JSON-based themes.
  List<Map<String, dynamic>>? get allJsonThemes =>
      ThemeJsonScope.getAllThemes(this);
}

/// Extension on [String] to resolve theme colors from JSON theme maps.
///
/// Supports dot notation keys like:
/// ```dart
/// "colors.primary".cr
/// ```
extension ThemeStringExtension on String {
  /// Resolves a color from the current JSON theme context.
  ///
  /// Returns [Colors.white] as fallback if resolution fails.
  Color get cr {
    if (UtilerScope.themeContext == null) {
      return Colors.white;
    }

    final inheritedWidget = ThemeJsonManager.of(UtilerScope.themeContext!);

    if (inheritedWidget == null) return Colors.white;

    final Map<String, dynamic> theme =
        inheritedWidget.currentTheme.values.first as Map<String, dynamic>;

    return _resolveJsonPath(theme, this) ?? Colors.white;
  }

  /// Resolves a dot-separated path inside a nested JSON map.
  Color? _resolveJsonPath(Map<String, dynamic> json, String path) {
    final parts = path.split('.');
    dynamic current = json;

    for (final part in parts) {
      if (current is Map<String, dynamic>) {
        if (!current.containsKey(part)) return null;
        current = current[part];
      } else {
        return null;
      }
    }

    return _getColor(current?.toString());
  }
}

/// Converts a hex color string into a [Color].
///
/// Supports formats:
/// - `#RRGGBB`
/// - `RRGGBB`
/// - `AARRGGBB`
///
/// Returns `null` when [color] is not a valid hex string.
Color? _getColor(String? color) {
  if (color == null || color.isEmpty) {
    return null;
  }

  color = color.replaceAll('#', '');

  if (color.length == 6) {
    color = 'FF$color';
  }

  if (color.length != 8) {
    return null;
  }

  try {
    return Color(int.parse(color, radix: 16));
  } catch (_) {
    return null;
  }
}
