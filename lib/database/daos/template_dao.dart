import 'dart:convert';

import 'package:drift/drift.dart';

import '../../models/session_models.dart' as models;
import '../../models/template_models.dart' as models;
import '../app_database.dart';

part 'template_dao.g.dart';

@DriftAccessor(tables: [SessionTemplates])
class TemplateDao extends DatabaseAccessor<AppDatabase>
    with _$TemplateDaoMixin {
  TemplateDao(super.db);

  Future<void> insertTemplate(models.SessionTemplate template) async {
    await into(sessionTemplates).insert(
      SessionTemplatesCompanion.insert(
        id: template.id,
        name: template.name,
        protocolConfigJson:
            jsonEncode(template.protocolConfig.toJson()),
        createdAt: template.createdAt,
      ),
    );
  }

  Future<List<models.SessionTemplate>> getAllTemplates() async {
    final rows = await (select(sessionTemplates)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
    return rows.map(_toModel).toList();
  }

  Future<void> deleteTemplate(String id) async {
    await (delete(sessionTemplates)..where((t) => t.id.equals(id))).go();
  }

  Future<void> updateTemplateName(String id, String name) async {
    await (update(sessionTemplates)..where((t) => t.id.equals(id)))
        .write(SessionTemplatesCompanion(name: Value(name)));
  }

  Future<void> updateTemplate(models.SessionTemplate template) async {
    await (update(sessionTemplates)
          ..where((t) => t.id.equals(template.id)))
        .write(SessionTemplatesCompanion(
      name: Value(template.name),
      protocolConfigJson:
          Value(jsonEncode(template.protocolConfig.toJson())),
    ));
  }

  models.SessionTemplate _toModel(SessionTemplate row) {
    return models.SessionTemplate(
      id: row.id,
      name: row.name,
      protocolConfig: models.ProtocolConfig.fromJson(
        jsonDecode(row.protocolConfigJson) as Map<String, dynamic>,
      ),
      createdAt: row.createdAt,
    );
  }
}
