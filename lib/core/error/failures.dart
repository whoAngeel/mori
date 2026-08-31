/// Base type for every recoverable error that crosses a layer boundary.
///
/// The Data layer catches raw [Exception]s and maps them to a [Failure]; the
/// Domain and Presentation layers only ever see [Failure]s.
sealed class Failure {
  const Failure(this.message);

  final String message;

  @override
  String toString() => '$runtimeType($message)';
}

/// Something went wrong while talking to the local database / cache.
final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local storage error']);
}

/// Anything we did not explicitly model.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Unexpected error']);
}

/// Errors raised while decoding, validating or applying a scanned QR payload.
///
/// Each concrete case maps to exactly one copy string in
/// `docs/design-system.md` §8. The UI switches exhaustively over this sealed
/// type, so adding a case forces its message to be written.
sealed class SyncFailure extends Failure {
  const SyncFailure(super.message);
}

/// The payload bytes do not parse: bad length, bad padding, or a `0b11` box.
final class MalformedPayload extends SyncFailure {
  const MalformedPayload([super.message = 'Malformed payload']);
}

/// The payload uses a schema version this build does not understand.
final class UnsupportedSchema extends SyncFailure {
  const UnsupportedSchema([super.message = 'Unsupported schema version']);
}

/// The payload kind is valid but not accepted by the scanning screen.
final class UnsupportedKind extends SyncFailure {
  const UnsupportedKind([super.message = 'Unsupported payload kind']);
}

/// The CRC-32 footer does not match the payload body.
final class ChecksumMismatch extends SyncFailure {
  const ChecksumMismatch([super.message = 'Checksum mismatch']);
}

/// The payload belongs to a different challenge (`pairingId` mismatch).
final class ForeignPairing extends SyncFailure {
  const ForeignPairing([super.message = 'Foreign pairing']);
}

/// The scanned payload was produced by this very device.
final class OwnPayloadScanned extends SyncFailure {
  const OwnPayloadScanned([super.message = 'Own payload scanned']);
}

/// The snapshot is older than or equal to the one already stored.
final class StaleSnapshot extends SyncFailure {
  const StaleSnapshot([super.message = 'Stale snapshot']);
}

/// A `RESTORE` was scanned while a challenge is already in progress.
final class RestoreNotApplicable extends SyncFailure {
  const RestoreNotApplicable([super.message = 'Restore not applicable']);
}

/// Asked to emit a `RESTORE` but there is no partner snapshot to send.
final class NothingToRestore extends SyncFailure {
  const NothingToRestore([super.message = 'Nothing to restore']);
}

/// Errors raised by the challenge board: drawing and paying.
///
/// Each concrete case maps to exactly one copy string in
/// `docs/design-system.md` §8, consumed by an exhaustive `switch`.
sealed class ChallengeFailure extends Failure {
  const ChallengeFailure(super.message);
}

/// There are no pending draws to spend today.
final class NoDrawsPending extends ChallengeFailure {
  const NoDrawsPending([super.message = 'No draws pending']);
}

/// Every box has already been drawn; the challenge is finished.
final class NoBoxesLeft extends ChallengeFailure {
  const NoBoxesLeft([super.message = 'No boxes left']);
}
