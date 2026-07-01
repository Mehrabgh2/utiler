import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:utiler/src/database/secure_database_data.dart';
import 'package:utiler/src/logger/pretty_logger.dart';

/// A secure key-value storage wrapper built on top of
/// [FlutterSecureStorage].
///
/// This database is intended for sensitive information such as:
/// - authentication tokens
/// - API keys
/// - user secrets
///
/// Data is stored securely using platform-specific secure storage
/// (Keychain on iOS, Keystore on Android).
///
/// Example:
/// ```dart
/// final secureDb = SecureDatabase();
/// await secureDb.init(true);
///
/// await secureDb.put(SecureDatabaseData(
///   key: 'token',
///   value: 'secret_token_123',
/// ));
///
/// final token = await secureDb.get('token');
/// print(token?.value);
///
/// await secureDb.delete('token');
/// await secureDb.clear();
/// ```
class SecureDatabase {
  /// Creates a [SecureDatabase]. Call [init] before use.
  SecureDatabase();

  /// Internal secure storage instance.
  final FlutterSecureStorage _db = FlutterSecureStorage(
    aOptions: _getAndroidOptions(),
    iOptions: _getIOSOptions(),
  );

  /// Android-specific secure storage configuration.
  static AndroidOptions _getAndroidOptions() => const AndroidOptions();

  /// iOS-specific secure storage configuration.
  ///
  /// Uses [KeychainAccessibility.unlocked] so data is accessible when
  /// the device is unlocked.
  static IOSOptions _getIOSOptions() =>
      const IOSOptions(accessibility: KeychainAccessibility.unlocked);

  /// Enables or disables logging for database operations.
  bool _logging = false;

  /// Initializes the secure database.
  ///
  /// Performs a lightweight write/read test to ensure storage is available.
  /// If [logging] is true, initialization status is logged.
  Future<void> init(bool logging) async {
    _logging = logging;
    try {
      await put(SecureDatabaseData(key: 'init', value: 'init'));
      await delete('init');

      if (_logging) {
        PrettyLogger.s('Secure database initialized successfuly');
      }
    } catch (e) {
      if (_logging) {
        PrettyLogger.e('Secure database initializing error: ${e.toString()}');
      }
    }
  }

  /// Stores a secure key-value pair.
  ///
  /// Returns `true` if successful.
  /// Throws a [StateError] if writing fails.
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

  /// Retrieves a secure value by [key].
  ///
  /// Returns a [SecureDatabaseData] if found, otherwise `null`.
  /// Throws a [StateError] if an unexpected error occurs.
  Future<SecureDatabaseData?> get(String key) async {
    try {
      if (await containsKey(key)) {
        final String? value = await _db.read(key: key);

        if (value == null) {
          if (_logging) {
            PrettyLogger.e('Secure Database get can`t read "$key"');
          }
          return null;
        }

        final SecureDatabaseData data = SecureDatabaseData(
          key: key,
          value: value,
        );

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

  /// Deletes a secure entry by [key].
  ///
  /// Returns `true` if the key existed and was deleted, otherwise `false`.
  /// Throws a [StateError] if deletion fails.
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

  /// Clears all secure storage entries.
  ///
  /// Returns `true` if successful.
  /// Throws a [StateError] if the operation fails.
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

  /// Checks whether a [key] exists in secure storage.
  ///
  /// Returns `true` if the key exists, otherwise `false`.
  Future<bool> containsKey(String key) async {
    try {
      return await _db.containsKey(key: key);
    } catch (_) {
      return false;
    }
  }
}
