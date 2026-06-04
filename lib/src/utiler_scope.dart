import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:utiler/src/core/lifecycle_handler.dart';
import 'package:utiler/src/database/database.dart';
import 'package:utiler/src/database/secure_database_data.dart';
import 'package:utiler/src/logger/logger.dart';
import 'package:utiler/src/logger/logger_console.dart';
import 'package:utiler/src/values/animation/animation_circle_clipper.dart';
import 'package:utiler/src/values/animation/animation_clipper.dart';
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
    this.showLogWidget = false,
    this.themes,
    this.jsonThemes,
    this.jsonThemesAddress,
    this.locales,
    this.jsonLocales,
    this.jsonLocalesAddress,
    this.themeAnimationClipper = const AnimationCircleClipper(),
    this.themeAnimationDuration = const Duration(milliseconds: 500),
    this.localeAnimationClipper = const AnimationCircleClipper(),
    this.localeAnimationDuration = const Duration(milliseconds: 500),
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

  /// Theme animation clipper.
  final AnimationClipper themeAnimationClipper;

  /// Duration of animated theme reveal transitions.
  final Duration themeAnimationDuration;

  /// Locale animation clipper.
  final AnimationClipper localeAnimationClipper;

  /// Duration of animated locale reveal transitions.
  final Duration localeAnimationDuration;

  /// Global context used by theme extensions.
  static BuildContext? themeContext;

  /// Global context used by locale extensions.
  static BuildContext? localeContext;

  /// Changes the global theme at runtime.
  static void changeAppTheme(String newTheme, [bool withAnimation = true]) {
    themeContext?.changeAppTheme(newTheme, withAnimation);
  }

  /// Changes the global locale at runtime.
  static void changeAppLocale(String newLocale, [bool withAnimation = true]) {
    localeContext?.changeAppLocale(newLocale, withAnimation);
  }

  @override
  State<UtilerScope> createState() => _UtilerScopeState();
}

class _UtilerScopeState extends State<UtilerScope> {
  late final Future<Widget> _initializedChild;

  @override
  void initState() {
    super.initState();
    _initLogging();
    _initializedChild = _buildChild();
  }

  void _initLogging() {
    Logger.enabled = widget.enabledLog;
    Logger.export = widget.exportLog;
    Logger.showWidget = widget.showLogWidget;
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

    if (savedTheme != null) {
      ValuesRuntime.currentThemeId = savedTheme;
    }
    if (savedLocale != null) {
      ValuesRuntime.currentLocaleId = savedLocale;
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
      themeAnimationClipper: widget.themeAnimationClipper,
      themeAnimationDuration: widget.themeAnimationDuration,
      localeAnimationClipper: widget.localeAnimationClipper,
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

  /// Reads and parses a JSON asset file into a map.
  Future<Map<String, dynamic>> _readAssets(String address) async {
    final file = json.decode(await rootBundle.loadString(address));
    return {p.basenameWithoutExtension(address): file};
  }
}
