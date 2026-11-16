import 'package:fl_chart/fl_chart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../analysis/opengrips_curve.dart';

part 'training_models.freezed.dart';

/// Grips the Crimpdeq pulls through: the crimpdeq-grips rebuilds of the
/// OpenGrips Prometheus and Sisyphus.
const trainingTools = ['Photon', 'Spark'];

enum Hand {
  left('Left'),
  right('Right');

  const Hand(this.label);

  final String label;
}

/// Highest force held for 5 s with one hand on one tool.
class Benchmark {
  const Benchmark({
    required this.date,
    required this.tool,
    required this.hand,
    required this.forceKg,
  });

  Benchmark.fromJson(Map<String, Object?> json)
    : date = DateTime.parse(json['date']! as String),
      tool = json['tool']! as String,
      hand = Hand.values.byName(json['hand']! as String),
      forceKg = (json['forceKg']! as num).toDouble();

  final DateTime date;
  final String tool;
  final Hand hand;
  final double forceKg;

  Map<String, Object?> toJson() => {
    'date': date.toIso8601String(),
    'tool': tool,
    'hand': hand.name,
    'forceKg': forceKg,
  };
}

/// Highest benchmark for [tool] and [hand], the latest among equals.
Benchmark? bestBenchmark(List<Benchmark> benchmarks, String tool, Hand hand) {
  Benchmark? best;
  for (final benchmark in benchmarks) {
    if (benchmark.tool != tool || benchmark.hand != hand) continue;
    if (best == null ||
        benchmark.forceKg > best.forceKg ||
        (benchmark.forceKg == best.forceKg &&
            benchmark.date.isAfter(best.date))) {
      best = benchmark;
    }
  }
  return best;
}

/// One hand's pull of a readiness check: the best 5 s of a maximal pull, and
/// the benchmark it compares with.
typedef ReadinessPull = ({Hand hand, double forceKg, double benchmarkKg});

/// Maximal pulls after a climbing warm-up, against the benchmarks then: how
/// ready the fingers are for the session.
class ReadinessCheck {
  const ReadinessCheck({
    required this.date,
    required this.tool,
    required this.pulls,
  });

  ReadinessCheck.fromJson(Map<String, Object?> json)
    : date = DateTime.parse(json['date']! as String),
      tool = json['tool']! as String,
      pulls = [
        for (final pull in (json['pulls']! as List).cast<Map>())
          (
            hand: Hand.values.byName(pull['hand']! as String),
            forceKg: (pull['forceKg']! as num).toDouble(),
            benchmarkKg: (pull['benchmarkKg']! as num).toDouble(),
          ),
      ];

  final DateTime date;
  final String tool;

  /// The hands pulled for at least 5 s, in their order.
  final List<ReadinessPull> pulls;

  Map<String, Object?> toJson() => {
    'date': date.toIso8601String(),
    'tool': tool,
    'pulls': [
      for (final pull in pulls)
        {
          'hand': pull.hand.name,
          'forceKg': pull.forceKg,
          'benchmarkKg': pull.benchmarkKg,
        },
    ],
  };
}

class WorkoutRecord {
  const WorkoutRecord({
    required this.date,
    required this.tool,
    required this.hand,
    required this.section,
    required this.targetForceKg,
    required this.forceKg,
    required this.restSeconds,
    required this.targetSeconds,
    required this.actualSeconds,
    required this.perceivedExertion,
    required this.notes,
  });

  WorkoutRecord.fromJson(Map<String, Object?> json)
    : date = DateTime.parse(json['date']! as String),
      tool = json['tool']! as String,
      hand = Hand.values.byName(json['hand']! as String),
      section = CurveSection.values.byName(json['section']! as String),
      targetForceKg = (json['targetForceKg']! as num).toDouble(),
      forceKg = (json['forceKg'] as num?)?.toDouble(),
      restSeconds = json['restSeconds']! as int,
      targetSeconds = (json['targetSeconds']! as List).cast<int>(),
      actualSeconds = [
        for (final seconds in json['actualSeconds']! as List)
          (seconds as num).toDouble(),
      ],
      perceivedExertion = json['perceivedExertion']! as int,
      notes = json['notes']! as String;

