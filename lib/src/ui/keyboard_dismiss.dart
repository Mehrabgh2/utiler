import 'package:flutter/material.dart';

/// A wrapper widget that dismisses the keyboard when the user taps outside
/// of a focused input field.
///
/// [KeyboardDismiss] is commonly used to improve UX in forms and screens
/// containing text fields.
///
/// Example:
/// ```dart
/// KeyboardDismiss(
///   child: Scaffold(
///     body: Column(
///       children: [
///         TextField(),
///       ],
///     ),
///   ),
/// )
/// ```
class KeyboardDismiss extends StatelessWidget {
  /// Creates a [KeyboardDismiss] widget.
  const KeyboardDismiss({super.key, required this.child});

  /// The widget below this keyboard dismissal handler.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: child,
    );
  }
}
