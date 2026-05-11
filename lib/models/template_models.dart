import 'package:freezed_annotation/freezed_annotation.dart';

import 'session_models.dart';

part 'template_models.freezed.dart';
part 'template_models.g.dart';

@freezed
sealed class SessionTemplate with _$SessionTemplate {
  const factory SessionTemplate({
    required String id,
    required String name,
    required ProtocolConfig protocolConfig,
    required DateTime createdAt,
  }) = _SessionTemplate;

  factory SessionTemplate.fromJson(Map<String, dynamic> json) =>
      _$SessionTemplateFromJson(json);
}
