import 'package:flutter/cupertino.dart';

/// A widget that smoothly expands or collapses its [child] with animation.
///
/// [ExpandedableWidget] uses a [SizeTransition] internally to animate the
/// visibility of its child based on the [expand] flag.
///
/// When [expand] is `true`, the widget animates from zero height to full size.
/// When `false`, it collapses back smoothly.
///
/// Example:
/// ```dart
/// ExpandedableWidget(
///   expand: isExpanded,
///   child: Text('Expandable content'),
/// )
/// ```
class ExpandableWidget extends StatefulWidget {
  /// Creates an [ExpandedableWidget].
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
  /// Controls the expansion animation.
  late AnimationController expandController;

  /// Curved animation applied to the size transition.
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    prepareAnimations();
    _runExpandCheck();
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
  void _runExpandCheck() {
    if (widget.expand) {
      expandController.forward();
    } else {
      expandController.reverse();
    }
  }

  @override
  void didUpdateWidget(ExpandableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _runExpandCheck();
  }

  @override
  void dispose() {
    expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      axisAlignment: 1.0,
      sizeFactor: animation,
      child: widget.child,
    );
  }
}
