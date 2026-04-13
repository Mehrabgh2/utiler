import 'package:flutter/material.dart';

import 'locale_values.dart';

class LocaleManager<T extends LocaleValues> extends InheritedWidget {
  final List<T> locales;
  final T currentLocale;
  final Function(String) changeLocale;

  const LocaleManager({
    super.key,
    required super.child,
    required this.locales,
    required this.currentLocale,
    required this.changeLocale,
  });

  static LocaleManager<T>? of<T extends LocaleValues>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LocaleManager<T>>();
  }

  @override
  bool updateShouldNotify(LocaleManager<T> oldWidget) {
    return currentLocale != oldWidget.currentLocale;
  }
}
