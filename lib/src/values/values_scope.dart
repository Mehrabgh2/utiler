import 'package:flutter/material.dart';

import 'locale/locale_scope.dart';
import 'locale/locale_values.dart';
import 'theme/theme_scope.dart';
import 'theme/theme_values.dart';

class ValuesScope<T extends ThemeValues, L extends LocaleValues>
    extends StatelessWidget {
  const ValuesScope({
    required this.child,
    required this.locales,
    required this.themes,
    this.initialLocale,
    this.initialTheme,
    this.themeChanged,
    this.localeChanged,
    this.themeTransitionInitRadius,
    this.themeTransitionDuration,
    this.themeTransitionOffset,
    super.key,
  });

  final List<L>? locales;
  final String? initialLocale;
  final List<T>? themes;
  final String? initialTheme;
  final int? themeTransitionInitRadius;
  final Duration? themeTransitionDuration;
  final Offset? themeTransitionOffset;
  final Function(String)? themeChanged;
  final Function(String)? localeChanged;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (locales != null && themes != null) {
      return LocaleScope<L>(
        locales: locales!,
        initialLocale: initialLocale ?? locales!.first.id,
        localeChanged: localeChanged,
        child: ThemeScope<T>(
          themes: themes!,
          initialTheme: initialTheme ?? themes!.first.id,
          themeChanged: themeChanged,
          transitionInitRadius: themeTransitionInitRadius ?? 60,
          transitionDuration:
              themeTransitionDuration ?? const Duration(milliseconds: 1250),
          transitionOffset: themeTransitionOffset ?? Offset.zero,
          child: child,
        ),
      );
    } else if (locales != null) {
      return LocaleScope<L>(
        locales: locales!,
        initialLocale: initialLocale ?? locales!.first.id,
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
    } else {
      return child;
    }
  }
}
