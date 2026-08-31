import '../../../core/error/failures.dart';
import '../domain/entities/sync_outcome.dart';

/// Maps sync failures and outcomes to their exact copy (`docs/design-system.md`
/// §8). Exhaustive switches over the sealed types: adding a case forces a
/// message to be written here.
abstract final class SyncMessages {
  /// Message for a [SyncFailure].
  static String forFailure(SyncFailure failure) => switch (failure) {
        MalformedPayload() => 'No se pudo leer. Inténtalo otra vez.',
        UnsupportedSchema() => 'No se pudo leer. Inténtalo otra vez.',
        UnsupportedKind() => 'Ese código no es de este reto',
        ChecksumMismatch() => 'No se pudo leer. Inténtalo otra vez.',
        ForeignPairing() => 'Ese código no es de este reto',
        OwnPayloadScanned() => 'Ese es tu propio código',
        StaleSnapshot() => 'Ya estabas al día',
        RestoreNotApplicable() =>
          'Ya tienes un reto en curso. Restablécelo primero si quieres '
              'recuperar otro.',
        NothingToRestore() =>
          'Todavía no has escaneado su código, no hay nada guardado',
      };

  /// Message for a [SyncOutcome] after a successful apply. [partnerName] fills
  /// the reinstall/restore lines.
  static String forOutcome(SyncOutcome outcome, {required String partnerName}) {
    return switch (outcome) {
      SyncApplied() =>
        'Listo. Ahora muéstrale tu código para que $partnerName te vea.',
      SyncNoChange() => 'Ya estabas al día',
      SyncPartnerReset(:final lostProgress) => lostProgress
          ? '$partnerName reinstaló la app y perdió parte de su avance'
          : '$partnerName reinstaló la app',
      RestoreApplied(:final daysStale) =>
        'Recuperaste lo que $partnerName vio hace $daysStale días. Ahora '
            'escanea su código para volver a ver su avance.',
    };
  }
}
