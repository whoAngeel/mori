import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/counter.dart';
import '../../domain/repositories/counter_repository.dart';
import '../datasources/counter_local_data_source.dart';

part 'counter_repository_impl.g.dart';

/// Implements the Domain contract using the local datasource.
///
/// Responsibility: catch Data-layer [Exception]s and translate them into
/// Domain-friendly [Failure]s wrapped in a [Result].
class CounterRepositoryImpl implements CounterRepository {
  CounterRepositoryImpl(this._local);

  final CounterLocalDataSource _local;

  @override
  Future<Result<Counter>> getCounter() => _guard(_local.readCounter);

  @override
  Future<Result<Counter>> incrementCounter() => _guard(_local.incrementCounter);

  Future<Result<Counter>> _guard(Future<Counter> Function() action) async {
    try {
      return Ok(await action());
    } on CacheException catch (e) {
      return Err(CacheFailure(e.message));
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}

@riverpod
CounterRepository counterRepository(Ref ref) =>
    CounterRepositoryImpl(ref.watch(counterLocalDataSourceProvider));
