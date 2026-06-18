import 'package:flutter/widgets.dart';
import 'package:utiler/src/core/app_config.dart';
import 'package:utiler/src/core/feature_flags.dart';
import 'package:utiler/src/utiler_scope.dart';
import 'package:utiler/src/values/animation/values_animation_type.dart';
import 'package:utiler/src/values/locale/locale_extension.dart';
import 'package:utiler/src/values/theme/theme_extension.dart';
import 'package:utiler/src/values/values_runtime.dart';

/// Static entry point for all Utiler runtime APIs.
///
/// `Utiler` provides global access to theme, locale, feature flags,
/// app configuration, and animation preferences — all of which are
/// initialized by [UtilerScope] at startup.
///
/// All members are safe to call after [UtilerScope] is mounted. Calling
/// config-related members before mounting (or without providing the
/// corresponding parameter) will throw a [StateError].
///
/// ---
///
/// ### Theme
///
/// ```dart
/// Utiler.changeAppTheme('dark');
/// Utiler.changeAppTheme('light', ValuesAnimationType.fade);
///
/// await Utiler.changeThemeAnimation(ValuesAnimationType.fade);
/// await Utiler.changeThemeAnimation(null); // revert to instant
///
/// final current = Utiler.themeAnimationType; // ValuesAnimationType?
/// ```
///
/// ### Locale
///
/// ```dart
/// Utiler.changeAppLocale('en');
/// Utiler.changeAppLocale('fa', ValuesAnimationType.scale);
///
/// await Utiler.changeLocaleAnimation(ValuesAnimationType.scale);
/// await Utiler.changeLocaleAnimation(null); // revert to instant
///
/// final current = Utiler.localeAnimationType; // ValuesAnimationType?
/// ```
///
/// ### Feature Flags
///
/// ```dart
/// if (Utiler.flags.isEnabled('new_checkout')) {
///   // show new checkout flow
/// }
/// ```
///
/// ### App Configuration
///
/// ```dart
/// final url  = Utiler.config.active.require<String>('api_base_url');
/// final timeout = Utiler.config.active.get<int>('timeout_seconds', fallback: 10);
/// ```
abstract final class Utiler {
  // ── internal wiring (set by _UtilerScopeState) ─────────────────────────────

  /// @nodoc — wired by [_UtilerScopeState].
  static Future<void> Function(ValuesAnimationType?)? persistThemeAnimation;

  /// @nodoc — wired by [_UtilerScopeState].
  static Future<void> Function(ValuesAnimationType?)? persistLocaleAnimation;

  /// @nodoc — global context used by theme extensions.
  static BuildContext? themeContext;

  /// @nodoc — global context used by locale extensions.
  static BuildContext? localeContext;

  // ── feature flags ──────────────────────────────────────────────────────────

  static FeatureFlags _flags = FeatureFlags({});

  /// The active [FeatureFlags] registry.
  ///
  /// Always safe to call — returns an empty registry (all flags `false`)
  /// if no [featureFlags] map was provided to [UtilerScope].
  ///
  /// ```dart
  /// if (Utiler.flags.isEnabled('beta_chat')) { ... }
  /// ```
  static FeatureFlags get flags => _flags;

  /// @nodoc — called by [_UtilerScopeState].
  static void setFlags(Map<String, bool> flags) {
    _flags = FeatureFlags(flags);
  }

  // ── app config ─────────────────────────────────────────────────────────────

  static AppConfigStore? _config;

  /// The active [AppConfigStore].
  ///
  /// Throws [StateError] if accessed before [UtilerScope] is mounted or when
  /// no [appConfig] was provided to [UtilerScope].
  ///
  /// ```dart
  /// final url   = Utiler.config.active.require<String>('api_base_url');
  /// final isDev = Utiler.config.active.isDevelopment;
  /// ```
  static AppConfigStore get config {
    if (_config == null) {
      throw StateError(
        'Utiler.config: no AppConfigStore was provided. '
        'Pass an appConfig to UtilerScope.',
      );
    }
    return _config!;
  }

  /// @nodoc — called by [_UtilerScopeState].
  static void setConfig(AppConfigStore config) => _config = config;

  // ── theme ──────────────────────────────────────────────────────────────────

  /// Returns the currently active theme ID.
  ///
  /// Returns `null` if no theme is active.
  static String? get currentThemeId => themeContext?.currentThemeId;

  /// Changes the global theme at runtime.
  ///
  /// Animation priority: [animation] → default from [UtilerScope.themeAnimation] → instant.
  ///
  /// ```dart
  /// Utiler.changeAppTheme('dark');
  /// Utiler.changeAppTheme('light', ValuesAnimationType.fade);
  /// ```
  static void changeAppTheme(
    String newTheme, [
    ValuesAnimationType? animation,
  ]) {
    themeContext?.changeAppTheme(newTheme, animation);
  }

  /// Updates the default theme transition style and persists the preference.
  ///
  /// Pass `null` to clear the default and use instant transitions.
  ///
  /// ```dart
  /// await Utiler.changeThemeAnimation(ValuesAnimationType.fade);
  /// await Utiler.changeThemeAnimation(null); // instant
  /// ```
  static Future<void> changeThemeAnimation(
    ValuesAnimationType? animation,
  ) async {
    ValuesRuntime.themeAnimation = animation;
    await persistThemeAnimation?.call(animation);
  }

  /// Returns the active default theme transition style.
  static ValuesAnimationType? get themeAnimationType =>
      ValuesRuntime.themeAnimation;

  // ── locale ─────────────────────────────────────────────────────────────────

  /// Returns the current locale identifier (e.g. `"en"`, `"fa"`).
  ///
  /// Returns `null` if no locale is active.
  static String? get currentLocaleId => localeContext?.currentLocaleId;

  /// Changes the global locale at runtime.
  ///
  /// Animation priority: [animation] → default from [UtilerScope.localeAnimation] → instant.
  ///
  /// ```dart
  /// Utiler.changeAppLocale('en');
  /// Utiler.changeAppLocale('fa', ValuesAnimationType.scale);
  /// ```
  static void changeAppLocale(
    String newLocale, [
    ValuesAnimationType? animation,
  ]) {
    localeContext?.changeAppLocale(newLocale, animation);
  }

  /// Updates the default locale transition style and persists the preference.
  ///
  /// Pass `null` to clear the default and use instant transitions.
  ///
  /// ```dart
  /// await Utiler.changeLocaleAnimation(ValuesAnimationType.scale);
  /// await Utiler.changeLocaleAnimation(null); // instant
  /// ```
  static Future<void> changeLocaleAnimation(
    ValuesAnimationType? animation,
  ) async {
    ValuesRuntime.localeAnimation = animation;
    await persistLocaleAnimation?.call(animation);
  }

  /// Returns the active default locale transition style.
  static ValuesAnimationType? get localeAnimationType =>
      ValuesRuntime.localeAnimation;
}
