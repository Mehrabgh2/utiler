import 'dart:async';

import 'package:flutter/material.dart';
import 'package:utiler/src/values/animation/values_animation_type.dart';
import 'package:utiler/src/values/locale/locale_animation_model.dart';
import 'package:utiler/src/values/locale/locale_json_manager.dart';
import 'package:utiler/src/values/locale/locale_switching_area.dart';
import 'package:utiler/src/values/values_runtime.dart';

/// A stateful scope widget that manages JSON-based localization state.
///
/// [LocaleJsonScope] is responsible for:
/// - holding all available locales
/// - tracking the currently selected locale
/// - switching locales at runtime with an animated reveal
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
    this.animation,
    this.animationDuration = const Duration(milliseconds: 500),
    this.useLocaleSwitchingArea = true,
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

  /// Default locale transition. `null` = instant change unless overridden per call.
  final ValuesAnimationType? animation;

  /// Duration of the animated reveal when switching locales.
  final Duration animationDuration;

  /// When `false`, locale transitions are rendered by [CombinedSwitchingArea].
  final bool useLocaleSwitchingArea;

  /// Changes the current locale by its identifier.
  ///
  /// Animation priority: [animation] → [UtilerScope.localeAnimation] → instant.
  static void changeLocale(
    BuildContext context,
    String id, [
    ValuesAnimationType? animation,
  ]) {
    final model = LocaleAnimationInherited.maybeOf(context);
    if (model != null) {
      final origin =
          model.lastPointerDown ?? localeAnimationOrigin(context, model);
      model.lastPointerDown = null;
      unawaited(
        model.changeLocale(
          localeId: id,
          origin: origin,
          animation: animation,
        ),
      );
      return;
    }

    final inheritedWidget = LocaleJsonManager.of(context);
    inheritedWidget?.changeLocale(id);
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
class _LocaleJsonScope extends State<LocaleJsonScope>
    with SingleTickerProviderStateMixin {
  /// Currently active locale map.
  late Map<String, dynamic> _currentLocale;

  /// Drives the animated reveal transition.
  late AnimationController _animationController;

  /// Holds screenshot and transition state for locale switching.
  late LocaleAnimationModel _animationModel;

  @override
  void initState() {
    super.initState();

    final effectiveLocaleId =
        ValuesRuntime.currentLocaleId ?? widget.initialLocale;

    int index = widget.locales.indexWhere(
      (element) => element.keys.first == effectiveLocaleId,
    );

    if (index == -1) {
      index = 0;
    }

    _currentLocale = widget.locales[index];
    ValuesRuntime.currentLocaleId = _currentLocale.keys.first;

    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    if (widget.animation != null) {
      ValuesRuntime.localeAnimation = widget.animation;
    }

    _animationModel = LocaleAnimationModel(
      controller: _animationController,
      fixedDuration: widget.animationDuration,
      getCurrentLocale: () => _currentLocale,
      resolveLocale: (id) {
        final index = widget.locales.indexWhere(
          (element) => element.keys.first == id,
        );
        return index == -1 ? null : widget.locales[index];
      },
      applyLocale: _applyLocale,
      wrapLocaledChild: (locale, child) => LocaleJsonManager(
        locales: widget.locales,
        currentLocale: locale,
        changeLocale: _changeLocale,
        child: child,
      ),
    );
  }

  @override
  void dispose() {
    _animationModel.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Triggers an animated locale change by ID.
  void _changeLocale(String id) {
    if (!mounted) {
      return;
    }

    final origin =
        _animationModel.lastPointerDown ??
        localeAnimationOrigin(context, _animationModel);
    _animationModel.lastPointerDown = null;
    unawaited(_animationModel.changeLocale(localeId: id, origin: origin));
  }

  /// Updates the active locale by its ID.
  void _applyLocale(String id) {
    final index = widget.locales.indexWhere(
      (element) => element.keys.first == id,
    );

    if (index != -1) {
      ValuesRuntime.currentLocaleId = id;
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
    return LocaleAnimationInherited(
      notifier: _animationModel,
      child: RepaintBoundary(
        key: _animationModel.previewContainer,
        child: Listener(
          onPointerDown: (event) {
            _animationModel.lastPointerDown = event.position;
          },
          child: LocaleJsonManager(
            locales: widget.locales,
            currentLocale: _currentLocale,
            changeLocale: _changeLocale,
            child: widget.useLocaleSwitchingArea
                ? LocaleSwitchingArea(child: widget.child)
                : widget.child,
          ),
        ),
      ),
    );
  }
}
