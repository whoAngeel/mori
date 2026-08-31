import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../../data/repositories/counter_repository_impl.dart';
import '../../domain/usecases/get_counter.dart';
import '../../domain/usecases/increment_counter.dart';

part 'counter_notifier.g.dart';

// --- Use-case DI (Presentation wires the pure Domain classes) ----------------

@riverpod
GetCounter getCounter(Ref ref) =>
    GetCounter(ref.watch(counterRepositoryProvider));

@riverpod
IncrementCounter incrementCounter(Ref ref) =>
    IncrementCounter(ref.watch(counterRepositoryProvider));

// --- Screen state -----------------------------------------------------------

/// Holds the counter value as an [AsyncValue] so the UI gets loading/error for
/// free.
///
/// NOTE: `riverpod_generator` v3 strips the `Notifier` suffix, so the generated
/// provider is `counterProvider` (not `counterNotifierProvider`).
@riverpod
class CounterNotifier extends _$CounterNotifier {
  @override
  Future<int> build() async {
    final result = await ref.watch(getCounterProvider)(const NoParams());
    return switch (result) {
      Ok(:final value) => value.value,
      Err(:final failure) => throw Exception(failure.message),
    };
  }

  Future<void> increment() async {
    state = const AsyncLoading<int>();
    state = await AsyncValue.guard(() async {
      final result =
          await ref.read(incrementCounterProvider)(const NoParams());
      return switch (result) {
        Ok(:final value) => value.value,
        Err(:final failure) => throw Exception(failure.message),
      };
    });
  }
}
