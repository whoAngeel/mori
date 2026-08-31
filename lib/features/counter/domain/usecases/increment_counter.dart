import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/counter.dart';
import '../repositories/counter_repository.dart';

/// Increments the counter and returns the new value.
class IncrementCounter implements UseCase<Counter, NoParams> {
  const IncrementCounter(this._repository);

  final CounterRepository _repository;

  @override
  Future<Result<Counter>> call(NoParams params) =>
      _repository.incrementCounter();
}
