import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/counter.dart';
import '../repositories/counter_repository.dart';

/// Reads the current counter value.
///
/// Pure Domain: no Flutter, no Riverpod, no Data imports. It is wired into DI
/// from the Presentation layer (`presentation/providers/counter_notifier.dart`).
class GetCounter implements UseCase<Counter, NoParams> {
  const GetCounter(this._repository);

  final CounterRepository _repository;

  @override
  Future<Result<Counter>> call(NoParams params) => _repository.getCounter();
}
