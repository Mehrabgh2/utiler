/// Extensions on [Map] providing utility methods for merging and filtering.
///
/// These helpers simplify common map operations such as merging maps,
/// filtering by keys or values, and converting map data into lists.
extension MapExtensions<K, V> on Map<K, V> {
  /// Returns a new map containing the merged values of this map and [other].
  ///
  /// If both maps contain the same key, the value from [other] will override
  /// the existing value.
  ///
  /// Example:
  /// ```dart
  /// final a = {'a': 1};
  /// final b = {'b': 2};
  /// print(a.merge(b)); // {a: 1, b: 2}
  /// ```
  Map<K, V> merge(Map<K, V> other) {
    final result = Map<K, V>.from(this);
    result.addAll(other);
    return result;
  }

  /// Returns a new map containing only entries whose keys satisfy [predicate].
  ///
  /// Example:
  /// ```dart
  /// final map = {'a': 1, 'bb': 2};
  /// print(map.whereKey((k) => k.length == 1)); // {a: 1}
  /// ```
  Map<K, V> whereKey(bool Function(K key) predicate) {
    final result = <K, V>{};
    for (var entry in entries) {
      if (predicate(entry.key)) {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }

  /// Returns a new map containing only entries whose values satisfy [predicate].
  ///
  /// Example:
  /// ```dart
  /// final map = {'a': 1, 'b': 2};
  /// print(map.whereValue((v) => v > 1)); // {b: 2}
  /// ```
  Map<K, V> whereValue(bool Function(V value) predicate) {
    final result = <K, V>{};
    for (var entry in entries) {
      if (predicate(entry.value)) {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }

  /// Returns all values of the map as a [List].
  ///
  /// Example:
  /// ```dart
  /// final map = {'a': 1, 'b': 2};
  /// print(map.valuesList); // [1, 2]
  /// ```
  List<V> get valuesList => values.toList();

  /// Returns all keys of the map as a [List].
  ///
  /// Example:
  /// ```dart
  /// final map = {'a': 1, 'b': 2};
  /// print(map.keysList); // [a, b]
  /// ```
  List<K> get keysList => keys.toList();
}
