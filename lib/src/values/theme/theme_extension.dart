import 'package:flutter/material.dart';

import 'theme_manager.dart';
import 'theme_scope.dart';
import 'theme_values.dart';

extension ThemeExtension on BuildContext {
  ThemeValues? get appTheme {
    final inheritedWidget = ThemeManager.of<ThemeValues>(this);
    return inheritedWidget?.currentTheme;
  }

  void changeAppTheme(
    String id, [
    Offset? offset,
    int? themeTransitionInitRadius,
    Duration? themeTransitionDuration,
  ]) {
    ThemeScope.changeTheme(
      this,
      id,
      offset,
      themeTransitionInitRadius,
      themeTransitionDuration,
    );
  }

  String? get currentThemeId => appTheme?.id;

  List<ThemeValues>? get allThemes => ThemeScope.getAllThemes(this);
}
