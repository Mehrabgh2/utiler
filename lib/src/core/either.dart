sealed class Either<L, R> {
  const Either();

  bool get isLeft => this is Left<L, R>;

  bool get isRight => this is Right<L, R>;

  L get left {
    if (this is Left<L, R>) {
      return (this as Left<L, R>).value;
    }
    throw StateError('Cannot get left value from a right value.');
  }

  R get right {
    if (this is Right<L, R>) {
      return (this as Right<L, R>).value;
    }
    throw StateError('Cannot get right value from a left value.');
  }

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
              isRight && other.isRight && right == other.right);

  @override
  int get hashCode => fold((left) => left.hashCode, (right) => right.hashCode);
}

class Left<L, R> extends Either<L, R> {
  const Left(this.value);
  final L value;

  @override
  String toString() {
    return 'Left: $value';
  }
}

class Right<L, R> extends Either<L, R> {
  const Right(this.value);
  final R value;

  @override
  String toString() {
    return 'Right: $value';
  }
}
