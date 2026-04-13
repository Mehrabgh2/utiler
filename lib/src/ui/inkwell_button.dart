import 'package:flutter/material.dart';

class InkwellButton extends StatelessWidget {
  const InkwellButton({
    super.key,
    required this.child,
    this.onPressed,
    this.color = Colors.white,
    this.overlayColor,
    this.borderRadius = 0,
  });
  final Widget child;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? overlayColor;
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
