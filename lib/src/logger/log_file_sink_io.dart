import 'dart:io';

/// Appends [message] to `app.log` inside [directory] on IO platforms.
Future<void> appendLogToFile(String directory, String message) async {
  final file = File('$directory/app.log');
  await file.writeAsString('$message\n', mode: FileMode.append);
}
