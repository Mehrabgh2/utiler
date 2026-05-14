import 'package:flutter/material.dart';

/// A customizable button widget built with [InkWell] for ripple effects.
///
/// [InkwellButton] provides a simple wrapper around [Material] + [InkWell]
/// to create tappable areas with configurable background color, ripple color,
/// and border radius.
///
/// Example:
/// ```dart
/// InkwellButton(
///   onPressed: () {},
///   borderRadius: 12,
///   color: Colors.white,
///   overlayColor: Colors.grey.withOpacity(0.2),
///   child: Padding(
///     padding: EdgeInsets.all(16),
///     child: Text('Tap me'),
///   ),
/// )
/// ```
class InkwellButton extends StatelessWidget {
  /// Creates an [InkwellButton].
  const InkwellButton({
    super.key,
    required this.child,
    this.onPressed,
    this.color = Colors.white,
    this.overlayColor,
    this.borderRadius = 0,
  });

  /// The widget displayed inside the button.
  final Widget child;

  /// Callback triggered when the button is tapped.
  final VoidCallback? onPressed;

  /// Background color of the button.
  final Color? color;

  /// Color of the ink splash (ripple effect).
  final Color? overlayColor;

  /// Corner radius of the button.
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        overlayColor: WidgetStateProperty.resolveWith((states) => overlayColor),
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onPressed,
        child: child,
      ),
    );
  }
}
