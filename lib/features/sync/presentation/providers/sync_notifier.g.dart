// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The sync datasource.

@ProviderFor(syncLocalDataSource)
const syncLocalDataSourceProvider = SyncLocalDataSourceProvider._();

/// The sync datasource.

final class SyncLocalDataSourceProvider
    extends
        $FunctionalProvider<
          SyncLocalDataSource,
          SyncLocalDataSource,
          SyncLocalDataSource
        >
    with $Provider<SyncLocalDataSource> {
  /// The sync datasource.
  const SyncLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncLocalDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<SyncLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SyncLocalDataSource create(Ref ref) {
    return syncLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncLocalDataSource>(value),
    );
  }
}

String _$syncLocalDataSourceHash() =>
    r'ad68cbd0a86807eb98add03f7b434c0392eb4a67';

/// The sync repository, wired with the clock and RNG.

@ProviderFor(syncRepository)
const syncRepositoryProvider = SyncRepositoryProvider._();

/// The sync repository, wired with the clock and RNG.

final class SyncRepositoryProvider
    extends $FunctionalProvider<SyncRepository, SyncRepository, SyncRepository>
    with $Provider<SyncRepository> {
  /// The sync repository, wired with the clock and RNG.
  const SyncRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncRepositoryHash();

  @$internal
  @override
  $ProviderElement<SyncRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncRepository create(Ref ref) {
    return syncRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncRepository>(value),
    );
  }
}

String _$syncRepositoryHash() => r'e5140e1aeecfc9d8af08c839a4a0ea245f5e01f9';

/// Streams the partner's last snapshot description (or null).

@ProviderFor(partnerSnapshot)
const partnerSnapshotProvider = PartnerSnapshotProvider._();

/// Streams the partner's last snapshot description (or null).

final class PartnerSnapshotProvider
    extends
        $FunctionalProvider<
          AsyncValue<PartnerSnapshot?>,
          PartnerSnapshot?,
          Stream<PartnerSnapshot?>
        >
    with $FutureModifier<PartnerSnapshot?>, $StreamProvider<PartnerSnapshot?> {
  /// Streams the partner's last snapshot description (or null).
  const PartnerSnapshotProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'partnerSnapshotProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$partnerSnapshotHash();

  @$internal
  @override
  $StreamProviderElement<PartnerSnapshot?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<PartnerSnapshot?> create(Ref ref) {
    return partnerSnapshot(ref);
  }
}

String _$partnerSnapshotHash() => r'dd8f12c7e4cbc8c2307e6aab01966b7ef6d19a14';

/// Streams the partner's replica board.

@ProviderFor(partnerBoxes)
const partnerBoxesProvider = PartnerBoxesProvider._();

/// Streams the partner's replica board.

final class PartnerBoxesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PartnerBox>>,
          List<PartnerBox>,
          Stream<List<PartnerBox>>
        >
    with $FutureModifier<List<PartnerBox>>, $StreamProvider<List<PartnerBox>> {
  /// Streams the partner's replica board.
  const PartnerBoxesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'partnerBoxesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$partnerBoxesHash();

  @$internal
  @override
  $StreamProviderElement<List<PartnerBox>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PartnerBox>> create(Ref ref) {
    return partnerBoxes(ref);
  }
}

String _$partnerBoxesHash() => r'cec92b6c4b4f5bb81b074b766f8828df157e3bd2';

/// Coordinates the scan/apply commands.

@ProviderFor(SyncController)
const syncControllerProvider = SyncControllerProvider._();

/// Coordinates the scan/apply commands.
final class SyncControllerProvider
    extends $NotifierProvider<SyncController, void> {
  /// Coordinates the scan/apply commands.
  const SyncControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncControllerHash();

  @$internal
  @override
  SyncController create() => SyncController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$syncControllerHash() => r'5f097ac15c4324c6a461ab56418c83b66b7b033f';

/// Coordinates the scan/apply commands.

abstract class _$SyncController extends $Notifier<void> {
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
