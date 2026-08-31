// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'counter_local_data_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(counterLocalDataSource)
const counterLocalDataSourceProvider = CounterLocalDataSourceProvider._();

final class CounterLocalDataSourceProvider
    extends
        $FunctionalProvider<
          CounterLocalDataSource,
          CounterLocalDataSource,
          CounterLocalDataSource
        >
    with $Provider<CounterLocalDataSource> {
  const CounterLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'counterLocalDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$counterLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<CounterLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CounterLocalDataSource create(Ref ref) {
    return counterLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CounterLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CounterLocalDataSource>(value),
    );
  }
}

String _$counterLocalDataSourceHash() =>
    r'8be1e7bd14cecbf2ee9e4a5a77f2d642ef9e07f0';
