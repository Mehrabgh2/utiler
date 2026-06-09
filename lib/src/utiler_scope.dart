import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:utiler/src/core/app_config.dart';
import 'package:utiler/src/core/feature_flags.dart';
import 'package:utiler/src/core/internet_connectivity.dart';
import 'package:utiler/src/core/lifecycle_handler.dart';
import 'package:utiler/src/database/database.dart';
import 'package:utiler/src/database/secure_database_data.dart';
import 'package:utiler/src/logger/logger.dart';
import 'package:utiler/src/logger/logger_console.dart';
import 'package:utiler/src/values/animation/values_animation_type.dart';
import 'package:utiler/src/values/locale/locale_extension.dart';
import 'package:utiler/src/values/locale/locale_values.dart';
import 'package:utiler/src/values/theme/theme_extension.dart';
import 'package:utiler/src/values/theme/theme_values.dart';
import 'package:utiler/src/values/values_runtime.dart';
import 'package:utiler/src/values/values_scope.dart';

/// The root configuration widget for the Utiler utility package.
///
/// `UtilerScope` is responsible for initializing and wiring together
/// all core utilities provided by the package, including:
///
/// - 🔄 App lifecycle tracking (`LifecycleHandler`)
/// - 🪵 Logging system (`Logger`, `LoggerConsole`)
/// - 🌍 Localization system (JSON-based or typed `LocaleScope`)
/// - 🎨 Theme system (JSON-based or typed `ThemeScope`)
/// - 🚩 Feature flags (`FeatureFlags`)
/// - 🌐 Internet connectivity monitoring (`InternetConnectivity`)
/// - ⚙️ Environment-aware app configuration (`AppConfigStore`)
/// - 💾 Secure persistence for theme & locale selection
///
/// It acts as a single entry point that wraps your entire app
/// and conditionally builds feature systems based on provided configuration.
///
/// ---
///
/// ### Features
///
/// #### Logging
/// - Enable/disable logs via `enabledLog`
/// - Export logs to file via `exportLog`
/// - Show in-app log console via `showLogWidget`
///
/// #### Localization
/// Supports two modes:
/// - Typed localization (`LocaleValues`)
/// - JSON-based localization (`Map<String, dynamic>`)
///
/// You can also load JSON assets directly using `jsonLocalesAddress`.
///
/// ---
///
/// #### JSON helpers (`.cr` and `.tr`)
///
/// **Recursive JSON value access (color / nested maps)** via `.cr`:
///
/// ```dart
/// // JSON (example)
/// {
///   'light': {
///     'home': {'background': 'FF1565C0'},
///     'profile': {'background': 'FF1565C0'},
///   },
/// }
///
/// // Usage
/// 'home.background'.cr
/// ```
///
/// **Localized string access** via `.tr` (dot notation):
///
/// ```dart
/// // JSON (example)
/// {
///   'en': {
///     'home': {'appbar': 'Home Screen'},
///     'profile': {'appbar': 'Profile Screen'},
///   },
/// }
///
/// // Usage
/// 'home.appbar'.tr
/// ```
///
/// #### Theming
/// Supports two modes:
/// - Typed theme system (`ThemeValues`)
/// - JSON-based theme system (`Map<String, dynamic>`)
///
/// You can also load JSON assets directly using `jsonThemesAddress`.
///
/// Theme and Locale switching is animated automatically when using
/// (`BuildContext.changeAppTheme`) or (`UtilerScope.changeAppTheme`).
///
/// #### Animation defaults
///
/// Set default transition styles via [themeAnimation] and [localeAnimation].
/// Durations are controlled by [themeAnimationDuration] and
/// [localeAnimationDuration]. User preferences are persisted and can be
/// updated at runtime with [changeThemeAnimation] and
/// [changeLocaleAnimation].
///
/// @example
/// ```dart
/// UtilerScope(
///   themeAnimation: ValuesAnimationType.fade,
///   themeAnimationDuration: Duration(milliseconds: 300),
///   localeAnimation: ValuesAnimationType.scale,
///   localeAnimationDuration: Duration(milliseconds: 400),
///   child: MyApp(),
/// );
/// ```
///
/// #### Feature Flags
///
/// Register boolean feature flags at startup and query them anywhere in the
/// app via [UtilerScope.flags]. Missing keys resolve to `false`.
///
/// @example
/// ```dart
/// UtilerScope(
///   featureFlags: {
///     'new_checkout': true,
///     'beta_chat': false,
///   },
///   child: MyApp(),
/// );
///
/// // Later, anywhere in the app:
/// if (UtilerScope.flags.isEnabled('new_checkout')) {
///   // show new checkout flow
/// }
/// ```
///
/// #### Internet Connectivity
///
/// Monitor network status changes reactively or check it on demand.
/// Set [monitorConnectivity] to `true` to activate monitoring and receive
/// status updates via [onConnectivityChange]. Use [onConnectivityChange] to
/// react to [InternetStatus] updates (connected, vpn, disconnected).
///
/// @example
/// ```dart
/// UtilerScope(
///   monitorConnectivity: true,
///   onConnectivityChange: (status) {
///     if (status == InternetStatus.disconnected) {
///       showOfflineBanner();
///     }
///   },
///   child: MyApp(),
/// );
///
/// // One-time check anywhere in the app:
/// final status = await InternetConnectivity.currentStatus;
/// final hasInternet = await InternetConnectivity.hasInternetAccess();
/// ```
///
/// #### App Configuration
///
/// Provide an [AppConfigStore] at startup to make environment-specific
/// settings available globally via [UtilerScope.config]. The active config
/// is resolved from the store's [AppConfigStore.active] environment.
///
/// @example
/// ```dart
/// UtilerScope(
///   appConfig: AppConfigStore(
///     active: AppEnvironment.production,
///     configs: {
///       AppEnvironment.development: AppConfig.fromMap(
///         environment: AppEnvironment.development,
///         data: {'api_base_url': 'http://localhost:8080'},
///       ),
///       AppEnvironment.production: AppConfig.fromMap(
///         environment: AppEnvironment.production,
///         data: {'api_base_url': 'https://api.example.com'},
///       ),
///     },
///   ),
///   child: MyApp(),
/// );
///
/// // Later, anywhere in the app:
/// final url = UtilerScope.config.active.require<String>('api_base_url');
/// final timeout = UtilerScope.config.active.get<int>('timeout_seconds', fallback: 10);
/// ```
///
/// #### Persistence
/// Automatically saves:
/// - Selected theme
/// - Selected locale
///
/// using secure storage via `Database`
///
/// ---
///
/// ### Usage
///
/// ```dart
/// UtilerScope(
///   enabledLog: true,
///   exportLog: false,
///   showLogWidget: false,
///   themes: AppThemes.themes,
///   locales: AppLocales.locales,
///   featureFlags: {
///     'new_checkout': true,
///     'beta_chat': false,
///   },
///   monitorConnectivity: true,
///   onConnectivityChange: (status) => print(status),
///   appConfig: AppConfigStore(
///     active: AppEnvironment.production,
///     configs: { /* ... */ },
///   ),
///   child: MyApp(),
/// );
/// ```
///
/// or JSON-based:
///
/// ```dart
/// UtilerScope(
///   jsonThemesAddress: ['assets/themes/dark.json'],
///   jsonLocalesAddress: ['assets/locales/en.json'],
///   child: MyApp(),
/// );
/// ```
///
/// ---
///
/// ### Notes
///
/// - Only one of `themes` or `jsonThemes` should be used.
/// - Only one of `locales` or `jsonLocales` should be used.
/// - Mixing typed and JSON modes will throw an error.
/// - This widget must be placed above `MaterialApp` or equivalent.
///
class UtilerScope extends StatefulWidget {
  /// Creates a [UtilerScope].
  const UtilerScope({
    required this.child,
    this.lifecycleListener,
    this.enabledLog = true,
    this.exportLog = false,
    this.logExportDirectory,
    this.showLogWidget = false,
    this.themes,
    this.jsonThemes,
    this.jsonThemesAddress,
    this.locales,
    this.jsonLocales,
    this.jsonLocalesAddress,
    this.themeAnimation,
    this.themeAnimationDuration = const Duration(milliseconds: 500),
    this.localeAnimation,
    this.localeAnimationDuration = const Duration(milliseconds: 500),
    this.featureFlags,
    this.onConnectivityChange,
    this.appConfig,
    super.key,
  });

