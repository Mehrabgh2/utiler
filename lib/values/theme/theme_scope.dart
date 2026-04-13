import 'dart:async';

import 'package:flutter/material.dart';

import 'theme_manager.dart';
import 'theme_transition_scope.dart';
import 'theme_values.dart';

class ThemeScope<T extends ThemeValues> extends StatefulWidget {
  final Widget child;
  final List<T> themes;
  final String initialTheme;
  final int transitionInitRadius;
  final Duration transitionDuration;
  final Offset transitionOffset;
  final Function(String)? themeChanged;

  const ThemeScope({
    super.key,
    this.themes = const [],
    this.transitionInitRadius = 60,
    this.transitionDuration = const Duration(milliseconds: 1250),
    this.transitionOffset = Offset.zero,
    this.themeChanged,
    required this.child,
    required this.initialTheme,
  });

  static void changeTheme(
    BuildContext context,
    String id, [
    Offset? offset,
    int? transitionInitRadius,
    Duration? transitionDuration,
  ]) {
    final inheritedWidget = ThemeManager.of(context);
    if (inheritedWidget != null) {
      inheritedWidget.changeTheme(
        id,
        offset,
        transitionInitRadius,
        transitionDuration,
      );
    }
  }

  static ThemeValues? getCurrentTheme(BuildContext context) {
    return ThemeManager.of(context)?.currentTheme;
  }

  static List<ThemeValues>? getAllThemes(BuildContext context) {
    return ThemeManager.of(context)?.themes;
  }

  @override
  State<ThemeScope<T>> createState() => _ThemeScope<T>();
}

class _ThemeScope<T extends ThemeValues> extends State<ThemeScope<T>> {
  late T _currentTheme;
  bool _changingTheme = false;
  Offset? _offset;
  int? _transitionInitRadius;
  Duration? _transitionDuration;

  @override
  void initState() {
    super.initState();
    int index = widget.themes.indexWhere(
      (element) => element.id == widget.initialTheme,
    );
    if (index == -1) {
      index = 0;
    }
    _currentTheme = widget.themes[index];
  }

  void _changeTheme(
    String id, [
    Offset? offset,
    int? transitionInitRadius,
    Duration? transitionDuration,
  ]) {
    if (!_changingTheme) {
      final index = widget.themes.indexWhere((theme) => theme.id == id);
      if (index != -1) {
        if (offset != null) {
          _offset = offset;
        }
        if (transitionInitRadius != null) {
          _transitionInitRadius = transitionInitRadius;
        }
        if (transitionDuration != null) {
          _transitionDuration = transitionDuration;
        }
        setState(() {
          _changingTheme = true;
          _currentTheme = widget.themes[index];
          if (widget.themeChanged != null) {
            widget.themeChanged!(widget.themes[index].id);
          }
          Timer(widget.transitionDuration, () {
            _changingTheme = false;
            _offset = null;
            _transitionInitRadius = null;
            _transitionDuration = null;
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemeManager<ThemeValues>(
      themes: widget.themes,
      currentTheme: _currentTheme,
      changeTheme: _changeTheme,
      child: ThemeTransitionScope(
        duration: _transitionDuration ?? widget.transitionDuration,
        initRdius: _transitionInitRadius ?? widget.transitionInitRadius,
        offset: _offset ?? widget.transitionOffset,
        child: widget.child,
      ),
    );
  }
}
