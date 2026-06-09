import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:utiler/src/core/app_config.dart';
import 'package:utiler/src/core/internet_connectivity.dart';
import 'package:utiler/src/core/lifecycle_handler.dart';
import 'package:utiler/src/database/database.dart';
import 'package:utiler/src/database/secure_database_data.dart';
import 'package:utiler/src/logger/logger.dart';
import 'package:utiler/src/logger/logger_console.dart';
import 'package:utiler/src/utiler.dart';
import 'package:utiler/src/values/animation/values_animation_type.dart';
import 'package:utiler/src/values/locale/locale_values.dart';
import 'package:utiler/src/values/theme/theme_values.dart';
import 'package:utiler/src/values/values_runtime.dart';
import 'package:utiler/src/values/values_scope.dart';

/// The root configuration widget for the Utiler utility package.
///
/// Place `UtilerScope` above your `MaterialApp` (or equivalent) to wire up
/// all Utiler subsystems at startup. Once mounted, every subsystem is
/// accessible through the [Utiler] static API.
///
/// ---
///
/// ## Subsystems
///
/// ### Logging
///
/// ```dart
/// UtilerScope(
///   enabledLog: true,
///   exportLog: false,
///   showLogWidget: false,
///   child: MyApp(),
/// );
/// ```
///
/// ### Theming
///
/// Supports typed ([ThemeValues]) or JSON-based themes. JSON files can be
/// passed directly via [jsonThemes] or loaded from assets via
/// [jsonThemesAddress].
///
/// Theme switching is animated when called via [Utiler.changeAppTheme].
/// The default transition style is set with [themeAnimation] and its duration
/// with [themeAnimationDuration]. Both are persisted across sessions.
///
/// **JSON helper — `.cr` (recursive color/map access):**
///
/// ```dart
/// // JSON
/// { 'light': { 'home': { 'background': 'FF1565C0' } } }
///
/// // Usage
/// 'home.background'.cr
/// ```
///
/// ### Localization
///
/// Supports typed ([LocaleValues]) or JSON-based locales. JSON files can be
/// passed directly via [jsonLocales] or loaded from assets via
/// [jsonLocalesAddress].
///
/// Locale switching is animated when called via [Utiler.changeAppLocale].
/// The default transition style is set with [localeAnimation] and its duration
/// with [localeAnimationDuration]. Both are persisted across sessions.
///
/// **JSON helper — `.tr` (dot-notation string lookup):**
///
/// ```dart
/// // JSON
/// { 'en': { 'home': { 'appbar': 'Home Screen' } } }
///
/// // Usage
/// 'home.appbar'.tr
/// ```
///
/// ### Feature Flags
///
/// ```dart
/// UtilerScope(
///   featureFlags: {
///     'new_checkout': true,
///     'beta_chat': false,
///   },
///   child: MyApp(),
/// );
///
/// // Anywhere in the app:
/// if (Utiler.flags.isEnabled('new_checkout')) { ... }
/// ```
///
/// ### Internet Connectivity
///
/// ```dart
/// UtilerScope(
///   onConnectivityChange: (status) {
///     if (status == InternetStatus.disconnected) showOfflineBanner();
///   },
///   child: MyApp(),
/// );
///
/// // One-time check:
/// final hasInternet = await InternetConnectivity.hasInternetAccess();
/// ```
///
/// ### App Configuration
///
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
/// // Anywhere in the app:
/// final url = Utiler.config.active.require<String>('api_base_url');
/// ```
///
/// ### Persistence
///
/// Selected theme, locale, and their animation preferences are automatically
/// persisted to secure storage and restored on the next launch.
///
/// ---
///
/// ## Notes
///
/// - Use either [themes] **or** [jsonThemes] / [jsonThemesAddress], not both.
/// - Use either [locales] **or** [jsonLocales] / [jsonLocalesAddress], not both.
/// - Mixing typed and JSON modes for the same subsystem will throw an error.
/// - All runtime APIs ([Utiler.changeAppTheme], [Utiler.flags], etc.) are only
///   available after this widget is mounted.
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

  /// Whether logs should be exported to a file.
  final bool exportLog;

  /// Directory for log export when [exportLog] is `true`.
  ///
  /// Provide an absolute path (e.g. from `path_provider`).
  /// Ignored on web where file export is unavailable.
  final String? logExportDirectory;

  /// Whether to show an in-app log console overlay.
  final bool showLogWidget;

  /// Typed theme definitions. Mutually exclusive with [jsonThemes] and
  /// [jsonThemesAddress].
  final List<ThemeValues>? themes;

  /// JSON-based theme definitions. Mutually exclusive with [themes].
  final List<Map<String, dynamic>>? jsonThemes;

  /// Asset paths for JSON theme files. Loaded and merged at startup.
  /// Mutually exclusive with [themes].
  final List<String>? jsonThemesAddress;

  /// Typed locale definitions. Mutually exclusive with [jsonLocales] and
  /// [jsonLocalesAddress].
  final List<LocaleValues>? locales;

  /// JSON-based locale definitions. Mutually exclusive with [locales].
  final List<Map<String, dynamic>>? jsonLocales;

  /// Asset paths for JSON locale files. Loaded and merged at startup.
  /// Mutually exclusive with [locales].
  final List<String>? jsonLocalesAddress;

  /// Default theme transition applied when [Utiler.changeAppTheme] is called
  /// without an explicit animation argument. `null` means instant.
  ///
  /// The value is persisted and restored across sessions. It can be updated
  /// at runtime via [Utiler.changeThemeAnimation].
  final ValuesAnimationType? themeAnimation;

  /// Duration of animated theme reveal transitions.
  final Duration themeAnimationDuration;

  /// Default locale transition applied when [Utiler.changeAppLocale] is called
  /// without an explicit animation argument. `null` means instant.
  ///
  /// The value is persisted and restored across sessions. It can be updated
  /// at runtime via [Utiler.changeLocaleAnimation].
  final ValuesAnimationType? localeAnimation;

  /// Duration of animated locale reveal transitions.
  final Duration localeAnimationDuration;

  /// Initial feature-flag definitions.
  ///
  /// Missing keys resolve to `false` when queried via [Utiler.flags].
  ///
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

  /// Callback invoked whenever [InternetStatus] changes.
  ///
  /// Connectivity monitoring is activated automatically when this callback
  /// is provided.
  ///
  /// ```dart
  /// UtilerScope(
  ///   onConnectivityChange: (status) {
  ///     if (status == InternetStatus.disconnected) showOfflineBanner();
  ///   },
  ///   child: MyApp(),
  /// );
  /// ```
  final void Function(InternetStatus status)? onConnectivityChange;

  /// Environment-aware application configuration store.
  ///
  /// Made available globally via [Utiler.config] once mounted.
  ///
  /// ```dart
  /// UtilerScope(
  ///   appConfig: AppConfigStore(
  ///     active: AppEnvironment.production,
  ///     configs: { ... },
  ///   ),
  ///   child: MyApp(),
  /// );
  ///
  /// // Anywhere in the app:
  /// final url = Utiler.config.active.require<String>('api_base_url');
  /// ```
  final AppConfigStore? appConfig;

  @override
  State<UtilerScope> createState() => _UtilerScopeState();
}

