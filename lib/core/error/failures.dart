/// Base type for every recoverable error that crosses a layer boundary.
///
/// The Data layer catches raw [Exception]s and maps them to a [Failure]; the
/// Domain and Presentation layers only ever see [Failure]s.
sealed class Failure {
  const Failure(this.message);

  final String message;

  @override
  String toString() => '$runtimeType($message)';
}

/// Something went wrong while talking to the local database / cache.
final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local storage error']);
}

/// Anything we did not explicitly model.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Unexpected error']);
}
