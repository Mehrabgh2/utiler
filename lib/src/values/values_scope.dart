import 'package:flutter/material.dart';

import 'locale/locale_json_scope.dart';
import 'locale/locale_scope.dart';
import 'locale/locale_values.dart';
import 'theme/theme_json_scope.dart';
import 'theme/theme_scope.dart';
import 'theme/theme_values.dart';

class ValuesScope<T extends ThemeValues, L extends LocaleValues>
    extends StatelessWidget {
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
    this.themeTransitionInitRadius,
    this.themeTransitionDuration,
    this.themeTransitionOffset,
    super.key,
  });

  static bool isJsonLocale = false;
  static bool isJsonTheme = false;
  final List<L>? locales;
  final List<Map<String, dynamic>>? jsonLocales;
  final String? initialLocale;
  final List<T>? themes;
  final List<Map<String, dynamic>>? jsonThemes;
  final String? initialTheme;
  final int? themeTransitionInitRadius;
  final Duration? themeTransitionDuration;
  final Offset? themeTransitionOffset;
  final Function(String)? themeChanged;
  final Function(String)? localeChanged;
  final Widget child;

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
              transitionInitRadius: themeTransitionInitRadius ?? 60,
              transitionDuration:
                  themeTransitionDuration ?? const Duration(milliseconds: 1250),
              transitionOffset: themeTransitionOffset ?? Offset.zero,
              child: child,
            )
          : ThemeScope<T>(
              themes: themes!,
              initialTheme: initialTheme ?? themes!.first.id,
              themeChanged: themeChanged,
              transitionInitRadius: themeTransitionInitRadius ?? 60,
              transitionDuration:
                  themeTransitionDuration ?? const Duration(milliseconds: 1250),
              transitionOffset: themeTransitionOffset ?? Offset.zero,
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
        transitionInitRadius: themeTransitionInitRadius ?? 60,
        transitionDuration:
            themeTransitionDuration ?? const Duration(milliseconds: 1250),
        transitionOffset: themeTransitionOffset ?? Offset.zero,
        child: child,
      );
    } else if (jsonThemes != null) {
      return ThemeJsonScope(
        themes: jsonThemes!,
        initialTheme: initialTheme ?? themes!.first.id,
        themeChanged: themeChanged,
        transitionInitRadius: themeTransitionInitRadius ?? 60,
        transitionDuration:
            themeTransitionDuration ?? const Duration(milliseconds: 1250),
        transitionOffset: themeTransitionOffset ?? Offset.zero,
        child: child,
      );
    } else {
      return child;
    }
  }
}
