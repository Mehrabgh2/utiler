/// A lazily-initialized asynchronous value holder.
///
/// [LazyValue] defers the execution of an expensive or asynchronous
/// computation until it is first accessed via [value].
///
/// Once initialized, the computed value is cached and reused for all
/// subsequent accesses unless [reset] is called.
///
/// This is useful for:
/// - deferred API calls
/// - expensive async computations
/// - lazy-loaded configuration or resources
///
/// Example:
/// ```dart
/// final config = LazyValue(() async {
///   return await loadConfigFromApi();
/// });
///
/// final value = await config.value;
/// print(value);
///
/// print(config.isInitilizaed); // true
///
/// config.reset(); // forces recomputation on next access
/// ```
class LazyValue<T> {
  /// Creates a lazy async value with the given [initializer].
  LazyValue(this.initializer);

  /// Function that produces the value when needed.
  final Future<T> Function() initializer;

  T? _value;
  bool _isInitialized = false;

  /// Whether the value has already been initialized.
  bool get isInitilizaed => _isInitialized;

  /// Returns the computed value, initializing it if necessary.
  ///
  /// The [initializer] is executed only once. After that, the cached
  /// value is returned.
  Future<T> get value async {
    if (!_isInitialized) {
      _value = await initializer();
      _isInitialized = true;
    }
    return _value!;
  }

  /// Resets the cached value.
  ///
  /// After calling this, the next access to [value] will re-run the
  /// [initializer].
  void reset() {
    _isInitialized = false;
    _value = null;
  }
}
