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
import 'package:utiler/src/performance/performance_monitor.dart';
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
/// passed directly via [jsonThemes] or loaded from an asset directory via
/// [jsonThemesAddress] (every `.json` file under that directory is loaded).
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
/// passed directly via [jsonLocales] or loaded from an asset directory via
/// [jsonLocalesAddress] (every `.json` file under that directory is loaded).
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
    this.showPerformanceMonitor = false,
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

  /// Whether to show the live [PerformanceMonitor] overlay.
  ///
  /// When `true`, a floating speed icon appears at the bottom-right corner of
  /// the screen. Tapping it opens a glassmorphism panel with real-time metrics:
  /// FPS, memory, battery, build time, raster time, UI-thread load, and jank.
  ///
  /// Intended for **development use only**. Disable before publishing.
  final bool showPerformanceMonitor;

  /// Typed theme definitions. Mutually exclusive with [jsonThemes] and
  /// [jsonThemesAddress].
  final List<ThemeValues>? themes;

  /// JSON-based theme definitions keyed by theme id, e.g.
  /// `{'light': {...}, 'dark': {...}}`. Mutually exclusive with [themes].
  final Map<String, dynamic>? jsonThemes;

  /// Asset directory containing JSON theme files. Every `.json` file directly
  /// or recursively under this directory is loaded and merged at startup,
  /// sorted by asset path. Mutually exclusive with [themes].
  ///
  /// ```dart
  /// jsonThemesAddress: 'assets/theme',
  /// ```
  final String? jsonThemesAddress;

  /// Typed locale definitions. Mutually exclusive with [jsonLocales] and
  /// [jsonLocalesAddress].
  final List<LocaleValues>? locales;

  /// JSON-based locale definitions keyed by locale id, e.g.
  /// `{'en': {...}, 'fa': {...}}`. Mutually exclusive with [locales].
  final Map<String, dynamic>? jsonLocales;

  /// Asset directory containing JSON locale files. Every `.json` file directly
  /// or recursively under this directory is loaded and merged at startup,
  /// sorted by asset path. Mutually exclusive with [locales].
  ///
  /// ```dart
  /// jsonLocalesAddress: 'assets/locale',
  /// ```
  final String? jsonLocalesAddress;

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

    if (widget.showPerformanceMonitor) {
      finalChild = PerformanceMonitor(
        hasLoggerConsole: widget.showLogWidget,
        child: finalChild,
      );
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

    // Resolve JSON assets first so we can read their first key for seeding.
    final resolvedJsonThemes = hasThemes && widget.jsonThemesAddress != null
        ? await _readAssetDirectory(widget.jsonThemesAddress!)
        : widget.jsonThemes;
    final resolvedJsonLocales = hasLocales && widget.jsonLocalesAddress != null
        ? await _readAssetDirectory(widget.jsonLocalesAddress!)
        : widget.jsonLocales;

    final savedTheme = await _getSavedTheme();
    final savedLocale = await _getSavedLocale();

    // Theme — apply saved value or seed the DB with the first theme on first launch.
    if (savedTheme != null) {
      ValuesRuntime.currentThemeId = savedTheme;
    } else {
      final initial = _firstThemeId(resolvedJsonThemes);
      if (initial != null) {
        await _database.putSecure(
          SecureDatabaseData(key: 'theme', value: initial),
        );
      }
    }

    // Locale — apply saved value or seed the DB on first launch.
    if (savedLocale != null) {
      ValuesRuntime.currentLocaleId = savedLocale;
    } else {
      final initial = _firstLocaleId(resolvedJsonLocales);
      if (initial != null) {
        await _database.putSecure(
          SecureDatabaseData(key: 'locale', value: initial),
        );
      }
    }

    return ValuesScope(
      locales: widget.locales,
      themes: widget.themes,
      jsonLocales: resolvedJsonLocales,
      jsonThemes: resolvedJsonThemes,
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

  String? _firstThemeId(Map<String, dynamic>? resolvedJson) {
    if (widget.themes != null && widget.themes!.isNotEmpty) {
      return widget.themes!.first.id;
    }
    if (resolvedJson != null && resolvedJson.isNotEmpty) {
      return resolvedJson.keys.first;
    }
    return null;
  }

  String? _firstLocaleId(Map<String, dynamic>? resolvedJson) {
    if (widget.locales != null && widget.locales!.isNotEmpty) {
      return widget.locales!.first.id;
    }
    if (resolvedJson != null && resolvedJson.isNotEmpty) {
      return resolvedJson.keys.first;
    }
    return null;
  }

  Future<void> _persistThemeAnimation(ValuesAnimationType? animation) async {
    ValuesRuntime.themeAnimation = animation;
  }

  Future<void> _persistLocaleAnimation(ValuesAnimationType? animation) async {
    ValuesRuntime.localeAnimation = animation;
  }

  /// Loads every `.json` asset under [directory] (sorted by path) and merges
  /// them into a single map keyed by each file's name without extension, e.g.
  /// `{'light': {...}, 'dark': {...}}`.
  ///
  /// The asset list is resolved from the [AssetManifest], so it works across
  /// all platforms including web and wasm.
  Future<Map<String, dynamic>> _readAssetDirectory(String directory) async {
    final normalized = directory.endsWith('/') ? directory : '$directory/';
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final paths =
        manifest
            .listAssets()
            .where(
              (asset) =>
                  asset.startsWith(normalized) &&
                  asset.toLowerCase().endsWith('.json'),
            )
            .toList()
          ..sort();
    final entries = await Future.wait(paths.map(_readAsset));
    return {for (final entry in entries) ...entry};
  }

  /// Reads a JSON asset file and returns it keyed by its filename (no ext).
  Future<Map<String, dynamic>> _readAsset(String address) async {
    final file = json.decode(await rootBundle.loadString(address));
    return {p.basenameWithoutExtension(address): file};
  }
}
