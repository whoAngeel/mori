// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'counter_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getCounter)
const getCounterProvider = GetCounterProvider._();

final class GetCounterProvider
    extends $FunctionalProvider<GetCounter, GetCounter, GetCounter>
    with $Provider<GetCounter> {
  const GetCounterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getCounterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getCounterHash();

  @$internal
  @override
  $ProviderElement<GetCounter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetCounter create(Ref ref) {
    return getCounter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetCounter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetCounter>(value),
    );
  }
}

String _$getCounterHash() => r'5e5fc922ce58ccfd53e37d16168b8f32f99a2bca';

@ProviderFor(incrementCounter)
const incrementCounterProvider = IncrementCounterProvider._();

final class IncrementCounterProvider
    extends
        $FunctionalProvider<
          IncrementCounter,
          IncrementCounter,
          IncrementCounter
        >
    with $Provider<IncrementCounter> {
  const IncrementCounterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'incrementCounterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$incrementCounterHash();

  @$internal
  @override
  $ProviderElement<IncrementCounter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IncrementCounter create(Ref ref) {
    return incrementCounter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IncrementCounter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IncrementCounter>(value),
    );
  }
}

String _$incrementCounterHash() => r'64110bc9ef0466b5f2ea999c8b55c475f93fc3a8';

/// Holds the counter value as an [AsyncValue] so the UI gets loading/error for
/// free.
///
/// NOTE: `riverpod_generator` v3 strips the `Notifier` suffix, so the generated
/// provider is `counterProvider` (not `counterNotifierProvider`).

@ProviderFor(CounterNotifier)
const counterProvider = CounterNotifierProvider._();

/// Holds the counter value as an [AsyncValue] so the UI gets loading/error for
/// free.
///
/// NOTE: `riverpod_generator` v3 strips the `Notifier` suffix, so the generated
/// provider is `counterProvider` (not `counterNotifierProvider`).
final class CounterNotifierProvider
    extends $AsyncNotifierProvider<CounterNotifier, int> {
  /// Holds the counter value as an [AsyncValue] so the UI gets loading/error for
  /// free.
  ///
  /// NOTE: `riverpod_generator` v3 strips the `Notifier` suffix, so the generated
  /// provider is `counterProvider` (not `counterNotifierProvider`).
  const CounterNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'counterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$counterNotifierHash();

  @$internal
  @override
  CounterNotifier create() => CounterNotifier();
}

String _$counterNotifierHash() => r'9fb8e4b965aab35587225f99c5be9866241cbf06';

/// Holds the counter value as an [AsyncValue] so the UI gets loading/error for
/// free.
///
/// NOTE: `riverpod_generator` v3 strips the `Notifier` suffix, so the generated
/// provider is `counterProvider` (not `counterNotifierProvider`).

abstract class _$CounterNotifier extends $AsyncNotifier<int> {
  FutureOr<int> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<int>, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<int>, int>,
              AsyncValue<int>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
