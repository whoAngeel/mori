// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qr_payload_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The SYNC QR text, memoized by `stateVersion`.
///
/// It only recomputes when the local `stateVersion` changes (a mutation), never
/// per frame (§10, design §6). Watching [pairingStateProvider] gives the
/// dependency on stateVersion for free.

@ProviderFor(syncQrPayload)
const syncQrPayloadProvider = SyncQrPayloadProvider._();

/// The SYNC QR text, memoized by `stateVersion`.
///
/// It only recomputes when the local `stateVersion` changes (a mutation), never
/// per frame (§10, design §6). Watching [pairingStateProvider] gives the
/// dependency on stateVersion for free.

final class SyncQrPayloadProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// The SYNC QR text, memoized by `stateVersion`.
  ///
  /// It only recomputes when the local `stateVersion` changes (a mutation), never
  /// per frame (§10, design §6). Watching [pairingStateProvider] gives the
  /// dependency on stateVersion for free.
  const SyncQrPayloadProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncQrPayloadProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncQrPayloadHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return syncQrPayload(ref);
  }
}

String _$syncQrPayloadHash() => r'032a246f7c8f514a0d69349ab1df12996dd19033';
