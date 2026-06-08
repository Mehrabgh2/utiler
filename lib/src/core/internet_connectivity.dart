import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Represents the current interpreted internet state of the device.
///
/// - [connected]: device has an active network connection
/// - [vpn]: device is connected through a VPN
/// - [disconnected]: no usable network connection
enum InternetStatus {
  /// Device has an active network connection.
  connected,

  /// Device is connected through a VPN.
  vpn,

  /// No usable network connection.
  disconnected,
}

/// A utility for monitoring and checking internet connectivity status.
///
/// [InternetConnectivity] wraps [Connectivity] from `connectivity_plus`
/// and adds:
/// - interpreted network status ([InternetStatus])
/// - optional VPN detection
/// - real internet reachability check via DNS lookup
///
/// It provides both:
/// - a one-time status check ([currentStatus])
/// - a reactive stream ([onStatusChange])
///
/// Example:
/// ```dart
/// final status = await InternetConnectivity.currentStatus;
/// print(status);
///
/// InternetConnectivity.onStatusChange.listen((status) {
///   print('Network changed: $status');
/// });
///
/// final hasInternet =
///     await InternetConnectivity.hasInternetAccess();
/// ```
class InternetConnectivity {
  InternetConnectivity._();

  static final Connectivity _connectivity = Connectivity();

  static StreamController<InternetStatus>? _controller;
  static StreamSubscription? _subscription;

  /// Returns the current interpreted network status.
  static Future<InternetStatus> get currentStatus async {
    final result = await _connectivity.checkConnectivity();
    return _mapResult(result);
  }

  /// Stream of network status updates.
  ///
  /// Emits a new [InternetStatus] whenever connectivity changes.
  static Stream<InternetStatus> get onStatusChange {
    _controller ??= StreamController<InternetStatus>.broadcast();

    _subscription ??= _connectivity.onConnectivityChanged.listen((result) {
      _controller?.add(_mapResult(result));
    });

    return _controller!.stream;
  }

  /// Checks real internet access by performing a DNS lookup.
  ///
  /// This verifies actual internet reachability, not just network connection.
  ///
  /// [address] defaults to `google.com`.
  static Future<bool> hasInternetAccess([String address = 'google.com']) async {
    try {
      final result = await InternetAddress.lookup(address);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Maps raw [ConnectivityResult] values into [InternetStatus].
  static InternetStatus _mapResult(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return InternetStatus.disconnected;
    }
    final hasVpn = results.contains(ConnectivityResult.vpn);
    if (hasVpn) {
      return InternetStatus.vpn;
    }

    final hasConnection = results.any(
      (r) =>
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.ethernet,
    );

    if (hasConnection) {
      return InternetStatus.connected;
    }
    return InternetStatus.disconnected;
  }

  /// Cleans up internal stream resources.
  ///
  /// Should be called when the app no longer needs connectivity monitoring.
  static Future<void> dispose() async {
    await _subscription?.cancel();
    await _controller?.close();
    _subscription = null;
    _controller = null;
  }
}
