import 'package:http/http.dart' as http;

/// File upload from disk is not supported on web.
Future<http.MultipartFile> multipartFileFromPath(String field, String path) {
  throw UnsupportedError(
    'uploadFile with a file path is not supported on web. '
    'Use MultipartFile.fromBytes instead.',
  );
}

/// File download to disk is not supported on web.
Future<void> writeResponseStreamToFile(
  String savePath,
  Stream<List<int>> stream, {
  void Function(double progress)? onProgress,
  int totalBytes = 0,
}) {
  throw UnsupportedError(
    'downloadFile is not supported on web. '
    'Read response bytes in memory instead.',
  );
}
