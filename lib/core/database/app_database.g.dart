// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ChallengeConfigRowsTable extends ChallengeConfigRows
    with TableInfo<$ChallengeConfigRowsTable, ChallengeConfigRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChallengeConfigRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _pairingIdMeta = const VerificationMeta(
    'pairingId',
  );
  @override
  late final GeneratedColumn<int> pairingId = GeneratedColumn<int>(
    'pairing_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localSlotMeta = const VerificationMeta(
    'localSlot',
  );
  @override
  late final GeneratedColumn<int> localSlot = GeneratedColumn<int>(
    'local_slot',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localInstallIdMeta = const VerificationMeta(
    'localInstallId',
  );
  @override
  late final GeneratedColumn<int> localInstallId = GeneratedColumn<int>(
    'local_install_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localNameMeta = const VerificationMeta(
    'localName',
  );
  @override
  late final GeneratedColumn<String> localName = GeneratedColumn<String>(
    'local_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _partnerNameMeta = const VerificationMeta(
    'partnerName',
  );
  @override
  late final GeneratedColumn<String> partnerName = GeneratedColumn<String>(
    'partner_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _partnerInstallIdMeta = const VerificationMeta(
    'partnerInstallId',
  );
  @override
  late final GeneratedColumn<int> partnerInstallId = GeneratedColumn<int>(
    'partner_install_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startEpochDayMeta = const VerificationMeta(
    'startEpochDay',
  );
  @override
  late final GeneratedColumn<int> startEpochDay = GeneratedColumn<int>(
    'start_epoch_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateVersionMeta = const VerificationMeta(
    'stateVersion',
  );
  @override
  late final GeneratedColumn<int> stateVersion = GeneratedColumn<int>(
    'state_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMillisMeta = const VerificationMeta(
    'createdAtMillis',
  );
  @override
  late final GeneratedColumn<int> createdAtMillis = GeneratedColumn<int>(
    'created_at_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pairingId,
    localSlot,
    localInstallId,
    localName,
    partnerName,
    partnerInstallId,
    startEpochDay,
    stateVersion,
    createdAtMillis,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'challenge_config_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChallengeConfigRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pairing_id')) {
      context.handle(
        _pairingIdMeta,
        pairingId.isAcceptableOrUnknown(data['pairing_id']!, _pairingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pairingIdMeta);
    }
    if (data.containsKey('local_slot')) {
      context.handle(
        _localSlotMeta,
        localSlot.isAcceptableOrUnknown(data['local_slot']!, _localSlotMeta),
      );
    } else if (isInserting) {
      context.missing(_localSlotMeta);
    }
    if (data.containsKey('local_install_id')) {
      context.handle(
        _localInstallIdMeta,
        localInstallId.isAcceptableOrUnknown(
          data['local_install_id']!,
          _localInstallIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localInstallIdMeta);
    }
    if (data.containsKey('local_name')) {
      context.handle(
        _localNameMeta,
        localName.isAcceptableOrUnknown(data['local_name']!, _localNameMeta),
      );
    } else if (isInserting) {
      context.missing(_localNameMeta);
    }
    if (data.containsKey('partner_name')) {
      context.handle(
        _partnerNameMeta,
        partnerName.isAcceptableOrUnknown(
          data['partner_name']!,
          _partnerNameMeta,
        ),
      );
    }
    if (data.containsKey('partner_install_id')) {
      context.handle(
        _partnerInstallIdMeta,
        partnerInstallId.isAcceptableOrUnknown(
          data['partner_install_id']!,
          _partnerInstallIdMeta,
        ),
      );
    }
    if (data.containsKey('start_epoch_day')) {
      context.handle(
        _startEpochDayMeta,
        startEpochDay.isAcceptableOrUnknown(
          data['start_epoch_day']!,
          _startEpochDayMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startEpochDayMeta);
    }
    if (data.containsKey('state_version')) {
      context.handle(
        _stateVersionMeta,
        stateVersion.isAcceptableOrUnknown(
          data['state_version']!,
          _stateVersionMeta,
        ),
      );
    }
    if (data.containsKey('created_at_millis')) {
      context.handle(
        _createdAtMillisMeta,
        createdAtMillis.isAcceptableOrUnknown(
          data['created_at_millis']!,
          _createdAtMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMillisMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChallengeConfigRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChallengeConfigRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pairingId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pairing_id'],
      )!,
      localSlot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_slot'],
      )!,
      localInstallId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_install_id'],
      )!,
      localName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_name'],
      )!,
      partnerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}partner_name'],
      ),
      partnerInstallId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}partner_install_id'],
      ),
      startEpochDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_epoch_day'],
      )!,
      stateVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}state_version'],
      )!,
      createdAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_millis'],
      )!,
    );
  }

  @override
  $ChallengeConfigRowsTable createAlias(String alias) {
    return $ChallengeConfigRowsTable(attachedDatabase, alias);
  }
}