class _UtilerScopeState extends State<UtilerScope> {
  late final Future<Widget> _initializedChild;
  StreamSubscription<InternetStatus>? _connectivitySubscription;

  final Database _database = Database();

  @override
  void initState() {
    super.initState();
    _initLogging();
    _initFeatureFlags();
    _initAppConfig();
    _initConnectivity();
    _wireUtilerCallbacks();
    ValuesRuntime.themeAnimation = widget.themeAnimation;
    ValuesRuntime.localeAnimation = widget.localeAnimation;
    _initializedChild = _buildChild();
  }

  @override
  void dispose() {
    Utiler.persistThemeAnimation = null;
    Utiler.persistLocaleAnimation = null;
    if (widget.onConnectivityChange != null) {
      unawaited(_connectivitySubscription?.cancel());
      unawaited(InternetConnectivity.dispose());
    }
    super.dispose();
  }

  // ── init helpers ────────────────────────────────────────────────────────────

  void _initLogging() {
    Logger.enabled = widget.enabledLog;
    Logger.export = widget.exportLog;
    Logger.exportDirectory = widget.logExportDirectory;
    Logger.showWidget = widget.showLogWidget;
  }

  void _initFeatureFlags() {
    if (widget.featureFlags != null) {
      Utiler.setFlags(widget.featureFlags!);
    }
  }