  /// Root widget of the application.
  final Widget child;

  /// Optional lifecycle callback for app state changes.
  final LifecycleListener? lifecycleListener;

  /// Enables or disables logging globally.
  final bool enabledLog;

  /// Whether logs should be exported to file.
  final bool exportLog;

  /// Directory for log export when [exportLog] is `true`.
  ///
  /// Provide an absolute path from your app (e.g. from `path_provider` in the
  /// host project). Ignored on web where file export is unavailable.
  final String? logExportDirectory;

  /// Whether to show an in-app log console widget.
  final bool showLogWidget;

  /// Typed theme definitions.
  final List<ThemeValues>? themes;

  /// JSON-based theme definitions.
  final List<Map<String, dynamic>>? jsonThemes;

  /// Asset paths for JSON theme files.
  final List<String>? jsonThemesAddress;

  /// Typed locale definitions.
  final List<LocaleValues>? locales;

  /// JSON-based locale definitions.
  final List<Map<String, dynamic>>? jsonLocales;

  /// Asset paths for JSON locale files.
  final List<String>? jsonLocalesAddress;

  /// Default theme transition applied when [changeAppTheme] is called without
  /// an explicit animation. `null` means instant unless overridden per call.
  final ValuesAnimationType? themeAnimation;

  /// Duration of animated theme reveal transitions.
  final Duration themeAnimationDuration;

