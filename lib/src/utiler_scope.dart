import 'package:flutter/material.dart';

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
    this.locales,
    this.themeTransitionInitRadius = 60,
    this.themeTransitionDuration = const Duration(milliseconds: 1250),
    this.themeTransitionOffset = Offset.zero,
    super.key,
  }) {
    init();
  }

  final Database database = Database();
  final Widget child;
  final LifecycleListener? lifecycleListener;
  final bool enabledLog;
  final bool exportLog;
  final bool showLogWidget;
  final List<ThemeValues>? themes;
  final int themeTransitionInitRadius;
  final Duration themeTransitionDuration;
  final Offset themeTransitionOffset;
  final List<LocaleValues>? locales;

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
    finalChild = ValuesScope(
      locales: locales,
      themes: themes,
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
}
