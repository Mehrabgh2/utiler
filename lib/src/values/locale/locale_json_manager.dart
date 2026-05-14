import 'package:flutter/material.dart';
import 'package:utiler/src/utiler_scope.dart';

/// An [InheritedWidget] that provides JSON-based localization data
/// to the widget tree.
///
/// [LocaleJsonManager] holds:
/// - a list of available locales
/// - the currently selected locale
/// - a callback to change the active locale
///
/// It is used as the foundation for JSON-driven localization in the app.
///
/// Example:
/// ```dart
/// LocaleJsonManager(
///   locales: locales,
///   currentLocale: locales.first,
///   changeLocale: (id) {},
///   child: MyApp(),
/// )
/// ```
class LocaleJsonManager extends InheritedWidget {
  /// Creates a [LocaleJsonManager].
  const LocaleJsonManager({
    super.key,
    required super.child,
    required this.locales,
    required this.currentLocale,
    required this.changeLocale,
    required this.context,
  });

  /// All available localization maps.
  final List<Map<String, dynamic>> locales;

  /// The currently active locale map.
  final Map<String, dynamic> currentLocale;

  /// Optional context reference used internally for scope tracking.
  final BuildContext? context;

  /// Callback used to switch the active locale by its identifier.
  final Function(String) changeLocale;

  /// Retrieves the nearest [LocaleJsonManager] instance from the widget tree.
  static LocaleJsonManager? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LocaleJsonManager>();
  }

  /// Wraps the inherited child to update [UtilerScope.localeContext].
  ///
  /// This ensures global access to the current locale context.
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
  /// Triggers rebuild when the locale key changes.
  @override
  bool updateShouldNotify(LocaleJsonManager oldWidget) {
    UtilerScope.localeContext = context;
    return currentLocale.keys.first != oldWidget.currentLocale.keys.first;
  }
}
