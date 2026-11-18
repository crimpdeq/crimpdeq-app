import 'dart:math';

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

/// When the rest after the latest workout, with another tool than [tool],
/// ends: HoG Academy sets an hour between gripper workouts. Null without a
/// rest, such as after a workout with [tool], which a workout of the other
/// hand continues.
DateTime? gripperRestEnd(
  List<WorkoutRecord> workouts,
  String tool,
  Duration rest,
) {
  final latest = workouts.lastOrNull;
  if (latest == null || latest.tool == tool || rest == Duration.zero) {
    return null;
  }
  return latest.date.add(rest);
}

/// The tools of [tools] without a workout on the local day of [now]: a grip
/// day trains both grippers.
List<String> toolsLeftToday(
  List<WorkoutRecord> workouts,
  List<String> tools,
  DateTime now,
) {
  DateTime day(DateTime date) {
    final local = date.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  final today = day(now);
  return [
    for (final tool in tools)
      if (!workouts.any(
        (workout) => workout.tool == tool && day(workout.date) == today,
      ))
        tool,
  ];
}

/// A weekly reminder to train [tool] on [weekdays] at [hour]:[minute], local
/// time.
class Reminder {
  const Reminder({
    required this.tool,
    required this.weekdays,
    required this.hour,
    required this.minute,
  });

  Reminder.fromJson(Map<String, Object?> json)
    : tool = json['tool']! as String,
      weekdays = (json['weekdays']! as List).cast<int>(),
      hour = json['hour']! as int,
      minute = json['minute']! as int;

  final String tool;

  /// [DateTime.monday] to [DateTime.sunday], in order.
  final List<int> weekdays;
  final int hour;
  final int minute;

  Reminder copyWith({
    String? tool,
    List<int>? weekdays,
    int? hour,
    int? minute,
  }) => Reminder(
    tool: tool ?? this.tool,
    weekdays: weekdays ?? this.weekdays,
    hour: hour ?? this.hour,
    minute: minute ?? this.minute,
  );

  Map<String, Object?> toJson() => {
    'tool': tool,
    'weekdays': weekdays,
    'hour': hour,
    'minute': minute,
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

  /// Rest of the hand since its previous rep: the first rep starts rested.
  int restBefore(int rep) => rep == 1 ? 0 : restSeconds;
}

/// Which hands a workout trains: the selected one, or both, starting with it.
enum WorkoutHands {
  one('One hand'),

  /// Every rep of the first hand, then of the other.
  inTurn('Both in turn'),

  /// Each rep with the first hand, then the other: the other hand holds
  /// during each rest, which [alternateRestSeconds] keeps long enough.
  alternating('Alternate');

  const WorkoutHands(this.label);

  final String label;
}

/// One rep of a workout: the index of its plan, and the rep, 1-based.
typedef WorkoutRep = ({int plan, int rep});

/// The reps of [plans] in order: each plan's reps in turn, or with
/// [alternating], every plan's rep before the next rep.
List<WorkoutRep> workoutSchedule(
  List<WorkoutPlan> plans, {
  required bool alternating,
}) {
  if (!alternating) {
    return [
      for (final (index, plan) in plans.indexed)
        for (var rep = 1; rep <= plan.reps; rep++) (plan: index, rep: rep),
    ];
  }
  final reps = plans.map((plan) => plan.reps).reduce(max);
  return [
    for (var rep = 1; rep <= reps; rep++)
      for (final (index, plan) in plans.indexed)
        if (rep <= plan.reps) (plan: index, rep: rep),
  ];
}

/// Time to change to the other hand and back during a rest between reps.
const alternateMarginSeconds = 2 * handChangeSeconds;

/// Shortest rest between reps that alternating with [other] needs: its
/// longest hold and [alternateMarginSeconds]. A shorter rest would be over
/// before the other hand's hold, so the hand would rest longer than planned.
int alternateRestSeconds(WorkoutPlan other) =>
    other.targets().reduce(max) + alternateMarginSeconds;

/// Estimated time of a workout of [plans] at the planned targets.
int workoutSeconds(List<WorkoutPlan> plans, {required bool alternating}) =>
    holdsSeconds([
      for (final (:plan, :rep) in workoutSchedule(
        plans,
        alternating: alternating,
      ))
        (
          hand: plans[plan].hand,
          seconds: plans[plan].targets()[rep - 1],
          restSeconds: plans[plan].restBefore(rep),
        ),
    ]);

/// Time to change hands or tools, for the estimated totals: each hold waits
/// for the pull.
const handChangeSeconds = 5;

/// A hold of [hand] for [seconds], once the hand has rested [restSeconds]
/// since its previous hold or the start.
typedef TimedHold = ({Hand hand, int seconds, int restSeconds});

/// Estimated time of [holds] in order, with [handChangeSeconds] between the
/// holds and the rests that the other hand's holds do not cover.
int holdsSeconds(List<TimedHold> holds) {
  var seconds = 0;
  final restedFrom = {for (final hand in Hand.values) hand: 0};
  for (final (index, hold) in holds.indexed) {
    final ready = restedFrom[hold.hand]! + hold.restSeconds;
    final changed = index == 0 ? 0 : seconds + handChangeSeconds;
    seconds = max(changed, ready) + hold.seconds;
    restedFrom[hold.hand] = seconds;
  }
  return seconds;
}

/// The workout setup choices, kept while switching tabs. Null follows the
/// default: the latest benchmark's tool and hand, the suggested section and
/// its template.
@freezed
sealed class WorkoutSetup with _$WorkoutSetup {
  const factory WorkoutSetup({
    String? tool,
    Hand? hand,
    @Default(WorkoutHands.one) WorkoutHands hands,
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

/// One hold of a warm-up: [forceKg] for [seconds], or without a force, as
/// hard as possible. Its hand rests [restSeconds] first, since its previous
/// hold or the start of the warm-up.
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

    /// Current step, or the next one during its hand's rest. 0-based.
    @Default(0) int step,

    /// The rest of the step's hand, or once a training warm-up is done, the
    /// rest before the workout.
    @Default(0) int restRemainingSeconds,
    @Default(false) bool paused,
    @Default(false) bool holding,
    @Default(false) bool waitingForRelease,
    @Default(0.0) double heldSeconds,

    /// The hold pulls well over its target force.
    @Default(false) bool overshooting,
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
    /// One plan per hand, in the order of their first reps.
    @Default([]) List<WorkoutPlan> plans,

    /// The hands take turns rep by rep, instead of plan by plan.
    @Default(false) bool alternating,
    @Default(WorkoutPhase.idle) WorkoutPhase phase,

    /// The rest the current rep's hand still needs.
    @Default(0) int restRemainingSeconds,
    @Default(false) bool paused,

    /// The pull passed the threshold, so the current hold counts.
    @Default(false) bool holding,

    /// The current rep waits for a load left on to drop.
    @Default(false) bool waitingForRelease,
    @Default(0.0) double heldSeconds,

    /// The latest force of the workout, through the holds and rests.
    @Default([]) List<FlSpot> forceTrace,

    /// Time held in each rep done, in the [schedule] order.
    @Default([]) List<double> actualSeconds,

    /// Mean force of each rep done, null for a rep not held.
    @Default([]) List<double?> repForcesKg,
    @Default(false) bool saved,

    /// Set when the workout ended before its last rep.
    WorkoutEnd? endedEarly,
  }) = _WorkoutState;

  bool get isRunning =>
      phase != WorkoutPhase.idle && phase != WorkoutPhase.done;

  List<WorkoutRep> get schedule =>
      workoutSchedule(plans, alternating: alternating);

  /// The rep after those done: the current one, or the next one during a
  /// rest.
  WorkoutRep get current => schedule[actualSeconds.length];

  WorkoutPlan get plan => plans[current.plan];

  int get rep => current.rep;

  /// The current rep's target.
  int get target => targetsOf(current.plan)[rep - 1];

  /// Indexes of the reps done with plan [plan].
  Iterable<int> _repsDoneOf(int plan) => [
    for (final (index, rep) in schedule.take(actualSeconds.length).indexed)
      if (rep.plan == plan) index,
  ];

  List<double> actualSecondsOf(int plan) => [
    for (final index in _repsDoneOf(plan)) actualSeconds[index],
  ];

  /// Targets of plan [plan], adapted to its first hang once it is over.
  List<int> targetsOf(int plan) =>
      plans[plan].targets(actualSecondsOf(plan).firstOrNull);

  /// Mean force over the hangs of plan [plan], weighted by their duration.
  double? meanForceKgOf(int plan) {
    var seconds = 0.0;
    var kgSeconds = 0.0;
    for (final index in _repsDoneOf(plan)) {
      final forceKg = repForcesKg[index];
      if (forceKg == null) continue;
      seconds += actualSeconds[index];
      kgSeconds += forceKg * actualSeconds[index];
    }
    return seconds == 0 ? null : kgSeconds / seconds;
  }
}
