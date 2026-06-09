import 'dart:io';

import 'package:http/http.dart' as http;

/// Creates a multipart file from a disk [path] on IO platforms.
Future<http.MultipartFile> multipartFileFromPath(String field, String path) {
  return http.MultipartFile.fromPath(field, path);
}

/// Writes [stream] to [savePath] on IO platforms.
Future<void> writeResponseStreamToFile(
  String savePath,
  Stream<List<int>> stream, {
  void Function(double progress)? onProgress,
  int totalBytes = 0,
}) async {
  final file = File(savePath);
  final sink = file.openWrite();
  var receivedBytes = 0;

  await for (final chunk in stream) {
    sink.add(chunk);
    receivedBytes += chunk.length;
    if (onProgress != null && totalBytes > 0) {
      onProgress(receivedBytes / totalBytes);
    }
  }

  await sink.flush();
  await sink.close();
}