  final DateTime date;
  final String tool;
  final Hand hand;
  final CurveSection section;
  final double targetForceKg;

  /// Mean measured force over the hangs, null when every rep was skipped.
  final double? forceKg;
  final int restSeconds;

  /// The first target is the one the ideal force curve predicts at [forceKg].
  final List<int> targetSeconds;
  final List<double> actualSeconds;

  /// 1 (easy) to 10 (extreme).
  final int perceivedExertion;
  final String notes;

  Map<String, Object?> toJson() => {
    'date': date.toIso8601String(),
    'tool': tool,
    'hand': hand.name,
    'section': section.name,
    'targetForceKg': targetForceKg,
    'forceKg': forceKg,
    'restSeconds': restSeconds,
    'targetSeconds': targetSeconds,
    'actualSeconds': actualSeconds,
    'perceivedExertion': perceivedExertion,
    'notes': notes,
  };

  /// Hangs held, or the targets when every rep was skipped.
  List<double> get _hangSeconds {
    final held = actualSeconds.where((seconds) => seconds > 0).toList();
    return held.isNotEmpty
        ? held
        : [for (final seconds in targetSeconds) seconds.toDouble()];
  }

  /// Mean target of the reps done: a workout ended by a disconnect has fewer
  /// hangs than targets.
  double get meanTargetSeconds =>
      targetSeconds.take(actualSeconds.length).reduce((a, b) => a + b) /
      actualSeconds.length;

  double get meanActualSeconds =>
      actualSeconds.reduce((a, b) => a + b) / actualSeconds.length;

  /// Mean of each rep's actual minus target hang.
  double get meanDeltaSeconds => meanActualSeconds - meanTargetSeconds;

  double get meanHangSeconds =>
      _hangSeconds.reduce((a, b) => a + b) / _hangSeconds.length;

  /// The workout on the force curve, by its first hang.
  CurvePoint? get curvePoint {
    final forceKg = this.forceKg;
    if (forceKg == null) return null;
    return (forceKg: forceKg, firstHangSeconds: _hangSeconds.first);
  }

  /// The workout with its point, null without one.
  (WorkoutRecord, CurvePoint)? get withPoint => switch (curvePoint) {
    final point? => (this, point),
    null => null,
  };
}

@freezed
sealed class WorkoutPlan with _$WorkoutPlan {
  const WorkoutPlan._();

  const factory WorkoutPlan({
    required String tool,
    required Hand hand,
    required CurveSection section,
    required double benchmarkKg,
    required int firstHangSeconds,
    required int reps,
    required int restSeconds,

    /// Null follows the section's rep ratios.
    EnergySystems? energySystems,
  }) = _WorkoutPlan;

  /// The section's defaults for a benchmark.
  factory WorkoutPlan.forSection({
    required String tool,
    required Hand hand,
    required CurveSection section,
    required double benchmarkKg,
  }) => WorkoutPlan(
    tool: tool,
    hand: hand,
    section: section,
    benchmarkKg: benchmarkKg,
    firstHangSeconds: section.firstRepSeconds,
    reps: section.reps,
    restSeconds: defaultRestSeconds,
  );

  double get targetForceKg => section.targetForceKg(benchmarkKg);

  List<int> targets([double? firstHangActualSeconds]) => repTargetSeconds(
    section,
    reps: reps,
    firstHangSeconds: firstHangSeconds,
    firstHangActualSeconds: firstHangActualSeconds,
    energySystems: energySystems,
  );

  int get totalSeconds =>
      targets().reduce((a, b) => a + b) + (reps - 1) * restSeconds;
}

