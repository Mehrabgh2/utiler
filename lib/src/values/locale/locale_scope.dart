import 'package:flutter/material.dart';

import 'locale_manager.dart';
import 'locale_values.dart';

class LocaleScope<T extends LocaleValues> extends StatefulWidget {
  final Widget child;
  final List<T> locales;
  final String initialLocale;
  final Function(String)? localeChanged;

  const LocaleScope({
    super.key,
    this.locales = const [],
    this.localeChanged,
    required this.child,
    required this.initialLocale,
  });

  static void changeLocale(BuildContext context, String id) {
    final inheritedWidget = LocaleManager.of(context);
    if (inheritedWidget != null) {
      inheritedWidget.changeLocale(id);
    }
  }

  static LocaleValues? getCurrentLocale(BuildContext context) {
    return LocaleManager.of(context)?.currentLocale;
  }

  static List<LocaleValues>? getAllLocales(BuildContext context) {
    return LocaleManager.of(context)?.locales;
  }

  @override
  State<LocaleScope<T>> createState() => _LocaleScope<T>();
}

class _LocaleScope<T extends LocaleValues> extends State<LocaleScope<T>> {
  late T _currentLocale;

  @override
  void initState() {
    super.initState();
    int index = widget.locales.indexWhere(
      (element) => element.id == widget.initialLocale,
    );
    if (index == -1) {
      index = 0;
    }
    _currentLocale = widget.locales[index];
  }

  void _changeLocale(String id) {
    final index = widget.locales.indexWhere((locale) => locale.id == id);
    if (index != -1) {
      setState(() {
        _currentLocale = widget.locales[index];
        if (widget.localeChanged != null) {
          widget.localeChanged!(widget.locales[index].id);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LocaleManager<LocaleValues>(
      locales: widget.locales,
      currentLocale: _currentLocale,
      changeLocale: _changeLocale,
      child: widget.child,
    );
  }
}
