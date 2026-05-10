import 'package:flutter/material.dart';
import 'package:utiler/utiler.dart';

import 'theme_json_manager.dart';
import 'theme_json_scope.dart';
import 'theme_manager.dart';
import 'theme_scope.dart';

extension ThemeExtension on BuildContext {
  ThemeValues? get appTheme {
    final inheritedWidget = ThemeManager.of<ThemeValues>(this);
    if (inheritedWidget == null) return null;
    return inheritedWidget.currentTheme;
  }

  Map<String, dynamic>? get appJsonTheme {
    final inheritedWidget = ThemeJsonManager.of(this);
    if (inheritedWidget == null) return null;
    return inheritedWidget.currentTheme.values.first as Map<String, dynamic>;
  }

  void changeAppTheme(String id) {
    if (ValuesScope.isJsonTheme) {
      ThemeJsonScope.changeTheme(this, id);
    } else {
      ThemeScope.changeTheme(this, id);
    }
  }

  String? get currentThemeId {
    if (ValuesScope.isJsonTheme) {
      final inheritedWidget = ThemeJsonManager.of(this);
      return inheritedWidget?.currentTheme.keys.first;
    } else {
      return appTheme?.id;
    }
  }

  List<ThemeValues>? get allThemes => ThemeScope.getAllThemes(this);

  List<Map<String, dynamic>>? get allJsonThemes =>
      ThemeJsonScope.getAllThemes(this);
}

extension ThemeStringExtension on String {
  Color get cr {
    if (UtilerScope.themeContext == null) {
      return Colors.white;
    }
    final inheritedWidget = ThemeJsonManager.of(UtilerScope.themeContext!);
    if (inheritedWidget == null) return Colors.white;
    Map<String, dynamic> theme =
        inheritedWidget.currentTheme.values.first as Map<String, dynamic>;
    return _resolveJsonPath(theme, this) ?? Colors.white;
  }

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
    return _getColor(current);
  }
}

Color _getColor(String color) {
  color = color.replaceAll('#', '');
  if (color.length == 6) {
    color = 'FF$color';
  }
  return Color(int.parse(color, radix: 16));
}
