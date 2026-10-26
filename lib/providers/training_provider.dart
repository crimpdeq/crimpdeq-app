import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../analysis/hold_tracker.dart';
import '../analysis/opengrips_curve.dart';
import '../models/progressor_models.dart';
import '../models/training_models.dart';
import 'progressor_provider.dart';

typedef TrainingLog = ({
  List<Benchmark> benchmarks,
  List<WorkoutRecord> workouts,
});

/// Benchmarks and workouts, stored on this device.
final trainingLogProvider =
    AsyncNotifierProvider<TrainingLogNotifier, TrainingLog>(
      TrainingLogNotifier.new,
    );

class TrainingLogNotifier extends AsyncNotifier<TrainingLog> {
  static const _benchmarksKey = 'training.benchmarks';
  static const _workoutsKey = 'training.workouts';

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
    );
  }

  Future<void> addBenchmark(Benchmark benchmark) async {
    final log = await future;
    await _save(benchmarks: [...log.benchmarks, benchmark]);
  }

  Future<void> deleteBenchmark(Benchmark benchmark) async {
    final log = await future;
    await _save(benchmarks: [...log.benchmarks]..remove(benchmark));
  }

  Future<void> addWorkout(WorkoutRecord workout) async {
    final log = await future;
    await _save(workouts: [...log.workouts, workout]);
  }

  Future<void> _save({
    List<Benchmark>? benchmarks,
    List<WorkoutRecord>? workouts,
  }) async {
    final log = await future;
    final prefs = await SharedPreferences.getInstance();
    if (benchmarks != null) {
      await prefs.setString(_benchmarksKey, jsonEncode(benchmarks));
    }
    if (workouts != null) {
      await prefs.setString(_workoutsKey, jsonEncode(workouts));
    }
    state = AsyncData((
      benchmarks: benchmarks ?? log.benchmarks,
      workouts: workouts ?? log.workouts,
    ));
  }
}

/// Starts measuring unless the device already is. Returns whether it measures
/// and whether this call started it, so the caller stops it again.
Future<({bool measuring, bool started})> _ensureMeasuring(Ref ref) async {
  if (ref.read(progressorProvider).measurement.isMeasuring) {
    return (measuring: true, started: false);
  }
  await ref.read(progressorProvider.notifier).startMeasurement();
  final measuring = ref.read(progressorProvider).measurement.isMeasuring;
  return (measuring: measuring, started: measuring);
}

typedef BenchmarkRecording = ({
  bool recording,
  double elapsedSeconds,
  double? bestKg,
});

/// Records a benchmark pull: the highest mean force over 5 s.
final benchmarkRecorderProvider =
    NotifierProvider<BenchmarkRecorder, BenchmarkRecording>(
      BenchmarkRecorder.new,
    );

class BenchmarkRecorder extends Notifier<BenchmarkRecording> {
  StreamSubscription<List<WeightMeasurement>>? _samples;
  bool _startedMeasurement = false;

  @override
  BenchmarkRecording build() {
    ref.onDispose(() => _samples?.cancel());
    return (recording: false, elapsedSeconds: 0, bestKg: null);
  }

  Future<void> start() async {
    if (state.recording) return;
    final (:measuring, :started) = await _ensureMeasuring(ref);
    if (!measuring) return;
    _startedMeasurement = started;
    final fiveSecondMax = FiveSecondMax();
    state = (recording: true, elapsedSeconds: 0, bestKg: null);
    _samples = ref.read(progressorProvider.notifier).sampleBatches.listen((
      samples,
    ) {
      samples.forEach(fiveSecondMax.add);
      // Publish at the displayed resolution, a tenth of a second.
      final next = (
        recording: true,
        elapsedSeconds: (fiveSecondMax.elapsedUs ~/ 100000) / 10,
        bestKg: fiveSecondMax.bestKg,
      );
      if (next != state) state = next;
    });
  }

  Future<void> stop() async {
    _samples?.cancel();
    _samples = null;
    state = (
      recording: false,
      elapsedSeconds: state.elapsedSeconds,
      bestKg: state.bestKg,
    );
    if (_startedMeasurement) {
      _startedMeasurement = false;
      await ref.read(progressorProvider.notifier).stopMeasurement();
    }
  }

