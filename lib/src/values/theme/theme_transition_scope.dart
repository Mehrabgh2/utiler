import 'package:flutter/material.dart';

import 'theme_manager.dart';
import 'theme_scope.dart';
import 'theme_values.dart';

class ThemeTransitionScope extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Offset offset;
  final int initRdius;

  const ThemeTransitionScope({
    super.key,
    required this.offset,
    required this.duration,
    required this.child,
    required this.initRdius,
  });

  @override
  State<ThemeTransitionScope> createState() => _ThemeTransitionScopeState();
}

class _ThemeTransitionScopeState extends State<ThemeTransitionScope>
    with SingleTickerProviderStateMixin {
  ThemeValues? _lastTheme;
  ThemeValues? _currentTheme;
  late AnimationController _controller;
  late Animation<double> _radiusAnimation;

  bool _animating = false;
  bool _isVisible = false;

  late double initialRadius;
  late double maxRadius;

  @override
  void initState() {
    super.initState();
    initialRadius = widget.initRdius / 2;
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _controller.addListener(() => setState(() {}));
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        setState(() => _animating = false);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final manager = ThemeManager.of<ThemeValues>(context);
    if (manager == null) return;
    _lastTheme = _currentTheme;
    _currentTheme = manager.currentTheme;
    if (_lastTheme == null) {
      _lastTheme = _currentTheme;
      return;
    }
    final screenSize = MediaQuery.of(context).size;
    maxRadius = _calculateMaxRadius(screenSize, widget.offset);
    _radiusAnimation = Tween<double>(
      begin: initialRadius,
      end: maxRadius,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    setState(() {
      _animating = true;
      _isVisible = !_isVisible;
      if (_isVisible) {
        _controller.forward();
      } else {
        _controller.reverse(from: .575);
      }
    });
  }

  double _calculateMaxRadius(Size size, Offset origin) {
    final distToTopLeft = (origin - Offset.zero).distance;
    final distToTopRight = (origin - Offset(size.width, 0)).distance;
    final distToBottomLeft = (origin - Offset(0, size.height)).distance;
    final distToBottomRight =
        (origin - Offset(size.width, size.height)).distance;

    return [
      distToTopLeft,
      distToTopRight,
      distToBottomLeft,
      distToBottomRight,
    ].reduce((a, b) => a + b);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final alignmentX = (widget.offset.dx / screenSize.width) * 2 - 1;
    final alignmentY = (widget.offset.dy / screenSize.height) * 2 - 1;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          widget.child,
          if (_animating)
            ThemeScope<ThemeValues>(
              themes: [_isVisible ? _lastTheme! : _currentTheme!],
              initialTheme: _isVisible ? _lastTheme!.id : _currentTheme!.id,
              child: widget.child,
            ),
          if (_animating)
            ThemeScope<ThemeValues>(
              themes: [_isVisible ? _currentTheme! : _lastTheme!],
              initialTheme: _isVisible ? _currentTheme!.id : _lastTheme!.id,
              child: ClipOval(
                clipper: Real(
                  radius: _radiusAnimation.value,
                  origin: widget.offset,
                ),
                child: Align(
                  alignment: Alignment(alignmentX, alignmentY),
                  child: widget.child,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class Real extends CustomClipper<Rect> {
  Real({required this.radius, required this.origin});
  final double radius;
  final Offset origin;

  @override
  Rect getClip(Size size) {
    final effectiveRadius = radius < 0 ? 0.0 : radius;
    return Rect.fromCircle(center: origin, radius: effectiveRadius);
  }

  @override
  bool shouldReclip(Real oldClipper) {
    return oldClipper.radius != radius || oldClipper.origin != origin;
  }
}
