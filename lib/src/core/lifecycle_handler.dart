import 'package:flutter/material.dart';

typedef LifecycleListener = Function(AppLifecycleState);

class LifecycleHandler extends StatefulWidget {
  final Widget child;
  final LifecycleListener lifecycleListener;
  const LifecycleHandler({
    required this.lifecycleListener,
    required this.child,
    super.key,
  });

  @override
  State<LifecycleHandler> createState() => _LifecycleHandlerState();
}

class _LifecycleHandlerState extends State<LifecycleHandler>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    widget.lifecycleListener(state);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