  void _initAppConfig() {
    if (widget.appConfig != null) {
      Utiler.setConfig(widget.appConfig!);
    }
  }

  void _initConnectivity() {
    if (widget.onConnectivityChange == null) return;
    _connectivitySubscription = InternetConnectivity.onStatusChange
        .asBroadcastStream()
        .listen((status) => widget.onConnectivityChange?.call(status));
  }

  /// Wires persistence callbacks and context references into [Utiler].
  void _wireUtilerCallbacks() {
    Utiler.persistThemeAnimation = _persistThemeAnimation;
    Utiler.persistLocaleAnimation = _persistLocaleAnimation;
  }

  // ── build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializedChild,
      builder: (context, snapshot) {
        if (snapshot.hasData) return snapshot.data!;
        return const SizedBox();
      },
    );
  }

  /// Builds the final widget tree after async initialization completes.
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

    final hasThemes =
        widget.themes != null ||
        widget.jsonThemes != null ||
        widget.jsonThemesAddress != null;

    final hasLocales =
        widget.locales != null ||
        widget.jsonLocales != null ||
        widget.jsonLocalesAddress != null;

    if (!hasThemes && !hasLocales) return finalChild;

    final savedTheme = await _getSavedTheme();
    final savedLocale = await _getSavedLocale();
    final savedThemeAnimation = await _getSavedThemeAnimation();
    final savedLocaleAnimation = await _getSavedLocaleAnimation();

    if (savedTheme != null) ValuesRuntime.currentThemeId = savedTheme;
    if (savedLocale != null) ValuesRuntime.currentLocaleId = savedLocale;
    if (savedThemeAnimation != null) {
      ValuesRuntime.themeAnimation = savedThemeAnimation;
    }
    if (savedLocaleAnimation != null) {
      ValuesRuntime.localeAnimation = savedLocaleAnimation;
    }

    return ValuesScope(
      locales: widget.locales,
      themes: widget.themes,
      jsonLocales: hasLocales && widget.jsonLocalesAddress != null
          ? await Future.wait<Map<String, dynamic>>(
              widget.jsonLocalesAddress!.map(_readAsset),
            )
          : widget.jsonLocales,
      jsonThemes: hasThemes && widget.jsonThemesAddress != null
          ? await Future.wait<Map<String, dynamic>>(
              widget.jsonThemesAddress!.map(_readAsset),
            )
          : widget.jsonThemes,
      initialLocale: savedLocale,
      initialTheme: savedTheme,
      themeChanged: _onThemeChanged,
      localeChanged: _onLocaleChanged,
      themeAnimation: ValuesRuntime.themeAnimation,
      themeAnimationDuration: widget.themeAnimationDuration,
      localeAnimation: ValuesRuntime.localeAnimation,
      localeAnimationDuration: widget.localeAnimationDuration,
      child: finalChild,
    );
  }

  // ── persistence ─────────────────────────────────────────────────────────────

  Future<void> _onThemeChanged(String newTheme) async {
    ValuesRuntime.currentThemeId = newTheme;
    await _database.putSecure(
      SecureDatabaseData(key: 'theme', value: newTheme),
    );
  }

  Future<void> _onLocaleChanged(String newLocale) async {
    ValuesRuntime.currentLocaleId = newLocale;
    await _database.putSecure(
      SecureDatabaseData(key: 'locale', value: newLocale),
    );
  }

  Future<String?> _getSavedTheme() async =>
      (await _database.getSecure('theme'))?.value;

  Future<String?> _getSavedLocale() async =>
      (await _database.getSecure('locale'))?.value;

  Future<ValuesAnimationType?> _getSavedThemeAnimation() async {
    final value = (await _database.getSecure('theme_animation'))?.value;
    if (value == null) return null;
    return ValuesAnimationTypeX.parse(value, fallback: widget.themeAnimation);
  }

  Future<ValuesAnimationType?> _getSavedLocaleAnimation() async {
    final value = (await _database.getSecure('locale_animation'))?.value;
    if (value == null) return null;
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

  // ── assets ──────────────────────────────────────────────────────────────────

  /// Reads a JSON asset file and returns it keyed by its filename (no ext).
  Future<Map<String, dynamic>> _readAsset(String address) async {
    final file = json.decode(await rootBundle.loadString(address));
    return {p.basenameWithoutExtension(address): file};
  }
}
