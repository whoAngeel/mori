import '../utils/result.dart';

/// Contract every use case implements: one public `call` method, one job.
///
/// * [T]      – value produced on success.
/// * [Params] – input bag; use [NoParams] when the use case needs no argument.
abstract interface class UseCase<T, Params> {
  Future<Result<T>> call(Params params);
}

/// Placeholder argument for parameter-less use cases.
final class NoParams {
  const NoParams();
}
