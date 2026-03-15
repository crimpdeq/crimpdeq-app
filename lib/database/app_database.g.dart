// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _protocolTypeMeta = const VerificationMeta(
    'protocolType',
  );
  @override
  late final GeneratedColumn<int> protocolType = GeneratedColumn<int>(
    'protocol_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _protocolConfigJsonMeta =
      const VerificationMeta('protocolConfigJson');
  @override
  late final GeneratedColumn<String> protocolConfigJson =
      GeneratedColumn<String>(
        'protocol_config_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _peakForceKgMeta = const VerificationMeta(
    'peakForceKg',
  );
  @override
  late final GeneratedColumn<double> peakForceKg = GeneratedColumn<double>(
    'peak_force_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _avgPeakForceKgMeta = const VerificationMeta(
    'avgPeakForceKg',
  );
  @override
  late final GeneratedColumn<double> avgPeakForceKg = GeneratedColumn<double>(
    'avg_peak_force_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    protocolType,
    protocolConfigJson,
    startedAt,
    endedAt,
    peakForceKg,
    avgPeakForceKg,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Session> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('protocol_type')) {
      context.handle(
        _protocolTypeMeta,
        protocolType.isAcceptableOrUnknown(
          data['protocol_type']!,
          _protocolTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_protocolTypeMeta);
    }
    if (data.containsKey('protocol_config_json')) {
      context.handle(
        _protocolConfigJsonMeta,
        protocolConfigJson.isAcceptableOrUnknown(
          data['protocol_config_json']!,
          _protocolConfigJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_protocolConfigJsonMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('peak_force_kg')) {
      context.handle(
        _peakForceKgMeta,
        peakForceKg.isAcceptableOrUnknown(
          data['peak_force_kg']!,
          _peakForceKgMeta,
        ),
      );
    }
    if (data.containsKey('avg_peak_force_kg')) {
      context.handle(
        _avgPeakForceKgMeta,
        avgPeakForceKg.isAcceptableOrUnknown(
          data['avg_peak_force_kg']!,
          _avgPeakForceKgMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      protocolType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}protocol_type'],
      )!,
      protocolConfigJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}protocol_config_json'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      peakForceKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}peak_force_kg'],
      )!,
      avgPeakForceKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}avg_peak_force_kg'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final String id;
  final int protocolType;
  final String protocolConfigJson;
  final DateTime startedAt;
  final DateTime? endedAt;
  final double peakForceKg;
  final double avgPeakForceKg;
  final String notes;
  const Session({
    required this.id,
    required this.protocolType,
    required this.protocolConfigJson,
    required this.startedAt,
    this.endedAt,
    required this.peakForceKg,
    required this.avgPeakForceKg,
    required this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['protocol_type'] = Variable<int>(protocolType);
    map['protocol_config_json'] = Variable<String>(protocolConfigJson);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['peak_force_kg'] = Variable<double>(peakForceKg);
    map['avg_peak_force_kg'] = Variable<double>(avgPeakForceKg);
    map['notes'] = Variable<String>(notes);
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      protocolType: Value(protocolType),
      protocolConfigJson: Value(protocolConfigJson),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      peakForceKg: Value(peakForceKg),
      avgPeakForceKg: Value(avgPeakForceKg),
      notes: Value(notes),
    );
  }

  factory Session.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<String>(json['id']),
      protocolType: serializer.fromJson<int>(json['protocolType']),
      protocolConfigJson: serializer.fromJson<String>(
        json['protocolConfigJson'],
      ),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      peakForceKg: serializer.fromJson<double>(json['peakForceKg']),
      avgPeakForceKg: serializer.fromJson<double>(json['avgPeakForceKg']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'protocolType': serializer.toJson<int>(protocolType),
      'protocolConfigJson': serializer.toJson<String>(protocolConfigJson),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'peakForceKg': serializer.toJson<double>(peakForceKg),
      'avgPeakForceKg': serializer.toJson<double>(avgPeakForceKg),
      'notes': serializer.toJson<String>(notes),
    };
  }

  Session copyWith({
    String? id,
    int? protocolType,
    String? protocolConfigJson,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    double? peakForceKg,
    double? avgPeakForceKg,
    String? notes,
  }) => Session(
    id: id ?? this.id,
    protocolType: protocolType ?? this.protocolType,
    protocolConfigJson: protocolConfigJson ?? this.protocolConfigJson,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    peakForceKg: peakForceKg ?? this.peakForceKg,
    avgPeakForceKg: avgPeakForceKg ?? this.avgPeakForceKg,
    notes: notes ?? this.notes,
  );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      protocolType: data.protocolType.present
          ? data.protocolType.value
          : this.protocolType,
      protocolConfigJson: data.protocolConfigJson.present
          ? data.protocolConfigJson.value
          : this.protocolConfigJson,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      peakForceKg: data.peakForceKg.present
          ? data.peakForceKg.value
          : this.peakForceKg,
      avgPeakForceKg: data.avgPeakForceKg.present
          ? data.avgPeakForceKg.value
          : this.avgPeakForceKg,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('protocolType: $protocolType, ')
          ..write('protocolConfigJson: $protocolConfigJson, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('peakForceKg: $peakForceKg, ')
          ..write('avgPeakForceKg: $avgPeakForceKg, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    protocolType,
    protocolConfigJson,
    startedAt,
    endedAt,
    peakForceKg,
    avgPeakForceKg,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.protocolType == this.protocolType &&
          other.protocolConfigJson == this.protocolConfigJson &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.peakForceKg == this.peakForceKg &&
          other.avgPeakForceKg == this.avgPeakForceKg &&
          other.notes == this.notes);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<String> id;
  final Value<int> protocolType;
  final Value<String> protocolConfigJson;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<double> peakForceKg;
  final Value<double> avgPeakForceKg;
  final Value<String> notes;
  final Value<int> rowid;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.protocolType = const Value.absent(),
    this.protocolConfigJson = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.peakForceKg = const Value.absent(),
    this.avgPeakForceKg = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionsCompanion.insert({
    required String id,
    required int protocolType,
    required String protocolConfigJson,
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.peakForceKg = const Value.absent(),
    this.avgPeakForceKg = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       protocolType = Value(protocolType),
       protocolConfigJson = Value(protocolConfigJson),
       startedAt = Value(startedAt);
  static Insertable<Session> custom({
    Expression<String>? id,
    Expression<int>? protocolType,
    Expression<String>? protocolConfigJson,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<double>? peakForceKg,
    Expression<double>? avgPeakForceKg,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (protocolType != null) 'protocol_type': protocolType,
      if (protocolConfigJson != null)
        'protocol_config_json': protocolConfigJson,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (peakForceKg != null) 'peak_force_kg': peakForceKg,
      if (avgPeakForceKg != null) 'avg_peak_force_kg': avgPeakForceKg,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionsCompanion copyWith({
    Value<String>? id,
    Value<int>? protocolType,
    Value<String>? protocolConfigJson,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<double>? peakForceKg,
    Value<double>? avgPeakForceKg,
    Value<String>? notes,
    Value<int>? rowid,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      protocolType: protocolType ?? this.protocolType,
      protocolConfigJson: protocolConfigJson ?? this.protocolConfigJson,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      peakForceKg: peakForceKg ?? this.peakForceKg,
      avgPeakForceKg: avgPeakForceKg ?? this.avgPeakForceKg,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (protocolType.present) {
      map['protocol_type'] = Variable<int>(protocolType.value);
    }
    if (protocolConfigJson.present) {
      map['protocol_config_json'] = Variable<String>(protocolConfigJson.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (peakForceKg.present) {
      map['peak_force_kg'] = Variable<double>(peakForceKg.value);
    }
    if (avgPeakForceKg.present) {
      map['avg_peak_force_kg'] = Variable<double>(avgPeakForceKg.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('protocolType: $protocolType, ')
          ..write('protocolConfigJson: $protocolConfigJson, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('peakForceKg: $peakForceKg, ')
          ..write('avgPeakForceKg: $avgPeakForceKg, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrainingSetsTable extends TrainingSets
    with TableInfo<$TrainingSetsTable, TrainingSet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrainingSetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id)',
    ),
  );
  static const VerificationMeta _setIndexMeta = const VerificationMeta(
    'setIndex',
  );
  @override
  late final GeneratedColumn<int> setIndex = GeneratedColumn<int>(
    'set_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _restDurationMsMeta = const VerificationMeta(
    'restDurationMs',
  );
  @override
  late final GeneratedColumn<int> restDurationMs = GeneratedColumn<int>(
    'rest_duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    setIndex,
    restDurationMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'training_sets';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrainingSet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('set_index')) {
      context.handle(
        _setIndexMeta,
        setIndex.isAcceptableOrUnknown(data['set_index']!, _setIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_setIndexMeta);
    }
    if (data.containsKey('rest_duration_ms')) {
      context.handle(
        _restDurationMsMeta,
        restDurationMs.isAcceptableOrUnknown(
          data['rest_duration_ms']!,
          _restDurationMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrainingSet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrainingSet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      setIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}set_index'],
      )!,
      restDurationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_duration_ms'],
      )!,
    );
  }

  @override
  $TrainingSetsTable createAlias(String alias) {
    return $TrainingSetsTable(attachedDatabase, alias);
  }
}

class TrainingSet extends DataClass implements Insertable<TrainingSet> {
  final int id;
  final String sessionId;
  final int setIndex;
  final int restDurationMs;
  const TrainingSet({
    required this.id,
    required this.sessionId,
    required this.setIndex,
    required this.restDurationMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['set_index'] = Variable<int>(setIndex);
    map['rest_duration_ms'] = Variable<int>(restDurationMs);
    return map;
  }

  TrainingSetsCompanion toCompanion(bool nullToAbsent) {
    return TrainingSetsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      setIndex: Value(setIndex),
      restDurationMs: Value(restDurationMs),
    );
  }

  factory TrainingSet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrainingSet(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      setIndex: serializer.fromJson<int>(json['setIndex']),
      restDurationMs: serializer.fromJson<int>(json['restDurationMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'setIndex': serializer.toJson<int>(setIndex),
      'restDurationMs': serializer.toJson<int>(restDurationMs),
    };
  }

  TrainingSet copyWith({
    int? id,
    String? sessionId,
    int? setIndex,
    int? restDurationMs,
  }) => TrainingSet(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    setIndex: setIndex ?? this.setIndex,
    restDurationMs: restDurationMs ?? this.restDurationMs,
  );
  TrainingSet copyWithCompanion(TrainingSetsCompanion data) {
    return TrainingSet(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      setIndex: data.setIndex.present ? data.setIndex.value : this.setIndex,
      restDurationMs: data.restDurationMs.present
          ? data.restDurationMs.value
          : this.restDurationMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrainingSet(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('setIndex: $setIndex, ')
          ..write('restDurationMs: $restDurationMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sessionId, setIndex, restDurationMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrainingSet &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.setIndex == this.setIndex &&
          other.restDurationMs == this.restDurationMs);
}

class TrainingSetsCompanion extends UpdateCompanion<TrainingSet> {
  final Value<int> id;
  final Value<String> sessionId;
  final Value<int> setIndex;
  final Value<int> restDurationMs;
  const TrainingSetsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.setIndex = const Value.absent(),
    this.restDurationMs = const Value.absent(),
  });
  TrainingSetsCompanion.insert({
    this.id = const Value.absent(),
    required String sessionId,
    required int setIndex,
    this.restDurationMs = const Value.absent(),
  }) : sessionId = Value(sessionId),
       setIndex = Value(setIndex);
  static Insertable<TrainingSet> custom({
    Expression<int>? id,
    Expression<String>? sessionId,
    Expression<int>? setIndex,
    Expression<int>? restDurationMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (setIndex != null) 'set_index': setIndex,
      if (restDurationMs != null) 'rest_duration_ms': restDurationMs,
    });
  }

  TrainingSetsCompanion copyWith({
    Value<int>? id,
    Value<String>? sessionId,
    Value<int>? setIndex,
    Value<int>? restDurationMs,
  }) {
    return TrainingSetsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      setIndex: setIndex ?? this.setIndex,
      restDurationMs: restDurationMs ?? this.restDurationMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (setIndex.present) {
      map['set_index'] = Variable<int>(setIndex.value);
    }
    if (restDurationMs.present) {
      map['rest_duration_ms'] = Variable<int>(restDurationMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrainingSetsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('setIndex: $setIndex, ')
          ..write('restDurationMs: $restDurationMs')
          ..write(')'))
        .toString();
  }
}

class $RepsTable extends Reps with TableInfo<$RepsTable, Rep> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RepsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _trainingSetIdMeta = const VerificationMeta(
    'trainingSetId',
  );
  @override
  late final GeneratedColumn<int> trainingSetId = GeneratedColumn<int>(
    'training_set_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES training_sets (id)',
    ),
  );
  static const VerificationMeta _repIndexMeta = const VerificationMeta(
    'repIndex',
  );
  @override
  late final GeneratedColumn<int> repIndex = GeneratedColumn<int>(
    'rep_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _peakForceKgMeta = const VerificationMeta(
    'peakForceKg',
  );
  @override
  late final GeneratedColumn<double> peakForceKg = GeneratedColumn<double>(
    'peak_force_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avgForceKgMeta = const VerificationMeta(
    'avgForceKg',
  );
  @override
  late final GeneratedColumn<double> avgForceKg = GeneratedColumn<double>(
    'avg_force_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimestampMsMeta = const VerificationMeta(
    'startTimestampMs',
  );
  @override
  late final GeneratedColumn<int> startTimestampMs = GeneratedColumn<int>(
    'start_timestamp_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightSamplesJsonMeta = const VerificationMeta(
    'weightSamplesJson',
  );
  @override
  late final GeneratedColumn<String> weightSamplesJson =
      GeneratedColumn<String>(
        'weight_samples_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    trainingSetId,
    repIndex,
    peakForceKg,
    avgForceKg,
    durationMs,
    startTimestampMs,
    weightSamplesJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reps';
  @override
  VerificationContext validateIntegrity(
    Insertable<Rep> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('training_set_id')) {
      context.handle(
        _trainingSetIdMeta,
        trainingSetId.isAcceptableOrUnknown(
          data['training_set_id']!,
          _trainingSetIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_trainingSetIdMeta);
    }
    if (data.containsKey('rep_index')) {
      context.handle(
        _repIndexMeta,
        repIndex.isAcceptableOrUnknown(data['rep_index']!, _repIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_repIndexMeta);
    }
    if (data.containsKey('peak_force_kg')) {
      context.handle(
        _peakForceKgMeta,
        peakForceKg.isAcceptableOrUnknown(
          data['peak_force_kg']!,
          _peakForceKgMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_peakForceKgMeta);
    }
    if (data.containsKey('avg_force_kg')) {
      context.handle(
        _avgForceKgMeta,
        avgForceKg.isAcceptableOrUnknown(
          data['avg_force_kg']!,
          _avgForceKgMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_avgForceKgMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('start_timestamp_ms')) {
      context.handle(
        _startTimestampMsMeta,
        startTimestampMs.isAcceptableOrUnknown(
          data['start_timestamp_ms']!,
          _startTimestampMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startTimestampMsMeta);
    }
    if (data.containsKey('weight_samples_json')) {
      context.handle(
        _weightSamplesJsonMeta,
        weightSamplesJson.isAcceptableOrUnknown(
          data['weight_samples_json']!,
          _weightSamplesJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Rep map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Rep(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      trainingSetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}training_set_id'],
      )!,
      repIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rep_index'],
      )!,
      peakForceKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}peak_force_kg'],
      )!,
      avgForceKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}avg_force_kg'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      startTimestampMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_timestamp_ms'],
      )!,
      weightSamplesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weight_samples_json'],
      )!,
    );
  }

  @override
  $RepsTable createAlias(String alias) {
    return $RepsTable(attachedDatabase, alias);
  }
}

class Rep extends DataClass implements Insertable<Rep> {
  final int id;
  final int trainingSetId;
  final int repIndex;
  final double peakForceKg;
  final double avgForceKg;
  final int durationMs;
  final int startTimestampMs;
  final String weightSamplesJson;
  const Rep({
    required this.id,
    required this.trainingSetId,
    required this.repIndex,
    required this.peakForceKg,
    required this.avgForceKg,
    required this.durationMs,
    required this.startTimestampMs,
    required this.weightSamplesJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['training_set_id'] = Variable<int>(trainingSetId);
    map['rep_index'] = Variable<int>(repIndex);
    map['peak_force_kg'] = Variable<double>(peakForceKg);
    map['avg_force_kg'] = Variable<double>(avgForceKg);
    map['duration_ms'] = Variable<int>(durationMs);
    map['start_timestamp_ms'] = Variable<int>(startTimestampMs);
    map['weight_samples_json'] = Variable<String>(weightSamplesJson);
    return map;
  }

  RepsCompanion toCompanion(bool nullToAbsent) {
    return RepsCompanion(
      id: Value(id),
      trainingSetId: Value(trainingSetId),
      repIndex: Value(repIndex),
      peakForceKg: Value(peakForceKg),
      avgForceKg: Value(avgForceKg),
      durationMs: Value(durationMs),
      startTimestampMs: Value(startTimestampMs),
      weightSamplesJson: Value(weightSamplesJson),
    );
  }

  factory Rep.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Rep(
      id: serializer.fromJson<int>(json['id']),
      trainingSetId: serializer.fromJson<int>(json['trainingSetId']),
      repIndex: serializer.fromJson<int>(json['repIndex']),
      peakForceKg: serializer.fromJson<double>(json['peakForceKg']),
      avgForceKg: serializer.fromJson<double>(json['avgForceKg']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      startTimestampMs: serializer.fromJson<int>(json['startTimestampMs']),
      weightSamplesJson: serializer.fromJson<String>(json['weightSamplesJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'trainingSetId': serializer.toJson<int>(trainingSetId),
      'repIndex': serializer.toJson<int>(repIndex),
      'peakForceKg': serializer.toJson<double>(peakForceKg),
      'avgForceKg': serializer.toJson<double>(avgForceKg),
      'durationMs': serializer.toJson<int>(durationMs),
      'startTimestampMs': serializer.toJson<int>(startTimestampMs),
      'weightSamplesJson': serializer.toJson<String>(weightSamplesJson),
    };
  }

  Rep copyWith({
    int? id,
    int? trainingSetId,
    int? repIndex,
    double? peakForceKg,
    double? avgForceKg,
    int? durationMs,
    int? startTimestampMs,
    String? weightSamplesJson,
  }) => Rep(
    id: id ?? this.id,
    trainingSetId: trainingSetId ?? this.trainingSetId,
    repIndex: repIndex ?? this.repIndex,
    peakForceKg: peakForceKg ?? this.peakForceKg,
    avgForceKg: avgForceKg ?? this.avgForceKg,
    durationMs: durationMs ?? this.durationMs,
    startTimestampMs: startTimestampMs ?? this.startTimestampMs,
    weightSamplesJson: weightSamplesJson ?? this.weightSamplesJson,
  );
  Rep copyWithCompanion(RepsCompanion data) {
    return Rep(
      id: data.id.present ? data.id.value : this.id,
      trainingSetId: data.trainingSetId.present
          ? data.trainingSetId.value
          : this.trainingSetId,
      repIndex: data.repIndex.present ? data.repIndex.value : this.repIndex,
      peakForceKg: data.peakForceKg.present
          ? data.peakForceKg.value
          : this.peakForceKg,
      avgForceKg: data.avgForceKg.present
          ? data.avgForceKg.value
          : this.avgForceKg,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      startTimestampMs: data.startTimestampMs.present
          ? data.startTimestampMs.value
          : this.startTimestampMs,
      weightSamplesJson: data.weightSamplesJson.present
          ? data.weightSamplesJson.value
          : this.weightSamplesJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Rep(')
          ..write('id: $id, ')
          ..write('trainingSetId: $trainingSetId, ')
          ..write('repIndex: $repIndex, ')
          ..write('peakForceKg: $peakForceKg, ')
          ..write('avgForceKg: $avgForceKg, ')
          ..write('durationMs: $durationMs, ')
          ..write('startTimestampMs: $startTimestampMs, ')
          ..write('weightSamplesJson: $weightSamplesJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    trainingSetId,
    repIndex,
    peakForceKg,
    avgForceKg,
    durationMs,
    startTimestampMs,
    weightSamplesJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Rep &&
          other.id == this.id &&
          other.trainingSetId == this.trainingSetId &&
          other.repIndex == this.repIndex &&
          other.peakForceKg == this.peakForceKg &&
          other.avgForceKg == this.avgForceKg &&
          other.durationMs == this.durationMs &&
          other.startTimestampMs == this.startTimestampMs &&
          other.weightSamplesJson == this.weightSamplesJson);
}

class RepsCompanion extends UpdateCompanion<Rep> {
  final Value<int> id;
  final Value<int> trainingSetId;
  final Value<int> repIndex;
  final Value<double> peakForceKg;
  final Value<double> avgForceKg;
  final Value<int> durationMs;
  final Value<int> startTimestampMs;
  final Value<String> weightSamplesJson;
  const RepsCompanion({
    this.id = const Value.absent(),
    this.trainingSetId = const Value.absent(),
    this.repIndex = const Value.absent(),
    this.peakForceKg = const Value.absent(),
    this.avgForceKg = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.startTimestampMs = const Value.absent(),
    this.weightSamplesJson = const Value.absent(),
  });
  RepsCompanion.insert({
    this.id = const Value.absent(),
    required int trainingSetId,
    required int repIndex,
    required double peakForceKg,
    required double avgForceKg,
    required int durationMs,
    required int startTimestampMs,
    this.weightSamplesJson = const Value.absent(),
  }) : trainingSetId = Value(trainingSetId),
       repIndex = Value(repIndex),
       peakForceKg = Value(peakForceKg),
       avgForceKg = Value(avgForceKg),
       durationMs = Value(durationMs),
       startTimestampMs = Value(startTimestampMs);
  static Insertable<Rep> custom({
    Expression<int>? id,
    Expression<int>? trainingSetId,
    Expression<int>? repIndex,
    Expression<double>? peakForceKg,
    Expression<double>? avgForceKg,
    Expression<int>? durationMs,
    Expression<int>? startTimestampMs,
    Expression<String>? weightSamplesJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (trainingSetId != null) 'training_set_id': trainingSetId,
      if (repIndex != null) 'rep_index': repIndex,
      if (peakForceKg != null) 'peak_force_kg': peakForceKg,
      if (avgForceKg != null) 'avg_force_kg': avgForceKg,
      if (durationMs != null) 'duration_ms': durationMs,
      if (startTimestampMs != null) 'start_timestamp_ms': startTimestampMs,
      if (weightSamplesJson != null) 'weight_samples_json': weightSamplesJson,
    });
  }

  RepsCompanion copyWith({
    Value<int>? id,
    Value<int>? trainingSetId,
    Value<int>? repIndex,
    Value<double>? peakForceKg,
    Value<double>? avgForceKg,
    Value<int>? durationMs,
    Value<int>? startTimestampMs,
    Value<String>? weightSamplesJson,
  }) {
    return RepsCompanion(
      id: id ?? this.id,
      trainingSetId: trainingSetId ?? this.trainingSetId,
      repIndex: repIndex ?? this.repIndex,
      peakForceKg: peakForceKg ?? this.peakForceKg,
      avgForceKg: avgForceKg ?? this.avgForceKg,
      durationMs: durationMs ?? this.durationMs,
      startTimestampMs: startTimestampMs ?? this.startTimestampMs,
      weightSamplesJson: weightSamplesJson ?? this.weightSamplesJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (trainingSetId.present) {
      map['training_set_id'] = Variable<int>(trainingSetId.value);
    }
    if (repIndex.present) {
      map['rep_index'] = Variable<int>(repIndex.value);
    }
    if (peakForceKg.present) {
      map['peak_force_kg'] = Variable<double>(peakForceKg.value);
    }
    if (avgForceKg.present) {
      map['avg_force_kg'] = Variable<double>(avgForceKg.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (startTimestampMs.present) {
      map['start_timestamp_ms'] = Variable<int>(startTimestampMs.value);
    }
    if (weightSamplesJson.present) {
      map['weight_samples_json'] = Variable<String>(weightSamplesJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RepsCompanion(')
          ..write('id: $id, ')
          ..write('trainingSetId: $trainingSetId, ')
          ..write('repIndex: $repIndex, ')
          ..write('peakForceKg: $peakForceKg, ')
          ..write('avgForceKg: $avgForceKg, ')
          ..write('durationMs: $durationMs, ')
          ..write('startTimestampMs: $startTimestampMs, ')
          ..write('weightSamplesJson: $weightSamplesJson')
          ..write(')'))
        .toString();
  }
}

class $PersonalRecordsTable extends PersonalRecords
    with TableInfo<$PersonalRecordsTable, PersonalRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonalRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _protocolTypeMeta = const VerificationMeta(
    'protocolType',
  );
  @override
  late final GeneratedColumn<int> protocolType = GeneratedColumn<int>(
    'protocol_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _peakForceKgMeta = const VerificationMeta(
    'peakForceKg',
  );
  @override
  late final GeneratedColumn<double> peakForceKg = GeneratedColumn<double>(
    'peak_force_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id)',
    ),
  );
  static const VerificationMeta _achievedAtMeta = const VerificationMeta(
    'achievedAt',
  );
  @override
  late final GeneratedColumn<DateTime> achievedAt = GeneratedColumn<DateTime>(
    'achieved_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    protocolType,
    peakForceKg,
    sessionId,
    achievedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'personal_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersonalRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('protocol_type')) {
      context.handle(
        _protocolTypeMeta,
        protocolType.isAcceptableOrUnknown(
          data['protocol_type']!,
          _protocolTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_protocolTypeMeta);
    }
    if (data.containsKey('peak_force_kg')) {
      context.handle(
        _peakForceKgMeta,
        peakForceKg.isAcceptableOrUnknown(
          data['peak_force_kg']!,
          _peakForceKgMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_peakForceKgMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('achieved_at')) {
      context.handle(
        _achievedAtMeta,
        achievedAt.isAcceptableOrUnknown(data['achieved_at']!, _achievedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_achievedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PersonalRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonalRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      protocolType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}protocol_type'],
      )!,
      peakForceKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}peak_force_kg'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      achievedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}achieved_at'],
      )!,
    );
  }

  @override
  $PersonalRecordsTable createAlias(String alias) {
    return $PersonalRecordsTable(attachedDatabase, alias);
  }
}

class PersonalRecord extends DataClass implements Insertable<PersonalRecord> {
  final int id;
  final int protocolType;
  final double peakForceKg;
  final String sessionId;
  final DateTime achievedAt;
  const PersonalRecord({
    required this.id,
    required this.protocolType,
    required this.peakForceKg,
    required this.sessionId,
    required this.achievedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['protocol_type'] = Variable<int>(protocolType);
    map['peak_force_kg'] = Variable<double>(peakForceKg);
    map['session_id'] = Variable<String>(sessionId);
    map['achieved_at'] = Variable<DateTime>(achievedAt);
    return map;
  }

  PersonalRecordsCompanion toCompanion(bool nullToAbsent) {
    return PersonalRecordsCompanion(
      id: Value(id),
      protocolType: Value(protocolType),
      peakForceKg: Value(peakForceKg),
      sessionId: Value(sessionId),
      achievedAt: Value(achievedAt),
    );
  }

  factory PersonalRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonalRecord(
      id: serializer.fromJson<int>(json['id']),
      protocolType: serializer.fromJson<int>(json['protocolType']),
      peakForceKg: serializer.fromJson<double>(json['peakForceKg']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      achievedAt: serializer.fromJson<DateTime>(json['achievedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'protocolType': serializer.toJson<int>(protocolType),
      'peakForceKg': serializer.toJson<double>(peakForceKg),
      'sessionId': serializer.toJson<String>(sessionId),
      'achievedAt': serializer.toJson<DateTime>(achievedAt),
    };
  }

  PersonalRecord copyWith({
    int? id,
    int? protocolType,
    double? peakForceKg,
    String? sessionId,
    DateTime? achievedAt,
  }) => PersonalRecord(
    id: id ?? this.id,
    protocolType: protocolType ?? this.protocolType,
    peakForceKg: peakForceKg ?? this.peakForceKg,
    sessionId: sessionId ?? this.sessionId,
    achievedAt: achievedAt ?? this.achievedAt,
  );
  PersonalRecord copyWithCompanion(PersonalRecordsCompanion data) {
    return PersonalRecord(
      id: data.id.present ? data.id.value : this.id,
      protocolType: data.protocolType.present
          ? data.protocolType.value
          : this.protocolType,
      peakForceKg: data.peakForceKg.present
          ? data.peakForceKg.value
          : this.peakForceKg,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      achievedAt: data.achievedAt.present
          ? data.achievedAt.value
          : this.achievedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonalRecord(')
          ..write('id: $id, ')
          ..write('protocolType: $protocolType, ')
          ..write('peakForceKg: $peakForceKg, ')
          ..write('sessionId: $sessionId, ')
          ..write('achievedAt: $achievedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, protocolType, peakForceKg, sessionId, achievedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonalRecord &&
          other.id == this.id &&
          other.protocolType == this.protocolType &&
          other.peakForceKg == this.peakForceKg &&
          other.sessionId == this.sessionId &&
          other.achievedAt == this.achievedAt);
}

class PersonalRecordsCompanion extends UpdateCompanion<PersonalRecord> {
  final Value<int> id;
  final Value<int> protocolType;
  final Value<double> peakForceKg;
  final Value<String> sessionId;
  final Value<DateTime> achievedAt;
  const PersonalRecordsCompanion({
    this.id = const Value.absent(),
    this.protocolType = const Value.absent(),
    this.peakForceKg = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.achievedAt = const Value.absent(),
  });
  PersonalRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int protocolType,
    required double peakForceKg,
    required String sessionId,
    required DateTime achievedAt,
  }) : protocolType = Value(protocolType),
       peakForceKg = Value(peakForceKg),
       sessionId = Value(sessionId),
       achievedAt = Value(achievedAt);
  static Insertable<PersonalRecord> custom({
    Expression<int>? id,
    Expression<int>? protocolType,
    Expression<double>? peakForceKg,
    Expression<String>? sessionId,
    Expression<DateTime>? achievedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (protocolType != null) 'protocol_type': protocolType,
      if (peakForceKg != null) 'peak_force_kg': peakForceKg,
      if (sessionId != null) 'session_id': sessionId,
      if (achievedAt != null) 'achieved_at': achievedAt,
    });
  }

  PersonalRecordsCompanion copyWith({
    Value<int>? id,
    Value<int>? protocolType,
    Value<double>? peakForceKg,
    Value<String>? sessionId,
    Value<DateTime>? achievedAt,
  }) {
    return PersonalRecordsCompanion(
      id: id ?? this.id,
      protocolType: protocolType ?? this.protocolType,
      peakForceKg: peakForceKg ?? this.peakForceKg,
      sessionId: sessionId ?? this.sessionId,
      achievedAt: achievedAt ?? this.achievedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (protocolType.present) {
      map['protocol_type'] = Variable<int>(protocolType.value);
    }
    if (peakForceKg.present) {
      map['peak_force_kg'] = Variable<double>(peakForceKg.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (achievedAt.present) {
      map['achieved_at'] = Variable<DateTime>(achievedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonalRecordsCompanion(')
          ..write('id: $id, ')
          ..write('protocolType: $protocolType, ')
          ..write('peakForceKg: $peakForceKg, ')
          ..write('sessionId: $sessionId, ')
          ..write('achievedAt: $achievedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $TrainingSetsTable trainingSets = $TrainingSetsTable(this);
  late final $RepsTable reps = $RepsTable(this);
  late final $PersonalRecordsTable personalRecords = $PersonalRecordsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    sessions,
    trainingSets,
    reps,
    personalRecords,
  ];
}

typedef $$SessionsTableCreateCompanionBuilder =
    SessionsCompanion Function({
      required String id,
      required int protocolType,
      required String protocolConfigJson,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      Value<double> peakForceKg,
      Value<double> avgPeakForceKg,
      Value<String> notes,
      Value<int> rowid,
    });
typedef $$SessionsTableUpdateCompanionBuilder =
    SessionsCompanion Function({
      Value<String> id,
      Value<int> protocolType,
      Value<String> protocolConfigJson,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<double> peakForceKg,
      Value<double> avgPeakForceKg,
      Value<String> notes,
      Value<int> rowid,
    });

final class $$SessionsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionsTable, Session> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TrainingSetsTable, List<TrainingSet>>
  _trainingSetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.trainingSets,
    aliasName: $_aliasNameGenerator(db.sessions.id, db.trainingSets.sessionId),
  );

  $$TrainingSetsTableProcessedTableManager get trainingSetsRefs {
    final manager = $$TrainingSetsTableTableManager(
      $_db,
      $_db.trainingSets,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_trainingSetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PersonalRecordsTable, List<PersonalRecord>>
  _personalRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.personalRecords,
    aliasName: $_aliasNameGenerator(
      db.sessions.id,
      db.personalRecords.sessionId,
    ),
  );

  $$PersonalRecordsTableProcessedTableManager get personalRecordsRefs {
    final manager = $$PersonalRecordsTableTableManager(
      $_db,
      $_db.personalRecords,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _personalRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get protocolType => $composableBuilder(
    column: $table.protocolType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get protocolConfigJson => $composableBuilder(
    column: $table.protocolConfigJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get peakForceKg => $composableBuilder(
    column: $table.peakForceKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get avgPeakForceKg => $composableBuilder(
    column: $table.avgPeakForceKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> trainingSetsRefs(
    Expression<bool> Function($$TrainingSetsTableFilterComposer f) f,
  ) {
    final $$TrainingSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trainingSets,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrainingSetsTableFilterComposer(
            $db: $db,
            $table: $db.trainingSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> personalRecordsRefs(
    Expression<bool> Function($$PersonalRecordsTableFilterComposer f) f,
  ) {
    final $$PersonalRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personalRecords,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonalRecordsTableFilterComposer(
            $db: $db,
            $table: $db.personalRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get protocolType => $composableBuilder(
    column: $table.protocolType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get protocolConfigJson => $composableBuilder(
    column: $table.protocolConfigJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get peakForceKg => $composableBuilder(
    column: $table.peakForceKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get avgPeakForceKg => $composableBuilder(
    column: $table.avgPeakForceKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get protocolType => $composableBuilder(
    column: $table.protocolType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get protocolConfigJson => $composableBuilder(
    column: $table.protocolConfigJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<double> get peakForceKg => $composableBuilder(
    column: $table.peakForceKg,
    builder: (column) => column,
  );

  GeneratedColumn<double> get avgPeakForceKg => $composableBuilder(
    column: $table.avgPeakForceKg,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  Expression<T> trainingSetsRefs<T extends Object>(
    Expression<T> Function($$TrainingSetsTableAnnotationComposer a) f,
  ) {
    final $$TrainingSetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trainingSets,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrainingSetsTableAnnotationComposer(
            $db: $db,
            $table: $db.trainingSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> personalRecordsRefs<T extends Object>(
    Expression<T> Function($$PersonalRecordsTableAnnotationComposer a) f,
  ) {
    final $$PersonalRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personalRecords,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonalRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.personalRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          Session,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (Session, $$SessionsTableReferences),
          Session,
          PrefetchHooks Function({
            bool trainingSetsRefs,
            bool personalRecordsRefs,
          })
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> protocolType = const Value.absent(),
                Value<String> protocolConfigJson = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<double> peakForceKg = const Value.absent(),
                Value<double> avgPeakForceKg = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                protocolType: protocolType,
                protocolConfigJson: protocolConfigJson,
                startedAt: startedAt,
                endedAt: endedAt,
                peakForceKg: peakForceKg,
                avgPeakForceKg: avgPeakForceKg,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int protocolType,
                required String protocolConfigJson,
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<double> peakForceKg = const Value.absent(),
                Value<double> avgPeakForceKg = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                protocolType: protocolType,
                protocolConfigJson: protocolConfigJson,
                startedAt: startedAt,
                endedAt: endedAt,
                peakForceKg: peakForceKg,
                avgPeakForceKg: avgPeakForceKg,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({trainingSetsRefs = false, personalRecordsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (trainingSetsRefs) db.trainingSets,
                    if (personalRecordsRefs) db.personalRecords,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (trainingSetsRefs)
                        await $_getPrefetchedData<
                          Session,
                          $SessionsTable,
                          TrainingSet
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._trainingSetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).trainingSetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (personalRecordsRefs)
                        await $_getPrefetchedData<
                          Session,
                          $SessionsTable,
                          PersonalRecord
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._personalRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).personalRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      Session,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (Session, $$SessionsTableReferences),
      Session,
      PrefetchHooks Function({bool trainingSetsRefs, bool personalRecordsRefs})
    >;
typedef $$TrainingSetsTableCreateCompanionBuilder =
    TrainingSetsCompanion Function({
      Value<int> id,
      required String sessionId,
      required int setIndex,
      Value<int> restDurationMs,
    });
typedef $$TrainingSetsTableUpdateCompanionBuilder =
    TrainingSetsCompanion Function({
      Value<int> id,
      Value<String> sessionId,
      Value<int> setIndex,
      Value<int> restDurationMs,
    });

final class $$TrainingSetsTableReferences
    extends BaseReferences<_$AppDatabase, $TrainingSetsTable, TrainingSet> {
  $$TrainingSetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias(
        $_aliasNameGenerator(db.trainingSets.sessionId, db.sessions.id),
      );

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$RepsTable, List<Rep>> _repsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.reps,
    aliasName: $_aliasNameGenerator(db.trainingSets.id, db.reps.trainingSetId),
  );

  $$RepsTableProcessedTableManager get repsRefs {
    final manager = $$RepsTableTableManager(
      $_db,
      $_db.reps,
    ).filter((f) => f.trainingSetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_repsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TrainingSetsTableFilterComposer
    extends Composer<_$AppDatabase, $TrainingSetsTable> {
  $$TrainingSetsTableFilterComposer({
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

  ColumnFilters<int> get setIndex => $composableBuilder(
    column: $table.setIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restDurationMs => $composableBuilder(
    column: $table.restDurationMs,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> repsRefs(
    Expression<bool> Function($$RepsTableFilterComposer f) f,
  ) {
    final $$RepsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reps,
      getReferencedColumn: (t) => t.trainingSetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RepsTableFilterComposer(
            $db: $db,
            $table: $db.reps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TrainingSetsTableOrderingComposer
    extends Composer<_$AppDatabase, $TrainingSetsTable> {
  $$TrainingSetsTableOrderingComposer({
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

  ColumnOrderings<int> get setIndex => $composableBuilder(
    column: $table.setIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restDurationMs => $composableBuilder(
    column: $table.restDurationMs,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrainingSetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrainingSetsTable> {
  $$TrainingSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get setIndex =>
      $composableBuilder(column: $table.setIndex, builder: (column) => column);

  GeneratedColumn<int> get restDurationMs => $composableBuilder(
    column: $table.restDurationMs,
    builder: (column) => column,
  );

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> repsRefs<T extends Object>(
    Expression<T> Function($$RepsTableAnnotationComposer a) f,
  ) {
    final $$RepsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reps,
      getReferencedColumn: (t) => t.trainingSetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RepsTableAnnotationComposer(
            $db: $db,
            $table: $db.reps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TrainingSetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrainingSetsTable,
          TrainingSet,
          $$TrainingSetsTableFilterComposer,
          $$TrainingSetsTableOrderingComposer,
          $$TrainingSetsTableAnnotationComposer,
          $$TrainingSetsTableCreateCompanionBuilder,
          $$TrainingSetsTableUpdateCompanionBuilder,
          (TrainingSet, $$TrainingSetsTableReferences),
          TrainingSet,
          PrefetchHooks Function({bool sessionId, bool repsRefs})
        > {
  $$TrainingSetsTableTableManager(_$AppDatabase db, $TrainingSetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrainingSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrainingSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrainingSetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<int> setIndex = const Value.absent(),
                Value<int> restDurationMs = const Value.absent(),
              }) => TrainingSetsCompanion(
                id: id,
                sessionId: sessionId,
                setIndex: setIndex,
                restDurationMs: restDurationMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String sessionId,
                required int setIndex,
                Value<int> restDurationMs = const Value.absent(),
              }) => TrainingSetsCompanion.insert(
                id: id,
                sessionId: sessionId,
                setIndex: setIndex,
                restDurationMs: restDurationMs,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TrainingSetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false, repsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (repsRefs) db.reps],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$TrainingSetsTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$TrainingSetsTableReferences
                                    ._sessionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (repsRefs)
                    await $_getPrefetchedData<
                      TrainingSet,
                      $TrainingSetsTable,
                      Rep
                    >(
                      currentTable: table,
                      referencedTable: $$TrainingSetsTableReferences
                          ._repsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TrainingSetsTableReferences(db, table, p0).repsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.trainingSetId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TrainingSetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrainingSetsTable,
      TrainingSet,
      $$TrainingSetsTableFilterComposer,
      $$TrainingSetsTableOrderingComposer,
      $$TrainingSetsTableAnnotationComposer,
      $$TrainingSetsTableCreateCompanionBuilder,
      $$TrainingSetsTableUpdateCompanionBuilder,
      (TrainingSet, $$TrainingSetsTableReferences),
      TrainingSet,
      PrefetchHooks Function({bool sessionId, bool repsRefs})
    >;
typedef $$RepsTableCreateCompanionBuilder =
    RepsCompanion Function({
      Value<int> id,
      required int trainingSetId,
      required int repIndex,
      required double peakForceKg,
      required double avgForceKg,
      required int durationMs,
      required int startTimestampMs,
      Value<String> weightSamplesJson,
    });
typedef $$RepsTableUpdateCompanionBuilder =
    RepsCompanion Function({
      Value<int> id,
      Value<int> trainingSetId,
      Value<int> repIndex,
      Value<double> peakForceKg,
      Value<double> avgForceKg,
      Value<int> durationMs,
      Value<int> startTimestampMs,
      Value<String> weightSamplesJson,
    });

final class $$RepsTableReferences
    extends BaseReferences<_$AppDatabase, $RepsTable, Rep> {
  $$RepsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TrainingSetsTable _trainingSetIdTable(_$AppDatabase db) =>
      db.trainingSets.createAlias(
        $_aliasNameGenerator(db.reps.trainingSetId, db.trainingSets.id),
      );

  $$TrainingSetsTableProcessedTableManager get trainingSetId {
    final $_column = $_itemColumn<int>('training_set_id')!;

    final manager = $$TrainingSetsTableTableManager(
      $_db,
      $_db.trainingSets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_trainingSetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RepsTableFilterComposer extends Composer<_$AppDatabase, $RepsTable> {
  $$RepsTableFilterComposer({
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

  ColumnFilters<int> get repIndex => $composableBuilder(
    column: $table.repIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get peakForceKg => $composableBuilder(
    column: $table.peakForceKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get avgForceKg => $composableBuilder(
    column: $table.avgForceKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startTimestampMs => $composableBuilder(
    column: $table.startTimestampMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weightSamplesJson => $composableBuilder(
    column: $table.weightSamplesJson,
    builder: (column) => ColumnFilters(column),
  );

  $$TrainingSetsTableFilterComposer get trainingSetId {
    final $$TrainingSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trainingSetId,
      referencedTable: $db.trainingSets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrainingSetsTableFilterComposer(
            $db: $db,
            $table: $db.trainingSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RepsTableOrderingComposer extends Composer<_$AppDatabase, $RepsTable> {
  $$RepsTableOrderingComposer({
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

  ColumnOrderings<int> get repIndex => $composableBuilder(
    column: $table.repIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get peakForceKg => $composableBuilder(
    column: $table.peakForceKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get avgForceKg => $composableBuilder(
    column: $table.avgForceKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startTimestampMs => $composableBuilder(
    column: $table.startTimestampMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weightSamplesJson => $composableBuilder(
    column: $table.weightSamplesJson,
    builder: (column) => ColumnOrderings(column),
  );

  $$TrainingSetsTableOrderingComposer get trainingSetId {
    final $$TrainingSetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trainingSetId,
      referencedTable: $db.trainingSets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrainingSetsTableOrderingComposer(
            $db: $db,
            $table: $db.trainingSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RepsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RepsTable> {
  $$RepsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get repIndex =>
      $composableBuilder(column: $table.repIndex, builder: (column) => column);

  GeneratedColumn<double> get peakForceKg => $composableBuilder(
    column: $table.peakForceKg,
    builder: (column) => column,
  );

  GeneratedColumn<double> get avgForceKg => $composableBuilder(
    column: $table.avgForceKg,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startTimestampMs => $composableBuilder(
    column: $table.startTimestampMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get weightSamplesJson => $composableBuilder(
    column: $table.weightSamplesJson,
    builder: (column) => column,
  );

  $$TrainingSetsTableAnnotationComposer get trainingSetId {
    final $$TrainingSetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trainingSetId,
      referencedTable: $db.trainingSets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrainingSetsTableAnnotationComposer(
            $db: $db,
            $table: $db.trainingSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RepsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RepsTable,
          Rep,
          $$RepsTableFilterComposer,
          $$RepsTableOrderingComposer,
          $$RepsTableAnnotationComposer,
          $$RepsTableCreateCompanionBuilder,
          $$RepsTableUpdateCompanionBuilder,
          (Rep, $$RepsTableReferences),
          Rep,
          PrefetchHooks Function({bool trainingSetId})
        > {
  $$RepsTableTableManager(_$AppDatabase db, $RepsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RepsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RepsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RepsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> trainingSetId = const Value.absent(),
                Value<int> repIndex = const Value.absent(),
                Value<double> peakForceKg = const Value.absent(),
                Value<double> avgForceKg = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<int> startTimestampMs = const Value.absent(),
                Value<String> weightSamplesJson = const Value.absent(),
              }) => RepsCompanion(
                id: id,
                trainingSetId: trainingSetId,
                repIndex: repIndex,
                peakForceKg: peakForceKg,
                avgForceKg: avgForceKg,
                durationMs: durationMs,
                startTimestampMs: startTimestampMs,
                weightSamplesJson: weightSamplesJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int trainingSetId,
                required int repIndex,
                required double peakForceKg,
                required double avgForceKg,
                required int durationMs,
                required int startTimestampMs,
                Value<String> weightSamplesJson = const Value.absent(),
              }) => RepsCompanion.insert(
                id: id,
                trainingSetId: trainingSetId,
                repIndex: repIndex,
                peakForceKg: peakForceKg,
                avgForceKg: avgForceKg,
                durationMs: durationMs,
                startTimestampMs: startTimestampMs,
                weightSamplesJson: weightSamplesJson,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$RepsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({trainingSetId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (trainingSetId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.trainingSetId,
                                referencedTable: $$RepsTableReferences
                                    ._trainingSetIdTable(db),
                                referencedColumn: $$RepsTableReferences
                                    ._trainingSetIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RepsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RepsTable,
      Rep,
      $$RepsTableFilterComposer,
      $$RepsTableOrderingComposer,
      $$RepsTableAnnotationComposer,
      $$RepsTableCreateCompanionBuilder,
      $$RepsTableUpdateCompanionBuilder,
      (Rep, $$RepsTableReferences),
      Rep,
      PrefetchHooks Function({bool trainingSetId})
    >;
typedef $$PersonalRecordsTableCreateCompanionBuilder =
    PersonalRecordsCompanion Function({
      Value<int> id,
      required int protocolType,
      required double peakForceKg,
      required String sessionId,
      required DateTime achievedAt,
    });
typedef $$PersonalRecordsTableUpdateCompanionBuilder =
    PersonalRecordsCompanion Function({
      Value<int> id,
      Value<int> protocolType,
      Value<double> peakForceKg,
      Value<String> sessionId,
      Value<DateTime> achievedAt,
    });

final class $$PersonalRecordsTableReferences
    extends
        BaseReferences<_$AppDatabase, $PersonalRecordsTable, PersonalRecord> {
  $$PersonalRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias(
        $_aliasNameGenerator(db.personalRecords.sessionId, db.sessions.id),
      );

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PersonalRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $PersonalRecordsTable> {
  $$PersonalRecordsTableFilterComposer({
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

  ColumnFilters<int> get protocolType => $composableBuilder(
    column: $table.protocolType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get peakForceKg => $composableBuilder(
    column: $table.peakForceKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonalRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonalRecordsTable> {
  $$PersonalRecordsTableOrderingComposer({
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

  ColumnOrderings<int> get protocolType => $composableBuilder(
    column: $table.protocolType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get peakForceKg => $composableBuilder(
    column: $table.peakForceKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonalRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonalRecordsTable> {
  $$PersonalRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get protocolType => $composableBuilder(
    column: $table.protocolType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get peakForceKg => $composableBuilder(
    column: $table.peakForceKg,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => column,
  );

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonalRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PersonalRecordsTable,
          PersonalRecord,
          $$PersonalRecordsTableFilterComposer,
          $$PersonalRecordsTableOrderingComposer,
          $$PersonalRecordsTableAnnotationComposer,
          $$PersonalRecordsTableCreateCompanionBuilder,
          $$PersonalRecordsTableUpdateCompanionBuilder,
          (PersonalRecord, $$PersonalRecordsTableReferences),
          PersonalRecord,
          PrefetchHooks Function({bool sessionId})
        > {
  $$PersonalRecordsTableTableManager(
    _$AppDatabase db,
    $PersonalRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonalRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonalRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonalRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> protocolType = const Value.absent(),
                Value<double> peakForceKg = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<DateTime> achievedAt = const Value.absent(),
              }) => PersonalRecordsCompanion(
                id: id,
                protocolType: protocolType,
                peakForceKg: peakForceKg,
                sessionId: sessionId,
                achievedAt: achievedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int protocolType,
                required double peakForceKg,
                required String sessionId,
                required DateTime achievedAt,
              }) => PersonalRecordsCompanion.insert(
                id: id,
                protocolType: protocolType,
                peakForceKg: peakForceKg,
                sessionId: sessionId,
                achievedAt: achievedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PersonalRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable:
                                    $$PersonalRecordsTableReferences
                                        ._sessionIdTable(db),
                                referencedColumn:
                                    $$PersonalRecordsTableReferences
                                        ._sessionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PersonalRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PersonalRecordsTable,
      PersonalRecord,
      $$PersonalRecordsTableFilterComposer,
      $$PersonalRecordsTableOrderingComposer,
      $$PersonalRecordsTableAnnotationComposer,
      $$PersonalRecordsTableCreateCompanionBuilder,
      $$PersonalRecordsTableUpdateCompanionBuilder,
      (PersonalRecord, $$PersonalRecordsTableReferences),
      PersonalRecord,
      PrefetchHooks Function({bool sessionId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$TrainingSetsTableTableManager get trainingSets =>
      $$TrainingSetsTableTableManager(_db, _db.trainingSets);
  $$RepsTableTableManager get reps => $$RepsTableTableManager(_db, _db.reps);
  $$PersonalRecordsTableTableManager get personalRecords =>
      $$PersonalRecordsTableTableManager(_db, _db.personalRecords);
}
