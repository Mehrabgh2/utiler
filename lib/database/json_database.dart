import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../logger/pretty_logger.dart';
import 'json_database_data.dart';

class JsonDatabase {
  Box<String>? _db;
  static const String _boxName = 'jsonDataBox';
  bool _logging = false;

  Future<void> init(bool logging) async {
    _logging = logging;
    if (Hive.isBoxOpen(_boxName)) {
      _db = Hive.box<String>(_boxName);
    } else {
      try {
        Hive.init((await getApplicationDocumentsDirectory()).path);
        _db = await Hive.openBox<String>(_boxName);
        if (_logging) {
          PrettyLogger.s('Json database initialized successfuly');
        }
      } catch (e) {
        if (_logging) {
          PrettyLogger.e('Json database initializing error: ${e.toString()}');
        }
      }
    }
  }

  Future<bool> put(JsonDatabaseData data) async {
    if (await isInit()) {
      try {
        await _db!.put(data.key, json.encode(data.toJson()));
        if (_logging) {
          PrettyLogger.i('Json Database put "${data.key}" successfuly');
        }
        return true;
      } catch (e) {
        if (_logging) {
          PrettyLogger.e(
            'Json Database put "${data.key}" error: ${e.toString()}',
          );
        }
        throw StateError(
          'Json Database put "${data.key}" error: ${e.toString()}',
        );
      }
    }
    if (_logging) {
      PrettyLogger.e('Json Database put "${data.key}" error: not initialized');
    }
    return false;
  }

  Future<JsonDatabaseData?> get(String key) async {
    if (await isInit()) {
      if (await containsKey(key)) {
        try {
          final jsonString = _db!.get(key);
          if (jsonString != null) {
            JsonDatabaseData data = JsonDatabaseData.fromJson(
              json.decode(jsonString),
            );
            if (_logging) {
              PrettyLogger.i(
                'Json Database get "$key" returned data successfuly',
              );
            }
            return data;
          }
          if (_logging) {
            PrettyLogger.e('Json Database get can`t read "$key"');
          }
        } catch (e) {
          if (_logging) {
            PrettyLogger.e('Json Database get "$key" error: ${e.toString()}');
          }
          throw StateError('Json Database get "$key" error: ${e.toString()}');
        }
      }
      if (_logging) {
        PrettyLogger.e('Json Database get can`t find "$key"');
      }
      return null;
    }
    if (_logging) {
      PrettyLogger.e('Json Database get "$key" error: not initialized');
    }
    return null;
  }

  Future<bool> delete(String key) async {
    if (await isInit()) {
      if (await containsKey(key)) {
        try {
          await _db!.delete(key);
          if (_logging) {
            PrettyLogger.i('Json Database delete "$key" successfuly');
          }
          return true;
        } catch (e) {
          if (_logging) {
            PrettyLogger.e(
              'Json Database delete "$key" error: ${e.toString()}',
            );
          }
          throw StateError(
            'Json Database delete "$key" error: ${e.toString()}',
          );
        }
      }
      if (_logging) {
        PrettyLogger.e('Json Database get can`t find "$key"');
      }
      return false;
    }
    if (_logging) {
      PrettyLogger.e('Json Database delete "$key" error: not initialized');
    }
    return false;
  }

  Future<bool> clear() async {
    if (await isInit()) {
      try {
        _db!.deleteFromDisk();
        if (_logging) {
          PrettyLogger.i('Json Database clear successfuly');
        }
      } catch (e) {
        if (_logging) {
          PrettyLogger.e('Json Database clear error: ${e.toString()}');
        }
        throw StateError('Json Database clear error: ${e.toString()}');
      }
      return true;
    }
    if (_logging) {
      PrettyLogger.e('Json Database clear error: not initialized');
    }
    return false;
  }

  Future<bool> containsKey(String key) async {
    if (await isInit()) {
      try {
        return _db!.containsKey(key);
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  Future<bool> isInit() async {
    if (_db == null) {
      await init(_logging);
    }
    return _db != null;
  }

  Future<void> close() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
    }
  }
}
