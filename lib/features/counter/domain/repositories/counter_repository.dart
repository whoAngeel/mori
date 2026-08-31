import '../../../../core/utils/result.dart';
import '../entities/counter.dart';

/// Domain-owned contract. The Data layer implements it; the Domain layer never
/// knows *how* the data is stored.
abstract interface class CounterRepository {
  Future<Result<Counter>> getCounter();

  Future<Result<Counter>> incrementCounter();
}
