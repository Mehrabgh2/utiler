import 'package:utiler/src/values/animation/values_animation_type.dart';

/// In-memory theme and locale selection used across scope rebuilds.
///
/// Persists the latest user choice so [ThemeScope], [ThemeJsonScope],
/// [LocaleScope], and [LocaleJsonScope] do not fall back to stale
/// [initialTheme] / [initialLocale] when the widget tree is recreated.
///
/// Also stores app-wide default animation types set by [UtilerScope] or
/// individual scope widgets.
///
/// ## Animation priority
///
/// For both theme and locale switches, the effective animation is:
/// 1. Per-call `animation` parameter (e.g. on `changeAppTheme`)
/// 2. [themeAnimation] / [localeAnimation] on this class
/// 3. Instant change when both are `null`
///
/// Example:
/// ```dart
/// // UtilerScope sets defaults at startup:
/// ValuesRuntime.themeAnimation = ValuesAnimationType.circle;
///
/// // Per-call override wins:
/// context.changeAppTheme('dark', ValuesAnimationType.fade);
///
/// // Falls back to circle, not instant:
/// context.changeAppTheme('light');
/// ```
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
  /// Priority:
  /// 1. [animation] passed to the switch call
  /// 2. [themeAnimation] from [UtilerScope] or scope widgets
  /// 3. `null` (instant change) when both are `null`
  static ValuesAnimationType? resolveThemeAnimation({
    ValuesAnimationType? animation,
  }) {
    return animation ?? themeAnimation;
  }

  /// Resolves which locale animation to use.
  ///
  /// Priority:
  /// 1. [animation] passed to the switch call
  /// 2. [localeAnimation] from [UtilerScope] or scope widgets
  /// 3. `null` (instant change) when both are `null`
  static ValuesAnimationType? resolveLocaleAnimation({
    ValuesAnimationType? animation,
  }) {
    return animation ?? localeAnimation;
  }
}
