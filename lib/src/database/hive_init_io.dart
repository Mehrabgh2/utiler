import 'dart:io';

import 'package:hive_ce/hive.dart';

/// Initialises Hive on native platforms with [path] or [Directory.systemTemp].
void hiveInit(String? path) {
  Hive.init(path ?? Directory.systemTemp.path);
}