  /// Default locale transition applied when [changeAppLocale] is called without
  /// an explicit animation. `null` means instant unless overridden per call.
  final ValuesAnimationType? localeAnimation;

  /// Duration of animated locale reveal transitions.
  final Duration localeAnimationDuration;

  /// Initial feature-flag definitions for the app.
  ///
  /// Pass a map of flag names to their boolean state. Missing keys resolve
  /// to `false` when queried via [UtilerScope.flags].
  ///
  /// @example
  /// ```dart
  /// UtilerScope(
  ///   featureFlags: {
  ///     'new_checkout': true,
  ///     'dark_mode_v2': false,
  ///   },
  ///   child: MyApp(),
  /// );
  /// ```
  final Map<String, bool>? featureFlags;

  /// Callback invoked whenever the [InternetStatus] changes.
  ///
  /// Only called when [monitorConnectivity] is `true`.
  ///
  /// @example
  /// ```dart
  /// UtilerScope(
  ///   monitorConnectivity: true,
  ///   onConnectivityChange: (status) {
  ///     if (status == InternetStatus.disconnected) {
  ///       showOfflineBanner();
  ///     }
  ///   },
  ///   child: MyApp(),
  /// );
  /// ```
  final void Function(InternetStatus status)? onConnectivityChange;

  /// Environment-aware application configuration store.
  ///
  /// When provided, the store is made available globally via
  /// [UtilerScope.config]. Access the active environment's settings through
  /// [AppConfigStore.active].
  ///
  /// Throws [StateError] at access time if no config is registered for the
  /// active environment (propagated from [AppConfigStore.active]).
  ///
  /// @example
  /// ```dart
  /// UtilerScope(
  ///   appConfig: AppConfigStore(
  ///     active: AppEnvironment.production,
  ///     configs: {
  ///       AppEnvironment.development: AppConfig.fromMap(
  ///         environment: AppEnvironment.development,
  ///         data: {'api_base_url': 'http://localhost:8080'},
  ///       ),
  ///       AppEnvironment.production: AppConfig.fromMap(
  ///         environment: AppEnvironment.production,
  ///         data: {'api_base_url': 'https://api.example.com'},
  ///       ),
  ///     },
  ///   ),
  ///   child: MyApp(),
  /// );
  ///
  /// // Later, anywhere in the app:
  /// final url = UtilerScope.config.active.require<String>('api_base_url');
  /// ```
  final AppConfigStore? appConfig;

