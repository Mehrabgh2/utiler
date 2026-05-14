/// Extensions on [Iterable] providing safer and convenience helpers.
///
/// These helpers reduce boilerplate when working with collections,
/// especially when dealing with potentially empty iterables or
/// searching for elements.
extension IterableExtensions<T> on Iterable<T> {
  /// Returns the first element, or `null` if the iterable is empty.
  ///
  /// Example:
  /// ```dart
  /// final list = <int>[];
  /// print(list.firstOrNull); // null
  /// ```
  T? get firstOrNull => isEmpty ? null : first;

  /// Returns the last element, or `null` if the iterable is empty.
  ///
  /// Example:
  /// ```dart
  /// final list = [1, 2, 3];
  /// print(list.lastOrNull); // 3
  /// ```
  T? get lastOrNull => isEmpty ? null : last;

  /// Returns a list containing only unique elements.
  ///
  /// Uniqueness is determined using a [Set], so equality is based on
  /// the `==` operator and `hashCode`.
  ///
  /// Example:
  /// ```dart
  /// final list = [1, 1, 2, 3];
  /// print(list.unique); // [1, 2, 3]
  /// ```
  List<T> get unique => toSet().toList();

  /// Returns the first element that matches [checker], or `null` if none match.
  ///
  /// Example:
  /// ```dart
  /// final list = [1, 2, 3];
  /// print(list.firstWhereOrNull((e) => e > 1)); // 2
  /// ```
  T? firstWhereOrNull(bool Function(T element) checker) {
    for (var e in this) {
      if (checker(e)) {
        return e;
      }
    }
    return null;
  }
}
