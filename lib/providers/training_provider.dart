import 'dart:async';
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../analysis/force_trace.dart';
import '../analysis/hold_tracker.dart';
import '../analysis/opengrips_curve.dart';
import '../models/progressor_models.dart';
import '../models/training_models.dart';
import 'progressor_provider.dart';
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

  Future<void> addWorkout(WorkoutRecord workout) => _update(
    (log) => (
      benchmarks: log.benchmarks,
      workouts: [...log.workouts, workout],
      readiness: log.readiness,
    ),
  );

  Future<void> deleteWorkout(WorkoutRecord workout) => _update(
    (log) => (
      benchmarks: log.benchmarks,
      workouts: [...log.workouts]..remove(workout),
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
  /// overlapping updates cannot read the same log and drop each other.
  Future<void> _update(TrainingLog Function(TrainingLog log) change) {
    final update = _updated.then((_) async {
      final log = change(await future);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_benchmarksKey, jsonEncode(log.benchmarks));
      await prefs.setString(_workoutsKey, jsonEncode(log.workouts));
      await prefs.setString(_readinessKey, jsonEncode(log.readiness));
      state = AsyncData(log);
    });
    // A failed update fails its caller, not the later updates.
    _updated = update.catchError((_) {});
    return update;
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
      state = WorkoutSetup(tool: tool, hand: state.hand);

  void selectHand(Hand? hand) =>
      state = WorkoutSetup(tool: state.tool, hand: hand);

  void selectSection(CurveSection section) =>
      state = state.copyWith(section: section, plan: null);

  void updatePlan(WorkoutPlan plan) => state = state.copyWith(plan: plan);
}

/// Starts measuring unless the device already is. Returns whether it measures
/// and whether this call started it, so the caller stops it again.
Future<({bool measuring, bool started})> ensureMeasuring(Ref ref) async {
  if (ref.read(progressorProvider).measurement.isMeasuring) {
    return (measuring: true, started: false);
  }
  await ref.read(progressorProvider.notifier).startMeasurement();
  final measuring = ref.read(progressorProvider).measurement.isMeasuring;
  return (measuring: measuring, started: measuring);
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
      final (:measuring, :started) = await ensureMeasuring(ref);
      if (!measuring) return;
      _startedMeasurement = started;
      final fiveSecondMax = FiveSecondMax();
      final trace = ForceTrace();
      state = (
        recording: true,
        elapsedSeconds: 0,
        bestKg: null,
        trace: const [],
      );
      _samples = ref.read(progressorProvider.notifier).sampleBatches.listen((
        samples,
      ) {
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
      });
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
/// threshold, and the rests count down.
final workoutProvider = NotifierProvider<WorkoutNotifier, WorkoutState>(
  WorkoutNotifier.new,
);

class WorkoutNotifier extends Notifier<WorkoutState> {
  late WorkoutFeedback _feedback;
  bool _screenKeptOn = false;
  Timer? _restTimer;
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

  Future<void> start(WorkoutPlan plan) async {
    if (state.isRunning || _starting) return;
    _starting = true;
    try {
      // Loaded before the first cue and hold, which read them.
      await ref.read(soundsMutedProvider.future);
      final thresholdKg = await ref.read(holdThresholdProvider.future);
      final (:measuring, :started) = await ensureMeasuring(ref);
      if (!measuring) return;
      _startedMeasurement = started;
      _thresholdKg = thresholdKg;
      _trace = ForceTrace();
      _restLoad = null;
      _samples = ref
          .read(progressorProvider.notifier)
          .sampleBatches
          .listen(addSamples);
      state = WorkoutState(plan: plan);
      _startRep(1);
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
    final target = state.targets[state.rep - 1];
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
        _startRep(state.rep + 1);
      case WorkoutPhase.idle || WorkoutPhase.done:
        return;
    }
  }

  /// Pauses or resumes the rest countdown. Holds follow the force.
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
        : state.copyWith(phase: WorkoutPhase.done, endedEarly: reason);
  }

  /// Saves the finished workout. The first target becomes the one the ideal
  /// force curve predicts at the measured force, like OpenGrips does.
  Future<void> save({
    required int perceivedExertion,
    required String notes,
  }) async {
    if (state.saved || _saving) return;
    _saving = true;
    final workout = state;
    try {
      final plan = state.plan!;
      final forceKg = state.meanForceKg;
      final targets = [...state.targets];
      if (forceKg != null && forceKg > 0) {
        targets[0] = idealFirstHangSeconds(forceKg, plan.benchmarkKg);
      }
      await ref
          .read(trainingLogProvider.notifier)
          .addWorkout(
            WorkoutRecord(
              date: DateTime.now(),
              tool: plan.tool,
              hand: plan.hand,
              section: plan.section,
              targetForceKg: plan.targetForceKg,
              forceKg: forceKg,
              restSeconds: plan.restSeconds,
              targetSeconds: targets,
              actualSeconds: state.actualSeconds,
              perceivedExertion: perceivedExertion,
              notes: notes,
            ),
          );
      // Leaving the results meanwhile starts over with another workout.
      if (identical(state, workout)) state = state.copyWith(saved: true);
    } finally {
      _saving = false;
    }
  }

  /// Returns to the setup after the results.
  void reset() => state = const WorkoutState();

  void _rest(int seconds) {
    _hold = null;
    _restLoad = RestLoad(thresholdKg: _thresholdKg);
    state = state.copyWith(
      phase: WorkoutPhase.rest,
      restRemainingSeconds: seconds,
    );
    _restCue(seconds);
    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.paused) return;
      if (state.restRemainingSeconds > 1) {
        final remaining = state.restRemainingSeconds - 1;
        state = state.copyWith(restRemainingSeconds: remaining);
        _restCue(remaining);
        return;
      }
      _startRep(state.rep + 1);
    });
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

  /// Starts a hold, which waits for the pull above the threshold however
  /// long the rest was.
  void _startRep(int rep) {
    _restTimer?.cancel();
    final leftOn = _restLoad?.leftOn ?? false;
    _restLoad = null;
    // Without a rest before it, the first hold waits for any load already on,
    // such as an offset, to drop. Its first sample shows whether there is one.
    _hold = HoldTracker(
      thresholdKg: _thresholdKg,
      waitForRelease: leftOn || rep == 1,
    );
    state = state.copyWith(
      phase: WorkoutPhase.hold,
      rep: rep,
      paused: false,
      holding: false,
      waitingForRelease: leftOn,
      heldSeconds: 0,
    );
    _cue(WorkoutCue.go);
  }

  void _endRep(double heldSeconds, double? forceKg) {
    if (state.phase != WorkoutPhase.hold) return;
    state = state.copyWith(
      actualSeconds: [...state.actualSeconds, heldSeconds],
      repForcesKg: [...state.repForcesKg, forceKg],
    );
    if (state.rep < state.plan!.reps) {
      _rest(state.plan!.restSeconds);
      return;
    }
    _hold = null;
    state = state.copyWith(phase: WorkoutPhase.done);
    unawaited(_release());
  }

  void _cancel() {
    _restTimer?.cancel();
    _restTimer = null;
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
