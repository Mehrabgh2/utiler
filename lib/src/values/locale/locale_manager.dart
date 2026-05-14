import 'package:flutter/material.dart';
import 'package:utiler/src/utiler_scope.dart';
import 'package:utiler/src/values/locale/locale_values.dart';

/// A generic [InheritedWidget] that provides strongly typed localization
/// values to the widget tree.
///
/// [LocaleManager] is the typed counterpart of JSON-based localization,
/// offering compile-time safety through [LocaleValues].
///
/// It provides:
/// - a list of available typed locales
/// - the currently active locale
/// - a callback to switch locales
///
/// Example:
/// ```dart
/// LocaleManager<AppLocale>(
///   locales: locales,
///   currentLocale: locales.first,
///   changeLocale: (id) {},
///   child: MyApp(),
/// )
/// ```
class LocaleManager<T extends LocaleValues> extends InheritedWidget {
  /// Creates a [LocaleManager].
  const LocaleManager({
    super.key,
    required super.child,
    required this.locales,
    required this.currentLocale,
    required this.changeLocale,
  });

  /// All available typed locale values.
  final List<T> locales;

  /// The currently active locale.
  final T currentLocale;

  /// Callback used to change the active locale by its identifier.
  final Function(String) changeLocale;

  /// Retrieves the nearest [LocaleManager] of type [T] from the widget tree.
  static LocaleManager<T>? of<T extends LocaleValues>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LocaleManager<T>>();
  }

  /// Wraps the inherited child to update [UtilerScope.localeContext].
  ///
  /// This allows global access to the current localization context.
  @override
  Widget get child {
    return Builder(
      builder: (context) {
        UtilerScope.localeContext = context;
        return super.child;
      },
    );
  }

  /// Determines whether widgets depending on this should rebuild.
  ///
  /// Triggers rebuild when the current locale instance changes.
  @override
  bool updateShouldNotify(LocaleManager<T> oldWidget) {
    return currentLocale != oldWidget.currentLocale;
  }
}
