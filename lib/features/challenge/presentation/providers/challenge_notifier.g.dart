// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The challenge datasource, wired with the RNG and the clock's millis.

@ProviderFor(challengeLocalDataSource)
const challengeLocalDataSourceProvider = ChallengeLocalDataSourceProvider._();

/// The challenge datasource, wired with the RNG and the clock's millis.

final class ChallengeLocalDataSourceProvider
    extends
        $FunctionalProvider<
          ChallengeLocalDataSource,
          ChallengeLocalDataSource,
          ChallengeLocalDataSource
        >
    with $Provider<ChallengeLocalDataSource> {
  /// The challenge datasource, wired with the RNG and the clock's millis.
  const ChallengeLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'challengeLocalDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$challengeLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<ChallengeLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ChallengeLocalDataSource create(Ref ref) {
    return challengeLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChallengeLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChallengeLocalDataSource>(value),
    );
  }
}

String _$challengeLocalDataSourceHash() =>
    r'c900a5055f477ad94b8ad194dc06d0392b41db3b';

/// The challenge repository.

@ProviderFor(challengeRepository)
const challengeRepositoryProvider = ChallengeRepositoryProvider._();

/// The challenge repository.

final class ChallengeRepositoryProvider
    extends
        $FunctionalProvider<
          ChallengeRepository,
          ChallengeRepository,
          ChallengeRepository
        >
    with $Provider<ChallengeRepository> {
  /// The challenge repository.
  const ChallengeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'challengeRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$challengeRepositoryHash();

  @$internal
  @override
  $ProviderElement<ChallengeRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ChallengeRepository create(Ref ref) {
    return challengeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChallengeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChallengeRepository>(value),
    );
  }
}

String _$challengeRepositoryHash() =>
    r'e4c9b17876929dd9f0823fb080c58ef47fa78702';

/// Streams boxes + progress and exposes the board commands.

@ProviderFor(ChallengeNotifier)
const challengeProvider = ChallengeNotifierProvider._();

/// Streams boxes + progress and exposes the board commands.
final class ChallengeNotifierProvider
    extends $StreamNotifierProvider<ChallengeNotifier, ChallengeState> {
  /// Streams boxes + progress and exposes the board commands.
  const ChallengeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'challengeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$challengeNotifierHash();

  @$internal
  @override
  ChallengeNotifier create() => ChallengeNotifier();
}

String _$challengeNotifierHash() => r'eb8ef503bdf081b17edc66514d4aa9dea7b1846e';

/// Streams boxes + progress and exposes the board commands.

abstract class _$ChallengeNotifier extends $StreamNotifier<ChallengeState> {
  Stream<ChallengeState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<ChallengeState>, ChallengeState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ChallengeState>, ChallengeState>,
              AsyncValue<ChallengeState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
