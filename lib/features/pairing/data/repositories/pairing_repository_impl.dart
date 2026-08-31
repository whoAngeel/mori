import 'dart:math';

import '../../../../core/database/app_database.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/time/clock.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/pair_invite.dart';
import '../../domain/entities/pairing_state.dart';
import '../../domain/repositories/pairing_repository.dart';
import '../datasources/pairing_local_data_source.dart';

/// Drift-backed [PairingRepository].
///
/// Generates ids with an injected [Random] (seedable in tests) and reads "now"
/// from an injected [Clock]. Catches [CacheException] and returns a [Failure].
class PairingRepositoryImpl implements PairingRepository {
  /// Creates the repository over its datasource, clock and RNG.
  PairingRepositoryImpl(this._local, this._clock, this._random);

  final PairingLocalDataSource _local;
  final Clock _clock;
  final Random _random;

  // uint32
  int _newPairingId() => _random.nextInt(1 << 32);

  // uint64 assembled from two 32-bit draws (Random.nextInt caps at 2^32).
  int _newInstallId() =>
      (_random.nextInt(1 << 32) << 32) | _random.nextInt(1 << 32);

  PairingState _toState(ChallengeConfigRow? row) {
    if (row == null) return const Unpaired();
    return Paired(
      pairingId: row.pairingId,
      localSlot: row.localSlot,
      localInstallId: row.localInstallId,
      localName: row.localName,
      startEpochDay: row.startEpochDay,
      stateVersion: row.stateVersion,
      partnerName: row.partnerName,
      partnerInstallId: row.partnerInstallId,
    );
  }

  @override
  Stream<PairingState> watchPairingState() =>
      _local.watchConfig().map(_toState);

  @override
  Future<Result<PairingState>> readPairingState() async {
    try {
      return Ok(_toState(await _local.readConfig()));
    } on CacheException catch (e) {
      return Err(CacheFailure(e.message));
    }
  }

  @override
  Future<Result<PairInvite>> createChallenge({
    required String localName,
  }) async {
    try {
      final pairingId = _newPairingId();
      final installId = _newInstallId();
      final startEpochDay = _clock.todayEpochDay();
      await _local.seedChallenge(
        pairingId: pairingId,
        localSlot: 0,
        localInstallId: installId,
        localName: localName,
        startEpochDay: startEpochDay,
        createdAtMillis: _clock.now().millisecondsSinceEpoch,
      );
      return Ok(
        PairInvite(
          pairingId: pairingId,
          slot: 0,
          installId: installId,
          startEpochDay: startEpochDay,
          name: localName,
        ),
      );
    } on CacheException catch (e) {
      return Err(CacheFailure(e.message));
    }
  }

  @override
  Future<Result<PairInvite>> joinChallenge({
    required PairInvite inviterInvite,
    required String localName,
  }) async {
    try {
      final installId = _newInstallId();
      // Slot B adopts the inviter's pairingId and start date, records the
      // inviter as partner, and seeds its own board.
      await _local.seedChallenge(
        pairingId: inviterInvite.pairingId,
        localSlot: 1,
        localInstallId: installId,
        localName: localName,
        startEpochDay: inviterInvite.startEpochDay,
        createdAtMillis: _clock.now().millisecondsSinceEpoch,
        partnerName: inviterInvite.name,
        partnerInstallId: inviterInvite.installId,
      );
      return Ok(
        PairInvite(
          pairingId: inviterInvite.pairingId,
          slot: 1,
          installId: installId,
          startEpochDay: inviterInvite.startEpochDay,
          name: localName,
        ),
      );
    } on CacheException catch (e) {
      return Err(CacheFailure(e.message));
    }
  }

  @override
  Future<Result<PairInvite>> buildPairInvite() async {
    try {
      final row = await _local.readConfig();
      if (row == null) {
        return const Err(CacheFailure('No challenge to build an invite from'));
      }
      return Ok(
        PairInvite(
          pairingId: row.pairingId,
          slot: row.localSlot,
          installId: row.localInstallId,
          startEpochDay: row.startEpochDay,
          name: row.localName,
        ),
      );
    } on CacheException catch (e) {
      return Err(CacheFailure(e.message));
    }
  }

  @override
  Future<Result<ApplyPairOutcome>> applyPairInvite(
    PairInvite partnerInvite,
  ) async {
    try {
      final row = await _local.readConfig();

      // Branch 1: no local pairing -> adopt the scanned challenge as slot B.
      if (row == null) {
        final installId = _newInstallId();
        await _local.seedChallenge(
          pairingId: partnerInvite.pairingId,
          localSlot: partnerInvite.slot == 0 ? 1 : 0,
          localInstallId: installId,
          localName: '',
          startEpochDay: partnerInvite.startEpochDay,
          createdAtMillis: _clock.now().millisecondsSinceEpoch,
          partnerName: partnerInvite.name,
          partnerInstallId: partnerInvite.installId,
        );
        return const Ok(ApplyPairOutcome.adopted);
      }

      // Branch 3: different pairingId -> reject without writing.
      if (row.pairingId != partnerInvite.pairingId) {
        return const Ok(ApplyPairOutcome.rejectedForeign);
      }

      // Branch 2: same pairingId -> store partner identity only, boxes
      // untouched.
      await _local.linkPartner(
        partnerName: partnerInvite.name,
        partnerInstallId: partnerInvite.installId,
      );
      return const Ok(ApplyPairOutcome.partnerLinked);
    } on CacheException catch (e) {
      return Err(CacheFailure(e.message));
    }
  }

  @override
  Future<Result<void>> renameParticipants({
    String? localName,
    String? partnerName,
  }) async {
    try {
      await _local.rename(localName: localName, partnerName: partnerName);
      return const Ok(null);
    } on CacheException catch (e) {
      return Err(CacheFailure(e.message));
    }
  }

  @override
  Future<Result<void>> resetChallenge() async {
    try {
      await _local.wipe();
      return const Ok(null);
    } on CacheException catch (e) {
      return Err(CacheFailure(e.message));
    }
  }
}
