import 'dart:async';

import 'package:flutter/material.dart';
import 'package:utiler/src/values/animation/values_animation_type.dart';
import 'package:utiler/src/values/theme/theme_animation_model.dart';
import 'package:utiler/src/values/theme/theme_manager.dart';
import 'package:utiler/src/values/theme/theme_switching_area.dart';
import 'package:utiler/src/values/theme/theme_values.dart';
import 'package:utiler/src/values/values_runtime.dart';

/// A stateful theme controller that manages typed theme switching.
///
/// [ThemeScope] is responsible for:
/// - holding a list of available themes
/// - selecting an initial theme
/// - switching themes at runtime with an animated reveal
/// - exposing the active theme via [ThemeManager]
///
/// This is the runtime controller layer for strongly typed theming.
///
/// Example:
/// ```dart
/// ThemeScope<AppTheme>(
///   initialTheme: 'light',
///   themes: themes,
///   child: MyApp(),
/// )
/// ```
class ThemeScope<T extends ThemeValues> extends StatefulWidget {
  /// Creates a [ThemeScope].
  const ThemeScope({
    required this.child,
    required this.initialTheme,
    this.themes = const [],
    this.themeChanged,
    this.animation,
    this.animationDuration = const Duration(milliseconds: 500),
    this.useThemeSwitchingArea = true,
    super.key,
  });

  /// The widget below this scope.
  final Widget child;

  /// The ID of the initial theme to apply.
  final String initialTheme;

  /// List of available typed themes.
  final List<T> themes;

  /// Optional callback triggered when theme changes.
  final Function(String)? themeChanged;

  /// Default theme transition for switches initiated from this scope.
  ///
  /// Written to [ValuesRuntime.themeAnimation] when non-null.
  /// Per-call overrides take priority; instant when both are `null`.
  final ValuesAnimationType? animation;

  /// Duration of the animated reveal when switching themes.
  final Duration animationDuration;

  /// When `false`, theme transitions are rendered by [CombinedSwitchingArea].
  final bool useThemeSwitchingArea;

  /// Changes the active theme by its ID with an animated reveal.
  ///
  /// Animation priority:
  /// 1. [animation] passed to this call
  /// 2. [ValuesRuntime.themeAnimation] from [UtilerScope] or scope widgets
  /// 3. Instant change when both are `null`
  ///
  /// Example:
  /// ```dart
  /// ThemeScope.changeTheme(context, 'dark', ValuesAnimationType.fade);
  /// ```
  static void changeTheme(
    BuildContext context,
    String id, [
    ValuesAnimationType? animation,
  ]) {
    final model = ThemeAnimationInherited.maybeOf(context);
    if (model != null) {
      final origin =
          model.lastPointerDown ?? themeAnimationOrigin(context, model);
      model.lastPointerDown = null;
      unawaited(
        model.changeTheme(themeId: id, origin: origin, animation: animation),
      );
      return;
    }

    final inheritedWidget = ThemeManager.of(context);
    inheritedWidget?.changeTheme(id);
  }

  /// Returns the currently active typed theme from the nearest [ThemeManager].
  static ThemeValues? getCurrentTheme(BuildContext context) {
    return ThemeManager.of(context)?.currentTheme;
  }

  /// Returns all themes registered on the nearest [ThemeManager].
  static List<ThemeValues>? getAllThemes(BuildContext context) {
    return ThemeManager.of(context)?.themes;
  }

  @override
  State<ThemeScope<T>> createState() => _ThemeScope<T>();
}

/// Internal state for [ThemeScope].
///
/// Handles initialization and runtime switching of themes.
class _ThemeScope<T extends ThemeValues> extends State<ThemeScope<T>>
    with SingleTickerProviderStateMixin {
  /// Currently selected theme instance.
  late T _currentTheme;

  /// Drives the animated reveal when switching themes.
  late AnimationController _animationController;

  /// Holds screenshot and transition state for animated switching.
  late ThemeAnimationModel _animationModel;

  @override
  void initState() {
    super.initState();

    final effectiveThemeId =
        ValuesRuntime.currentThemeId ?? widget.initialTheme;

    int index = widget.themes.indexWhere(
      (element) => element.id == effectiveThemeId,
    );

    if (index == -1) {
      index = 0;
    }

    _currentTheme = widget.themes[index];
    ValuesRuntime.currentThemeId = _currentTheme.id;

    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    if (widget.animation != null) {
      ValuesRuntime.themeAnimation = widget.animation;
    }

    _animationModel = ThemeAnimationModel(
      controller: _animationController,
      fixedDuration: widget.animationDuration,
      getCurrentTheme: () => _currentTheme,
      resolveTheme: (id) {
        final index = widget.themes.indexWhere((theme) => theme.id == id);
        return index == -1 ? null : widget.themes[index];
      },
      applyTheme: _applyTheme,
      wrapThemedChild: (theme, child) => ThemeManager<ThemeValues>(
        themes: widget.themes,
        currentTheme: theme as ThemeValues,
        changeTheme: _changeTheme,
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

  /// Triggers an animated theme change by ID.
  void _changeTheme(String id) {
    if (!mounted) {
      return;
    }

    final origin =
        _animationModel.lastPointerDown ??
        themeAnimationOrigin(context, _animationModel);
    _animationModel.lastPointerDown = null;
    unawaited(_animationModel.changeTheme(themeId: id, origin: origin));
  }

  /// Updates the active theme by ID.
  void _applyTheme(String id) {
    final index = widget.themes.indexWhere((theme) => theme.id == id);

    if (index != -1) {
      ValuesRuntime.currentThemeId = id;
      setState(() {
        _currentTheme = widget.themes[index];

        if (widget.themeChanged != null) {
          widget.themeChanged!(widget.themes[index].id);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemeAnimationInherited(
      notifier: _animationModel,
      child: RepaintBoundary(
        key: _animationModel.previewContainer,
        child: Listener(
          onPointerDown: (event) {
            _animationModel.lastPointerDown = event.position;
          },
          child: ThemeManager<ThemeValues>(
            themes: widget.themes,
            currentTheme: _currentTheme,
            changeTheme: _changeTheme,
            child: widget.useThemeSwitchingArea
                ? ThemeSwitchingArea(child: widget.child)
                : widget.child,
          ),
        ),
      ),
    );
  }
}
