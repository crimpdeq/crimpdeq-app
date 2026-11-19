import 'dart:async';
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../analysis/force_trace.dart';
import '../analysis/hold_tracker.dart';
import '../analysis/opengrips_curve.dart';
import '../models/progressor_models.dart';
import '../models/training_models.dart';
import 'progressor_provider.dart';
import 'schedule_provider.dart';
import 'warmup_provider.dart';
import 'workout_feedback_provider.dart';

typedef TrainingLog = ({
  List<Benchmark> benchmarks,
  List<WorkoutRecord> workouts,
  List<ReadinessCheck> readiness,
});

/// Benchmarks, workouts and readiness checks, stored on this device.
final trainingLogProvider =
    AsyncNotifierProvider<TrainingLogNotifier, TrainingLog>(
      TrainingLogNotifier.new,
    );

class TrainingLogNotifier extends AsyncNotifier<TrainingLog> {
  static const _benchmarksKey = 'training.benchmarks';
  static const _workoutsKey = 'training.workouts';
  static const _readinessKey = 'training.readiness';

  @override
  Future<TrainingLog> build() async {
    final prefs = await SharedPreferences.getInstance();
    List<T> read<T>(String key, T Function(Map<String, Object?>) fromJson) => [
      for (final json in jsonDecode(prefs.getString(key) ?? '[]') as List)
        fromJson(json as Map<String, Object?>),
    ];
    return (
      benchmarks: read(_benchmarksKey, Benchmark.fromJson),
      workouts: read(_workoutsKey, WorkoutRecord.fromJson),
      readiness: read(_readinessKey, ReadinessCheck.fromJson),
    );
  }

  Future<void> addBenchmark(Benchmark benchmark) => _update(
    (log) => (
      benchmarks: [...log.benchmarks, benchmark],
      workouts: log.workouts,
      readiness: log.readiness,
    ),
  );

  Future<void> deleteBenchmark(Benchmark benchmark) => _update(
    (log) => (
      benchmarks: [...log.benchmarks]..remove(benchmark),
      workouts: log.workouts,
      readiness: log.readiness,
    ),
  );

  Future<void> addWorkouts(List<WorkoutRecord> workouts) => _update(
    (log) => (
      benchmarks: log.benchmarks,
      workouts: [...log.workouts, ...workouts],
      readiness: log.readiness,
    ),
  );

  /// Deletes [workouts], such as the hands of one workout.
  Future<void> deleteWorkouts(List<WorkoutRecord> workouts) => _update(
    (log) => (
      benchmarks: log.benchmarks,
      workouts: [
        for (final workout in log.workouts)
          if (!workouts.contains(workout)) workout,
      ],
      readiness: log.readiness,
    ),
  );

  Future<void> addReadiness(ReadinessCheck check) => _update(
    (log) => (
      benchmarks: log.benchmarks,
      workouts: log.workouts,
      readiness: [...log.readiness, check],
    ),
  );

  Future<void> deleteReadiness(ReadinessCheck check) => _update(
    (log) => (
      benchmarks: log.benchmarks,
      workouts: log.workouts,
      readiness: [...log.readiness]..remove(check),
    ),
  );

  // The last update, so the next one reads the log after it is stored.
  Future<void> _updated = Future.value();

  /// Applies [change] to the log and stores it, after the pending updates, so
  /// overlapping updates cannot read the same log and drop each other. The
  /// rest notice then follows the stored log, such as a deleted workout.
  Future<void> _update(TrainingLog Function(TrainingLog log) change) {
    final update = _updated.then((_) async {
      final log = change(await future);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_benchmarksKey, jsonEncode(log.benchmarks));
      await prefs.setString(_workoutsKey, jsonEncode(log.workouts));
      await prefs.setString(_readinessKey, jsonEncode(log.readiness));
      state = AsyncData(log);
      try {
        await ref.read(gripperRestProvider.notifier).notifyRestOver();
      } on Exception catch (error) {
        // The log is stored, so the update succeeds: only the notice is off.
        debugPrint('The rest notice did not follow the log: $error');
      }
    });
    // A failed update fails its caller, not the later updates.
    _updated = update.catchError((_) {});
    return update;
  }
}

