import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:utiler/src/core/internet_connectivity.dart';

/// IO/native connectivity backend backed by `package:connectivity_plus`.
///
/// This file is only compiled on platforms where `dart:io` is available, so the
/// `connectivity_plus` dependency (and its transitive `dart:io` usage) never
/// reaches a web/WASM build.
class ConnectivityBackend {
  /// Creates a backend wrapping a [Connectivity] instance.
  ConnectivityBackend() : _connectivity = Connectivity();

  final Connectivity _connectivity;

  /// Returns the current interpreted network status.
  Future<InternetStatus> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    return _mapResult(result);
  }

  /// Stream of interpreted network status changes.
  Stream<InternetStatus> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged.map(_mapResult);

  /// Maps raw [ConnectivityResult] values into [InternetStatus].
  InternetStatus _mapResult(List<ConnectivityResult> results) {
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

  /// Releases any resources held by the backend.
  Future<void> dispose() async {}
}
