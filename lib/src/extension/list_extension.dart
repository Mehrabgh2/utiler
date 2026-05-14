/// Extensions on [List] providing safe access and convenience utilities.
///
/// These helpers make it easier to work with lists without needing to
/// manually check for empty collections or write repetitive loops.
extension ListExtensions<T> on List<T> {
  /// Returns the first element, or `null` if the list is empty.
  ///
  /// Example:
  /// ```dart
  /// final list = <int>[];
  /// print(list.firstOrNull); // null
  /// ```
  T? get firstOrNull => isEmpty ? null : first;

  /// Returns the last element, or `null` if the list is empty.
  ///
  /// Example:
  /// ```dart
  /// final list = [1, 2, 3];
  /// print(list.lastOrNull); // 3
  /// ```
  T? get lastOrNull => isEmpty ? null : last;

  /// Returns a new list with duplicate elements removed.
  ///
  /// Uniqueness is determined by converting the list to a [Set], so
  /// equality depends on `==` and `hashCode`.
  ///
  /// Example:
  /// ```dart
  /// final list = [1, 1, 2, 3];
  /// print(list.unique); // [1, 2, 3]
  /// ```
  List<T> get unique => toSet().toList();

  /// Returns the first element that satisfies [checker], or `null` if none match.
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
