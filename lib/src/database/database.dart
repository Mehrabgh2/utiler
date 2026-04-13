import 'json_database.dart';
import 'json_database_data.dart';
import 'secure_database.dart';
import 'secure_database_data.dart';

class Database {
  static final Database _instance = Database._internal();
  factory Database() => _instance;
  Database._internal();

  static final JsonDatabase _jsonDb = JsonDatabase();
  static final SecureDatabase _secureDb = SecureDatabase();

  Future<void> init([bool logging = false]) async {
    await _secureDb.init(logging);
    await _jsonDb.init(logging);
  }

  Future<bool> putJson(JsonDatabaseData data) async {
    return await _jsonDb.put(data);
  }

  Future<JsonDatabaseData?> getJson(String key) async {
    return await _jsonDb.get(key);
  }

  Future<bool> deleteJson(String key) async {
    return await _jsonDb.delete(key);
  }

  Future<bool> clearJson() async {
    return await _jsonDb.clear();
  }

  Future<bool> containsJson(String key) async {
    return await _jsonDb.containsKey(key);
  }

  Future<bool> putSecure(SecureDatabaseData data) async {
    return await _secureDb.put(data);
  }

  Future<SecureDatabaseData?> getSecure(String key) async {
    return await _secureDb.get(key);
  }

  Future<bool> deleteSecure(String key) async {
    return await _secureDb.delete(key);
  }

  Future<bool> clearSecure() async {
    return await _secureDb.clear();
  }

  Future<bool> containsSecure(String key) async {
    return await _secureDb.containsKey(key);
  }
}
