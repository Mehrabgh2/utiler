import 'package:flutter/material.dart';
import 'package:utiler/src/values/locale/locale_json_scope.dart';
import 'package:utiler/src/values/locale/locale_scope.dart';
import 'package:utiler/src/values/locale/locale_values.dart';
import 'package:utiler/src/values/theme/theme_json_scope.dart';
import 'package:utiler/src/values/theme/theme_scope.dart';
import 'package:utiler/src/values/theme/theme_values.dart';

/// A high-level configuration wrapper that wires together theming and localization.
///
/// [ValuesScope] is the entry point for the `utiler` values system and decides:
/// - whether to use typed or JSON-based themes/locales
/// - which scopes to mount in the widget tree
/// - how locale/theme switching is configured
///
/// It supports four modes:
/// - typed themes + typed locales
/// - JSON themes + JSON locales
/// - themes only
/// - locales only
///
/// Example:
/// ```dart
/// ValuesScope<AppTheme, AppLocale>(
///   themes: themes,
///   locales: locales,
///   initialTheme: 'light',
///   initialLocale: 'en',
///   child: MyApp(),
/// )
/// ```
class ValuesScope<T extends ThemeValues, L extends LocaleValues>
    extends StatelessWidget {
  /// Creates a [ValuesScope].
  const ValuesScope({
    required this.child,
    this.locales,
    this.jsonLocales,
    this.initialLocale,
    this.themes,
    this.jsonThemes,
    this.initialTheme,
    this.themeChanged,
    this.localeChanged,
    super.key,
  });

  /// Typed locale definitions.
  final List<L>? locales;

  /// JSON-based locale definitions.
  final List<Map<String, dynamic>>? jsonLocales;

  /// Initial locale identifier.
  final String? initialLocale;

  /// Typed theme definitions.
  final List<T>? themes;

  /// JSON-based theme definitions.
  final List<Map<String, dynamic>>? jsonThemes;

  /// Initial theme identifier.
  final String? initialTheme;

  /// Callback triggered when theme changes.
  final Function(String)? themeChanged;

  /// Callback triggered when locale changes.
  final Function(String)? localeChanged;

  /// The widget below this scope.
  final Widget child;

  /// Internal flag indicating JSON locale mode.
  static bool isJsonLocale = false;

  /// Internal flag indicating JSON theme mode.
  static bool isJsonTheme = false;

  @override
  Widget build(BuildContext context) {
    if (jsonLocales != null && locales != null) {
      throw FlutterError('Use 1 way localization');
    }
    if (jsonThemes != null && themes != null) {
      throw FlutterError('Use 1 way theming');
    }

    isJsonLocale = jsonLocales != null;
    isJsonTheme = jsonThemes != null;

    if ((locales != null || jsonLocales != null) &&
        (themes != null || jsonThemes != null)) {
      Widget innerChild = isJsonTheme
          ? ThemeJsonScope(
              themes: jsonThemes!,
              initialTheme: initialTheme ?? themes!.first.id,
              themeChanged: themeChanged,
              child: child,
            )
          : ThemeScope<T>(
              themes: themes!,
              initialTheme: initialTheme ?? themes!.first.id,
              themeChanged: themeChanged,
              child: child,
            );

      return isJsonLocale
          ? LocaleJsonScope(
              locales: jsonLocales!,
              initialLocale: initialLocale ?? jsonLocales!.first.keys.first,
              localeChanged: localeChanged,
              child: innerChild,
            )
          : LocaleScope<L>(
              locales: locales!,
              initialLocale: initialLocale ?? locales!.first.id,
              localeChanged: localeChanged,
              child: innerChild,
            );
    } else if (locales != null) {
      return LocaleScope<L>(
        locales: locales!,
        initialLocale: initialLocale ?? locales!.first.id,
        localeChanged: localeChanged,
        child: child,
      );
    } else if (jsonLocales != null) {
      return LocaleJsonScope(
        locales: jsonLocales!,
        initialLocale: initialLocale ?? jsonLocales!.first.keys.first,
        localeChanged: localeChanged,
        child: child,
      );
    } else if (themes != null) {
      return ThemeScope<T>(
        themes: themes!,
        initialTheme: initialTheme ?? themes!.first.id,
        themeChanged: themeChanged,
        child: child,
      );
    } else if (jsonThemes != null) {
      return ThemeJsonScope(
        themes: jsonThemes!,
        initialTheme: initialTheme ?? themes!.first.id,
        themeChanged: themeChanged,
        child: child,
      );
    } else {
      return child;
    }
  }
}
