import 'dart:convert';

import 'package:drift/drift.dart';

import '../../models/session_models.dart' as models;
import '../app_database.dart';

part 'session_dao.g.dart';

@DriftAccessor(tables: [Sessions, TrainingSets, Reps, PersonalRecords])
class SessionDao extends DatabaseAccessor<AppDatabase> with _$SessionDaoMixin {
  SessionDao(super.db);

  // ──────────────────────── Insert ──────────────────────────────────

  Future<void> insertSession(models.Session session) async {
    await into(sessions).insert(
      SessionsCompanion.insert(
        id: session.id,
        protocolType: session.protocolType.index,
        protocolConfigJson: jsonEncode(session.protocolConfig.toJson()),
        startedAt: session.startedAt,
        endedAt: Value(session.endedAt),
        peakForceKg: Value(session.peakForceKg),
        avgPeakForceKg: Value(session.avgPeakForceKg),
        notes: Value(session.notes),
      ),
    );

    for (var setIdx = 0; setIdx < session.sets.length; setIdx++) {
      final trainingSet = session.sets[setIdx];
      final setId = await into(trainingSets).insert(
        TrainingSetsCompanion.insert(
          sessionId: session.id,
          setIndex: setIdx,
          restDurationMs: Value(trainingSet.restDurationMs),
        ),
      );

      for (var repIdx = 0; repIdx < trainingSet.reps.length; repIdx++) {
        final rep = trainingSet.reps[repIdx];
        final samplesJson = jsonEncode(
          rep.weightSamples.map((s) => s.toJson()).toList(),
        );
        await into(reps).insert(
          RepsCompanion.insert(
            trainingSetId: setId,
            repIndex: repIdx,
            peakForceKg: rep.peakForceKg,
            avgForceKg: rep.avgForceKg,
            durationMs: rep.durationMs,
            startTimestampMs: rep.startTimestampMs,
            weightSamplesJson: Value(samplesJson),
          ),
        );
      }
    }
  }

  // ──────────────────────── Query ───────────────────────────────────

  Future<List<models.Session>> getAllSessions() async {
    final sessionRows = await (select(sessions)
          ..orderBy([(s) => OrderingTerm.desc(s.startedAt)]))
        .get();

    final result = <models.Session>[];
    for (final row in sessionRows) {
      result.add(await _buildSession(row));
    }
    return result;
  }

  Future<models.Session?> getSession(String id) async {
    final row = await (select(sessions)..where((s) => s.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return _buildSession(row);
  }

  Future<models.Session> _buildSession(Session row) async {
    final setRows = await (select(trainingSets)
          ..where((ts) => ts.sessionId.equals(row.id))
          ..orderBy([(ts) => OrderingTerm.asc(ts.setIndex)]))
        .get();

    final modelSets = <models.TrainingSet>[];
    for (final setRow in setRows) {
      final repRows = await (select(reps)
            ..where((r) => r.trainingSetId.equals(setRow.id))
            ..orderBy([(r) => OrderingTerm.asc(r.repIndex)]))
          .get();

      final modelReps = repRows.map((r) {
        final samplesRaw = jsonDecode(r.weightSamplesJson) as List;
        final samples = samplesRaw
            .map((s) =>
                models.WeightSample.fromJson(s as Map<String, dynamic>))
            .toList();
        return models.Rep(
          peakForceKg: r.peakForceKg,
          avgForceKg: r.avgForceKg,
          durationMs: r.durationMs,
          startTimestampMs: r.startTimestampMs,
          weightSamples: samples,
        );
      }).toList();

      modelSets.add(models.TrainingSet(
        reps: modelReps,
        restDurationMs: setRow.restDurationMs,
      ));
    }

    return models.Session(
      id: row.id,
      protocolType: models.ProtocolType.values[row.protocolType],
      protocolConfig: models.ProtocolConfig.fromJson(
        jsonDecode(row.protocolConfigJson) as Map<String, dynamic>,
      ),
      sets: modelSets,
      startedAt: row.startedAt,
      endedAt: row.endedAt,
      peakForceKg: row.peakForceKg,
      avgPeakForceKg: row.avgPeakForceKg,
      notes: row.notes,
    );
  }

  // ──────────────────────── Delete ──────────────────────────────────

  Future<void> deleteSession(String id) async {
    // Get set IDs for cascade
    final setRows = await (select(trainingSets)
          ..where((ts) => ts.sessionId.equals(id)))
        .get();
    for (final setRow in setRows) {
      await (delete(reps)..where((r) => r.trainingSetId.equals(setRow.id)))
          .go();
    }
    await (delete(trainingSets)..where((ts) => ts.sessionId.equals(id))).go();
    await (delete(personalRecords)..where((pr) => pr.sessionId.equals(id)))
        .go();
    await (delete(sessions)..where((s) => s.id.equals(id))).go();
  }

  // ──────────────────────── Personal records ────────────────────────

  Future<void> checkAndUpdatePR(models.Session session) async {
    final existing = await (select(personalRecords)
          ..where(
            (pr) => pr.protocolType.equals(session.protocolType.index),
          ))
        .getSingleOrNull();

    if (existing == null || session.peakForceKg > existing.peakForceKg) {
      if (existing != null) {
        await (delete(personalRecords)
              ..where((pr) => pr.id.equals(existing.id)))
            .go();
      }
      await into(personalRecords).insert(
        PersonalRecordsCompanion.insert(
          protocolType: session.protocolType.index,
          peakForceKg: session.peakForceKg,
          sessionId: session.id,
          achievedAt: session.endedAt ?? session.startedAt,
        ),
      );
    }
  }

  Future<Map<models.ProtocolType, double>> getPersonalRecords() async {
    final rows = await select(personalRecords).get();
    final result = <models.ProtocolType, double>{};
    for (final row in rows) {
      if (row.protocolType < models.ProtocolType.values.length) {
        result[models.ProtocolType.values[row.protocolType]] =
            row.peakForceKg;
      }
    }
    return result;
  }
}
