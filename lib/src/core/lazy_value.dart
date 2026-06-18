/// A lazily-initialized asynchronous value holder.
///
/// [LazyValue] defers the execution of an expensive or asynchronous
/// computation until it is first accessed via [value].
///
/// Once initialized, the computed value is cached and reused for all
/// subsequent accesses unless [reset] is called.
///
/// Concurrent accesses before initialization completes all await the same
/// underlying [Future], so [initializer] runs exactly once per lifecycle.
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
/// // Concurrent callers both await the same initialization:
/// final a = config.value;
/// final b = config.value; // does NOT run initializer again
///
/// print(config.isInitialized); // true after awaiting
///
/// config.reset(); // forces recomputation on next access
/// ```
class LazyValue<T> {
  /// Creates a lazy async value with the given [initializer].
  LazyValue(this.initializer);

  /// Function that produces the value when needed.
  final Future<T> Function() initializer;

  Future<T>? _future;
  bool _isInitialized = false;

  /// Whether the value has been successfully initialized.
  ///
  /// Returns `true` only after [initializer] completes without error.
  bool get isInitialized => _isInitialized;

  /// Returns the computed value, initializing it if necessary.
  ///
  /// Multiple concurrent calls all await the same [Future]; the
  /// [initializer] runs exactly once. If initialization fails, the
  /// error is propagated to all awaiting callers and the cache is
  /// cleared so the next access retries from scratch.
  Future<T> get value {
    _future ??= _run();
    return _future!;
  }

  Future<T> _run() async {
    try {
      final result = await initializer();
      _isInitialized = true;
      return result;
    } catch (e) {
      _future = null;
      rethrow;
    }
  }

  /// Resets the cached value.
  ///
  /// After calling this, the next access to [value] will re-run the
  /// [initializer].
  void reset() {
    _future = null;
    _isInitialized = false;
  }
}
