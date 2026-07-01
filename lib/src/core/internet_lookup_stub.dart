/// Fallback reachability check for platforms with neither `dart:io` nor
/// `dart:js_interop` available.
///
/// This branch is never selected on Android, iOS, desktop, or web/WASM — see
/// [internet_connectivity.dart] for why it exists.
Future<bool> lookupHost(String address) async => false;
