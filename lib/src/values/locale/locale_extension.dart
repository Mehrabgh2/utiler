import 'package:flutter/material.dart';

import 'locale_manager.dart';
import 'locale_scope.dart';
import 'locale_values.dart';

extension LocaleExtension on BuildContext {
  LocaleValues? get appLocale {
    final inheritedWidget = LocaleManager.of<LocaleValues>(this);
    return inheritedWidget?.currentLocale;
  }

  void changeAppLocale(String id) {
    LocaleScope.changeLocale(this, id);
  }

  String? get currentLocaleId => appLocale?.id;

  List<LocaleValues>? get allLocales => LocaleScope.getAllLocales(this);
}
