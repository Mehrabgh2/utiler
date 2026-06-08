import 'package:utiler/src/values/animation/values_animation_type.dart';

/// In-memory theme and locale selection used across scope rebuilds.
///
/// Persists the latest user choice so [ThemeScope], [ThemeJsonScope],
/// [LocaleScope], and [LocaleJsonScope] do not fall back to stale
/// [initialTheme] / [initialLocale] when the widget tree is recreated.
abstract final class ValuesRuntime {
  /// Last selected theme id in this app session.
  static String? currentThemeId;

  /// Last selected locale id in this app session.
  static String? currentLocaleId;

  /// App-wide default theme transition from [UtilerScope].
  ///
  /// `null` means theme changes are instant unless a call passes [animation].
  static ValuesAnimationType? themeAnimation;

  /// App-wide default locale transition from [UtilerScope].
  ///
  /// `null` means locale changes are instant unless a call passes [animation].
  static ValuesAnimationType? localeAnimation;

  /// Resolves which theme animation to use.
  ///
  /// Priority: call [animation] → [themeAnimation] → no animation (`null`).
  static ValuesAnimationType? resolveThemeAnimation({
    ValuesAnimationType? animation,
  }) {
    return animation ?? themeAnimation;
  }

  /// Resolves which locale animation to use.
  ///
  /// Priority: call [animation] → [localeAnimation] → no animation (`null`).
  static ValuesAnimationType? resolveLocaleAnimation({
    ValuesAnimationType? animation,
  }) {
    return animation ?? localeAnimation;
  }
}
