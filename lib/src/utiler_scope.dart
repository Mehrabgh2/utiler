import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:utiler/src/values/locale/locale_extension.dart';
import 'package:utiler/src/values/theme/theme_extension.dart';

import 'core/lifecycle_handler.dart';
import 'database/database.dart';
import 'database/secure_database_data.dart';
import 'logger/logger.dart';
import 'logger/logger_console.dart';
import 'values/locale/locale_values.dart';
import 'values/theme/theme_values.dart';
import 'values/values_scope.dart';

class UtilerScope extends StatelessWidget {
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
    this.themeTransitionInitRadius = 60,
    this.themeTransitionDuration = const Duration(milliseconds: 1250),
    this.themeTransitionOffset = Offset.zero,
    super.key,
  }) {
    init();
  }

  static BuildContext? themeContext;
  static BuildContext? localeContext;
  final Database database = Database();
  final Widget child;
  final LifecycleListener? lifecycleListener;
  final bool enabledLog;
  final bool exportLog;
  final bool showLogWidget;
  final List<ThemeValues>? themes;
  final List<Map<String, dynamic>>? jsonThemes;
  final List<String>? jsonThemesAddress;
  final List<LocaleValues>? locales;
  final List<Map<String, dynamic>>? jsonLocales;
  final List<String>? jsonLocalesAddress;
  final int themeTransitionInitRadius;
  final Duration themeTransitionDuration;
  final Offset themeTransitionOffset;

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
              jsonLocalesAddress!.map((e) => _readAssets(e)),
            )
          : jsonLocales,
      jsonThemes: jsonThemesAddress != null && jsonThemesAddress!.isNotEmpty
          ? await Future.wait<Map<String, dynamic>>(
              jsonThemesAddress!.map((e) => _readAssets(e)),
            )
          : jsonThemes,
      initialLocale: await _getSavedLocale(),
      initialTheme: await _getSavedTheme(),
      themeChanged: _themeChanged,
      localeChanged: _localeChanged,
      themeTransitionDuration: themeTransitionDuration,
      themeTransitionInitRadius: themeTransitionInitRadius,
      themeTransitionOffset: themeTransitionOffset,
      child: finalChild,
    );
    return finalChild;
  }

  static void changeAppTheme(String newTheme) {
    themeContext?.changeAppTheme(newTheme, false);
  }

  static void changeAppLocale(String newLocale) {
    localeContext?.changeAppLocale(newLocale);
  }

  void _themeChanged(String newTheme) {
    database.putSecure(SecureDatabaseData(key: 'theme', value: newTheme));
  }

  void _localeChanged(String newLocale) {
    database.putSecure(SecureDatabaseData(key: 'locale', value: newLocale));
  }

  Future<String?> _getSavedTheme() async {
    return (await database.getSecure('theme'))?.value;
  }

  Future<String?> _getSavedLocale() async {
    return (await database.getSecure('locale'))?.value;
  }

  Future<Map<String, dynamic>> _readAssets(String address) async {
    Map<String, dynamic> file = json.decode(
      await rootBundle.loadString(address),
    );
    return {p.basenameWithoutExtension(address): file};
  }
}
