import 'dart:async';

import 'package:utiler/src/core/internet_connectivity.dart';

/// Fallback connectivity backend for platforms with neither `dart:io` nor
/// `dart:js_interop` available.
///
/// This branch is never selected on Android, iOS, desktop, or web/WASM — it
/// exists only so the conditional import in `internet_connectivity.dart`
/// resolves to a target with no platform-restricted imports, which keeps
/// this package's declared platform support accurate.
class ConnectivityBackend {
  /// Always reports [InternetStatus.disconnected].
  Future<InternetStatus> checkConnectivity() async =>
      InternetStatus.disconnected;

  /// A stream that never emits.
  Stream<InternetStatus> get onConnectivityChanged => const Stream.empty();

  /// Releases any resources held by the backend.
  Future<void> dispose() async {}
}
