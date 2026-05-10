import 'package:flutter/material.dart';
import 'package:utiler/utiler.dart';

class LocaleJsonManager extends InheritedWidget {
  final List<Map<String, dynamic>> locales;
  final Map<String, dynamic> currentLocale;
  final BuildContext? context;
  final Function(String) changeLocale;

  const LocaleJsonManager({
    super.key,
    required super.child,
    required this.locales,
    required this.currentLocale,
    required this.changeLocale,
    required this.context,
  });

  static LocaleJsonManager? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LocaleJsonManager>();
  }

  @override
  Widget get child {
    return Builder(
      builder: (context) {
        UtilerScope.localeContext = context;
        return super.child;
      },
    );
  }

  @override
  bool updateShouldNotify(LocaleJsonManager oldWidget) {
    UtilerScope.localeContext = context;
    return currentLocale.keys.first != oldWidget.currentLocale.keys.first;
  }
}
