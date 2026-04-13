import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../logger/pretty_logger.dart';
import 'secure_database_data.dart';

class SecureDatabase {
  final FlutterSecureStorage _db = FlutterSecureStorage(
    aOptions: _getAndroidOptions(),
    iOptions: _getIOSOptions(),
  );
  static AndroidOptions _getAndroidOptions() => const AndroidOptions();
  static IOSOptions _getIOSOptions() =>
      const IOSOptions(accessibility: KeychainAccessibility.unlocked);

  bool _logging = false;

  Future<void> init(bool logging) async {
    try {
      await put(SecureDatabaseData(key: 'init', value: 'init'));
      await delete('init');
      _logging = logging;
      if (_logging) {
        PrettyLogger.s('Secure database initialized successfuly');
      }
    } catch (e) {
      if (_logging) {
        PrettyLogger.e('Secure database initializing error: ${e.toString()}');
      }
    }
  }

  Future<bool> put(SecureDatabaseData data) async {
    try {
      await _db.write(key: data.key, value: data.value);
      if (_logging) {
        PrettyLogger.i('Secure Database put "${data.key}" successfuly');
      }
      return true;
    } catch (e) {
      if (_logging) {
        PrettyLogger.e('Secure Database put error: ${e.toString()}');
      }
      throw StateError('Secure Database put error: ${e.toString()}');
    }
  }

  Future<SecureDatabaseData?> get(String key) async {
    try {
      if (await containsKey(key)) {
        String? value = await _db.read(key: key);
        if (value == null) {
          if (_logging) {
            PrettyLogger.e('Secure Database get can`t read "$key"');
          }
          return null;
        }
        SecureDatabaseData data = SecureDatabaseData(key: key, value: value);
        if (_logging) {
          PrettyLogger.i(
            'Secure Database get "$key" returned data successfuly',
          );
        }
        return data;
      }
      if (_logging) {
        PrettyLogger.e('Secure Database get can`t find "$key"');
      }
      return null;
    } catch (e) {
      if (_logging) {
        PrettyLogger.e('Secure Database get error: ${e.toString()}');
      }
      throw StateError('Secure Database get error: ${e.toString()}');
    }
  }

  Future<bool> delete(String key) async {
    try {
      if (await containsKey(key)) {
        await _db.delete(key: key);
        if (_logging) {
          PrettyLogger.i('Secure Database delete "$key" successfuly');
        }
        return true;
      }
      if (_logging) {
        PrettyLogger.e('Secure Database delete can`t find "$key"');
      }
      return false;
    } catch (e) {
      if (_logging) {
        PrettyLogger.e('Secure Database delete error: ${e.toString()}');
      }
      throw StateError('Secure Database delete error: ${e.toString()}');
    }
  }

  Future<bool> clear() async {
    try {
      await _db.deleteAll();
      if (_logging) {
        PrettyLogger.i('Secure Database clear successfuly');
      }
      return true;
    } catch (e) {
      if (_logging) {
        PrettyLogger.e('Secure Database clear error: ${e.toString()}');
      }
      throw StateError('Secure Database clear error: ${e.toString()}');
    }
  }

  Future<bool> containsKey(String key) async {
    try {
      return await _db.containsKey(key: key);
    } catch (e) {
      return false;
    }
  }
}
