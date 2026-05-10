import 'package:flutter/material.dart';
import '/utiler.dart';

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
  Widget get child {
    return Builder(
      builder: (context) {
        UtilerScope.localeContext = context;
        return super.child;
      },
    );
  }

  @override
  bool updateShouldNotify(LocaleManager<T> oldWidget) {
    return currentLocale != oldWidget.currentLocale;
  }
}
