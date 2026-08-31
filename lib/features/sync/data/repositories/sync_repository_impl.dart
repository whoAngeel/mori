import 'dart:math';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/time/clock.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/box_state.dart';
import '../../domain/entities/partner_snapshot.dart';
import '../../domain/entities/sync_outcome.dart';
import '../../domain/entities/sync_payload.dart';
import '../../domain/repositories/sync_repository.dart';
import '../codec/sync_codec.dart';
import '../datasources/sync_local_data_source.dart';

/// Drift-backed [SyncRepository]. Owns validation checks 8..10, the acceptance
/// rule (§8) and the RESTORE guard (§8.3). The codec handles checks 1..7.
class SyncRepositoryImpl implements SyncRepository {
  /// Creates the repository over its datasource, clock and RNG.
  SyncRepositoryImpl(this._local, this._clock, this._random);

  final SyncLocalDataSource _local;
  final Clock _clock;
  final Random _random;

  static WireBoxState _toWire(int status) => switch (status) {
    2 => WireBoxState.paid,
    1 => WireBoxState.assigned,
    _ => WireBoxState.free,
  };

  int _newInstallId() =>
      (_random.nextInt(1 << 32) << 32) | _random.nextInt(1 << 32);

  @override
  Future<Result<String>> buildSyncPayload() async {
    try {
      final config = await _local.readConfig();
      if (config == null) {
        return const Err(CacheFailure('No challenge to sync'));
      }
      final boxes = await _local.readOwnBoxes();
      final statuses = boxes.map((b) => _toWire(b.status)).toList();
      final text = SyncCodec.encodeSync(
        SyncSnapshot(
          pairingId: config.pairingId,
          slot: config.localSlot,
          installId: config.localInstallId,
          stateVersion: config.stateVersion,
          startEpochDay: config.startEpochDay,
          statuses: statuses,
        ),
      );
      return Ok(text);
    } on CacheException catch (e) {
      return Err(CacheFailure(e.message));
    }
  }

  @override
  Future<Result<SyncOutcome>> applySyncPayload(String scannedText) async {
    try {
      final decoded = SyncCodec.decode(scannedText);
      if (decoded is Err<DecodedPayload>) {
        return Err(decoded.failure);
      }
      final payload = (decoded as Ok<DecodedPayload>).value;
      if (payload is! DecodedSync) {
        // A RESTORE must not be applied from the normal sync scanner (§8.3);
        // a PAIR is not a sync.
        return const Err(UnsupportedKind());
      }
      final snapshot = payload.snapshot;

      final config = await _local.readConfig();
      if (config == null) {
        return const Err(CacheFailure('No local challenge'));
      }

      // Check 8: same pairing.
      if (snapshot.pairingId != config.pairingId) {
        return const Err(ForeignPairing());
      }
      // Check 9: not our own payload.
      if (snapshot.slot == config.localSlot) {
        return const Err(OwnPayloadScanned());
      }

      // Check 10 / acceptance rule (§8).
      final stored = await _local.readPartnerSnapshot();
      final incomingNonFree = snapshot.statuses
          .where((s) => s != WireBoxState.free)
          .length;

      if (stored == null) {
        // First sync ever: accept.
        await _apply(snapshot);
        return Ok(SyncApplied(snapshot.stateVersion));
      }

      if (snapshot.installId != stored.installId) {
        // Reinstall: accept and reset the baseline (§8.1).
        final storedNonFree = await _storedNonFreeCount();
        await _apply(snapshot);
        return Ok(
          SyncPartnerReset(lostProgress: incomingNonFree < storedNonFree),
        );
      }

      if (snapshot.stateVersion > stored.stateVersion) {
        await _apply(snapshot);
        return Ok(SyncApplied(snapshot.stateVersion));
      }
      if (snapshot.stateVersion == stored.stateVersion) {
        return const Ok(SyncNoChange()); // rescan
      }
      // Older: reject, no write.
      return const Err(StaleSnapshot());
    } on CacheException catch (e) {
      return Err(CacheFailure(e.message));
    }
  }

