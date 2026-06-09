import 'dart:async';

import 'package:flutter/material.dart';
import 'package:utiler/src/values/animation/values_animation_type.dart';
import 'package:utiler/src/values/locale/locale_animation_model.dart';
import 'package:utiler/src/values/locale/locale_manager.dart';
import 'package:utiler/src/values/locale/locale_switching_area.dart';
import 'package:utiler/src/values/locale/locale_values.dart';
import 'package:utiler/src/values/values_runtime.dart';

/// A stateful scope widget that manages strongly typed localization state.
///
/// [LocaleScope] is responsible for:
/// - storing all available typed locales
/// - tracking the currently active locale
/// - switching locales at runtime with an animated reveal
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
    this.animation,
    this.animationDuration = const Duration(milliseconds: 500),
    this.useLocaleSwitchingArea = true,
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

  /// Default locale transition for switches initiated from this scope.
  ///
  /// Written to [ValuesRuntime.localeAnimation] when non-null.
  /// Per-call overrides take priority; instant when both are `null`.
  final ValuesAnimationType? animation;

  /// Duration of the animated reveal when switching locales.
  final Duration animationDuration;

  /// When `false`, locale transitions are rendered by [CombinedSwitchingArea].
  final bool useLocaleSwitchingArea;

  /// Changes the active locale by its ID with an animated reveal.
  ///
  /// Animation priority:
  /// 1. [animation] passed to this call
  /// 2. [ValuesRuntime.localeAnimation] from [UtilerScope] or scope widgets
  /// 3. Instant change when both are `null`
  ///
  /// Example:
  /// ```dart
  /// LocaleScope.changeAppLocale(context, 'fa', ValuesAnimationType.fade);
  /// ```
  static void changeAppLocale(
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
        model.changeAppLocale(
          localeId: id,
          origin: origin,
          animation: animation,
        ),
      );
      return;
    }

    final inheritedWidget = LocaleManager.of(context);
    inheritedWidget?.changeAppLocale(id);
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
class _LocaleScope<T extends LocaleValues> extends State<LocaleScope<T>>
    with SingleTickerProviderStateMixin {
  /// Currently active locale instance.
  late T _currentLocale;

  /// Drives the animated reveal when switching locales.
  late AnimationController _animationController;

  /// Holds screenshot and transition state for animated switching.
  late LocaleAnimationModel _animationModel;

  @override
  void initState() {
    super.initState();

    final effectiveLocaleId =
        ValuesRuntime.currentLocaleId ?? widget.initialLocale;

    int index = widget.locales.indexWhere(
      (element) => element.id == effectiveLocaleId,
    );

    if (index == -1) {
      index = 0;
    }

    _currentLocale = widget.locales[index];
    ValuesRuntime.currentLocaleId = _currentLocale.id;

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
        final index = widget.locales.indexWhere((locale) => locale.id == id);
        return index == -1 ? null : widget.locales[index];
      },
      applyLocale: _applyLocale,
      wrapLocaledChild: (locale, child) => LocaleManager<LocaleValues>(
        locales: widget.locales,
        currentLocale: locale as LocaleValues,
        changeAppLocale: _changeLocale,
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
    unawaited(_animationModel.changeAppLocale(localeId: id, origin: origin));
  }

  /// Updates the active locale by its ID.
  void _applyLocale(String id) {
    final index = widget.locales.indexWhere((locale) => locale.id == id);

    if (index != -1) {
      ValuesRuntime.currentLocaleId = id;
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
    return LocaleAnimationInherited(
      notifier: _animationModel,
      child: RepaintBoundary(
        key: _animationModel.previewContainer,
        child: Listener(
          onPointerDown: (event) {
            _animationModel.lastPointerDown = event.position;
          },
          child: LocaleManager<LocaleValues>(
            locales: widget.locales,
            currentLocale: _currentLocale,
            changeAppLocale: _changeLocale,
            child: widget.useLocaleSwitchingArea
                ? LocaleSwitchingArea(child: widget.child)
                : widget.child,
          ),
        ),
      ),
    );
  }
}