  void clear() => state = (recording: false, elapsedSeconds: 0, bestKg: null);
}

/// The OpenGrips workout timer, with the Crimpdeq as the weight: a rest
/// before the first rep, then hangs at the target force separated by rests.
/// The force starts and ends each hang, and the rests count down.
final workoutProvider = NotifierProvider<WorkoutNotifier, WorkoutState>(
  WorkoutNotifier.new,
);

class WorkoutNotifier extends Notifier<WorkoutState> {
  Timer? _restTimer;
  StreamSubscription<List<WeightMeasurement>>? _samples;
  HoldTracker? _hold;
  bool _startedMeasurement = false;

  @override
  WorkoutState build() {
    ref.onDispose(_cancel);
    return const WorkoutState();
  }

  Future<void> start(WorkoutPlan plan) async {
    if (state.isRunning) return;
    final (:measuring, :started) = await _ensureMeasuring(ref);
    if (!measuring) return;
    _startedMeasurement = started;
    _samples = ref
        .read(progressorProvider.notifier)
        .sampleBatches
        .listen(addSamples);
    state = WorkoutState(plan: plan);
    _rest(WorkoutPhase.preRest, plan.preRestSeconds);
  }

  /// Times the current hang with the samples.
  void addSamples(List<WeightMeasurement> samples) {
    final hold = _hold;
    if (state.phase != WorkoutPhase.hang || hold == null) return;
    samples.forEach(hold.add);
    if (hold.failed) {
      finishRep();
      return;
    }
    // Publish at the displayed resolution, a tenth of a second.
    final heldSeconds = (hold.heldSeconds * 10).floor() / 10;
    if (hold.started != state.holding || heldSeconds != state.heldSeconds) {
      state = state.copyWith(holding: hold.started, heldSeconds: heldSeconds);
    }
  }

  /// Ends the current hang with the time held so far.
  void finishRep() => _endRep(_hold?.heldSeconds ?? 0, _hold?.meanKg);

  /// Skips the current hang, which counts as not held, or the current rest.
  void skip() {
    switch (state.phase) {
      case WorkoutPhase.hang:
        _endRep(0, null);
      case WorkoutPhase.preRest:
        _hang(1);
      case WorkoutPhase.rest:
        _hang(state.rep + 1);
      case WorkoutPhase.idle || WorkoutPhase.done:
        return;
    }
  }

  /// Pauses or resumes the rest countdown. Hangs follow the force.
  void togglePause() => state = state.copyWith(paused: !state.paused);

  /// Abandons the workout.
  Future<void> stop() async {
    await _release();
    state = const WorkoutState();
  }

  /// Saves the finished workout. The first target becomes the one the ideal
  /// force curve predicts at the measured force, like OpenGrips does.
  Future<void> save({
    required int perceivedExertion,
    required String notes,
  }) async {
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
    state = state.copyWith(saved: true);
  }

  /// Returns to the setup after the results.
  void reset() => state = const WorkoutState();

  void _rest(WorkoutPhase phase, int seconds) {
    _hold = null;
    state = state.copyWith(phase: phase, restRemainingSeconds: seconds);
    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.paused) return;
      if (state.restRemainingSeconds > 1) {
        state = state.copyWith(
          restRemainingSeconds: state.restRemainingSeconds - 1,
        );
        return;
      }
      _hang(state.phase == WorkoutPhase.preRest ? 1 : state.rep + 1);
    });
  }

  void _hang(int rep) {
    _restTimer?.cancel();
    _hold = HoldTracker(state.plan!.targetForceKg);
    state = state.copyWith(
      phase: WorkoutPhase.hang,
      rep: rep,
      paused: false,
      holding: false,
      heldSeconds: 0,
    );
  }

  void _endRep(double heldSeconds, double? forceKg) {
    if (state.phase != WorkoutPhase.hang) return;
    state = state.copyWith(
      actualSeconds: [...state.actualSeconds, heldSeconds],
      repForcesKg: [...state.repForcesKg, forceKg],
    );
    if (state.rep < state.plan!.reps) {
      _rest(WorkoutPhase.rest, state.plan!.restSeconds);
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
