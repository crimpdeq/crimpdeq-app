// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProtocolConfig _$ProtocolConfigFromJson(Map<String, dynamic> json) =>
    _ProtocolConfig(
      type: $enumDecode(_$ProtocolTypeEnumMap, json['type']),
      hangDurationSec: (json['hangDurationSec'] as num?)?.toInt() ?? 7,
      restDurationSec: (json['restDurationSec'] as num?)?.toInt() ?? 3,
      sets: (json['sets'] as num?)?.toInt() ?? 3,
      repsPerSet: (json['repsPerSet'] as num?)?.toInt() ?? 1,
      restBetweenSetsSec: (json['restBetweenSetsSec'] as num?)?.toInt() ?? 180,
      targetWeightKg: (json['targetWeightKg'] as num?)?.toDouble() ?? 0.0,
      hangThresholdKg: (json['hangThresholdKg'] as num?)?.toDouble() ?? 2.0,
    );

Map<String, dynamic> _$ProtocolConfigToJson(_ProtocolConfig instance) =>
    <String, dynamic>{
      'type': _$ProtocolTypeEnumMap[instance.type]!,
      'hangDurationSec': instance.hangDurationSec,
      'restDurationSec': instance.restDurationSec,
      'sets': instance.sets,
      'repsPerSet': instance.repsPerSet,
      'restBetweenSetsSec': instance.restBetweenSetsSec,
      'targetWeightKg': instance.targetWeightKg,
      'hangThresholdKg': instance.hangThresholdKg,
    };

const _$ProtocolTypeEnumMap = {
  ProtocolType.maxHang: 'maxHang',
  ProtocolType.repeater: 'repeater',
  ProtocolType.freeform: 'freeform',
};

_WeightSample _$WeightSampleFromJson(Map<String, dynamic> json) =>
    _WeightSample(
      weight: (json['weight'] as num).toDouble(),
      timestampMs: (json['timestampMs'] as num).toInt(),
    );

Map<String, dynamic> _$WeightSampleToJson(_WeightSample instance) =>
    <String, dynamic>{
      'weight': instance.weight,
      'timestampMs': instance.timestampMs,
    };

_Rep _$RepFromJson(Map<String, dynamic> json) => _Rep(
  peakForceKg: (json['peakForceKg'] as num).toDouble(),
  avgForceKg: (json['avgForceKg'] as num).toDouble(),
  durationMs: (json['durationMs'] as num).toInt(),
  startTimestampMs: (json['startTimestampMs'] as num).toInt(),
  weightSamples:
      (json['weightSamples'] as List<dynamic>?)
          ?.map((e) => WeightSample.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$RepToJson(_Rep instance) => <String, dynamic>{
  'peakForceKg': instance.peakForceKg,
  'avgForceKg': instance.avgForceKg,
  'durationMs': instance.durationMs,
  'startTimestampMs': instance.startTimestampMs,
  'weightSamples': instance.weightSamples,
};

_TrainingSet _$TrainingSetFromJson(Map<String, dynamic> json) => _TrainingSet(
  reps:
      (json['reps'] as List<dynamic>?)
          ?.map((e) => Rep.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  restDurationMs: (json['restDurationMs'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$TrainingSetToJson(_TrainingSet instance) =>
    <String, dynamic>{
      'reps': instance.reps,
      'restDurationMs': instance.restDurationMs,
    };

_Session _$SessionFromJson(Map<String, dynamic> json) => _Session(
  id: json['id'] as String,
  protocolType: $enumDecode(_$ProtocolTypeEnumMap, json['protocolType']),
  protocolConfig: ProtocolConfig.fromJson(
    json['protocolConfig'] as Map<String, dynamic>,
  ),
  sets:
      (json['sets'] as List<dynamic>?)
          ?.map((e) => TrainingSet.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  startedAt: DateTime.parse(json['startedAt'] as String),
  endedAt: json['endedAt'] == null
      ? null
      : DateTime.parse(json['endedAt'] as String),
  peakForceKg: (json['peakForceKg'] as num?)?.toDouble() ?? 0.0,
  avgPeakForceKg: (json['avgPeakForceKg'] as num?)?.toDouble() ?? 0.0,
  notes: json['notes'] as String? ?? '',
);

Map<String, dynamic> _$SessionToJson(_Session instance) => <String, dynamic>{
  'id': instance.id,
  'protocolType': _$ProtocolTypeEnumMap[instance.protocolType]!,
  'protocolConfig': instance.protocolConfig,
  'sets': instance.sets,
  'startedAt': instance.startedAt.toIso8601String(),
  'endedAt': instance.endedAt?.toIso8601String(),
  'peakForceKg': instance.peakForceKg,
  'avgPeakForceKg': instance.avgPeakForceKg,
  'notes': instance.notes,
};
