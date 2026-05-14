import 'package:utiler/src/database/json_database.dart';
import 'package:utiler/src/database/json_database_data.dart';
import 'package:utiler/src/database/secure_database.dart';
import 'package:utiler/src/database/secure_database_data.dart';

/// A unified singleton database interface for both JSON and secure storage.
///
/// This class acts as a facade over:
/// - [JsonDatabase] for unencrypted structured data
/// - [SecureDatabase] for sensitive encrypted data
///
/// It provides a single access point for initialization and CRUD operations.
///
/// Example:
/// ```dart
/// final db = Database();
/// await db.init(true);
///
/// await db.putJson(JsonDatabaseData(
///   key: 'settings',
///   data: {'theme': 'dark'},
/// ));
///
/// final settings = await db.getJson('settings');
/// print(settings?.data);
///
/// await db.putSecure(SecureDatabaseData(
///   key: 'token',
///   value: 'abc123',
/// ));
///
/// final token = await db.getSecure('token');
/// print(token?.value);
/// ```
class Database {
  /// Internal singleton instance.
  static final Database _instance = Database._internal();

  /// Factory constructor returning the singleton instance.
  factory Database() => _instance;

  Database._internal();

  /// Internal JSON database instance.
  static final JsonDatabase _jsonDb = JsonDatabase();

  /// Internal secure database instance.
  static final SecureDatabase _secureDb = SecureDatabase();

  /// Initializes both JSON and secure databases.
  ///
  /// If [logging] is true, internal operations of both databases will log
  /// their status and errors.
  Future<void> init([bool logging = false]) async {
    await _secureDb.init(logging);
    await _jsonDb.init(logging);
  }

  // ---------------------------------------------------------------------------
  // JSON DATABASE OPERATIONS
  // ---------------------------------------------------------------------------

  /// Stores a JSON record in the JSON database.
  Future<bool> putJson(JsonDatabaseData data) async {
    return await _jsonDb.put(data);
  }

  /// Retrieves a JSON record by [key].
  Future<JsonDatabaseData?> getJson(String key) async {
    return await _jsonDb.get(key);
  }

  /// Deletes a JSON record by [key].
  Future<bool> deleteJson(String key) async {
    return await _jsonDb.delete(key);
  }

  /// Clears all JSON database entries.
  Future<bool> clearJson() async {
    return await _jsonDb.clear();
  }

  /// Checks whether a JSON key exists.
  Future<bool> containsJson(String key) async {
    return await _jsonDb.containsKey(key);
  }

  // ---------------------------------------------------------------------------
  // SECURE DATABASE OPERATIONS
  // ---------------------------------------------------------------------------

  /// Stores a secure (encrypted) record.
  Future<bool> putSecure(SecureDatabaseData data) async {
    return await _secureDb.put(data);
  }

  /// Retrieves a secure (encrypted) record by [key].
  Future<SecureDatabaseData?> getSecure(String key) async {
    return await _secureDb.get(key);
  }

  /// Deletes a secure record by [key].
  Future<bool> deleteSecure(String key) async {
    return await _secureDb.delete(key);
  }

  /// Clears all secure storage entries.
  Future<bool> clearSecure() async {
    return await _secureDb.clear();
  }

  /// Checks whether a secure key exists.
  Future<bool> containsSecure(String key) async {
    return await _secureDb.containsKey(key);
  }
}
