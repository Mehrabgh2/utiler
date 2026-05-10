import 'package:flutter/material.dart';
import 'package:utiler/utiler.dart';

import 'locale_json_manager.dart';
import 'locale_json_scope.dart';
import 'locale_manager.dart';
import 'locale_scope.dart';

extension LocaleExtension on BuildContext {
  LocaleValues? get appLocale {
    final inheritedWidget = LocaleManager.of<LocaleValues>(this);
    if (inheritedWidget == null) return null;
    return inheritedWidget.currentLocale;
  }

  Map<String, dynamic>? get appJsonLocale {
    final inheritedWidget = LocaleJsonManager.of(this);
    if (inheritedWidget == null) return null;
    return inheritedWidget.currentLocale.values.first as Map<String, dynamic>;
  }

  void changeAppLocale(String id) {
    if (ValuesScope.isJsonLocale) {
      LocaleJsonScope.changeLocale(this, id);
    } else {
      LocaleScope.changeLocale(this, id);
    }
  }

  String? get currentLocaleId {
    if (ValuesScope.isJsonLocale) {
      final inheritedWidget = LocaleJsonManager.of(this);
      return inheritedWidget?.currentLocale.keys.first;
    } else {
      return appLocale?.id;
    }
  }

  List<LocaleValues>? get allLocales => LocaleScope.getAllLocales(this);

  List<Map<String, dynamic>>? get allJsonLocales =>
      LocaleJsonScope.getAllLocales(this);
}

extension LocaleStringExtension on String {
  String get tr {
    if (UtilerScope.localeContext == null) {
      return this;
    }
    final inheritedWidget = LocaleJsonManager.of(UtilerScope.localeContext!);
    if (inheritedWidget == null) return this;
    Map<String, dynamic> locale =
        inheritedWidget.currentLocale.values.first as Map<String, dynamic>;
    return _resolveJsonPath(locale, this) ?? this;
  }

  String? _resolveJsonPath(Map<String, dynamic> json, String path) {
    final parts = path.split('.');
    dynamic current = json;
    for (final part in parts) {
      if (current is Map<String, dynamic>) {
        if (!current.containsKey(part)) return null;
        current = current[part];
      } else {
        return null;
      }
    }
    return current;
  }
}
