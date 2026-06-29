import 'dart:async';
import 'dart:js_interop';

import 'package:utiler/src/core/internet_connectivity.dart';
import 'package:web/web.dart' as web;

/// Web/WASM connectivity backend backed by the browser `navigator.onLine` API.
///
/// This is the default implementation. It avoids `package:connectivity_plus`
/// entirely so the web/WASM compile never pulls in `dart:io`, keeping the
/// package WASM-compatible.
class ConnectivityBackend {
  /// Returns the current interpreted network status.
  Future<InternetStatus> checkConnectivity() async {
    return web.window.navigator.onLine
        ? InternetStatus.connected
        : InternetStatus.disconnected;
  }

  /// Stream of interpreted network status changes.
  ///
  /// Driven by the browser `online`/`offline` window events.
  Stream<InternetStatus> get onConnectivityChanged {
    // The controller's lifetime is tied to its subscription via onCancel,
    // not to this function scope, so it is not closed here.
    // ignore: close_sinks
    late final StreamController<InternetStatus> controller;

    void onOnline(web.Event _) => controller.add(InternetStatus.connected);
    void onOffline(web.Event _) => controller.add(InternetStatus.disconnected);

    final onlineListener = onOnline.toJS;
    final offlineListener = onOffline.toJS;

    controller = StreamController<InternetStatus>.broadcast(
      onListen: () {
        web.window.addEventListener('online', onlineListener);
        web.window.addEventListener('offline', offlineListener);
      },
      onCancel: () {
        web.window.removeEventListener('online', onlineListener);
        web.window.removeEventListener('offline', offlineListener);
      },
    );

    return controller.stream;
  }

  /// Releases any resources held by the backend.
  Future<void> dispose() async {}
}
