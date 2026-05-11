import 'dart:convert';

import 'package:drift/drift.dart';

import '../../models/grip_models.dart' as models;
import '../app_database.dart';

part 'grip_dao.g.dart';

@DriftAccessor(tables: [Grips])
class GripDao extends DatabaseAccessor<AppDatabase> with _$GripDaoMixin {
  GripDao(super.db);

  Future<void> insertGrip(models.Grip grip) async {
    await into(grips).insert(
      GripsCompanion.insert(
        id: grip.id,
        name: grip.name,
        edgeDepthMm: grip.edgeDepthMm,
        fingersJson: jsonEncode(grip.fingers.map((f) => f.index).toList()),
        gripType: grip.gripType.index,
        contractionType: grip.contractionType.index,
        createdAt: grip.createdAt,
      ),
    );
  }

  Future<List<models.Grip>> getAllGrips() async {
    final rows = await (select(grips)
          ..orderBy([(g) => OrderingTerm.desc(g.createdAt)]))
        .get();
    return rows.map(_toModel).toList();
  }

  Future<void> deleteGrip(String id) async {
    await (delete(grips)..where((g) => g.id.equals(id))).go();
  }

  models.Grip _toModel(Grip row) {
    final fingerIndices = (jsonDecode(row.fingersJson) as List).cast<int>();
    return models.Grip(
      id: row.id,
      name: row.name,
      edgeDepthMm: row.edgeDepthMm,
      fingers: fingerIndices.map((i) => models.Finger.values[i]).toSet(),
      gripType: models.GripType.values[row.gripType],
      contractionType: models.ContractionType.values[row.contractionType],
      createdAt: row.createdAt,
    );
  }
}
