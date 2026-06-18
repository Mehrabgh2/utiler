/// An in-memory key-value cache where each entry expires after a given [ttl].
///
/// Expired entries are evicted lazily on access. Call [evictExpired] to
/// proactively remove all stale entries at once.
///
/// Example:
/// ```dart
/// final cache = TimedCache<String, User>(ttl: Duration(minutes: 5));
///
/// cache.set('user_42', user);
///
/// final cached = cache.get('user_42'); // null after TTL expires
/// print(cache.isAlive('user_42'));     // true / false
///
/// cache.evictExpired(); // remove all stale entries
/// ```
class TimedCache<K, V> {
  /// Creates a cache where each entry lives for [ttl].
  TimedCache({required this.ttl});

  /// How long each entry remains valid after being written.
  final Duration ttl;

  final Map<K, _CacheEntry<V>> _store = {};

  /// Stores [value] under [key], resetting its TTL if it already exists.
  void set(K key, V value) {
    _store[key] = _CacheEntry(value: value, expiresAt: DateTime.now().add(ttl));
  }

  /// Returns the value for [key], or `null` if missing or expired.
  ///
  /// Expired entries are removed from the cache on access.
  V? get(K key) {
    final entry = _store[key];
    if (entry == null) return null;
    if (DateTime.now().isAfter(entry.expiresAt)) {
      _store.remove(key);
      return null;
    }
    return entry.value;
  }

  /// Returns `true` if [key] exists and has not yet expired.
  bool isAlive(K key) => get(key) != null;

  /// Removes the entry for [key] regardless of its TTL.
  void remove(K key) => _store.remove(key);

  /// Removes all entries, including unexpired ones.
  void clear() => _store.clear();

  /// Removes only entries whose TTL has passed.
  void evictExpired() {
    final now = DateTime.now();
    _store.removeWhere((_, entry) => now.isAfter(entry.expiresAt));
  }

  /// Total number of entries currently held (including ones not yet evicted).
  int get length => _store.length;
}

class _CacheEntry<V> {
  const _CacheEntry({required this.value, required this.expiresAt});

  final V value;
  final DateTime expiresAt;
}
