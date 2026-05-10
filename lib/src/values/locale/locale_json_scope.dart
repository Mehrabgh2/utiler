import 'package:flutter/material.dart';

import 'locale_json_manager.dart';

class LocaleJsonScope extends StatefulWidget {
  final Widget child;
  final List<Map<String, dynamic>> locales;
  final String initialLocale;
  final Function(String)? localeChanged;

  const LocaleJsonScope({
    required this.child,
    required this.initialLocale,
    this.locales = const [],
    this.localeChanged,
    super.key,
  });

  static void changeLocale(BuildContext context, String id) {
    final inheritedWidget = LocaleJsonManager.of(context);
    if (inheritedWidget != null) {
      inheritedWidget.changeLocale(id);
    }
  }

  static Map<String, dynamic>? getCurrentLocale(BuildContext context) {
    return LocaleJsonManager.of(context)?.currentLocale;
  }

  static List<Map<String, dynamic>>? getAllLocales(BuildContext context) {
    return LocaleJsonManager.of(context)?.locales;
  }

  @override
  State<LocaleJsonScope> createState() => _LocaleJsonScope();
}

class _LocaleJsonScope extends State<LocaleJsonScope> {
  late Map<String, dynamic> _currentLocale;

  @override
  void initState() {
    super.initState();
    int index = widget.locales.indexWhere(
      (element) => element.keys.first == widget.initialLocale,
    );
    if (index == -1) {
      index = 0;
    }
    _currentLocale = widget.locales[index];
  }

  void _changeLocale(String id) {
    final index = widget.locales.indexWhere(
      (element) => element.keys.first == id,
    );
    if (index != -1) {
      setState(() {
        _currentLocale = widget.locales[index];
        if (widget.localeChanged != null) {
          widget.localeChanged!(id);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LocaleJsonManager(
      locales: widget.locales,
      currentLocale: _currentLocale,
      changeLocale: _changeLocale,
      child: widget.child,
      context: context,
    );
  }
}
