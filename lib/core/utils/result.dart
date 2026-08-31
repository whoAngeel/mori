import '../error/failures.dart';

/// A tiny, dependency-free `Either` replacement built on Dart 3 sealed classes.
///
/// Repositories return `Future<Result<T>>`; callers pattern-match:
///
/// ```dart
/// switch (result) {
///   Ok(:final value) => use(value),
///   Err(:final failure) => show(failure.message),
/// }
/// ```
sealed class Result<T> {
  const Result();

  /// Convenience folder for call sites that prefer callbacks over `switch`.
  R fold<R>(R Function(Failure failure) onErr, R Function(T value) onOk) =>
      switch (this) {
        Ok<T>(:final value) => onOk(value),
        Err<T>(:final failure) => onErr(failure),
      };
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;
}