  Future<int> _storedNonFreeCount() async {
    final boxes = await _local.readPartnerBoxes();
    return boxes.where((b) => b.status != 0).length;
  }

  Future<void> _apply(SyncSnapshot snapshot) => _local.applySnapshot(
    statuses: snapshot.statuses,
    stateVersion: snapshot.stateVersion,
    installId: snapshot.installId,
    startEpochDay: snapshot.startEpochDay,
    receivedAtMillis: _clock.now().millisecondsSinceEpoch,
  );

  @override
  Future<Result<String>> buildRestorePayload() async {
    try {
      final config = await _local.readConfig();
      if (config == null) {
        return const Err(CacheFailure('No challenge configured'));
      }
      final snapshot = await _local.readPartnerSnapshot();
      if (snapshot == null) {
        return const Err(NothingToRestore());
      }
      final partnerBoxes = await _local.readPartnerBoxes();
      final statuses = partnerBoxes.map((b) => _toWire(b.status)).toList();

      final text = SyncCodec.encodeRestore(
        RestorePayload(
          pairingId: config.pairingId,
          senderSlot: config.localSlot,
          senderInstallId: config.localInstallId,
          restoredStateVersion: snapshot.stateVersion,
          startEpochDay: snapshot.startEpochDay,
          snapshotEpochDay: _toEpochDayFromMillis(snapshot.receivedAtMillis),
          senderName: config.localName,
          statuses: statuses,
        ),
      );
      return Ok(text);
    } on CacheException catch (e) {
      return Err(CacheFailure(e.message));
    }
  }

  /// Civil-date epoch-day of a stored millis timestamp. Goes through the civil
  /// date (not a raw `~/ 86400000`) so it matches the protocol's §4.2 rule and
  /// does not slip a day near midnight.
  static int _toEpochDayFromMillis(int millis) =>
      toEpochDay(DateTime.fromMillisecondsSinceEpoch(millis));

  @override
  Future<Result<SyncOutcome>> applyRestorePayload({
    required String scannedText,
    required String localName,
  }) async {
    try {
      // Hard guard (§8.3): a RESTORE is accepted only when no config exists.
      final existing = await _local.readConfig();
      if (existing != null) {
        return const Err(RestoreNotApplicable());
      }

      final decoded = SyncCodec.decode(scannedText);
      if (decoded is Err<DecodedPayload>) {
        return Err(decoded.failure);
      }
      final payload = (decoded as Ok<DecodedPayload>).value;
      if (payload is! DecodedRestore) {
        return const Err(UnsupportedKind());
      }
      final restore = payload.payload;

      await _local.seedFromRestore(
        pairingId: restore.pairingId,
        localSlot: 1 - restore.senderSlot,
        localInstallId: _newInstallId(),
        localName: localName,
        partnerName: restore.senderName,
        partnerInstallId: restore.senderInstallId,
        startEpochDay: restore.startEpochDay,
        stateVersion: restore.restoredStateVersion,
        createdAtMillis: _clock.now().millisecondsSinceEpoch,
        statuses: restore.statuses,
      );

      final daysStale = (_clock.todayEpochDay() - restore.snapshotEpochDay)
          .clamp(0, 100000);
      return Ok(RestoreApplied(daysStale));
    } on CacheException catch (e) {
      return Err(CacheFailure(e.message));
    }
  }

  @override
  Stream<PartnerSnapshot?> watchPartnerSnapshot() {
    return _local.watchPartnerSnapshot().map((row) {
      if (row == null) return null;
      return PartnerSnapshot(
        stateVersion: row.stateVersion,
        installId: row.installId,
        startEpochDay: row.startEpochDay,
        receivedAtMillis: row.receivedAtMillis,
      );
    });
  }

  @override
  Stream<List<PartnerBox>> watchPartnerBoxes() {
    return _local.watchPartnerBoxes().map(
      (rows) => rows
          .map((r) => PartnerBox(day: r.day, status: _toWire(r.status)))
          .toList(),
    );
  }
}
