// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's [GoRouter]. Redirects by pairing state (design §6): an unpaired
/// device is pinned to onboarding/pairing; a paired device leaves onboarding
/// for home.

@ProviderFor(goRouter)
const goRouterProvider = GoRouterProvider._();

/// The app's [GoRouter]. Redirects by pairing state (design §6): an unpaired
/// device is pinned to onboarding/pairing; a paired device leaves onboarding
/// for home.

final class GoRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// The app's [GoRouter]. Redirects by pairing state (design §6): an unpaired
  /// device is pinned to onboarding/pairing; a paired device leaves onboarding
  /// for home.
  const GoRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return goRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$goRouterHash() => r'36e12ca3f220a019a1f210a569bef95daa7e960e';
