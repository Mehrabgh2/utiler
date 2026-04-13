class Guard<T> {
  T? call(T Function() task) {
    try {
      return task();
    } catch (_) {
      return null;
    }
  }
}
