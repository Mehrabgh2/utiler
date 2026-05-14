import 'package:flutter/material.dart';
import 'package:utiler/src/values/locale/locale_manager.dart';
import 'package:utiler/src/values/locale/locale_values.dart';

/// A stateful scope widget that manages strongly typed localization state.
///
/// [LocaleScope] is responsible for:
/// - storing all available typed locales
/// - tracking the currently active locale
/// - switching locales at runtime using [setState]
/// - providing data through [LocaleManager]
///
/// It acts as the controller layer for strongly typed localization.
///
/// Example:
/// ```dart
/// LocaleScope<AppLocale>(
///   initialLocale: 'en',
///   locales: locales,
///   child: MyApp(),
/// )
/// ```
class LocaleScope<T extends LocaleValues> extends StatefulWidget {
  /// Creates a [LocaleScope].
  const LocaleScope({
    required this.child,
    required this.initialLocale,
    this.locales = const [],
    this.localeChanged,
    super.key,
  });

  /// The widget below this scope.
  final Widget child;

  /// The initial locale ID (e.g. `"en"`, `"fa"`).
  final String initialLocale;

  /// List of all available typed locales.
  final List<T> locales;

  /// Optional callback triggered when locale changes.
  final Function(String)? localeChanged;

  /// Changes the current locale from anywhere in the widget tree.
  ///
  /// Looks up the nearest [LocaleManager] and triggers a change.
  static void changeLocale(BuildContext context, String id) {
    final inheritedWidget = LocaleManager.of(context);
    if (inheritedWidget != null) {
      inheritedWidget.changeLocale(id);
    }
  }

  /// Returns the currently active locale (typed as [LocaleValues]).
  static LocaleValues? getCurrentLocale(BuildContext context) {
    return LocaleManager.of(context)?.currentLocale;
  }

  /// Returns all available locales from the nearest scope.
  static List<LocaleValues>? getAllLocales(BuildContext context) {
    return LocaleManager.of(context)?.locales;
  }

  @override
  State<LocaleScope<T>> createState() => _LocaleScope<T>();
}

/// Internal state for [LocaleScope].
///
/// Handles initialization and switching of typed locales.
class _LocaleScope<T extends LocaleValues> extends State<LocaleScope<T>> {
  /// Currently active locale instance.
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

  /// Updates the active locale by its ID.
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