/// Body weights, one per day in day order, stored on this device.
final bodyWeightsProvider =
    AsyncNotifierProvider<BodyWeightsNotifier, List<BodyWeight>>(
      BodyWeightsNotifier.new,
    );

class BodyWeightsNotifier extends AsyncNotifier<List<BodyWeight>> {
  static const _key = 'training.bodyWeights';

  @override
  Future<List<BodyWeight>> build() async => [
    for (final json in jsonDecode(
      (await SharedPreferences.getInstance()).getString(_key) ?? '[]',
    ) as List)
      BodyWeight.fromJson(json as Map<String, Object?>),
  ];

  /// Logs [weight], replacing the one of its day.
  Future<void> add(BodyWeight weight) => _update(
    (weights) => [
      for (final other in weights)
        if (other.day != weight.day) other,
      weight,
    ]..sort((a, b) => a.day.compareTo(b.day)),
  );

  Future<void> delete(BodyWeight weight) =>
      _update((weights) => [...weights]..remove(weight));

  /// Reads and sets the state with nothing between them, so overlapping
  /// updates cannot drop each other.
  Future<void> _update(
    List<BodyWeight> Function(List<BodyWeight> weights) change,
  ) async {
    await future;
    final weights = change(state.requireValue);
    state = AsyncData(weights);
    await (await SharedPreferences.getInstance()).setString(
      _key,
      jsonEncode(weights),
    );
  }
}

/// Force a hold counts above, stored on this device. Above it the hold timer
/// starts, and it ends once the force stays at or below it.
final holdThresholdProvider =
    AsyncNotifierProvider<HoldThresholdNotifier, double>(
      HoldThresholdNotifier.new,
    );

class HoldThresholdNotifier extends AsyncNotifier<double> {
  static const _key = 'training.holdThresholdKg';

  @override
  Future<double> build() async =>
      (await SharedPreferences.getInstance()).getDouble(_key) ??
      HoldTracker.defaultThresholdKg;

  Future<void> set(double kg) async {
    state = AsyncData(kg);
    await (await SharedPreferences.getInstance()).setDouble(_key, kg);
  }
}

final workoutSetupProvider =
    NotifierProvider<WorkoutSetupNotifier, WorkoutSetup>(
      WorkoutSetupNotifier.new,
    );

class WorkoutSetupNotifier extends Notifier<WorkoutSetup> {
  @override
  WorkoutSetup build() => const WorkoutSetup();

  /// Another tool or hand has its own suggestion and template.
  void selectTool(String? tool) =>
      state = WorkoutSetup(tool: tool, hand: state.hand, hands: state.hands);

  void selectHand(Hand? hand) =>
      state = WorkoutSetup(tool: state.tool, hand: hand, hands: state.hands);

  void selectHands(WorkoutHands hands) => state = state.copyWith(hands: hands);

  void selectSection(CurveSection section) =>
      state = state.copyWith(section: section, plan: null);

  void updatePlan(WorkoutPlan plan) => state = state.copyWith(plan: plan);
}

/// Measures for a workout, warm-up or benchmark pull, which take the same
/// samples, then calls [begin] with whether this call started the
/// measurement, so the session stops it again. Nothing begins when the
/// device does not measure or [otherRunning] does, such as a workout started
/// on another page while this start awaited the device: checked right
/// before [begin], so no other start can come between them.
Future<void> startSession(
  Ref ref, {
  required bool Function() otherRunning,
  required void Function(bool started) begin,
}) async {
  final started = !ref.read(progressorProvider).measurement.isMeasuring;
  if (started) await ref.read(progressorProvider.notifier).startMeasurement();
  if (!ref.read(progressorProvider).measurement.isMeasuring) return;
  if (!otherRunning()) {
    begin(started);
    return;
  }
  // The other session measures again once this stop reaches it.
  if (started) await ref.read(progressorProvider.notifier).stopMeasurement();
}

/// The benchmark form's tool and hand, kept while switching parts, so a
/// recorded pull saves under the ones it was recorded with. Null follows the
/// latest benchmark.
typedef BenchmarkSelection = ({String? tool, Hand? hand});

final benchmarkSelectionProvider =
    NotifierProvider<BenchmarkSelectionNotifier, BenchmarkSelection>(
      BenchmarkSelectionNotifier.new,
    );

