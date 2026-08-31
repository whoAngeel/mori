// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's [GoRouter], exposed as a Riverpod provider so routing can react to
/// other providers (auth state, feature flags, …) via `ref.watch` +
/// `refreshListenable`.

@ProviderFor(goRouter)
const goRouterProvider = GoRouterProvider._();

/// The app's [GoRouter], exposed as a Riverpod provider so routing can react to
/// other providers (auth state, feature flags, …) via `ref.watch` +
/// `refreshListenable`.

final class GoRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// The app's [GoRouter], exposed as a Riverpod provider so routing can react to
  /// other providers (auth state, feature flags, …) via `ref.watch` +
  /// `refreshListenable`.
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

String _$goRouterHash() => r'25856b4fe642d8d98e1068f31b195093dd8d23e0';
