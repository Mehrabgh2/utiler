import 'dart:io';

import 'package:hive/hive.dart';

/// Initialises Hive on native platforms with [path] or [Directory.systemTemp].
void hiveInit(String? path) {
  Hive.init(path ?? Directory.systemTemp.path);
}
