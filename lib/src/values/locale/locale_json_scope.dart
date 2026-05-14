import 'package:flutter/material.dart';
import 'package:utiler/src/values/locale/locale_json_manager.dart';

/// A stateful scope widget that manages JSON-based localization state.
///
/// [LocaleJsonScope] is responsible for:
/// - holding all available locales
/// - tracking the currently selected locale
/// - updating locale state using [setState]
/// - providing locale data through [LocaleJsonManager]
///
/// This widget acts as the controller layer for JSON localization.
///
/// Example:
/// ```dart
/// LocaleJsonScope(
///   initialLocale: 'en',
///   locales: [
///     {'en': {...}},
///     {'fa': {...}},
///   ],
///   child: MyApp(),
/// )
/// ```
class LocaleJsonScope extends StatefulWidget {
  /// Creates a [LocaleJsonScope].
  const LocaleJsonScope({
    required this.child,
    required this.initialLocale,
    this.locales = const [],
    this.localeChanged,
    super.key,
  });

  /// The widget below this scope.
  final Widget child;

  /// The initially selected locale ID.
  final String initialLocale;

  /// List of all available locale maps.
  final List<Map<String, dynamic>> locales;

  /// Optional callback triggered when locale changes.
  final Function(String)? localeChanged;

  /// Changes the current locale from anywhere in the widget tree.
  ///
  /// Looks up the nearest [LocaleJsonManager] and triggers a change.
  static void changeLocale(BuildContext context, String id) {
    final inheritedWidget = LocaleJsonManager.of(context);
    if (inheritedWidget != null) {
      inheritedWidget.changeLocale(id);
    }
  }

  /// Returns the currently active locale map.
  static Map<String, dynamic>? getCurrentLocale(BuildContext context) {
    return LocaleJsonManager.of(context)?.currentLocale;
  }

  /// Returns all available locales from the nearest scope.
  static List<Map<String, dynamic>>? getAllLocales(BuildContext context) {
    return LocaleJsonManager.of(context)?.locales;
  }

  @override
  State<LocaleJsonScope> createState() => _LocaleJsonScope();
}

/// Internal state for [LocaleJsonScope].
///
/// Handles locale initialization and updates using [setState].
class _LocaleJsonScope extends State<LocaleJsonScope> {
  /// Currently active locale map.
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

  /// Updates the active locale by its ID.
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
      context: context,
      child: widget.child,
    );
  }
}
