import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:utiler/src/database/hive_init_stub.dart'
    if (dart.library.io) 'package:utiler/src/database/hive_init_io.dart';
import 'package:utiler/src/database/json_database_data.dart';
import 'package:utiler/src/logger/pretty_logger.dart';

/// A lightweight JSON-based database built on top of Hive.
///
/// This class provides a simple key-value storage system where values are
/// stored as JSON-encoded strings and mapped to [JsonDatabaseData] objects.
///
/// The database must be initialized using [init] before any operations.
///
/// Example:
/// ```dart
/// final db = JsonDatabase();
/// await db.init(
///   storagePath: '/path/from/your/app', // or a Hive prefix on web
///   logging: true,
/// );
///
/// await db.put(JsonDatabaseData(
///   key: 'user_1',
///   data: {'name': 'Alice', 'age': 30},
/// ));
///
/// final result = await db.get('user_1');
/// print(result?.data);
///
/// await db.close();
/// ```
class JsonDatabase {
  Box<String>? _db;

  /// Internal Hive box name used for storage.
  static const String _boxName = 'jsonDataBox';

  /// Enables or disables logging for database operations.
  bool _logging = false;

  /// Hive storage path or web prefix, set by [init].
  String? _storagePath;

  /// Initializes the database and opens the Hive box.
  ///
  /// [storagePath] is the directory Hive uses to persist boxes on native
  /// platforms (Android, iOS, macOS, Windows, Linux). On web and WASM it is
  /// ignored — Hive uses IndexedDB automatically.
  ///
  /// If [storagePath] is omitted on native, `Directory.systemTemp` is used as
  /// a fallback; pass the path returned by `path_provider` for production use.
  ///
  /// If [logging] is true, internal operations and errors will be logged.
  ///
  /// This method must be called before any database operation.
  Future<void> init({bool logging = false, String? storagePath}) async {
    _logging = logging;
    if (storagePath != null) _storagePath = storagePath;
    if (Hive.isBoxOpen(_boxName)) {
      _db = Hive.box<String>(_boxName);
    } else {
      try {
        hiveInit(_storagePath);
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

  /// Stores a [JsonDatabaseData] entry in the database.
  ///
  /// Returns `true` if the operation succeeds, otherwise `false`.
  /// Throws a [StateError] if a write error occurs after initialization.
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

  /// Retrieves a stored entry by [key].
  ///
  /// Returns a [JsonDatabaseData] if found, otherwise `null`.
  /// Throws a [StateError] if decoding fails after initialization.
  Future<JsonDatabaseData?> get(String key) async {
    if (await isInit()) {
      if (await containsKey(key)) {
        try {
          final jsonString = _db!.get(key);
          if (jsonString != null) {
            final JsonDatabaseData data = JsonDatabaseData.fromJson(
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

  /// Deletes a stored entry by [key].
  ///
  /// Returns `true` if the entry was successfully deleted, otherwise `false`.
  /// Throws a [StateError] if deletion fails after initialization.
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

  /// Clears all stored data from the database.
  ///
  /// Returns `true` if successful, otherwise `false`.
  /// Throws a [StateError] if clearing fails after initialization.
  Future<bool> clear() async {
    if (await isInit()) {
      try {
        await _db!.deleteFromDisk();
        if (_logging) {
          PrettyLogger.i('Json Database clear successfuly');
        }
        return true;
      } catch (e) {
        if (_logging) {
          PrettyLogger.e('Json Database clear error: ${e.toString()}');
        }
        throw StateError('Json Database clear error: ${e.toString()}');
      }
    }

    if (_logging) {
      PrettyLogger.e('Json Database clear error: not initialized');
    }
    return false;
  }

  /// Checks whether a given [key] exists in the database.
  ///
  /// Returns `true` if the key exists, otherwise `false`.
  Future<bool> containsKey(String key) async {
    if (await isInit()) {
      try {
        return _db!.containsKey(key);
      } catch (_) {
        return false;
      }
    }
    return false;
  }

  /// Ensures the database is initialized.
  ///
  /// If not already initialized, it will attempt to initialize it using
  /// the current logging configuration.
  ///
  /// Returns `true` if the database is ready, otherwise `false`.
  Future<bool> isInit() async {
    if (_db == null && _storagePath != null) {
      await init(logging: _logging);
    }
    return _db != null;
  }

  /// Closes the database and releases resources.
  ///
  /// After calling this, the database must be re-initialized before use.
  Future<void> close() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
    }
  }
}
