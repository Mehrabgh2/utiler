import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

enum InternetStatus { connected, vpn, disconnected }

class InternetConnectivity {
  InternetConnectivity._();

  static final Connectivity _connectivity = Connectivity();

  static StreamController<InternetStatus>? _controller;
  static StreamSubscription? _subscription;

  static Future<InternetStatus> get currentStatus async {
    final result = await _connectivity.checkConnectivity();
    return _mapResult(result);
  }

  static Stream<InternetStatus> get onStatusChange {
    _controller ??= StreamController<InternetStatus>.broadcast();
    _subscription ??= _connectivity.onConnectivityChanged.listen((result) {
      _controller?.add(_mapResult(result));
    });
    return _controller!.stream;
  }

  static Future<bool> hasInternetAccess([String address = 'google.com']) async {
    try {
      final result = await InternetAddress.lookup(address);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

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

  static Future<void> dispose() async {
    await _subscription?.cancel();
    await _controller?.close();
    _subscription = null;
    _controller = null;
  }
}
