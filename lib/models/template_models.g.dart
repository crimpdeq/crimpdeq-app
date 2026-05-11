// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SessionTemplate _$SessionTemplateFromJson(Map<String, dynamic> json) =>
    _SessionTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      protocolConfig: ProtocolConfig.fromJson(
        json['protocolConfig'] as Map<String, dynamic>,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$SessionTemplateToJson(_SessionTemplate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'protocolConfig': instance.protocolConfig,
      'createdAt': instance.createdAt.toIso8601String(),
    };