/// The workout setup choices, kept while switching tabs. Null follows the
/// default: the latest benchmark's tool and hand, the suggested section and
/// its template.
@freezed
sealed class WorkoutSetup with _$WorkoutSetup {
  const factory WorkoutSetup({
    String? tool,
    Hand? hand,
    CurveSection? section,
    WorkoutPlan? plan,
  }) = _WorkoutSetup;
}

/// Each hold waits for the pull, so the workout starts with the first one.
enum WorkoutPhase { idle, hold, rest, done }

enum WarmupKind {
  climbing('Before climbing'),
  training('Before training'),
  readiness('Readiness check');

  const WarmupKind(this.label);

  final String label;
}

/// One hold of a warm-up, after [restSeconds] of rest: [forceKg] for
/// [seconds], or without a force, as hard as possible.
typedef WarmupStep = ({
  String tool,
  Hand hand,
  double benchmarkKg,
  double? forceKg,
  int seconds,
  int restSeconds,
});

/// A warm-up timer: each step rests, then holds once the pull starts, and
/// ends at its target or when released.
@freezed
sealed class WarmupState with _$WarmupState {
  const WarmupState._();

  const factory WarmupState({
    WarmupKind? kind,
    @Default([]) List<WarmupStep> steps,
    @Default(WorkoutPhase.idle) WorkoutPhase phase,

    /// Current step, or the next one during its rest. 0-based.
    @Default(0) int step,
    @Default(0) int restRemainingSeconds,
    @Default(false) bool paused,
    @Default(false) bool holding,
    @Default(false) bool waitingForRelease,
    @Default(0.0) double heldSeconds,
    @Default([]) List<FlSpot> forceTrace,

    /// Best 5 s of each step done, null for a hold at a force or a maximal
    /// pull under 5 s.
    @Default([]) List<double?> bestKg,

    /// The readiness check is stored in the training log.
    @Default(false) bool saved,
    WorkoutEnd? endedEarly,
  }) = _WarmupState;

  bool get isRunning =>
      phase != WorkoutPhase.idle && phase != WorkoutPhase.done;

  WarmupStep get current => steps[step];
}

/// Why a workout ended before its last rep.
enum WorkoutEnd { disconnected, measurementFailed }

@freezed
sealed class WorkoutState with _$WorkoutState {
  const WorkoutState._();

  const factory WorkoutState({
    WorkoutPlan? plan,
    @Default(WorkoutPhase.idle) WorkoutPhase phase,

    /// Current rep, or the last one during a rest. 1-based.
    @Default(1) int rep,
    @Default(0) int restRemainingSeconds,
    @Default(false) bool paused,

    /// The pull passed the threshold, so the current hold counts.
    @Default(false) bool holding,

    /// The current rep waits for a load left on to drop.
    @Default(false) bool waitingForRelease,
    @Default(0.0) double heldSeconds,

    /// The latest force of the workout, through the holds and rests.
    @Default([]) List<FlSpot> forceTrace,
    @Default([]) List<double> actualSeconds,

    /// Mean force of each rep, null for a rep not held.
    @Default([]) List<double?> repForcesKg,
    @Default(false) bool saved,

    /// Set when the workout ended before its last rep.
    WorkoutEnd? endedEarly,
  }) = _WorkoutState;

  bool get isRunning =>
      phase != WorkoutPhase.idle && phase != WorkoutPhase.done;

  /// Targets, adapted to the first hang once it is over.
  List<int> get targets => plan!.targets(actualSeconds.firstOrNull);

  /// Mean force over every hang, weighted by its duration.
  double? get meanForceKg {
    var seconds = 0.0;
    var kgSeconds = 0.0;
    for (final (rep, forceKg) in repForcesKg.indexed) {
      if (forceKg == null) continue;
      seconds += actualSeconds[rep];
      kgSeconds += forceKg * actualSeconds[rep];
    }
    return seconds == 0 ? null : kgSeconds / seconds;
  }
}
