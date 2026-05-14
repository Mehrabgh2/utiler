import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:utiler/src/core/lifecycle_handler.dart';
import 'package:utiler/src/database/database.dart';
import 'package:utiler/src/database/secure_database_data.dart';
import 'package:utiler/src/logger/logger.dart';
import 'package:utiler/src/logger/logger_console.dart';
import 'package:utiler/src/values/locale/locale_extension.dart';
import 'package:utiler/src/values/locale/locale_values.dart';
import 'package:utiler/src/values/theme/theme_extension.dart';
import 'package:utiler/src/values/theme/theme_values.dart';
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
/// #### Theming
/// Supports two modes:
/// - Typed theme system (`ThemeValues`)
/// - JSON-based theme system (`Map<String, dynamic>`)
///
/// You can also load JSON assets directly using `jsonThemesAddress`.
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
class UtilerScope extends StatelessWidget {
  /// Creates a [UtilerScope].
  UtilerScope({
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
    super.key,
  }) {
    init();
  }

  /// Global context used by theme extensions.
  static BuildContext? themeContext;

  /// Global context used by locale extensions.
  static BuildContext? localeContext;

  /// Internal database instance for persistence.
  final Database database = Database();

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

  /// Initializes global logging configuration.
  void init() async {
    Logger.enabled = enabledLog;
    Logger.export = exportLog;
    Logger.showWidget = showLogWidget;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getChild(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data!;
        }
        return const SizedBox();
      },
    );
  }

  /// Builds the final widget tree after async initialization.
  Future<Widget> _getChild() async {
    Widget finalChild = child;

    if (lifecycleListener != null) {
      finalChild = LifecycleHandler(
        lifecycleListener: lifecycleListener!,
        child: finalChild,
      );
    }

    if (showLogWidget) {
      finalChild = LoggerConsole(child: finalChild);
    }

    if (locales == null &&
        jsonLocales == null &&
        themes == null &&
        jsonThemes == null &&
        jsonLocalesAddress == null &&
        jsonThemesAddress == null) {
      return finalChild;
    }

    finalChild = ValuesScope(
      locales: locales,
      themes: themes,
      jsonLocales: jsonLocalesAddress != null && jsonLocalesAddress!.isNotEmpty
          ? await Future.wait<Map<String, dynamic>>(
              jsonLocalesAddress!.map(_readAssets),
            )
          : jsonLocales,
      jsonThemes: jsonThemesAddress != null && jsonThemesAddress!.isNotEmpty
          ? await Future.wait<Map<String, dynamic>>(
              jsonThemesAddress!.map(_readAssets),
            )
          : jsonThemes,
      initialLocale: await _getSavedLocale(),
      initialTheme: await _getSavedTheme(),
      themeChanged: _themeChanged,
      localeChanged: _localeChanged,
      child: finalChild,
    );

    return finalChild;
  }

  /// Changes the global theme at runtime.
  static void changeAppTheme(String newTheme) {
    themeContext?.changeAppTheme(newTheme);
  }

  /// Changes the global locale at runtime.
  static void changeAppLocale(String newLocale) {
    localeContext?.changeAppLocale(newLocale);
  }

  /// Persists theme selection to secure storage.
  Future<void> _themeChanged(String newTheme) async {
    await database.putSecure(SecureDatabaseData(key: 'theme', value: newTheme));
  }

  /// Persists locale selection to secure storage.
  Future<void> _localeChanged(String newLocale) async {
    await database.putSecure(
      SecureDatabaseData(key: 'locale', value: newLocale),
    );
  }

  /// Retrieves the last saved theme.
  Future<String?> _getSavedTheme() async {
    return (await database.getSecure('theme'))?.value;
  }

  /// Retrieves the last saved locale.
  Future<String?> _getSavedLocale() async {
    return (await database.getSecure('locale'))?.value;
  }

  /// Reads and parses a JSON asset file into a map.
  Future<Map<String, dynamic>> _readAssets(String address) async {
    final file = json.decode(await rootBundle.loadString(address));
    return {p.basenameWithoutExtension(address): file};
  }
}