class BenchmarkSelectionNotifier extends Notifier<BenchmarkSelection> {
  @override
  BenchmarkSelection build() => (tool: null, hand: null);

  void selectTool(String? tool) => state = (tool: tool, hand: state.hand);

  void selectHand(Hand? hand) => state = (tool: state.tool, hand: hand);
}

typedef BenchmarkRecording = ({
  bool recording,
  double elapsedSeconds,
  double? bestKg,

  /// The latest force of the pull.
  List<FlSpot> trace,
});

const BenchmarkRecording _noRecording = (
  recording: false,
  elapsedSeconds: 0,
  bestKg: null,
  trace: [],
);

/// Records a benchmark pull: the highest mean force over 5 s.
final benchmarkRecorderProvider =
    NotifierProvider<BenchmarkRecorder, BenchmarkRecording>(
      BenchmarkRecorder.new,
    );

class BenchmarkRecorder extends Notifier<BenchmarkRecording> {
  StreamSubscription<List<WeightMeasurement>>? _samples;
  bool _startedMeasurement = false;
  // Recording starts after the measurement does: a second tap meanwhile
  // would subscribe twice.
  bool _starting = false;
  // A failed restart sets the measurement off again, which would restart it.
  bool _restarting = false;

  @override
  BenchmarkRecording build() {
    ref.onDispose(() => _samples?.cancel());
    ref.listen(
      progressorProvider.select(
        (state) => (
          isConnected: state.connection.isConnected,
          isMeasuring: state.measurement.isMeasuring,
        ),
      ),
      (_, device) {
        if (!state.recording) return;
        if (!device.isConnected) {
          // The measurement ended with the connection.
          _startedMeasurement = false;
          stop();
        } else if (!device.isMeasuring) {
          // Stopped elsewhere, such as in the Measurements tab.
          _restartMeasurement();
        }
      },
    );
    return _noRecording;
  }

  /// Ends the pull when the measurement does not start again, instead of
  /// retrying on every failure.
  Future<void> _restartMeasurement() async {
    if (_restarting) return;
    _restarting = true;
    _startedMeasurement = true;
    await ref.read(progressorProvider.notifier).startMeasurement();
    _restarting = false;
    if (!state.recording ||
        ref.read(progressorProvider).measurement.isMeasuring) {
      return;
    }
    _startedMeasurement = false;
    await stop();
  }

  Future<void> start() async {
    if (state.recording || _starting) return;
    _starting = true;
    try {
      await startSession(
        ref,
        otherRunning: () =>
            ref.read(workoutProvider).isRunning ||
            ref.read(warmupProvider).isRunning,
        begin: (started) {
          _startedMeasurement = started;
          final fiveSecondMax = FiveSecondMax();
          final trace = ForceTrace();
          state = (
            recording: true,
            elapsedSeconds: 0,
            bestKg: null,
            trace: const [],
          );
          _samples = ref.read(progressorProvider.notifier).sampleBatches.listen(
            (samples) {
              samples.forEach(fiveSecondMax.add);
              trace.addAll(samples);
              // Publish at the displayed resolution, a tenth of a second.
              final next = (
                recording: true,
                elapsedSeconds: (fiveSecondMax.elapsedUs ~/ 100000) / 10,
                bestKg: fiveSecondMax.bestKg,
                trace: trace.points,
              );
              if (next != state) state = next;
            },
          );
        },
      );
    } finally {
      _starting = false;
    }
  }

  Future<void> stop() async {
    _samples?.cancel();
    _samples = null;
    // Not recording first, so stopping the measurement does not restart it.
    state = (
      recording: false,
      elapsedSeconds: state.elapsedSeconds,
      bestKg: state.bestKg,
      trace: state.trace,
    );
    if (_startedMeasurement) {
      _startedMeasurement = false;
      await ref.read(progressorProvider.notifier).stopMeasurement();
    }
  }

  void clear() => state = _noRecording;
}

/// The OpenGrips workout timer, with the Crimpdeq as the weight: holds at the
/// target force separated by rests. Each hold waits for the pull above the
/// threshold, and the rests count down. With both hands, each hand rests
/// since its own previous hold, so alternating holds the other hand during
/// the rest.
final workoutProvider = NotifierProvider<WorkoutNotifier, WorkoutState>(
  WorkoutNotifier.new,
);

