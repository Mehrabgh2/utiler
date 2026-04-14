extension IterableExtensions<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;

  T? get lastOrNull => isEmpty ? null : last;

  List<T> get unique => toSet().toList();

  T? firstWhereOrNull(bool Function(T element) checker) {
    for (var e in this) {
      if (checker(e)) {
        return e;
      }
    }
    return null;
  }
}