  static Future<void> Function(ValuesAnimationType?)? _persistThemeAnimation;
  static Future<void> Function(ValuesAnimationType?)? _persistLocaleAnimation;

  /// Global context used by theme extensions.
  static BuildContext? themeContext;

  /// Global context used by locale extensions.
  static BuildContext? localeContext;

  /// The active [FeatureFlags] registry.
  ///
  /// Always safe to call — returns an empty registry (all flags `false`)
  /// if no [featureFlags] map was provided to [UtilerScope].
  ///
  /// @example
  /// ```dart
  /// if (UtilerScope.flags.isEnabled('new_checkout')) {
  ///   // show new checkout flow
  /// }
  /// ```
  static FeatureFlags get flags => _flags;
  static FeatureFlags _flags = FeatureFlags({});

  /// The active [AppConfigStore].
  ///
  /// Throws [StateError] if accessed before [UtilerScope] is mounted or when
  /// no [appConfig] was provided.
  ///
  /// @example
  /// ```dart
  /// final url = UtilerScope.config.active.require<String>('api_base_url');
  /// final isDev = UtilerScope.config.active.isDevelopment;
  /// ```
  static AppConfigStore get config {
    if (_config == null) {
      throw StateError(
        'UtilerScope.config: no AppConfigStore was provided. '
        'Pass an appConfig to UtilerScope.',
      );
    }
    return _config!;
  }

  static AppConfigStore? _config;

  /// Changes the global theme at runtime.
  ///
  /// Animation priority: [animation] → [themeAnimation] → instant.
  ///
  /// @example
  /// ```dart
  /// // Uses the default from UtilerScope.themeAnimation
  /// UtilerScope.changeAppTheme('dark');
  ///
  /// // Overrides with a one-off animation
  /// UtilerScope.changeAppTheme('light', ValuesAnimationType.fade);
  /// ```
  static void changeAppTheme(
    String newTheme, [
    ValuesAnimationType? animation,
  ]) {
    themeContext?.changeAppTheme(newTheme, animation);
  }

  /// Changes the global locale at runtime.
  ///
  /// Animation priority: [animation] → [localeAnimation] → instant.
  ///
  /// @example
  /// ```dart
  /// // Uses the default from UtilerScope.localeAnimation
  /// UtilerScope.changeAppLocale('en');
  ///
  /// // Overrides with a one-off animation
  /// UtilerScope.changeAppLocale('fa', ValuesAnimationType.scale);
  /// ```
  static void changeAppLocale(
    String newLocale, [
    ValuesAnimationType? animation,
  ]) {
    localeContext?.changeAppLocale(newLocale, animation);
  }

  /// Updates the default theme transition style and persists the preference.
  ///
  /// Pass `null` to clear the default and use instant transitions.
  ///
  /// @example
  /// ```dart
  /// await UtilerScope.changeThemeAnimation(ValuesAnimationType.fade);
  /// await UtilerScope.changeThemeAnimation(null); // instant
  /// ```
  static Future<void> changeThemeAnimation(
    ValuesAnimationType? animation,
  ) async {
    ValuesRuntime.themeAnimation = animation;
    await _persistThemeAnimation?.call(animation);
  }

