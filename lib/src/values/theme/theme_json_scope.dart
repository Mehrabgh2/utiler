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
///   themes: {
///     'light': {...},
///     'dark': {...},
///   },
///   child: MyApp(),
/// )
/// ```
class ThemeJsonScope extends StatefulWidget {
  /// Creates a [ThemeJsonScope].
  const ThemeJsonScope({
    required this.child,
    required this.initialTheme,
    this.themes = const {},
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

  /// Available JSON themes keyed by theme id, e.g.
  /// `{'light': {...}, 'dark': {...}}`.
  final Map<String, dynamic> themes;

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

  /// Changes the current theme by its identifier.
  ///
  /// Animation priority:
  /// 1. [animation] passed to this call
  /// 2. [ValuesRuntime.themeAnimation] from [UtilerScope] or scope widgets
  /// 3. Instant change when both are `null`
  ///
  /// Example:
  /// ```dart
  /// ThemeJsonScope.changeAppTheme(context, 'dark', ValuesAnimationType.circle);
  /// ```
  static void changeAppTheme(
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
        model.changeAppTheme(themeId: id, origin: origin, animation: animation),
      );
      return;
    }

    final inheritedWidget = ThemeJsonManager.of(context);
    inheritedWidget?.changeAppTheme(id);
  }

  /// Returns the currently active theme map.
  static Map<String, dynamic>? getCurrentTheme(BuildContext context) {
    return ThemeJsonManager.of(context)?.currentTheme;
  }

  /// Returns all available JSON themes keyed by theme id.
  static Map<String, dynamic>? getAllThemes(BuildContext context) {
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
  /// Currently active theme as a single-entry map (`{id: values}`).
  late Map<String, dynamic> _currentTheme;

  /// Available themes as single-entry maps, derived from [widget.themes].
  ///
  /// Each entry keeps a stable identity so the animation model can compare
  /// resolved themes by reference.
  late final List<Map<String, dynamic>> _themeEntries;

  /// Drives the animated reveal transition.
  late AnimationController _animationController;

  /// Holds screenshot and transition state for theme switching.
  late ThemeAnimationModel _animationModel;

  @override
  void initState() {
    super.initState();

    _themeEntries = widget.themes.entries
        .map((entry) => <String, dynamic>{entry.key: entry.value})
        .toList();

    final effectiveThemeId =
        ValuesRuntime.currentThemeId ?? widget.initialTheme;

    int index = _themeEntries.indexWhere(
      (element) => element.keys.first == effectiveThemeId,
    );

    if (index == -1) {
      index = 0;
    }

    _currentTheme = _themeEntries[index];
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
        final index = _themeEntries.indexWhere(
          (element) => element.keys.first == id,
        );
        return index == -1 ? null : _themeEntries[index];
      },
      applyTheme: _applyTheme,
      wrapThemedChild: (theme, child) => ThemeJsonManager(
        themes: widget.themes,
        currentTheme: theme as Map<String, dynamic>,
        changeAppTheme: _changeTheme,
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
    unawaited(_animationModel.changeAppTheme(themeId: id, origin: origin));
  }

  /// Updates the active theme by its ID.
  void _applyTheme(String id) {
    final index = _themeEntries.indexWhere(
      (element) => element.keys.first == id,
    );

    if (index != -1) {
      ValuesRuntime.currentThemeId = id;
      setState(() {
        _currentTheme = _themeEntries[index];

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
            changeAppTheme: _changeTheme,
            child: widget.useThemeSwitchingArea
                ? ThemeSwitchingArea(child: widget.child)
                : widget.child,
          ),
        ),
      ),
    );
  }
}
