/// Represents a single encrypted/secure key-value record.
///
/// This model is used by [SecureDatabase] to store sensitive data such as
/// tokens, credentials, or other private values.
///
/// Example:
/// ```dart
/// final secure = SecureDatabaseData(
///   key: 'auth_token',
///   value: 'abc123securetoken',
/// );
///
/// final json = secure.toJson();
/// final restored = SecureDatabaseData.fromJson(json);
///
/// print(restored.key);   // auth_token
/// print(restored.value); // abc123securetoken
/// ```
class SecureDatabaseData {
  /// Creates a secure database record.
  ///
  /// The [key] identifies the entry, and [value] stores the encrypted or
  /// sensitive string data.
  SecureDatabaseData({required this.key, required this.value});

  /// Unique identifier for the secure record.
  String key;

  /// Sensitive value associated with the key (typically encrypted at rest).
  String value;

  /// Creates a [SecureDatabaseData] instance from a JSON map.
  ///
  /// Expected format:
  /// - `key`: record identifier
  /// - `value`: stored secure string
  factory SecureDatabaseData.fromJson(Map<String, dynamic> json) {
    return SecureDatabaseData(key: json['key'], value: json['value']);
  }

  /// Converts this secure record into a JSON-compatible map.
  Map<String, dynamic> toJson() => {'key': key, 'value': value};
}
