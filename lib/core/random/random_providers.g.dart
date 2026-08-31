// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'random_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app-wide [Random]. Override in tests with `Random(seed)` for
/// deterministic draws and id generation.

@ProviderFor(random)
const randomProvider = RandomProvider._();

/// The app-wide [Random]. Override in tests with `Random(seed)` for
/// deterministic draws and id generation.

final class RandomProvider extends $FunctionalProvider<Random, Random, Random>
    with $Provider<Random> {
  /// The app-wide [Random]. Override in tests with `Random(seed)` for
  /// deterministic draws and id generation.
  const RandomProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'randomProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$randomHash();

  @$internal
  @override
  $ProviderElement<Random> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Random create(Ref ref) {
    return random(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Random value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Random>(value),
    );
  }
}

String _$randomHash() => r'4e6a46743c705337f683ba9b67993abf97e14824';