class WorkoutNotifier extends Notifier<WorkoutState> {
  late WorkoutFeedback _feedback;
  bool _screenKeptOn = false;
  // Counts each hand's rest through the workout.
  Timer? _ticker;
  // Since each hand's previous hold, or the start.
  final _restedSeconds = {for (final hand in Hand.values) hand: 0};
  StreamSubscription<List<WeightMeasurement>>? _samples;
  HoldTracker? _hold;
  ForceTrace _trace = ForceTrace();
  double _thresholdKg = HoldTracker.defaultThresholdKg;
  bool _startedMeasurement = false;
  // The workout runs after the measurement starts: a second tap meanwhile
  // would subscribe twice.
  bool _starting = false;
  // A failed restart sets the measurement off again, which would restart it.
  bool _restarting = false;
  // The workout is saved once stored: a second tap meanwhile would store it
  // twice.
  bool _saving = false;
  RestLoad? _restLoad;

  @override
  WorkoutState build() {
    _feedback = ref.read(workoutFeedbackProvider);
    ref.onDispose(() {
      _cancel();
      if (_screenKeptOn) _feedback.keepScreenOn(false);
    });
    listenSelf((_, next) {
      if (next.isRunning == _screenKeptOn) return;
      _screenKeptOn = next.isRunning;
      _feedback.keepScreenOn(_screenKeptOn);
    });
    ref.listen(
      progressorProvider.select(
        (state) => (
          isConnected: state.connection.isConnected,
          isMeasuring: state.measurement.isMeasuring,
        ),
      ),
      (_, device) {
        if (!state.isRunning) return;
        if (!device.isConnected) {
          _endEarly(WorkoutEnd.disconnected);
        } else if (!device.isMeasuring) {
          // Stopped elsewhere, such as in the Measurements tab: the holds need
          // the samples, so measure again until the workout ends.
          _restartMeasurement();
        }
      },
    );
    return const WorkoutState();
  }

  /// Ends the workout when the measurement does not start again, instead of
  /// retrying on every failure.
  Future<void> _restartMeasurement() async {
    if (_restarting) return;
    _restarting = true;
    _startedMeasurement = true;
    await ref.read(progressorProvider.notifier).startMeasurement();
    _restarting = false;
    if (!state.isRunning ||
        ref.read(progressorProvider).measurement.isMeasuring) {
      return;
    }
    _endEarly(WorkoutEnd.measurementFailed);
  }

  /// Starts a workout of [plans], one per hand.
  Future<void> start(
    List<WorkoutPlan> plans, {
    bool alternating = false,
  }) async {
    final hands = {for (final plan in plans) plan.hand};
    if (plans.isEmpty || hands.length != plans.length) {
      throw ArgumentError('A workout needs one plan per hand, not $plans.');
    }
    // Alternating fits the other hand's holds in each hand's rests.
    if (alternating) {
      for (final plan in plans) {
        for (final other in plans.where((other) => other.hand != plan.hand)) {
          final needed = alternateRestSeconds(other);
          if (plan.restSeconds < needed) {
            throw ArgumentError(
              'Alternating needs ${plan.hand.label} hand rests of at least '
              '$needed s, not ${plan.restSeconds} s.',
            );
          }
        }
      }
    }
    if (state.isRunning || _starting) return;
    _starting = true;
    try {
      // Loaded before the first cue and hold, which read them.
      await ref.read(soundsMutedProvider.future);
      final thresholdKg = await ref.read(holdThresholdProvider.future);
      await startSession(
        ref,
        otherRunning: () =>
            ref.read(warmupProvider).isRunning ||
            ref.read(benchmarkRecorderProvider).recording,
        begin: (started) {
          _startedMeasurement = started;
          _thresholdKg = thresholdKg;
          _trace = ForceTrace();
          _restLoad = null;
          _samples = ref
              .read(progressorProvider.notifier)
              .sampleBatches
              .listen(addSamples);
          state = WorkoutState(
            plans: plans,
            alternating: alternating,
            startedAt: DateTime.now(),
          );
          _restedSeconds.updateAll((_, _) => 0);
          _startTicker();
          _next();
        },
      );
    } finally {
      _starting = false;
    }
  }

