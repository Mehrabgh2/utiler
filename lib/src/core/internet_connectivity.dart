import 'dart:async';

import 'package:utiler/src/core/connectivity_backend_web.dart'
    if (dart.library.io) 'package:utiler/src/core/connectivity_backend_io.dart';
import 'package:utiler/src/core/internet_lookup_web.dart'
    if (dart.library.io) 'package:utiler/src/core/internet_lookup_io.dart';

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
/// [InternetConnectivity] wraps a platform connectivity backend
/// (`connectivity_plus` on native, the browser `navigator.onLine` API on
/// web/WASM) and adds:
/// - interpreted network status ([InternetStatus])
/// - optional VPN detection (native only)
/// - real internet reachability check via DNS lookup (HTTP HEAD on web)
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

  static final ConnectivityBackend _connectivity = ConnectivityBackend();

  static StreamController<InternetStatus>? _controller;
  static StreamSubscription<InternetStatus>? _subscription;

  /// Returns the current interpreted network status.
  static Future<InternetStatus> get currentStatus =>
      _connectivity.checkConnectivity();

  /// Stream of network status updates.
  ///
  /// Emits a new [InternetStatus] whenever connectivity changes.
  static Stream<InternetStatus> get onStatusChange {
    _controller ??= StreamController<InternetStatus>.broadcast();

    _subscription ??= _connectivity.onConnectivityChanged.listen((status) {
      _controller?.add(status);
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
      return await lookupHost(address);
    } catch (_) {
      return false;
    }
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
