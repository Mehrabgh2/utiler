/// Represents a single record stored in the JSON database.
///
/// Each record contains a unique [key] and its associated JSON-compatible
/// [data].
///
/// Example:
/// ```dart
/// final record = JsonDatabaseData(
///   key: 'user_1',
///   data: {
///     'name': 'Alice',
///     'age': 28,
///   },
/// );
///
/// final json = record.toJson();
///
/// final restored = JsonDatabaseData.fromJson(json);
/// print(restored.key); // user_1
/// ```
class JsonDatabaseData {
  /// Creates a new JSON database record.
  ///
  /// The [key] identifies the record, while [data] stores the associated
  /// JSON-compatible values.
  JsonDatabaseData({required this.key, required this.data});

  /// Unique identifier for the stored record.
  String key;

  /// JSON-compatible payload associated with the record.
  Map<String, dynamic> data;

  /// Creates a [JsonDatabaseData] instance from a JSON map.
  ///
  /// Expects the JSON structure to contain:
  /// - `key`: a unique record identifier
  /// - `data`: a map containing the stored payload
  factory JsonDatabaseData.fromJson(Map<String, dynamic> json) {
    return JsonDatabaseData(key: json['key'], data: json['data']);
  }

  /// Converts this record into a JSON-compatible map.
  ///
  /// Returns a map containing the [key] and [data] fields.
  Map<String, dynamic> toJson() => {'key': key, 'data': data};
}