class ChallengeConfigRow extends DataClass
    implements Insertable<ChallengeConfigRow> {
  /// Always `1`: this table holds exactly one row.
  final int id;

  /// Logical uint32, generated by whoever creates the challenge.
  final int pairingId;

  /// `0` = A, `1` = B.
  final int localSlot;

  /// Logical uint64, random per install.
  final int localInstallId;

  /// This participant's name, <= 24 UTF-8 bytes.
  final String localName;

  /// The partner's name; `null` until pairing closes.
  final String? partnerName;

  /// The partner's install id; `null` until pairing closes.
  final int? partnerInstallId;

  /// Days since 1970-01-01 UTC.
  final int startEpochDay;

  /// Monotonic counter of local mutations.
  final int stateVersion;

  /// Informative only.
  final int createdAtMillis;
  const ChallengeConfigRow({
    required this.id,
    required this.pairingId,
    required this.localSlot,
    required this.localInstallId,
    required this.localName,
    this.partnerName,
    this.partnerInstallId,
    required this.startEpochDay,
    required this.stateVersion,
    required this.createdAtMillis,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pairing_id'] = Variable<int>(pairingId);
    map['local_slot'] = Variable<int>(localSlot);
    map['local_install_id'] = Variable<int>(localInstallId);
    map['local_name'] = Variable<String>(localName);
    if (!nullToAbsent || partnerName != null) {
      map['partner_name'] = Variable<String>(partnerName);
    }
    if (!nullToAbsent || partnerInstallId != null) {
      map['partner_install_id'] = Variable<int>(partnerInstallId);
    }
    map['start_epoch_day'] = Variable<int>(startEpochDay);
    map['state_version'] = Variable<int>(stateVersion);
    map['created_at_millis'] = Variable<int>(createdAtMillis);
    return map;
  }

  ChallengeConfigRowsCompanion toCompanion(bool nullToAbsent) {
    return ChallengeConfigRowsCompanion(
      id: Value(id),
      pairingId: Value(pairingId),
      localSlot: Value(localSlot),
      localInstallId: Value(localInstallId),
      localName: Value(localName),
      partnerName: partnerName == null && nullToAbsent
          ? const Value.absent()
          : Value(partnerName),
      partnerInstallId: partnerInstallId == null && nullToAbsent
          ? const Value.absent()
          : Value(partnerInstallId),
      startEpochDay: Value(startEpochDay),
      stateVersion: Value(stateVersion),
      createdAtMillis: Value(createdAtMillis),
    );
  }

  factory ChallengeConfigRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChallengeConfigRow(
      id: serializer.fromJson<int>(json['id']),
      pairingId: serializer.fromJson<int>(json['pairingId']),
      localSlot: serializer.fromJson<int>(json['localSlot']),
      localInstallId: serializer.fromJson<int>(json['localInstallId']),
      localName: serializer.fromJson<String>(json['localName']),
      partnerName: serializer.fromJson<String?>(json['partnerName']),
      partnerInstallId: serializer.fromJson<int?>(json['partnerInstallId']),
      startEpochDay: serializer.fromJson<int>(json['startEpochDay']),
      stateVersion: serializer.fromJson<int>(json['stateVersion']),
      createdAtMillis: serializer.fromJson<int>(json['createdAtMillis']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pairingId': serializer.toJson<int>(pairingId),
      'localSlot': serializer.toJson<int>(localSlot),
      'localInstallId': serializer.toJson<int>(localInstallId),
      'localName': serializer.toJson<String>(localName),
      'partnerName': serializer.toJson<String?>(partnerName),
      'partnerInstallId': serializer.toJson<int?>(partnerInstallId),
      'startEpochDay': serializer.toJson<int>(startEpochDay),
      'stateVersion': serializer.toJson<int>(stateVersion),
      'createdAtMillis': serializer.toJson<int>(createdAtMillis),
    };
  }

  ChallengeConfigRow copyWith({
    int? id,
    int? pairingId,
    int? localSlot,
    int? localInstallId,
    String? localName,
    Value<String?> partnerName = const Value.absent(),
    Value<int?> partnerInstallId = const Value.absent(),
    int? startEpochDay,
    int? stateVersion,
    int? createdAtMillis,
  }) => ChallengeConfigRow(
    id: id ?? this.id,
    pairingId: pairingId ?? this.pairingId,
    localSlot: localSlot ?? this.localSlot,
    localInstallId: localInstallId ?? this.localInstallId,
    localName: localName ?? this.localName,
    partnerName: partnerName.present ? partnerName.value : this.partnerName,
    partnerInstallId: partnerInstallId.present
        ? partnerInstallId.value
        : this.partnerInstallId,
    startEpochDay: startEpochDay ?? this.startEpochDay,
    stateVersion: stateVersion ?? this.stateVersion,
    createdAtMillis: createdAtMillis ?? this.createdAtMillis,
  );
  ChallengeConfigRow copyWithCompanion(ChallengeConfigRowsCompanion data) {
    return ChallengeConfigRow(
      id: data.id.present ? data.id.value : this.id,
      pairingId: data.pairingId.present ? data.pairingId.value : this.pairingId,
      localSlot: data.localSlot.present ? data.localSlot.value : this.localSlot,
      localInstallId: data.localInstallId.present
          ? data.localInstallId.value
          : this.localInstallId,
      localName: data.localName.present ? data.localName.value : this.localName,
      partnerName: data.partnerName.present
          ? data.partnerName.value
          : this.partnerName,
      partnerInstallId: data.partnerInstallId.present
          ? data.partnerInstallId.value
          : this.partnerInstallId,
      startEpochDay: data.startEpochDay.present
          ? data.startEpochDay.value
          : this.startEpochDay,
      stateVersion: data.stateVersion.present
          ? data.stateVersion.value
          : this.stateVersion,
      createdAtMillis: data.createdAtMillis.present
          ? data.createdAtMillis.value
          : this.createdAtMillis,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChallengeConfigRow(')
          ..write('id: $id, ')
          ..write('pairingId: $pairingId, ')
          ..write('localSlot: $localSlot, ')
          ..write('localInstallId: $localInstallId, ')
          ..write('localName: $localName, ')
          ..write('partnerName: $partnerName, ')
          ..write('partnerInstallId: $partnerInstallId, ')
          ..write('startEpochDay: $startEpochDay, ')
          ..write('stateVersion: $stateVersion, ')
          ..write('createdAtMillis: $createdAtMillis')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pairingId,
    localSlot,
    localInstallId,
    localName,
    partnerName,
    partnerInstallId,
    startEpochDay,
    stateVersion,
    createdAtMillis,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChallengeConfigRow &&
          other.id == this.id &&
          other.pairingId == this.pairingId &&
          other.localSlot == this.localSlot &&
          other.localInstallId == this.localInstallId &&
          other.localName == this.localName &&
          other.partnerName == this.partnerName &&
          other.partnerInstallId == this.partnerInstallId &&
          other.startEpochDay == this.startEpochDay &&
          other.stateVersion == this.stateVersion &&
          other.createdAtMillis == this.createdAtMillis);
}

class ChallengeConfigRowsCompanion extends UpdateCompanion<ChallengeConfigRow> {
  final Value<int> id;
  final Value<int> pairingId;
  final Value<int> localSlot;
  final Value<int> localInstallId;
  final Value<String> localName;
  final Value<String?> partnerName;
  final Value<int?> partnerInstallId;
  final Value<int> startEpochDay;
  final Value<int> stateVersion;
  final Value<int> createdAtMillis;
  const ChallengeConfigRowsCompanion({
    this.id = const Value.absent(),
    this.pairingId = const Value.absent(),
    this.localSlot = const Value.absent(),
    this.localInstallId = const Value.absent(),
    this.localName = const Value.absent(),
    this.partnerName = const Value.absent(),
    this.partnerInstallId = const Value.absent(),
    this.startEpochDay = const Value.absent(),
    this.stateVersion = const Value.absent(),
    this.createdAtMillis = const Value.absent(),
  });
  ChallengeConfigRowsCompanion.insert({
    this.id = const Value.absent(),
    required int pairingId,
    required int localSlot,
    required int localInstallId,
    required String localName,
    this.partnerName = const Value.absent(),
    this.partnerInstallId = const Value.absent(),
    required int startEpochDay,
    this.stateVersion = const Value.absent(),
    required int createdAtMillis,
  }) : pairingId = Value(pairingId),
       localSlot = Value(localSlot),
       localInstallId = Value(localInstallId),
       localName = Value(localName),
       startEpochDay = Value(startEpochDay),
       createdAtMillis = Value(createdAtMillis);
  static Insertable<ChallengeConfigRow> custom({
    Expression<int>? id,
    Expression<int>? pairingId,
    Expression<int>? localSlot,
    Expression<int>? localInstallId,
    Expression<String>? localName,
    Expression<String>? partnerName,
    Expression<int>? partnerInstallId,
    Expression<int>? startEpochDay,
    Expression<int>? stateVersion,
    Expression<int>? createdAtMillis,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pairingId != null) 'pairing_id': pairingId,
      if (localSlot != null) 'local_slot': localSlot,
      if (localInstallId != null) 'local_install_id': localInstallId,
      if (localName != null) 'local_name': localName,
      if (partnerName != null) 'partner_name': partnerName,
      if (partnerInstallId != null) 'partner_install_id': partnerInstallId,
      if (startEpochDay != null) 'start_epoch_day': startEpochDay,
      if (stateVersion != null) 'state_version': stateVersion,
      if (createdAtMillis != null) 'created_at_millis': createdAtMillis,
    });
  }

  ChallengeConfigRowsCompanion copyWith({
    Value<int>? id,
    Value<int>? pairingId,
    Value<int>? localSlot,
    Value<int>? localInstallId,
    Value<String>? localName,
    Value<String?>? partnerName,
    Value<int?>? partnerInstallId,
    Value<int>? startEpochDay,
    Value<int>? stateVersion,
    Value<int>? createdAtMillis,
  }) {
    return ChallengeConfigRowsCompanion(
      id: id ?? this.id,
      pairingId: pairingId ?? this.pairingId,
      localSlot: localSlot ?? this.localSlot,
      localInstallId: localInstallId ?? this.localInstallId,
      localName: localName ?? this.localName,
      partnerName: partnerName ?? this.partnerName,
      partnerInstallId: partnerInstallId ?? this.partnerInstallId,
      startEpochDay: startEpochDay ?? this.startEpochDay,
      stateVersion: stateVersion ?? this.stateVersion,
      createdAtMillis: createdAtMillis ?? this.createdAtMillis,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pairingId.present) {
      map['pairing_id'] = Variable<int>(pairingId.value);
    }
    if (localSlot.present) {
      map['local_slot'] = Variable<int>(localSlot.value);
    }
    if (localInstallId.present) {
      map['local_install_id'] = Variable<int>(localInstallId.value);
    }
    if (localName.present) {
      map['local_name'] = Variable<String>(localName.value);
    }
    if (partnerName.present) {
      map['partner_name'] = Variable<String>(partnerName.value);
    }
    if (partnerInstallId.present) {
      map['partner_install_id'] = Variable<int>(partnerInstallId.value);
    }
    if (startEpochDay.present) {
      map['start_epoch_day'] = Variable<int>(startEpochDay.value);
    }
    if (stateVersion.present) {
      map['state_version'] = Variable<int>(stateVersion.value);
    }
    if (createdAtMillis.present) {
      map['created_at_millis'] = Variable<int>(createdAtMillis.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChallengeConfigRowsCompanion(')
          ..write('id: $id, ')
          ..write('pairingId: $pairingId, ')
          ..write('localSlot: $localSlot, ')
          ..write('localInstallId: $localInstallId, ')
          ..write('localName: $localName, ')
          ..write('partnerName: $partnerName, ')
          ..write('partnerInstallId: $partnerInstallId, ')
          ..write('startEpochDay: $startEpochDay, ')
          ..write('stateVersion: $stateVersion, ')
          ..write('createdAtMillis: $createdAtMillis')
          ..write(')'))
        .toString();
  }
}

class $OwnBoxesTable extends OwnBoxes
    with TableInfo<$OwnBoxesTable, OwnBoxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OwnBoxesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<int> day = GeneratedColumn<int>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _drawnAtMillisMeta = const VerificationMeta(
    'drawnAtMillis',
  );
  @override
  late final GeneratedColumn<int> drawnAtMillis = GeneratedColumn<int>(
    'drawn_at_millis',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paidAtMillisMeta = const VerificationMeta(
    'paidAtMillis',
  );
  @override
  late final GeneratedColumn<int> paidAtMillis = GeneratedColumn<int>(
    'paid_at_millis',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    day,
    status,
    drawnAtMillis,
    paidAtMillis,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'own_boxes';
  @override
  VerificationContext validateIntegrity(
    Insertable<OwnBoxRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('drawn_at_millis')) {
      context.handle(
        _drawnAtMillisMeta,
        drawnAtMillis.isAcceptableOrUnknown(
          data['drawn_at_millis']!,
          _drawnAtMillisMeta,
        ),
      );
    }
    if (data.containsKey('paid_at_millis')) {
      context.handle(
        _paidAtMillisMeta,
        paidAtMillis.isAcceptableOrUnknown(
          data['paid_at_millis']!,
          _paidAtMillisMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day};
  @override
  OwnBoxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OwnBoxRow(
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      drawnAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}drawn_at_millis'],
      ),
      paidAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paid_at_millis'],
      ),
    );
  }

  @override
  $OwnBoxesTable createAlias(String alias) {
    return $OwnBoxesTable(attachedDatabase, alias);
  }
}

class OwnBoxRow extends DataClass implements Insertable<OwnBoxRow> {
  /// `1..365`. Also the amount in MXN.
  final int day;

  /// `0` free, `1` assigned, `2` paid.
  final int status;

  /// Local only, never travels in the QR. `null` after a RESTORE.
  final int? drawnAtMillis;

  /// Local only, never travels in the QR. `null` after a RESTORE.
  final int? paidAtMillis;
  const OwnBoxRow({
    required this.day,
    required this.status,
    this.drawnAtMillis,
    this.paidAtMillis,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<int>(day);
    map['status'] = Variable<int>(status);
    if (!nullToAbsent || drawnAtMillis != null) {
      map['drawn_at_millis'] = Variable<int>(drawnAtMillis);
    }
    if (!nullToAbsent || paidAtMillis != null) {
      map['paid_at_millis'] = Variable<int>(paidAtMillis);
    }
    return map;
  }

  OwnBoxesCompanion toCompanion(bool nullToAbsent) {
    return OwnBoxesCompanion(
      day: Value(day),
      status: Value(status),
      drawnAtMillis: drawnAtMillis == null && nullToAbsent
          ? const Value.absent()
          : Value(drawnAtMillis),
      paidAtMillis: paidAtMillis == null && nullToAbsent
          ? const Value.absent()
          : Value(paidAtMillis),
    );
  }

  factory OwnBoxRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OwnBoxRow(
      day: serializer.fromJson<int>(json['day']),
      status: serializer.fromJson<int>(json['status']),
      drawnAtMillis: serializer.fromJson<int?>(json['drawnAtMillis']),
      paidAtMillis: serializer.fromJson<int?>(json['paidAtMillis']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<int>(day),
      'status': serializer.toJson<int>(status),
      'drawnAtMillis': serializer.toJson<int?>(drawnAtMillis),
      'paidAtMillis': serializer.toJson<int?>(paidAtMillis),
    };
  }

  OwnBoxRow copyWith({
    int? day,
    int? status,
    Value<int?> drawnAtMillis = const Value.absent(),
    Value<int?> paidAtMillis = const Value.absent(),
  }) => OwnBoxRow(
    day: day ?? this.day,
    status: status ?? this.status,
    drawnAtMillis: drawnAtMillis.present
        ? drawnAtMillis.value
        : this.drawnAtMillis,
    paidAtMillis: paidAtMillis.present ? paidAtMillis.value : this.paidAtMillis,
  );
  OwnBoxRow copyWithCompanion(OwnBoxesCompanion data) {
    return OwnBoxRow(
      day: data.day.present ? data.day.value : this.day,
      status: data.status.present ? data.status.value : this.status,
      drawnAtMillis: data.drawnAtMillis.present
          ? data.drawnAtMillis.value
          : this.drawnAtMillis,
      paidAtMillis: data.paidAtMillis.present
          ? data.paidAtMillis.value
          : this.paidAtMillis,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OwnBoxRow(')
          ..write('day: $day, ')
          ..write('status: $status, ')
          ..write('drawnAtMillis: $drawnAtMillis, ')
          ..write('paidAtMillis: $paidAtMillis')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(day, status, drawnAtMillis, paidAtMillis);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OwnBoxRow &&
          other.day == this.day &&
          other.status == this.status &&
          other.drawnAtMillis == this.drawnAtMillis &&
          other.paidAtMillis == this.paidAtMillis);
}

class OwnBoxesCompanion extends UpdateCompanion<OwnBoxRow> {
  final Value<int> day;
  final Value<int> status;
  final Value<int?> drawnAtMillis;
  final Value<int?> paidAtMillis;
  const OwnBoxesCompanion({
    this.day = const Value.absent(),
    this.status = const Value.absent(),
    this.drawnAtMillis = const Value.absent(),
    this.paidAtMillis = const Value.absent(),
  });
  OwnBoxesCompanion.insert({
    this.day = const Value.absent(),
    this.status = const Value.absent(),
    this.drawnAtMillis = const Value.absent(),
    this.paidAtMillis = const Value.absent(),
  });
  static Insertable<OwnBoxRow> custom({
    Expression<int>? day,
    Expression<int>? status,
    Expression<int>? drawnAtMillis,
    Expression<int>? paidAtMillis,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (status != null) 'status': status,
      if (drawnAtMillis != null) 'drawn_at_millis': drawnAtMillis,
      if (paidAtMillis != null) 'paid_at_millis': paidAtMillis,
    });
  }

  OwnBoxesCompanion copyWith({
    Value<int>? day,
    Value<int>? status,
    Value<int?>? drawnAtMillis,
    Value<int?>? paidAtMillis,
  }) {
    return OwnBoxesCompanion(
      day: day ?? this.day,
      status: status ?? this.status,
      drawnAtMillis: drawnAtMillis ?? this.drawnAtMillis,
      paidAtMillis: paidAtMillis ?? this.paidAtMillis,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<int>(day.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (drawnAtMillis.present) {
      map['drawn_at_millis'] = Variable<int>(drawnAtMillis.value);
    }
    if (paidAtMillis.present) {
      map['paid_at_millis'] = Variable<int>(paidAtMillis.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OwnBoxesCompanion(')
          ..write('day: $day, ')
          ..write('status: $status, ')
          ..write('drawnAtMillis: $drawnAtMillis, ')
          ..write('paidAtMillis: $paidAtMillis')
          ..write(')'))
        .toString();
  }
}

class $PartnerBoxesTable extends PartnerBoxes
    with TableInfo<$PartnerBoxesTable, PartnerBoxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PartnerBoxesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<int> day = GeneratedColumn<int>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [day, status];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'partner_boxes';
  @override
  VerificationContext validateIntegrity(
    Insertable<PartnerBoxRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day};
  @override
  PartnerBoxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PartnerBoxRow(
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $PartnerBoxesTable createAlias(String alias) {
    return $PartnerBoxesTable(attachedDatabase, alias);
  }
}

class PartnerBoxRow extends DataClass implements Insertable<PartnerBoxRow> {
  /// `1..365`.
  final int day;

  /// `0` free, `1` assigned, `2` paid.
  final int status;
  const PartnerBoxRow({required this.day, required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<int>(day);
    map['status'] = Variable<int>(status);
    return map;
  }

  PartnerBoxesCompanion toCompanion(bool nullToAbsent) {
    return PartnerBoxesCompanion(day: Value(day), status: Value(status));
  }

  factory PartnerBoxRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PartnerBoxRow(
      day: serializer.fromJson<int>(json['day']),
      status: serializer.fromJson<int>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<int>(day),
      'status': serializer.toJson<int>(status),
    };
  }

  PartnerBoxRow copyWith({int? day, int? status}) =>
      PartnerBoxRow(day: day ?? this.day, status: status ?? this.status);
  PartnerBoxRow copyWithCompanion(PartnerBoxesCompanion data) {
    return PartnerBoxRow(
      day: data.day.present ? data.day.value : this.day,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PartnerBoxRow(')
          ..write('day: $day, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(day, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PartnerBoxRow &&
          other.day == this.day &&
          other.status == this.status);
}

class PartnerBoxesCompanion extends UpdateCompanion<PartnerBoxRow> {
  final Value<int> day;
  final Value<int> status;
  const PartnerBoxesCompanion({
    this.day = const Value.absent(),
    this.status = const Value.absent(),
  });
  PartnerBoxesCompanion.insert({
    this.day = const Value.absent(),
    this.status = const Value.absent(),
  });
  static Insertable<PartnerBoxRow> custom({
    Expression<int>? day,
    Expression<int>? status,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (status != null) 'status': status,
    });
  }

  PartnerBoxesCompanion copyWith({Value<int>? day, Value<int>? status}) {
    return PartnerBoxesCompanion(
      day: day ?? this.day,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<int>(day.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PartnerBoxesCompanion(')
          ..write('day: $day, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $PartnerSnapshotsTable extends PartnerSnapshots
    with TableInfo<$PartnerSnapshotsTable, PartnerSnapshotRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PartnerSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _stateVersionMeta = const VerificationMeta(
    'stateVersion',
  );
  @override
  late final GeneratedColumn<int> stateVersion = GeneratedColumn<int>(
    'state_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _installIdMeta = const VerificationMeta(
    'installId',
  );
  @override
  late final GeneratedColumn<int> installId = GeneratedColumn<int>(
    'install_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startEpochDayMeta = const VerificationMeta(
    'startEpochDay',
  );
  @override
  late final GeneratedColumn<int> startEpochDay = GeneratedColumn<int>(
    'start_epoch_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receivedAtMillisMeta = const VerificationMeta(
    'receivedAtMillis',
  );
  @override
  late final GeneratedColumn<int> receivedAtMillis = GeneratedColumn<int>(
    'received_at_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    stateVersion,
    installId,
    startEpochDay,
    receivedAtMillis,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'partner_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<PartnerSnapshotRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('state_version')) {
      context.handle(
        _stateVersionMeta,
        stateVersion.isAcceptableOrUnknown(
          data['state_version']!,
          _stateVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stateVersionMeta);
    }
    if (data.containsKey('install_id')) {
      context.handle(
        _installIdMeta,
        installId.isAcceptableOrUnknown(data['install_id']!, _installIdMeta),
      );
    } else if (isInserting) {
      context.missing(_installIdMeta);
    }
    if (data.containsKey('start_epoch_day')) {
      context.handle(
        _startEpochDayMeta,
        startEpochDay.isAcceptableOrUnknown(
          data['start_epoch_day']!,
          _startEpochDayMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startEpochDayMeta);
    }
    if (data.containsKey('received_at_millis')) {
      context.handle(
        _receivedAtMillisMeta,
        receivedAtMillis.isAcceptableOrUnknown(
          data['received_at_millis']!,
          _receivedAtMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_receivedAtMillisMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PartnerSnapshotRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PartnerSnapshotRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      stateVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}state_version'],
      )!,
      installId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}install_id'],
      )!,
      startEpochDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_epoch_day'],
      )!,
      receivedAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}received_at_millis'],
      )!,
    );
  }

  @override
  $PartnerSnapshotsTable createAlias(String alias) {
    return $PartnerSnapshotsTable(attachedDatabase, alias);
  }
}

class PartnerSnapshotRow extends DataClass
    implements Insertable<PartnerSnapshotRow> {
  /// Always `1`.
  final int id;

  /// From the last accepted snapshot.
  final int stateVersion;

  /// The partner's install id, used to detect reinstalls.
  final int installId;

  /// The partner's own start date, from their payload.
  final int startEpochDay;

  /// Local clock at receive time. For display only, never for decisions.
  final int receivedAtMillis;
  const PartnerSnapshotRow({
    required this.id,
    required this.stateVersion,
    required this.installId,
    required this.startEpochDay,
    required this.receivedAtMillis,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['state_version'] = Variable<int>(stateVersion);
    map['install_id'] = Variable<int>(installId);
    map['start_epoch_day'] = Variable<int>(startEpochDay);
    map['received_at_millis'] = Variable<int>(receivedAtMillis);
    return map;
  }

  PartnerSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return PartnerSnapshotsCompanion(
      id: Value(id),
      stateVersion: Value(stateVersion),
      installId: Value(installId),
      startEpochDay: Value(startEpochDay),
      receivedAtMillis: Value(receivedAtMillis),
    );
  }

  factory PartnerSnapshotRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PartnerSnapshotRow(
      id: serializer.fromJson<int>(json['id']),
      stateVersion: serializer.fromJson<int>(json['stateVersion']),
      installId: serializer.fromJson<int>(json['installId']),
      startEpochDay: serializer.fromJson<int>(json['startEpochDay']),
      receivedAtMillis: serializer.fromJson<int>(json['receivedAtMillis']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'stateVersion': serializer.toJson<int>(stateVersion),
      'installId': serializer.toJson<int>(installId),
      'startEpochDay': serializer.toJson<int>(startEpochDay),
      'receivedAtMillis': serializer.toJson<int>(receivedAtMillis),
    };
  }

  PartnerSnapshotRow copyWith({
    int? id,
    int? stateVersion,
    int? installId,
    int? startEpochDay,
    int? receivedAtMillis,
  }) => PartnerSnapshotRow(
    id: id ?? this.id,
    stateVersion: stateVersion ?? this.stateVersion,
    installId: installId ?? this.installId,
    startEpochDay: startEpochDay ?? this.startEpochDay,
    receivedAtMillis: receivedAtMillis ?? this.receivedAtMillis,
  );
  PartnerSnapshotRow copyWithCompanion(PartnerSnapshotsCompanion data) {
    return PartnerSnapshotRow(
      id: data.id.present ? data.id.value : this.id,
      stateVersion: data.stateVersion.present
          ? data.stateVersion.value
          : this.stateVersion,
      installId: data.installId.present ? data.installId.value : this.installId,
      startEpochDay: data.startEpochDay.present
          ? data.startEpochDay.value
          : this.startEpochDay,
      receivedAtMillis: data.receivedAtMillis.present
          ? data.receivedAtMillis.value
          : this.receivedAtMillis,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PartnerSnapshotRow(')
          ..write('id: $id, ')
          ..write('stateVersion: $stateVersion, ')
          ..write('installId: $installId, ')
          ..write('startEpochDay: $startEpochDay, ')
          ..write('receivedAtMillis: $receivedAtMillis')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, stateVersion, installId, startEpochDay, receivedAtMillis);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PartnerSnapshotRow &&
          other.id == this.id &&
          other.stateVersion == this.stateVersion &&
          other.installId == this.installId &&
          other.startEpochDay == this.startEpochDay &&
          other.receivedAtMillis == this.receivedAtMillis);
}

class PartnerSnapshotsCompanion extends UpdateCompanion<PartnerSnapshotRow> {
  final Value<int> id;
  final Value<int> stateVersion;
  final Value<int> installId;
  final Value<int> startEpochDay;
  final Value<int> receivedAtMillis;
  const PartnerSnapshotsCompanion({
    this.id = const Value.absent(),
    this.stateVersion = const Value.absent(),
    this.installId = const Value.absent(),
    this.startEpochDay = const Value.absent(),
    this.receivedAtMillis = const Value.absent(),
  });
  PartnerSnapshotsCompanion.insert({
    this.id = const Value.absent(),
    required int stateVersion,
    required int installId,
    required int startEpochDay,
    required int receivedAtMillis,
  }) : stateVersion = Value(stateVersion),
       installId = Value(installId),
       startEpochDay = Value(startEpochDay),
       receivedAtMillis = Value(receivedAtMillis);
  static Insertable<PartnerSnapshotRow> custom({
    Expression<int>? id,
    Expression<int>? stateVersion,
    Expression<int>? installId,
    Expression<int>? startEpochDay,
    Expression<int>? receivedAtMillis,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (stateVersion != null) 'state_version': stateVersion,
      if (installId != null) 'install_id': installId,
      if (startEpochDay != null) 'start_epoch_day': startEpochDay,
      if (receivedAtMillis != null) 'received_at_millis': receivedAtMillis,
    });
  }

  PartnerSnapshotsCompanion copyWith({
    Value<int>? id,
    Value<int>? stateVersion,
    Value<int>? installId,
    Value<int>? startEpochDay,
    Value<int>? receivedAtMillis,
  }) {
    return PartnerSnapshotsCompanion(
      id: id ?? this.id,
      stateVersion: stateVersion ?? this.stateVersion,
      installId: installId ?? this.installId,
      startEpochDay: startEpochDay ?? this.startEpochDay,
      receivedAtMillis: receivedAtMillis ?? this.receivedAtMillis,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (stateVersion.present) {
      map['state_version'] = Variable<int>(stateVersion.value);
    }
    if (installId.present) {
      map['install_id'] = Variable<int>(installId.value);
    }
    if (startEpochDay.present) {
      map['start_epoch_day'] = Variable<int>(startEpochDay.value);
    }
    if (receivedAtMillis.present) {
      map['received_at_millis'] = Variable<int>(receivedAtMillis.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PartnerSnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('stateVersion: $stateVersion, ')
          ..write('installId: $installId, ')
          ..write('startEpochDay: $startEpochDay, ')
          ..write('receivedAtMillis: $receivedAtMillis')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ChallengeConfigRowsTable challengeConfigRows =
      $ChallengeConfigRowsTable(this);
  late final $OwnBoxesTable ownBoxes = $OwnBoxesTable(this);
  late final $PartnerBoxesTable partnerBoxes = $PartnerBoxesTable(this);
  late final $PartnerSnapshotsTable partnerSnapshots = $PartnerSnapshotsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    challengeConfigRows,
    ownBoxes,
    partnerBoxes,
    partnerSnapshots,
  ];
}

typedef $$ChallengeConfigRowsTableCreateCompanionBuilder =
    ChallengeConfigRowsCompanion Function({
      Value<int> id,
      required int pairingId,
      required int localSlot,
      required int localInstallId,
      required String localName,
      Value<String?> partnerName,
      Value<int?> partnerInstallId,
      required int startEpochDay,
      Value<int> stateVersion,
      required int createdAtMillis,
    });
typedef $$ChallengeConfigRowsTableUpdateCompanionBuilder =
    ChallengeConfigRowsCompanion Function({
      Value<int> id,
      Value<int> pairingId,
      Value<int> localSlot,
      Value<int> localInstallId,
      Value<String> localName,
      Value<String?> partnerName,
      Value<int?> partnerInstallId,
      Value<int> startEpochDay,
      Value<int> stateVersion,
      Value<int> createdAtMillis,
    });

class $$ChallengeConfigRowsTableFilterComposer
    extends Composer<_$AppDatabase, $ChallengeConfigRowsTable> {
  $$ChallengeConfigRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pairingId => $composableBuilder(
    column: $table.pairingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localSlot => $composableBuilder(
    column: $table.localSlot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localInstallId => $composableBuilder(
    column: $table.localInstallId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localName => $composableBuilder(
    column: $table.localName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partnerName => $composableBuilder(
    column: $table.partnerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get partnerInstallId => $composableBuilder(
    column: $table.partnerInstallId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startEpochDay => $composableBuilder(
    column: $table.startEpochDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stateVersion => $composableBuilder(
    column: $table.stateVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMillis => $composableBuilder(
    column: $table.createdAtMillis,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChallengeConfigRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChallengeConfigRowsTable> {
  $$ChallengeConfigRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pairingId => $composableBuilder(
    column: $table.pairingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localSlot => $composableBuilder(
    column: $table.localSlot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localInstallId => $composableBuilder(
    column: $table.localInstallId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localName => $composableBuilder(
    column: $table.localName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partnerName => $composableBuilder(
    column: $table.partnerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get partnerInstallId => $composableBuilder(
    column: $table.partnerInstallId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startEpochDay => $composableBuilder(
    column: $table.startEpochDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stateVersion => $composableBuilder(
    column: $table.stateVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMillis => $composableBuilder(
    column: $table.createdAtMillis,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChallengeConfigRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChallengeConfigRowsTable> {
  $$ChallengeConfigRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get pairingId =>
      $composableBuilder(column: $table.pairingId, builder: (column) => column);

  GeneratedColumn<int> get localSlot =>
      $composableBuilder(column: $table.localSlot, builder: (column) => column);

  GeneratedColumn<int> get localInstallId => $composableBuilder(
    column: $table.localInstallId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localName =>
      $composableBuilder(column: $table.localName, builder: (column) => column);

  GeneratedColumn<String> get partnerName => $composableBuilder(
    column: $table.partnerName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get partnerInstallId => $composableBuilder(
    column: $table.partnerInstallId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startEpochDay => $composableBuilder(
    column: $table.startEpochDay,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stateVersion => $composableBuilder(
    column: $table.stateVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtMillis => $composableBuilder(
    column: $table.createdAtMillis,
    builder: (column) => column,
  );
}

class $$ChallengeConfigRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChallengeConfigRowsTable,
          ChallengeConfigRow,
          $$ChallengeConfigRowsTableFilterComposer,
          $$ChallengeConfigRowsTableOrderingComposer,
          $$ChallengeConfigRowsTableAnnotationComposer,
          $$ChallengeConfigRowsTableCreateCompanionBuilder,
          $$ChallengeConfigRowsTableUpdateCompanionBuilder,
          (
            ChallengeConfigRow,
            BaseReferences<
              _$AppDatabase,
              $ChallengeConfigRowsTable,
              ChallengeConfigRow
            >,
          ),
          ChallengeConfigRow,
          PrefetchHooks Function()
        > {
  $$ChallengeConfigRowsTableTableManager(
    _$AppDatabase db,
    $ChallengeConfigRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChallengeConfigRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChallengeConfigRowsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ChallengeConfigRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> pairingId = const Value.absent(),
                Value<int> localSlot = const Value.absent(),
                Value<int> localInstallId = const Value.absent(),
                Value<String> localName = const Value.absent(),
                Value<String?> partnerName = const Value.absent(),
                Value<int?> partnerInstallId = const Value.absent(),
                Value<int> startEpochDay = const Value.absent(),
                Value<int> stateVersion = const Value.absent(),
                Value<int> createdAtMillis = const Value.absent(),
              }) => ChallengeConfigRowsCompanion(
                id: id,
                pairingId: pairingId,
                localSlot: localSlot,
                localInstallId: localInstallId,
                localName: localName,
                partnerName: partnerName,
                partnerInstallId: partnerInstallId,
                startEpochDay: startEpochDay,
                stateVersion: stateVersion,
                createdAtMillis: createdAtMillis,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int pairingId,
                required int localSlot,
                required int localInstallId,
                required String localName,
                Value<String?> partnerName = const Value.absent(),
                Value<int?> partnerInstallId = const Value.absent(),
                required int startEpochDay,
                Value<int> stateVersion = const Value.absent(),
                required int createdAtMillis,
              }) => ChallengeConfigRowsCompanion.insert(
                id: id,
                pairingId: pairingId,
                localSlot: localSlot,
                localInstallId: localInstallId,
                localName: localName,
                partnerName: partnerName,
                partnerInstallId: partnerInstallId,
                startEpochDay: startEpochDay,
                stateVersion: stateVersion,
                createdAtMillis: createdAtMillis,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChallengeConfigRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChallengeConfigRowsTable,
      ChallengeConfigRow,
      $$ChallengeConfigRowsTableFilterComposer,
      $$ChallengeConfigRowsTableOrderingComposer,
      $$ChallengeConfigRowsTableAnnotationComposer,
      $$ChallengeConfigRowsTableCreateCompanionBuilder,
      $$ChallengeConfigRowsTableUpdateCompanionBuilder,
      (
        ChallengeConfigRow,
        BaseReferences<
          _$AppDatabase,
          $ChallengeConfigRowsTable,
          ChallengeConfigRow
        >,
      ),
      ChallengeConfigRow,
      PrefetchHooks Function()
    >;
typedef $$OwnBoxesTableCreateCompanionBuilder =
    OwnBoxesCompanion Function({
      Value<int> day,
      Value<int> status,
      Value<int?> drawnAtMillis,
      Value<int?> paidAtMillis,
    });
typedef $$OwnBoxesTableUpdateCompanionBuilder =
    OwnBoxesCompanion Function({
      Value<int> day,
      Value<int> status,
      Value<int?> drawnAtMillis,
      Value<int?> paidAtMillis,
    });

class $$OwnBoxesTableFilterComposer
    extends Composer<_$AppDatabase, $OwnBoxesTable> {
  $$OwnBoxesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get drawnAtMillis => $composableBuilder(
    column: $table.drawnAtMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paidAtMillis => $composableBuilder(
    column: $table.paidAtMillis,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OwnBoxesTableOrderingComposer
    extends Composer<_$AppDatabase, $OwnBoxesTable> {
  $$OwnBoxesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get drawnAtMillis => $composableBuilder(
    column: $table.drawnAtMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paidAtMillis => $composableBuilder(
    column: $table.paidAtMillis,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OwnBoxesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OwnBoxesTable> {
  $$OwnBoxesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get drawnAtMillis => $composableBuilder(
    column: $table.drawnAtMillis,
    builder: (column) => column,
  );

  GeneratedColumn<int> get paidAtMillis => $composableBuilder(
    column: $table.paidAtMillis,
    builder: (column) => column,
  );
}

class $$OwnBoxesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OwnBoxesTable,
          OwnBoxRow,
          $$OwnBoxesTableFilterComposer,
          $$OwnBoxesTableOrderingComposer,
          $$OwnBoxesTableAnnotationComposer,
          $$OwnBoxesTableCreateCompanionBuilder,
          $$OwnBoxesTableUpdateCompanionBuilder,
          (OwnBoxRow, BaseReferences<_$AppDatabase, $OwnBoxesTable, OwnBoxRow>),
          OwnBoxRow,
          PrefetchHooks Function()
        > {
  $$OwnBoxesTableTableManager(_$AppDatabase db, $OwnBoxesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OwnBoxesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OwnBoxesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OwnBoxesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> day = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<int?> drawnAtMillis = const Value.absent(),
                Value<int?> paidAtMillis = const Value.absent(),
              }) => OwnBoxesCompanion(
                day: day,
                status: status,
                drawnAtMillis: drawnAtMillis,
                paidAtMillis: paidAtMillis,
              ),
          createCompanionCallback:
              ({
                Value<int> day = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<int?> drawnAtMillis = const Value.absent(),
                Value<int?> paidAtMillis = const Value.absent(),
              }) => OwnBoxesCompanion.insert(
                day: day,
                status: status,
                drawnAtMillis: drawnAtMillis,
                paidAtMillis: paidAtMillis,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OwnBoxesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OwnBoxesTable,
      OwnBoxRow,
      $$OwnBoxesTableFilterComposer,
      $$OwnBoxesTableOrderingComposer,
      $$OwnBoxesTableAnnotationComposer,
      $$OwnBoxesTableCreateCompanionBuilder,
      $$OwnBoxesTableUpdateCompanionBuilder,
      (OwnBoxRow, BaseReferences<_$AppDatabase, $OwnBoxesTable, OwnBoxRow>),
      OwnBoxRow,
      PrefetchHooks Function()
    >;
typedef $$PartnerBoxesTableCreateCompanionBuilder =
    PartnerBoxesCompanion Function({Value<int> day, Value<int> status});
typedef $$PartnerBoxesTableUpdateCompanionBuilder =
    PartnerBoxesCompanion Function({Value<int> day, Value<int> status});

class $$PartnerBoxesTableFilterComposer
    extends Composer<_$AppDatabase, $PartnerBoxesTable> {
  $$PartnerBoxesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PartnerBoxesTableOrderingComposer
    extends Composer<_$AppDatabase, $PartnerBoxesTable> {
  $$PartnerBoxesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PartnerBoxesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PartnerBoxesTable> {
  $$PartnerBoxesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$PartnerBoxesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PartnerBoxesTable,
          PartnerBoxRow,
          $$PartnerBoxesTableFilterComposer,
          $$PartnerBoxesTableOrderingComposer,
          $$PartnerBoxesTableAnnotationComposer,
          $$PartnerBoxesTableCreateCompanionBuilder,
          $$PartnerBoxesTableUpdateCompanionBuilder,
          (
            PartnerBoxRow,
            BaseReferences<_$AppDatabase, $PartnerBoxesTable, PartnerBoxRow>,
          ),
          PartnerBoxRow,
          PrefetchHooks Function()
        > {
  $$PartnerBoxesTableTableManager(_$AppDatabase db, $PartnerBoxesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PartnerBoxesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PartnerBoxesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PartnerBoxesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> day = const Value.absent(),
                Value<int> status = const Value.absent(),
              }) => PartnerBoxesCompanion(day: day, status: status),
          createCompanionCallback:
              ({
                Value<int> day = const Value.absent(),
                Value<int> status = const Value.absent(),
              }) => PartnerBoxesCompanion.insert(day: day, status: status),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PartnerBoxesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PartnerBoxesTable,
      PartnerBoxRow,
      $$PartnerBoxesTableFilterComposer,
      $$PartnerBoxesTableOrderingComposer,
      $$PartnerBoxesTableAnnotationComposer,
      $$PartnerBoxesTableCreateCompanionBuilder,
      $$PartnerBoxesTableUpdateCompanionBuilder,
      (
        PartnerBoxRow,
        BaseReferences<_$AppDatabase, $PartnerBoxesTable, PartnerBoxRow>,
      ),
      PartnerBoxRow,
      PrefetchHooks Function()
    >;
typedef $$PartnerSnapshotsTableCreateCompanionBuilder =
    PartnerSnapshotsCompanion Function({
      Value<int> id,
      required int stateVersion,
      required int installId,
      required int startEpochDay,
      required int receivedAtMillis,
    });
typedef $$PartnerSnapshotsTableUpdateCompanionBuilder =
    PartnerSnapshotsCompanion Function({
      Value<int> id,
      Value<int> stateVersion,
      Value<int> installId,
      Value<int> startEpochDay,
      Value<int> receivedAtMillis,
    });

class $$PartnerSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $PartnerSnapshotsTable> {
  $$PartnerSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stateVersion => $composableBuilder(
    column: $table.stateVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get installId => $composableBuilder(
    column: $table.installId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startEpochDay => $composableBuilder(
    column: $table.startEpochDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get receivedAtMillis => $composableBuilder(
    column: $table.receivedAtMillis,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PartnerSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $PartnerSnapshotsTable> {
  $$PartnerSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stateVersion => $composableBuilder(
    column: $table.stateVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get installId => $composableBuilder(
    column: $table.installId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startEpochDay => $composableBuilder(
    column: $table.startEpochDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get receivedAtMillis => $composableBuilder(
    column: $table.receivedAtMillis,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PartnerSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PartnerSnapshotsTable> {
  $$PartnerSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get stateVersion => $composableBuilder(
    column: $table.stateVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get installId =>
      $composableBuilder(column: $table.installId, builder: (column) => column);

  GeneratedColumn<int> get startEpochDay => $composableBuilder(
    column: $table.startEpochDay,
    builder: (column) => column,
  );

  GeneratedColumn<int> get receivedAtMillis => $composableBuilder(
    column: $table.receivedAtMillis,
    builder: (column) => column,
  );
}

class $$PartnerSnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PartnerSnapshotsTable,
          PartnerSnapshotRow,
          $$PartnerSnapshotsTableFilterComposer,
          $$PartnerSnapshotsTableOrderingComposer,
          $$PartnerSnapshotsTableAnnotationComposer,
          $$PartnerSnapshotsTableCreateCompanionBuilder,
          $$PartnerSnapshotsTableUpdateCompanionBuilder,
          (
            PartnerSnapshotRow,
            BaseReferences<
              _$AppDatabase,
              $PartnerSnapshotsTable,
              PartnerSnapshotRow
            >,
          ),
          PartnerSnapshotRow,
          PrefetchHooks Function()
        > {
  $$PartnerSnapshotsTableTableManager(
    _$AppDatabase db,
    $PartnerSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PartnerSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PartnerSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PartnerSnapshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> stateVersion = const Value.absent(),
                Value<int> installId = const Value.absent(),
                Value<int> startEpochDay = const Value.absent(),
                Value<int> receivedAtMillis = const Value.absent(),
              }) => PartnerSnapshotsCompanion(
                id: id,
                stateVersion: stateVersion,
                installId: installId,
                startEpochDay: startEpochDay,
                receivedAtMillis: receivedAtMillis,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int stateVersion,
                required int installId,
                required int startEpochDay,
                required int receivedAtMillis,
              }) => PartnerSnapshotsCompanion.insert(
                id: id,
                stateVersion: stateVersion,
                installId: installId,
                startEpochDay: startEpochDay,
                receivedAtMillis: receivedAtMillis,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PartnerSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PartnerSnapshotsTable,
      PartnerSnapshotRow,
      $$PartnerSnapshotsTableFilterComposer,
      $$PartnerSnapshotsTableOrderingComposer,
      $$PartnerSnapshotsTableAnnotationComposer,
      $$PartnerSnapshotsTableCreateCompanionBuilder,
      $$PartnerSnapshotsTableUpdateCompanionBuilder,
      (
        PartnerSnapshotRow,
        BaseReferences<
          _$AppDatabase,
          $PartnerSnapshotsTable,
          PartnerSnapshotRow
        >,
      ),
      PartnerSnapshotRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ChallengeConfigRowsTableTableManager get challengeConfigRows =>
      $$ChallengeConfigRowsTableTableManager(_db, _db.challengeConfigRows);
  $$OwnBoxesTableTableManager get ownBoxes =>
      $$OwnBoxesTableTableManager(_db, _db.ownBoxes);
  $$PartnerBoxesTableTableManager get partnerBoxes =>
      $$PartnerBoxesTableTableManager(_db, _db.partnerBoxes);
  $$PartnerSnapshotsTableTableManager get partnerSnapshots =>
      $$PartnerSnapshotsTableTableManager(_db, _db.partnerSnapshots);
}
