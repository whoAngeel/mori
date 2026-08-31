// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'counter_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(counterRepository)
const counterRepositoryProvider = CounterRepositoryProvider._();

final class CounterRepositoryProvider
    extends
        $FunctionalProvider<
          CounterRepository,
          CounterRepository,
          CounterRepository
        >
    with $Provider<CounterRepository> {
  const CounterRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'counterRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$counterRepositoryHash();

  @$internal
  @override
  $ProviderElement<CounterRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CounterRepository create(Ref ref) {
    return counterRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CounterRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CounterRepository>(value),
    );
  }
}

String _$counterRepositoryHash() => r'5b0f45e60f14118e1f7ecb0a3c8ebb8ce25858ac';
