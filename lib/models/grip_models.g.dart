// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grip_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Grip _$GripFromJson(Map<String, dynamic> json) => _Grip(
  id: json['id'] as String,
  name: json['name'] as String,
  edgeDepthMm: (json['edgeDepthMm'] as num).toDouble(),
  fingers: (json['fingers'] as List<dynamic>)
      .map((e) => $enumDecode(_$FingerEnumMap, e))
      .toSet(),
  gripType: $enumDecode(_$GripTypeEnumMap, json['gripType']),
  contractionType: $enumDecode(
    _$ContractionTypeEnumMap,
    json['contractionType'],
  ),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$GripToJson(_Grip instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'edgeDepthMm': instance.edgeDepthMm,
  'fingers': instance.fingers.map((e) => _$FingerEnumMap[e]!).toList(),
  'gripType': _$GripTypeEnumMap[instance.gripType]!,
  'contractionType': _$ContractionTypeEnumMap[instance.contractionType]!,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$FingerEnumMap = {
  Finger.thumb: 'thumb',
  Finger.indexFinger: 'indexFinger',
  Finger.middle: 'middle',
  Finger.ring: 'ring',
  Finger.pinky: 'pinky',
};

const _$GripTypeEnumMap = {
  GripType.halfCrimp: 'halfCrimp',
  GripType.fullCrimp: 'fullCrimp',
  GripType.openHand: 'openHand',
};

const _$ContractionTypeEnumMap = {
  ContractionType.passive: 'passive',
  ContractionType.active: 'active',
};
