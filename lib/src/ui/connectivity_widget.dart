import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:utiler/src/core/internet_connectivity.dart';

/// A widget that rebuilds its child whenever the device's [InternetStatus]
/// changes, without requiring manual [StreamSubscription] management.
///
/// [connected] is displayed while the device has an active connection.
/// [disconnected] is displayed when no connection is available.
/// [vpn] is optionally shown when the device is on a VPN; falls back to
/// [connected] when omitted.
///
/// Example:
/// ```dart
/// ConnectivityWidget(
///   connected: (context) => const OnlineContent(),
///   disconnected: (context) => const OfflineBanner(),
/// )
///
/// // With explicit VPN handling:
/// ConnectivityWidget(
///   connected: (context) => const OnlineContent(),
///   disconnected: (context) => const OfflineBanner(),
///   vpn: (context) => const VpnNotice(),
/// )
/// ```
class ConnectivityWidget extends StatefulWidget {
  /// Creates a [ConnectivityWidget].
  const ConnectivityWidget({
    required this.connected,
    required this.disconnected,
    this.vpn,
    super.key,
  });

  /// Builder shown while connected to the internet.
  final Widget Function(BuildContext context) connected;

  /// Builder shown while disconnected from the internet.
  final Widget Function(BuildContext context) disconnected;

  /// Builder shown while connected via VPN. Defaults to [connected] if `null`.
  final Widget Function(BuildContext context)? vpn;

  @override
  State<ConnectivityWidget> createState() => _ConnectivityWidgetState();
}

class _ConnectivityWidgetState extends State<ConnectivityWidget> {
  InternetStatus _status = InternetStatus.connected;
  StreamSubscription<InternetStatus>? _subscription;

  @override
  void initState() {
    super.initState();
    unawaited(_fetchInitialStatus());
    _subscription = InternetConnectivity.onStatusChange.listen((status) {
      if (mounted) setState(() => _status = status);
    });
  }

  Future<void> _fetchInitialStatus() async {
    final status = await InternetConnectivity.currentStatus;
    if (mounted) setState(() => _status = status);
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return switch (_status) {
      InternetStatus.connected => widget.connected(context),
      InternetStatus.vpn => (widget.vpn ?? widget.connected)(context),
      InternetStatus.disconnected => widget.disconnected(context),
    };
  }
}