  /// Updates the default locale transition style and persists the preference.
  ///
  /// Pass `null` to clear the default and use instant transitions.
  ///
  /// @example
  /// ```dart
  /// await UtilerScope.changeLocaleAnimation(ValuesAnimationType.scale);
  /// await UtilerScope.changeLocaleAnimation(null); // instant
  /// ```
  static Future<void> changeLocaleAnimation(
    ValuesAnimationType? animation,
  ) async {
    ValuesRuntime.localeAnimation = animation;
    await _persistLocaleAnimation?.call(animation);
  }

  /// Returns the active default theme transition style.
  static ValuesAnimationType? get themeAnimationType =>
      ValuesRuntime.themeAnimation;

  /// Returns the active default locale transition style.
  static ValuesAnimationType? get localeAnimationType =>
      ValuesRuntime.localeAnimation;

  @override
  State<UtilerScope> createState() => _UtilerScopeState();
}

class _UtilerScopeState extends State<UtilerScope> {
  late final Future<Widget> _initializedChild;
  StreamSubscription<InternetStatus>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _initLogging();
    _initFeatureFlags();
    _initAppConfig();
    _initConnectivity();
    UtilerScope._persistThemeAnimation = _persistThemeAnimation;
    UtilerScope._persistLocaleAnimation = _persistLocaleAnimation;
    ValuesRuntime.themeAnimation = widget.themeAnimation;
    ValuesRuntime.localeAnimation = widget.localeAnimation;
    _initializedChild = _buildChild();
  }

  @override
  void dispose() {
    UtilerScope._persistThemeAnimation = null;
    UtilerScope._persistLocaleAnimation = null;
    if (widget.onConnectivityChange != null) {
      unawaited(_connectivitySubscription?.cancel());
      unawaited(InternetConnectivity.dispose());
    }
    super.dispose();
  }

  void _initLogging() {
    Logger.enabled = widget.enabledLog;
    Logger.export = widget.exportLog;
    Logger.exportDirectory = widget.logExportDirectory;
    Logger.showWidget = widget.showLogWidget;
  }

  /// Initialises the global [FeatureFlags] registry from [widget.featureFlags].
  void _initFeatureFlags() {
    if (widget.featureFlags != null) {
      UtilerScope._flags = FeatureFlags(widget.featureFlags!);
    }
  }

  /// Registers the [AppConfigStore] from [widget.appConfig] globally.
  void _initAppConfig() {
    if (widget.appConfig != null) {
      UtilerScope._config = widget.appConfig;
    }
  }

  /// Subscribes to [InternetConnectivity.onStatusChange] when
  /// [widget.monitorConnectivity] is `true`.
  void _initConnectivity() {
    if (widget.onConnectivityChange == null) return;
    _connectivitySubscription = InternetConnectivity.onStatusChange
        .asBroadcastStream()
        .listen((status) => widget.onConnectivityChange?.call(status));
  }

  /// Internal database instance for persistence.
  final Database _database = Database();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializedChild,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data!;
        }
        return const SizedBox();
      },
    );
  }

  /// Builds the final widget tree after async initialization.
  Future<Widget> _buildChild() async {
    Widget finalChild = widget.child;

    if (widget.lifecycleListener != null) {
      finalChild = LifecycleHandler(
        lifecycleListener: widget.lifecycleListener!,
        child: finalChild,
      );
    }

    if (widget.showLogWidget) {
      finalChild = LoggerConsole(child: finalChild);
    }

    if (widget.locales == null &&
        widget.jsonLocales == null &&
        widget.themes == null &&
        widget.jsonThemes == null &&
        widget.jsonLocalesAddress == null &&
        widget.jsonThemesAddress == null) {
      return finalChild;
    }

    final savedTheme = await _getSavedTheme();
    final savedLocale = await _getSavedLocale();
    final savedThemeAnimation = await _getSavedThemeAnimation();
    final savedLocaleAnimation = await _getSavedLocaleAnimation();

    if (savedTheme != null) {
      ValuesRuntime.currentThemeId = savedTheme;
    }
    if (savedLocale != null) {
      ValuesRuntime.currentLocaleId = savedLocale;
    }
    if (savedThemeAnimation != null) {
      ValuesRuntime.themeAnimation = savedThemeAnimation;
    }
    if (savedLocaleAnimation != null) {
      ValuesRuntime.localeAnimation = savedLocaleAnimation;
    }

    finalChild = ValuesScope(
      locales: widget.locales,
      themes: widget.themes,
      jsonLocales:
          widget.jsonLocalesAddress != null &&
              widget.jsonLocalesAddress!.isNotEmpty
          ? await Future.wait<Map<String, dynamic>>(
              widget.jsonLocalesAddress!.map(_readAssets),
            )
          : widget.jsonLocales,
      jsonThemes:
          widget.jsonThemesAddress != null &&
              widget.jsonThemesAddress!.isNotEmpty
          ? await Future.wait<Map<String, dynamic>>(
              widget.jsonThemesAddress!.map(_readAssets),
            )
          : widget.jsonThemes,
      initialLocale: savedLocale,
      initialTheme: savedTheme,
      themeChanged: _themeChanged,
      localeChanged: _localeChanged,
      themeAnimation: ValuesRuntime.themeAnimation,
      themeAnimationDuration: widget.themeAnimationDuration,
      localeAnimation: ValuesRuntime.localeAnimation,
      localeAnimationDuration: widget.localeAnimationDuration,
      child: finalChild,
    );

    return finalChild;
  }

  /// Persists theme selection to secure storage.
  Future<void> _themeChanged(String newTheme) async {
    ValuesRuntime.currentThemeId = newTheme;
    await _database.putSecure(
      SecureDatabaseData(key: 'theme', value: newTheme),
    );
  }

  /// Persists locale selection to secure storage.
  Future<void> _localeChanged(String newLocale) async {
    ValuesRuntime.currentLocaleId = newLocale;
    await _database.putSecure(
      SecureDatabaseData(key: 'locale', value: newLocale),
    );
  }

  /// Retrieves the last saved theme.
  Future<String?> _getSavedTheme() async {
    return (await _database.getSecure('theme'))?.value;
  }

  /// Retrieves the last saved locale.
  Future<String?> _getSavedLocale() async {
    return (await _database.getSecure('locale'))?.value;
  }

  Future<ValuesAnimationType?> _getSavedThemeAnimation() async {
    final value = (await _database.getSecure('theme_animation'))?.value;
    if (value == null) {
      return null;
    }
    return ValuesAnimationTypeX.parse(value, fallback: widget.themeAnimation);
  }

  Future<ValuesAnimationType?> _getSavedLocaleAnimation() async {
    final value = (await _database.getSecure('locale_animation'))?.value;
    if (value == null) {
      return null;
    }
    return ValuesAnimationTypeX.parse(value, fallback: widget.localeAnimation);
  }

  Future<void> _persistThemeAnimation(ValuesAnimationType? animation) async {
    ValuesRuntime.themeAnimation = animation;
    if (animation == null) {
      await _database.deleteSecure('theme_animation');
      return;
    }
    await _database.putSecure(
      SecureDatabaseData(key: 'theme_animation', value: animation.name),
    );
  }

  Future<void> _persistLocaleAnimation(ValuesAnimationType? animation) async {
    ValuesRuntime.localeAnimation = animation;
    if (animation == null) {
      await _database.deleteSecure('locale_animation');
      return;
    }
    await _database.putSecure(
      SecureDatabaseData(key: 'locale_animation', value: animation.name),
    );
  }

  /// Reads and parses a JSON asset file into a map.
  Future<Map<String, dynamic>> _readAssets(String address) async {
    final file = json.decode(await rootBundle.loadString(address));
    return {p.basenameWithoutExtension(address): file};
  }
}
