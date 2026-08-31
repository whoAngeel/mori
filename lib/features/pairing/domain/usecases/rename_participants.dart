import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../repositories/pairing_repository.dart';

/// Input for [RenameParticipants]: either or both names may be provided.
final class RenameParticipantsParams {
  /// Bundles the optional new names.
  const RenameParticipantsParams({this.localName, this.partnerName});

  /// New local name, or null to leave unchanged.
  final String? localName;

  /// New partner name, or null to leave unchanged.
  final String? partnerName;
}

/// Renames the local participant and/or the partner.
final class RenameParticipants
    implements UseCase<void, RenameParticipantsParams> {
  /// Creates the use case over [_repository].
  const RenameParticipants(this._repository);

  final PairingRepository _repository;

  @override
  Future<Result<void>> call(RenameParticipantsParams params) =>
      _repository.renameParticipants(
        localName: params.localName,
        partnerName: params.partnerName,
      );
}