  /// Traces the force, and times the current hold with the samples.
  void addSamples(List<WeightMeasurement> samples) {
    if (!state.isRunning) return;
    _trace.addAll(samples);
    if (!identical(_trace.points, state.forceTrace)) {
      state = state.copyWith(forceTrace: _trace.points);
    }
    switch (state.phase) {
      case WorkoutPhase.hold:
        _trackHold(samples);
      case WorkoutPhase.rest:
        samples.forEach(_restLoad!.add);
      case WorkoutPhase.idle || WorkoutPhase.done:
        return;
    }
  }

  void _trackHold(List<WeightMeasurement> samples) {
    final hold = _hold!;
    samples.forEach(hold.add);
    if (hold.failed) {
      finishRep();
      return;
    }
    // Publish at the displayed resolution, a tenth of a second.
    final heldSeconds = (hold.heldSeconds * 10).floor() / 10;
    final target = state.target;
    if (state.heldSeconds < target && heldSeconds >= target) {
      _cue(WorkoutCue.go);
    }
    if (hold.started != state.holding ||
        hold.waitForRelease != state.waitingForRelease ||
        heldSeconds != state.heldSeconds) {
      state = state.copyWith(
        holding: hold.started,
        waitingForRelease: hold.waitForRelease,
        heldSeconds: heldSeconds,
      );
    }
  }

  /// Ends the current hold with the time held so far.
  void finishRep() => _endRep(_hold?.heldSeconds ?? 0, _hold?.meanKg);

  /// Skips the current hold, which counts as not held, or the current rest.
  void skip() {
    switch (state.phase) {
      case WorkoutPhase.hold:
        _endRep(0, null);
      case WorkoutPhase.rest:
        _startHold(afterRest: true);
      case WorkoutPhase.idle || WorkoutPhase.done:
        return;
    }
  }

  /// Takes back the rep just done, such as a pull ended by accident, during
  /// the rest after it: the rep holds again at once, and a first rep scales
  /// the later targets to its new hold instead.
  void redoRep() {
    if (state.phase != WorkoutPhase.rest || state.actualSeconds.isEmpty) {
      return;
    }
    final done = state.actualSeconds.length - 1;
    state = state.copyWith(
      actualSeconds: state.actualSeconds.sublist(0, done),
      repForcesKg: state.repForcesKg.sublist(0, done),
    );
    _startHold(afterRest: false);
  }

  /// Pauses or resumes the rests. Holds follow the force.
  void togglePause() => state = state.copyWith(paused: !state.paused);

  /// Abandons the workout.
  Future<void> stop() async {
    // Idle first, so stopping the measurement does not restart it.
    state = const WorkoutState();
    await _release();
  }

  /// Ends the workout without the device's samples, with the reps done so far
  /// to save, or abandons it before the first rep.
  void _endEarly(WorkoutEnd reason) {
    _cancel();
    // The measurement ended with the connection, or did not start again.
    _startedMeasurement = false;
    state = state.actualSeconds.isEmpty
        ? const WorkoutState()
        : state.copyWith(
            phase: WorkoutPhase.done,
            endedEarly: reason,
            endedAt: DateTime.now(),
          );
  }

  /// Saves the finished workout, one record per hand with reps done. The
  /// first target becomes the one the ideal force curve predicts at the
  /// measured force, like OpenGrips does.
  Future<void> save({
    required int perceivedExertion,
    required String notes,
  }) async {
    if (state.saved || _saving) return;
    _saving = true;
    final workout = state;
    final date = DateTime.now();
    try {
      await ref.read(trainingLogProvider.notifier).addWorkouts([
        for (final (index, plan) in workout.plans.indexed)
          if (workout.actualSecondsOf(index).isNotEmpty)
            WorkoutRecord(
              date: date,
              tool: plan.tool,
              hand: plan.hand,
              section: plan.section,
              targetForceKg: plan.targetForceKg,
              forceKg: workout.meanForceKgOf(index),
              restSeconds: plan.restSeconds,
              targetSeconds: _savedTargets(workout, index),
              actualSeconds: workout.actualSecondsOf(index),
              repForcesKg: workout.repForcesKgOf(index),
              durationSeconds: workout.endedAt!
                  .difference(workout.startedAt!)
                  .inSeconds,
              perceivedExertion: perceivedExertion,
              notes: notes,
            ),
      ]);
      // Leaving the results meanwhile starts over with another workout.
      if (identical(state, workout)) state = state.copyWith(saved: true);
    } finally {
      _saving = false;
    }
  }

