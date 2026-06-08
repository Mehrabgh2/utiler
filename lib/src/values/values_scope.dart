import 'package:flutter/material.dart';
import 'package:utiler/src/values/animation/values_animation_type.dart';
import 'package:utiler/src/values/combined_switching_area.dart';
import 'package:utiler/src/values/locale/locale_json_scope.dart';
import 'package:utiler/src/values/locale/locale_scope.dart';
import 'package:utiler/src/values/locale/locale_values.dart';
import 'package:utiler/src/values/theme/theme_json_scope.dart';
import 'package:utiler/src/values/theme/theme_scope.dart';
import 'package:utiler/src/values/theme/theme_values.dart';
import 'package:utiler/src/values/values_runtime.dart';

/// A high-level configuration wrapper that wires together theming and localization.
///
/// `ValuesScope` is the entry point for the `utiler` values system and decides:
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
/// ## Animation defaults
///
/// [themeAnimation] and [localeAnimation] set scope-level defaults stored in
/// [ValuesRuntime]. Per-call overrides on `changeAppTheme` / `changeAppLocale`
/// take priority; when both are `null`, switches are instant.
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
  /// Creates a `ValuesScope`.
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
    this.themeAnimation,
    this.themeAnimationDuration = const Duration(milliseconds: 500),
    this.localeAnimation,
    this.localeAnimationDuration = const Duration(milliseconds: 500),
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

  /// Default theme transition for this scope.
  ///
  /// Stored in [ValuesRuntime.themeAnimation]. `null` means instant unless
  /// a per-call [ValuesAnimationType] is passed or [UtilerScope] sets a default.
  final ValuesAnimationType? themeAnimation;

  /// Duration of animated theme reveal transitions.
  ///
  /// Passed to [ThemeScope] and [ThemeJsonScope] when themes are enabled.
  final Duration themeAnimationDuration;

  /// Default locale transition for this scope.
  ///
  /// Stored in [ValuesRuntime.localeAnimation]. `null` means instant unless
  /// a per-call [ValuesAnimationType] is passed or [UtilerScope] sets a default.
  final ValuesAnimationType? localeAnimation;

  /// Duration of animated locale reveal transitions.
  ///
  /// Passed to [LocaleScope] and [LocaleJsonScope] when locales are enabled.
  final Duration localeAnimationDuration;

  /// The widget below this scope.
  final Widget child;

  /// Whether the active configuration uses JSON locales.
  ///
  /// Set during [build]. Read by locale context extensions to route switch calls.
  static bool isJsonLocale = false;

  /// Whether the active configuration uses JSON themes.
  ///
  /// Set during [build]. Read by theme context extensions to route switch calls.
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
      final effectiveThemeId =
          ValuesRuntime.currentThemeId ??
          initialTheme ??
          (isJsonTheme ? jsonThemes!.first.keys.first : themes!.first.id);
      final effectiveLocaleId =
          ValuesRuntime.currentLocaleId ??
          initialLocale ??
          (isJsonLocale ? jsonLocales!.first.keys.first : locales!.first.id);

      final switchingChild = CombinedSwitchingArea(child: child);

      final localedChild = isJsonLocale
          ? LocaleJsonScope(
              locales: jsonLocales!,
              initialLocale: effectiveLocaleId,
              localeChanged: localeChanged,
              animation: localeAnimation,
              animationDuration: localeAnimationDuration,
              useLocaleSwitchingArea: false,
              child: switchingChild,
            )
          : LocaleScope<L>(
              locales: locales!,
              initialLocale: effectiveLocaleId,
              localeChanged: localeChanged,
              animation: localeAnimation,
              animationDuration: localeAnimationDuration,
              useLocaleSwitchingArea: false,
              child: switchingChild,
            );

      return isJsonTheme
          ? ThemeJsonScope(
              themes: jsonThemes!,
              initialTheme: effectiveThemeId,
              themeChanged: themeChanged,
              animation: themeAnimation,
              animationDuration: themeAnimationDuration,
              useThemeSwitchingArea: false,
              child: localedChild,
            )
          : ThemeScope<T>(
              themes: themes!,
              initialTheme: effectiveThemeId,
              themeChanged: themeChanged,
              animation: themeAnimation,
              animationDuration: themeAnimationDuration,
              useThemeSwitchingArea: false,
              child: localedChild,
            );
    } else if (locales != null) {
      return LocaleScope<L>(
        locales: locales!,
        initialLocale: initialLocale ?? locales!.first.id,
        localeChanged: localeChanged,
        animation: localeAnimation,
        animationDuration: localeAnimationDuration,
        child: child,
      );
    } else if (jsonLocales != null) {
      return LocaleJsonScope(
        locales: jsonLocales!,
        initialLocale: initialLocale ?? jsonLocales!.first.keys.first,
        localeChanged: localeChanged,
        animation: localeAnimation,
        animationDuration: localeAnimationDuration,
        child: child,
      );
    } else if (themes != null) {
      return ThemeScope<T>(
        themes: themes!,
        initialTheme: initialTheme ?? themes!.first.id,
        themeChanged: themeChanged,
        animation: themeAnimation,
        animationDuration: themeAnimationDuration,
        child: child,
      );
    } else if (jsonThemes != null) {
      return ThemeJsonScope(
        themes: jsonThemes!,
        initialTheme: initialTheme ?? jsonThemes!.first.keys.first,
        themeChanged: themeChanged,
        animation: themeAnimation,
        animationDuration: themeAnimationDuration,
        child: child,
      );
    } else {
      return child;
    }
  }
}
