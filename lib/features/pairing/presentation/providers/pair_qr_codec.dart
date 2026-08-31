import '../../../../core/utils/result.dart';
import '../../../sync/data/codec/sync_codec.dart' as codec;
import '../../../sync/domain/entities/sync_payload.dart' as wire;
import '../../domain/entities/pair_invite.dart';

/// Bridges the `pairing` domain [PairInvite] to the `sync` wire codec.
///
/// Kept in Presentation: it is orchestration between two features, not domain
/// logic, so it does not violate the "Domain layers never import each other"
/// rule.
abstract final class PairQrCodec {
  /// Encodes a pairing invite to the base64url QR text.
  static String encode(PairInvite invite) => codec.SyncCodec.encodePair(
        wire.PairInvite(
          pairingId: invite.pairingId,
          slot: invite.slot,
          installId: invite.installId,
          startEpochDay: invite.startEpochDay,
          name: invite.name,
        ),
      );

  /// Decodes scanned text into a pairing invite, or null if it is not a valid
  /// PAIR payload.
  static PairInvite? decode(String text) {
    final result = codec.SyncCodec.decode(text);
    return switch (result) {
      Ok(value: wire.DecodedPair(:final invite)) => PairInvite(
          pairingId: invite.pairingId,
          slot: invite.slot,
          installId: invite.installId,
          startEpochDay: invite.startEpochDay,
          name: invite.name,
        ),
      _ => null,
    };
  }
}
