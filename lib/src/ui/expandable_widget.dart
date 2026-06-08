import 'dart:async';

import 'package:flutter/cupertino.dart';

/// A widget that smoothly expands or collapses its [child] with animation.
///
/// [ExpandableWidget] uses [ClipRect] and [Align] internally to animate the
/// visibility of its child based on the [expand] flag.
///
/// When [expand] is `true`, the widget animates from zero height to full size.
/// When `false`, it collapses back smoothly.
///
/// Example:
/// ```dart
/// ExpandableWidget(
///   expand: isExpanded,
///   child: Text('Expandable content'),
/// )
/// ```
class ExpandableWidget extends StatefulWidget {
  /// Creates an [ExpandableWidget].
  const ExpandableWidget({this.expand = false, required this.child, super.key});

  /// Whether the widget should be expanded or collapsed.
  final bool expand;

  /// The widget below this animated expansion.
  final Widget child;

  @override
  ExpandedSectionState createState() => ExpandedSectionState();
}

/// State class responsible for managing the expand/collapse animation.
///
/// Uses an [AnimationController] with a [CurvedAnimation] to smoothly
/// transition between expanded and collapsed states.
class ExpandedSectionState extends State<ExpandableWidget>
    with SingleTickerProviderStateMixin {
  /// Creates state that drives [ExpandableWidget] expand/collapse animation.
  ExpandedSectionState();

  /// Controls the expansion animation.
  late AnimationController expandController;

  /// Curved animation applied to the expand/collapse transition.
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    prepareAnimations();
    unawaited(_runExpandCheck());
  }

  /// Initializes animation controller and curve.
  void prepareAnimations() {
    expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    animation = CurvedAnimation(
      parent: expandController,
      curve: Curves.fastOutSlowIn,
    );
  }

  /// Runs the appropriate animation based on [widget.expand].
  Future<void> _runExpandCheck() async {
    if (widget.expand) {
      await expandController.forward();
    } else {
      await expandController.reverse();
    }
  }

  @override
  void didUpdateWidget(ExpandableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    unawaited(_runExpandCheck());
  }

  @override
  void dispose() {
    expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return ClipRect(
          child: Align(
            alignment: Alignment.bottomCenter,
            heightFactor: animation.value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
