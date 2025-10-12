/// A generic class that holds either a value of type [L] or [R].
/// Used for functional-style error handling.
abstract class Either<L, R> {
  /// Private constructor to prevent direct instantiation.
  const Either();

  /// Folds either the [left] or [right] side of this [Either] into a single value.
  ///
  /// [ifLeft] is executed if this is a [Left], and [ifRight] if this is a [Right].
  T fold<T>(T Function(L left) ifLeft, T Function(R right) ifRight);
}

/// Represents the left side of an [Either], typically used for failure cases.
class Left<L, R> extends Either<L, R> {
  final L value;

  const Left(this.value);

  @override
  T fold<T>(T Function(L left) ifLeft, T Function(R right) ifRight) => ifLeft(value);
}

/// Represents the right side of an [Either], typically used for success cases.
class Right<L, R> extends Either<L, R> {
  final R value;

  const Right(this.value);

  @override
  T fold<T>(T Function(L left) ifLeft, T Function(R right) ifRight) => ifRight(value);
}
