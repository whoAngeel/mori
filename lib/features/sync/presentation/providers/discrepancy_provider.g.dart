// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discrepancy_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// True when the partner's snapshot start date differs from the local one
/// (§8.4). The snapshot was still applied; this drives a persistent notice
/// shown until the challenge is reset.

@ProviderFor(startDateMismatch)
const startDateMismatchProvider = StartDateMismatchProvider._();

/// True when the partner's snapshot start date differs from the local one
/// (§8.4). The snapshot was still applied; this drives a persistent notice
/// shown until the challenge is reset.

final class StartDateMismatchProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// True when the partner's snapshot start date differs from the local one
  /// (§8.4). The snapshot was still applied; this drives a persistent notice
  /// shown until the challenge is reset.
  const StartDateMismatchProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'startDateMismatchProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$startDateMismatchHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return startDateMismatch(ref);
  }
}

String _$startDateMismatchHash() => r'a7c0b7bad17d5e042f9a2dc8b9be4d2cb792b169';

/// True when the partner's snapshot installId differs from the one recorded at
/// pairing time: the partner reinstalled the app (§7.10). Drives a persistent
/// reinstall notice.

@ProviderFor(partnerReinstalled)
const partnerReinstalledProvider = PartnerReinstalledProvider._();

/// True when the partner's snapshot installId differs from the one recorded at
/// pairing time: the partner reinstalled the app (§7.10). Drives a persistent
/// reinstall notice.

final class PartnerReinstalledProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// True when the partner's snapshot installId differs from the one recorded at
  /// pairing time: the partner reinstalled the app (§7.10). Drives a persistent
  /// reinstall notice.
  const PartnerReinstalledProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'partnerReinstalledProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$partnerReinstalledHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return partnerReinstalled(ref);
  }
}

String _$partnerReinstalledHash() =>
    r'd29079f7eed288dfc7fb61f59aeee60df849b0c8';
