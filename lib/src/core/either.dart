/// A sealed class representing a value that can be either a failure ([Left])
/// or a success ([Right]).
///
/// This is commonly used for functional-style error handling instead of
/// throwing exceptions.
///
/// - [Left] typically represents an error or failure case
/// - [Right] typically represents a successful result
///
/// Example:
/// ```dart
/// Either<String, int> result = Right(42);
///
/// result.fold(
///   (error) => print('Error: $error'),
///   (value) => print('Success: $value'),
/// );
/// ```
sealed class Either<L, R> {
  const Either();

  /// Returns `true` if this is a [Left] value.
  bool get isLeft => this is Left<L, R>;

  /// Returns `true` if this is a [Right] value.
  bool get isRight => this is Right<L, R>;

  /// Extracts the left value.
  ///
  /// Throws a [StateError] if this is a [Right].
  L get left {
    if (this is Left<L, R>) {
      return (this as Left<L, R>).value;
    }
    throw StateError('Cannot get left value from a right value.');
  }

  /// Extracts the right value.
  ///
  /// Throws a [StateError] if this is a [Left].
  R get right {
    if (this is Right<L, R>) {
      return (this as Right<L, R>).value;
    }
    throw StateError('Cannot get right value from a left value.');
  }

  /// Pattern-matches the value and transforms it into a single result.
  ///
  /// - [leftFn] is executed if this is a [Left]
  /// - [rightFn] is executed if this is a [Right]
  V fold<V>(V Function(L left) leftFn, V Function(R right) rightFn) {
    if (this is Left) {
      return leftFn((this as Left<L, R>).value);
    } else {
      return rightFn((this as Right<L, R>).value);
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Either<L, R> &&
          ((isLeft && other.isLeft && left == other.left) ||
              (isRight && other.isRight && right == other.right));

  @override
  int get hashCode => fold((left) => left.hashCode, (right) => right.hashCode);
}

/// Represents the failure side of an [Either].
///
/// Typically used to hold error information.
class Left<L, R> extends Either<L, R> {
  /// Creates a [Left] containing a failure value.
  const Left(this.value);

  /// The failure value.
  final L value;

  @override
  String toString() => 'Left: $value';
}

/// Represents the success side of an [Either].
///
/// Typically used to hold successful computation results.
class Right<L, R> extends Either<L, R> {
  /// Creates a [Right] containing a success value.
  const Right(this.value);

  /// The success value.
  final R value;

  @override
  String toString() => 'Right: $value';
}
