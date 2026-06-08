import 'dart:async';

import 'package:flutter/material.dart';
import 'package:utiler/src/values/animation/values_animation_type.dart';
import 'package:utiler/src/values/theme/theme_animation_model.dart';
import 'package:utiler/src/values/theme/theme_json_manager.dart';
import 'package:utiler/src/values/theme/theme_switching_area.dart';
import 'package:utiler/src/values/values_runtime.dart';

/// A stateful scope widget that manages JSON-based theme state.
///
/// [ThemeJsonScope] is responsible for:
/// - storing all available JSON themes
/// - tracking the currently selected theme
/// - switching themes at runtime with an animated reveal
/// - providing theme data through [ThemeJsonManager]
///
/// This widget acts as the controller layer for dynamic JSON theming.
///
/// Example:
/// ```dart
/// ThemeJsonScope(
///   initialTheme: 'light',
///   themes: [
///     {'light': {...}},
///     {'dark': {...}},
///   ],
///   child: MyApp(),
/// )
/// ```
class ThemeJsonScope extends StatefulWidget {
  /// Creates a [ThemeJsonScope].
  const ThemeJsonScope({
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

  /// The initial theme identifier (e.g. `"light"`, `"dark"`).
  final String initialTheme;

  /// List of available JSON theme maps.
  final List<Map<String, dynamic>> themes;

  /// Optional callback triggered when theme changes.
  final Function(String)? themeChanged;

  /// Default theme transition. `null` = instant change unless overridden per call.
  final ValuesAnimationType? animation;

  /// Duration of the animated reveal when switching themes.
  final Duration animationDuration;

  /// When `false`, theme transitions are rendered by [CombinedSwitchingArea].
  final bool useThemeSwitchingArea;

  /// Changes the current theme by its identifier.
  ///
  /// Animation priority: [animation] → [UtilerScope.themeAnimation] → instant.
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
        model.changeTheme(
          themeId: id,
          origin: origin,
          animation: animation,
        ),
      );
      return;
    }

    final inheritedWidget = ThemeJsonManager.of(context);
    inheritedWidget?.changeTheme(id);
  }

  /// Returns the currently active theme map.
  static Map<String, dynamic>? getCurrentTheme(BuildContext context) {
    return ThemeJsonManager.of(context)?.currentTheme;
  }

  /// Returns all available JSON themes.
  static List<Map<String, dynamic>>? getAllThemes(BuildContext context) {
    return ThemeJsonManager.of(context)?.themes;
  }

  @override
  State<ThemeJsonScope> createState() => _ThemeJsonScope();
}

/// Internal state for [ThemeJsonScope].
///
/// Handles initialization and switching of JSON themes.
class _ThemeJsonScope extends State<ThemeJsonScope>
    with SingleTickerProviderStateMixin {
  /// Currently active theme map.
  late Map<String, dynamic> _currentTheme;

  /// Drives the animated reveal transition.
  late AnimationController _animationController;

  /// Holds screenshot and transition state for theme switching.
  late ThemeAnimationModel _animationModel;

  @override
  void initState() {
    super.initState();

    final effectiveThemeId =
        ValuesRuntime.currentThemeId ?? widget.initialTheme;

    int index = widget.themes.indexWhere(
      (element) => element.keys.first == effectiveThemeId,
    );

    if (index == -1) {
      index = 0;
    }

    _currentTheme = widget.themes[index];
    ValuesRuntime.currentThemeId = _currentTheme.keys.first;

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
        final index = widget.themes.indexWhere(
          (element) => element.keys.first == id,
        );
        return index == -1 ? null : widget.themes[index];
      },
      applyTheme: _applyTheme,
      wrapThemedChild: (theme, child) => ThemeJsonManager(
        themes: widget.themes,
        currentTheme: theme as Map<String, dynamic>,
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

  /// Updates the active theme by its ID.
  void _applyTheme(String id) {
    final index = widget.themes.indexWhere(
      (element) => element.keys.first == id,
    );

    if (index != -1) {
      ValuesRuntime.currentThemeId = id;
      setState(() {
        _currentTheme = widget.themes[index];

        if (widget.themeChanged != null) {
          widget.themeChanged!(id);
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
          child: ThemeJsonManager(
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
