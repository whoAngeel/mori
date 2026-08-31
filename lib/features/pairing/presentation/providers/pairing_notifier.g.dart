// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pairing_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The pairing datasource.

@ProviderFor(pairingLocalDataSource)
const pairingLocalDataSourceProvider = PairingLocalDataSourceProvider._();

/// The pairing datasource.

final class PairingLocalDataSourceProvider
    extends
        $FunctionalProvider<
          PairingLocalDataSource,
          PairingLocalDataSource,
          PairingLocalDataSource
        >
    with $Provider<PairingLocalDataSource> {
  /// The pairing datasource.
  const PairingLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pairingLocalDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pairingLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<PairingLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PairingLocalDataSource create(Ref ref) {
    return pairingLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PairingLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PairingLocalDataSource>(value),
    );
  }
}

String _$pairingLocalDataSourceHash() =>
    r'0e04aa192ab128d00b1d6705bac408cc1a9605b9';

/// The pairing repository, wired with the clock and RNG.

@ProviderFor(pairingRepository)
const pairingRepositoryProvider = PairingRepositoryProvider._();

/// The pairing repository, wired with the clock and RNG.

final class PairingRepositoryProvider
    extends
        $FunctionalProvider<
          PairingRepository,
          PairingRepository,
          PairingRepository
        >
    with $Provider<PairingRepository> {
  /// The pairing repository, wired with the clock and RNG.
  const PairingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pairingRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pairingRepositoryHash();

  @$internal
  @override
  $ProviderElement<PairingRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PairingRepository create(Ref ref) {
    return pairingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PairingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PairingRepository>(value),
    );
  }
}

String _$pairingRepositoryHash() => r'3f2251eccb927dc9a97063bcb42d4808c9ffc841';

/// Streams the pairing state for the router redirect and UI.

@ProviderFor(pairingState)
const pairingStateProvider = PairingStateProvider._();

/// Streams the pairing state for the router redirect and UI.

final class PairingStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<PairingState>,
          PairingState,
          Stream<PairingState>
        >
    with $FutureModifier<PairingState>, $StreamProvider<PairingState> {
  /// Streams the pairing state for the router redirect and UI.
  const PairingStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pairingStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pairingStateHash();

  @$internal
  @override
  $StreamProviderElement<PairingState> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<PairingState> create(Ref ref) {
    return pairingState(ref);
  }
}

String _$pairingStateHash() => r'a77dc3ea2209087203a480417e4dd3a8494fcbc0';

/// Coordinates the pairing ceremony commands.

@ProviderFor(PairingController)
const pairingControllerProvider = PairingControllerProvider._();

/// Coordinates the pairing ceremony commands.
final class PairingControllerProvider
    extends $NotifierProvider<PairingController, void> {
  /// Coordinates the pairing ceremony commands.
  const PairingControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pairingControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pairingControllerHash();

  @$internal
  @override
  PairingController create() => PairingController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$pairingControllerHash() => r'c8381c3e976e7be1a3d24902221637a0bf991901';

/// Coordinates the pairing ceremony commands.

abstract class _$PairingController extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