  static List<int> _savedTargets(WorkoutState workout, int plan) {
    final targets = [...workout.targetsOf(plan)];
    final forceKg = workout.meanForceKgOf(plan);
    if (forceKg != null && forceKg > 0) {
      targets[0] = idealFirstHangSeconds(
        forceKg,
        workout.plans[plan].benchmarkKg,
      );
    }
    return targets;
  }

  /// Returns to the setup after the results.
  void reset() => state = const WorkoutState();

  /// Counts each hand's rest in whole seconds from now, so the hand that
  /// just held rests its full seconds, the other one up to a second more.
  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  /// The rest the current rep's hand still needs.
  int get _restLeft =>
      state.plan.restBefore(state.rep) - _restedSeconds[state.plan.hand]!;

  /// Counts each hand's rest, and the current rest down to its hold.
  void _tick() {
    if (state.paused) return;
    _restedSeconds.updateAll((_, seconds) => seconds + 1);
    if (state.phase != WorkoutPhase.rest) return;
    final remaining = _restLeft;
    if (remaining <= 0) {
      _startHold(afterRest: true);
      return;
    }
    state = state.copyWith(restRemainingSeconds: remaining);
    _restCue(remaining);
  }

  /// Rests before the current rep until its hand has rested enough, or with
  /// both hands, holds at once when the other hand's holds covered it.
  void _next() {
    _hold = null;
    final remaining = _restLeft;
    if (remaining <= 0) {
      _startHold(afterRest: false);
      return;
    }
    _restLoad = RestLoad(thresholdKg: _thresholdKg);
    state = state.copyWith(
      phase: WorkoutPhase.rest,
      restRemainingSeconds: remaining,
    );
    _restCue(remaining);
  }

  /// Warns at 5 s of rest left, then counts the last 2 s down.
  void _restCue(int remaining) {
    if (remaining == 5) _cue(WorkoutCue.restWarning);
    if (remaining <= 2) _cue(WorkoutCue.countdown);
  }

  void _cue(WorkoutCue cue) {
    if (ref.read(soundsMutedProvider).value ?? false) return;
    _feedback.play(cue);
  }

  /// Starts the current rep's hold, which waits for the pull above the
  /// threshold however long the rest was. At the start or straight after
  /// the previous hold, whose pull may still be on, it waits for any load,
  /// such as an offset, to drop first. Its first sample shows whether there
  /// is one.
  void _startHold({required bool afterRest}) {
    final leftOn = _restLoad?.leftOn ?? false;
    _restLoad = null;
    _hold = HoldTracker(
      thresholdKg: _thresholdKg,
      waitForRelease: !afterRest || leftOn,
    );
    state = state.copyWith(
      phase: WorkoutPhase.hold,
      paused: false,
      holding: false,
      waitingForRelease: leftOn,
      heldSeconds: 0,
    );
    _cue(WorkoutCue.go);
  }

  void _endRep(double heldSeconds, double? forceKg) {
    if (state.phase != WorkoutPhase.hold) return;
    _restedSeconds[state.plan.hand] = 0;
    _startTicker();
    final last = state.actualSeconds.length + 1 == state.schedule.length;
    state = state.copyWith(
      phase: last ? WorkoutPhase.done : WorkoutPhase.hold,
      actualSeconds: [...state.actualSeconds, heldSeconds],
      repForcesKg: [...state.repForcesKg, forceKg],
      endedAt: last ? DateTime.now() : null,
    );
    if (!last) {
      _next();
      return;
    }
    _hold = null;
    unawaited(_release());
  }

  void _cancel() {
    _ticker?.cancel();
    _ticker = null;
    _hold = null;
    _samples?.cancel();
    _samples = null;
  }

  /// Stops timing, and the measurement if the workout started it.
  Future<void> _release() async {
    _cancel();
    if (_startedMeasurement) {
      _startedMeasurement = false;
      await ref.read(progressorProvider.notifier).stopMeasurement();
    }
  }
}
