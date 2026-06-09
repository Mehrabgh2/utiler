import 'package:http/http.dart' as http;

/// Checks reachability via HTTPS on web (DNS lookup is unavailable).
Future<bool> lookupHost(String address) async {
  try {
    final uri = Uri.parse(
      address.startsWith('http') ? address : 'https://$address',
    );
    final response = await http.head(uri).timeout(const Duration(seconds: 5));
    return response.statusCode < 500;
  } catch (_) {
    return false;
  }
}
