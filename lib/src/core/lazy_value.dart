class LazyValue<T> {
  LazyValue(this.initializer);

  final Future<T> Function() initializer;
  T? _value;
  bool _isInitialized = false;

  bool get isInitilizaed => _isInitialized;

  Future<T> get value async {
    if (!_isInitialized) {
      _value = await initializer();
      _isInitialized = true;
    }
    return _value!;
  }

  void reset() {
    _isInitialized = false;
    _value = null;
  }
}
