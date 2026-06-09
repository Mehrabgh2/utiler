import 'dart:io';

/// Performs a DNS lookup on IO platforms.
Future<bool> lookupHost(String address) async {
  final result = await InternetAddress.lookup(address);
  return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
}
