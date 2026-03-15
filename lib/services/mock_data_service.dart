import 'dart:math';

import 'package:flutter/foundation.dart';

import '../database/daos/session_dao.dart';
import '../models/session_models.dart';

final _rng = Random(42);

/// Seeds the DB with realistic fake sessions for testing history/PRs.
/// Only runs in debug mode and only if no sessions exist yet.
Future<void> seedMockSessions(SessionDao dao) async {
  if (!kDebugMode) return;
  final existing = await dao.getAllSessions();
  if (existing.isNotEmpty) return;

  final now = DateTime.now();
  final sessions = <Session>[];

  for (var i = 0; i < 12; i++) {
    final daysAgo = i * 2 + _rng.nextInt(3);
    final date = now.subtract(Duration(days: daysAgo, hours: _rng.nextInt(8)));
    final protocol = ProtocolType.values[i % 3];
    sessions.add(_generateSession(
      id: 'mock_$i',
      date: date,
      protocol: protocol,
      sessionIndex: i,
    ));
  }

  for (final session in sessions) {
    await dao.insertSession(session);
    await dao.checkAndUpdatePR(session);
  }
  debugPrint('MockDataService: seeded ${sessions.length} sessions');
}

/// Generates a realistic fake session for the simulator.
Session generateSimulatorSession({
  required ProtocolConfig config,
  required DateTime startedAt,
}) {
  final sets = <TrainingSet>[];
  final numSets = config.type == ProtocolType.freeform
      ? 1 + _rng.nextInt(3)
      : config.sets;
  final repsPerSet = config.type == ProtocolType.freeform
      ? 3 + _rng.nextInt(5)
      : config.repsPerSet;

  double sessionPeak = 0;

  final baseTarget = config.targetWeightKg > 0
      ? config.targetWeightKg
      : 14.0 + _rng.nextDouble() * 12.0;

  for (var si = 0; si < numSets; si++) {
    final reps = <Rep>[];
    for (var ri = 0; ri < repsPerSet; ri++) {
      // Fatigue: later sets/reps slightly lower
      final fatigue = 1.0 - (si * 0.03) - (ri * 0.01);
      final peak = baseTarget * (1.1 + _rng.nextDouble() * 0.15) * fatigue;
      final avg = baseTarget * fatigue * (0.9 + _rng.nextDouble() * 0.1);
      final duration = config.hangDurationSec * 1000 +
          (_rng.nextInt(2000) - 1000);
      final startMs = si * 60000 + ri * (config.hangDurationSec + config.restDurationSec) * 1000;

      if (peak > sessionPeak) sessionPeak = peak;

      // Generate a few weight samples per rep
      final samples = <WeightSample>[];
      final sampleCount = duration ~/ 50;
      for (var s = 0; s < sampleCount; s++) {
        final t = startMs + s * 50;
        final noise = (_rng.nextDouble() - 0.5) * 3.0;
        samples.add(WeightSample(
          weight: (avg + noise).clamp(0, peak + 2),
          timestampMs: t,
        ));
      }

      reps.add(Rep(
        peakForceKg: peak,
        avgForceKg: avg,
        durationMs: duration.clamp(1000, 20000),
        startTimestampMs: startMs,
        weightSamples: samples,
      ));
    }
    sets.add(TrainingSet(reps: reps));
  }

  final allReps = sets.expand((s) => s.reps).toList();
  final avgPeak = allReps.isEmpty
      ? 0.0
      : allReps.map((r) => r.peakForceKg).reduce((a, b) => a + b) /
          allReps.length;

  final totalDurationMs = allReps.isEmpty
      ? 30000
      : allReps.map((r) => r.durationMs).reduce((a, b) => a + b);

  return Session(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    protocolType: config.type,
    protocolConfig: config,
    sets: sets,
    startedAt: startedAt,
    endedAt: startedAt.add(Duration(milliseconds: totalDurationMs + 5000)),
    peakForceKg: sessionPeak,
    avgPeakForceKg: avgPeak,
  );
}

Session _generateSession({
  required String id,
  required DateTime date,
  required ProtocolType protocol,
  required int sessionIndex,
}) {
  final config = ProtocolConfig(
    type: protocol,
    hangDurationSec: protocol == ProtocolType.maxHang ? 10 : 7,
    restDurationSec: protocol == ProtocolType.maxHang ? 5 : 3,
    sets: protocol == ProtocolType.freeform ? 2 : 3 + _rng.nextInt(2),
    repsPerSet: protocol == ProtocolType.repeater ? 6 : 1 + _rng.nextInt(2),
    restBetweenSetsSec: 120 + _rng.nextInt(60),
    targetWeightKg: 15.0 + _rng.nextDouble() * 5,
    hangThresholdKg: 2.0,
  );
  return generateSimulatorSession(config: config, startedAt: date);
}
