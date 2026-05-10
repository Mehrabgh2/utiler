import 'dart:async';

import 'package:flutter/material.dart';

import 'theme_json_manager.dart';
import 'theme_transition_scope.dart';

class ThemeJsonScope extends StatefulWidget {
  final Widget child;
  final List<Map<String, dynamic>> themes;
  final String initialTheme;
  final int transitionInitRadius;
  final Duration transitionDuration;
  final Offset transitionOffset;
  final Function(String)? themeChanged;

  const ThemeJsonScope({
    required this.child,
    required this.initialTheme,
    this.themes = const [],
    this.transitionInitRadius = 60,
    this.transitionDuration = const Duration(milliseconds: 1250),
    this.transitionOffset = Offset.zero,
    this.themeChanged,
    super.key,
  });

  static void changeTheme(
    BuildContext context,
    String id, [
    bool? withAnimation,
    Offset? offset,
    int? transitionInitRadius,
    Duration? transitionDuration,
  ]) {
    final inheritedWidget = ThemeJsonManager.of(context);
    if (inheritedWidget != null) {
      inheritedWidget.changeTheme(
        id,
        withAnimation,
        offset,
        transitionInitRadius,
        transitionDuration,
      );
    }
  }

  static Map<String, dynamic>? getCurrentTheme(BuildContext context) {
    return ThemeJsonManager.of(context)?.currentTheme;
  }

  static List<Map<String, dynamic>>? getAllThemes(BuildContext context) {
    return ThemeJsonManager.of(context)?.themes;
  }

  @override
  State<ThemeJsonScope> createState() => _ThemeJsonScope();
}

class _ThemeJsonScope extends State<ThemeJsonScope> {
  late Map<String, dynamic> _currentTheme;
  bool _changingTheme = false;
  Offset? _offset;
  int? _transitionInitRadius;
  Duration? _transitionDuration;
  bool withAnimation = false;

  @override
  void initState() {
    super.initState();
    int index = widget.themes.indexWhere(
      (element) => element.keys.first == widget.initialTheme,
    );
    if (index == -1) {
      index = 0;
    }
    _currentTheme = widget.themes[index];
  }

  void _changeTheme(
    String id, [
    bool? withAnimation,
    Offset? offset,
    int? transitionInitRadius,
    Duration? transitionDuration,
  ]) {
    this.withAnimation = withAnimation ?? false;
    if (!_changingTheme) {
      if (!this.withAnimation) {
        transitionDuration = Duration(milliseconds: 10);
      }
      final index = widget.themes.indexWhere(
        (element) => element.keys.first == id,
      );
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
            widget.themeChanged!(id);
          }
          Timer(_transitionDuration ?? widget.transitionDuration, () {
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
    return ThemeJsonManager(
      themes: widget.themes,
      currentTheme: _currentTheme,
      changeTheme: _changeTheme,
      child: withAnimation
          ? ThemeTransitionScope(
              duration: _transitionDuration ?? widget.transitionDuration,
              initRdius: _transitionInitRadius ?? widget.transitionInitRadius,
              offset: _offset ?? widget.transitionOffset,
              child: widget.child,
            )
          : widget.child,
    );
  }
}
