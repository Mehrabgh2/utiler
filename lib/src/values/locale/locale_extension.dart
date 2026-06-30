import 'package:flutter/material.dart';
import 'package:utiler/src/utiler.dart';
import 'package:utiler/src/utiler_scope.dart';
import 'package:utiler/src/values/animation/values_animation_type.dart';
import 'package:utiler/src/values/locale/locale_json_manager.dart';
import 'package:utiler/src/values/locale/locale_json_scope.dart';
import 'package:utiler/src/values/locale/locale_manager.dart';
import 'package:utiler/src/values/locale/locale_scope.dart';
import 'package:utiler/src/values/locale/locale_values.dart';
import 'package:utiler/src/values/values_scope.dart';

/// Extensions on [BuildContext] for accessing and managing app localization.
///
/// This extension provides a unified API for both structured locale models
/// ([LocaleValues]) and JSON-based localization systems.
///
/// It supports:
/// - retrieving current locale
/// - switching locale dynamically
/// - accessing all available locales
/// - compatibility with JSON and typed localization systems
///
/// Example:
/// ```dart
/// final locale = context.appLocale;
/// context.changeAppLocale('en');
/// print(context.currentLocaleId);
/// ```
extension LocaleExtension on BuildContext {
  /// Returns the current typed locale ([LocaleValues]) if available.
  ///
  /// Returns `null` if localization is not initialized or unavailable.
  LocaleValues? get appLocale {
    final inheritedWidget = LocaleManager.of<LocaleValues>(this);
    if (inheritedWidget == null) return null;
    return inheritedWidget.currentLocale;
  }

  /// Returns the current JSON-based locale as a [Map].
  ///
  /// This is used when localization is stored in JSON format instead of
  /// strongly typed classes.
  Map<String, dynamic>? get appJsonLocale {
    final inheritedWidget = LocaleJsonManager.of(this);
    if (inheritedWidget == null) return null;
    return inheritedWidget.currentLocale.values.first as Map<String, dynamic>;
  }

  /// Changes the current app locale by its identifier with an animated reveal.
  ///
  /// Automatically selects JSON or typed locale system based on configuration.
  /// The animation origin is the last tap position, or the screen center
  /// when the locale is changed programmatically.
  ///
  /// Animation priority:
  /// 1. [animation] passed to this call
  /// 2. [ValuesRuntime.localeAnimation] from [UtilerScope] or scope widgets
  /// 3. Instant change when both are `null`
  ///
  /// Example:
  /// ```dart
  /// context.changeAppLocale('fa'); // uses scope default
  /// context.changeAppLocale('en', ValuesAnimationType.slideLeft); // one-off
  /// ```
  void changeAppLocale(String id, [ValuesAnimationType? animation]) {
    if (ValuesScope.isJsonLocale) {
      LocaleJsonScope.changeAppLocale(this, id, animation);
    } else {
      LocaleScope.changeAppLocale(this, id, animation);
    }
  }

  /// Returns the current locale identifier (e.g. `"en"`, `"fa"`).
  ///
  /// Returns `null` if no locale is active.
  String? get currentLocaleId {
    if (ValuesScope.isJsonLocale) {
      final inheritedWidget = LocaleJsonManager.of(this);
      return inheritedWidget?.currentLocale.keys.first;
    } else {
      return appLocale?.id;
    }
  }

  /// Returns all available typed locales.
  List<LocaleValues>? get allLocales => LocaleScope.getAllLocales(this);

  /// Returns all available JSON locales keyed by locale id.
  Map<String, dynamic>? get allJsonLocales =>
      LocaleJsonScope.getAllLocales(this);
}

/// Extension on [String] to resolve localized values from JSON locale maps.
///
/// Supports dot notation paths like:
/// ```dart
/// // JSON:
/// // {
/// //   'en': {
/// //     'home': {'appbar': 'Home Screen'}
/// //   }
/// // }
///
/// 'home.appbar'.tr
/// ```
///
extension LocaleStringExtension on String {
  /// Translates the string using the current JSON locale context.
  ///
  /// If no localization context is available or the key is missing,
  /// returns the original string.
  String get tr {
    if (Utiler.localeContext == null) {
      return this;
    }

    final inheritedWidget = LocaleJsonManager.of(Utiler.localeContext!);

    if (inheritedWidget == null) return this;

    final Map<String, dynamic> locale =
        inheritedWidget.currentLocale.values.first as Map<String, dynamic>;

    return _resolveJsonPath(locale, this) ?? this;
  }

  /// Resolves a dot-separated key path inside a nested JSON map.
  ///
  /// Example:
  /// ```dart
  /// _resolveJsonPath(locale, "home.title")
  /// ```
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
