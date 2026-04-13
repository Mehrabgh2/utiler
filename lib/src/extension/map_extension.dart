extension MapExtensions<K, V> on Map<K, V> {
  Map<K, V> merge(Map<K, V> other) {
    final result = Map<K, V>.from(this);
    result.addAll(other);
    return result;
  }

  Map<K, V> whereKey(bool Function(K key) predicate) {
    final result = <K, V>{};
    for (var entry in entries) {
      if (predicate(entry.key)) {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }

  Map<K, V> whereValue(bool Function(V value) predicate) {
    final result = <K, V>{};
    for (var entry in entries) {
      if (predicate(entry.value)) {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }

  List<V> get valuesList => values.toList();
  List<K> get keysList => keys.toList();
}
