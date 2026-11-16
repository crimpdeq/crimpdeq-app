import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analysis/force_trace.dart';
import '../analysis/hold_tracker.dart';
import '../analysis/warmup.dart';
import '../models/progressor_models.dart';
import '../models/training_models.dart';
import 'progressor_provider.dart';
import 'training_provider.dart';
import 'workout_feedback_provider.dart';

/// The warm-up timer, with the Crimpdeq as the weight. Like a workout, each
/// hold waits for the pull above the threshold, but it ends at its target:
/// a warm-up never goes to failure. A readiness check is stored once done.
final warmupProvider = NotifierProvider<WarmupNotifier, WarmupState>(
  WarmupNotifier.new,
);

class WarmupNotifier extends Notifier<WarmupState> {
  late WorkoutFeedback _feedback;
  bool _screenKeptOn = false;
  Timer? _restTimer;
  StreamSubscription<List<WeightMeasurement>>? _samples;
  HoldTracker? _hold;
  FiveSecondMax? _max;
  RestLoad? _restLoad;
  ForceTrace _trace = ForceTrace();
  double _thresholdKg = HoldTracker.defaultThresholdKg;
  bool _startedMeasurement = false;
  // The warm-up runs after the measurement starts: a second tap meanwhile
  // would subscribe twice.
  bool _starting = false;
  // A failed restart sets the measurement off again, which would restart it.
  bool _restarting = false;

  @override
  WarmupState build() {
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
          // Stopped elsewhere: the holds need the samples.
          _restartMeasurement();
        }
      },
    );
    return const WarmupState();
  }

  /// Ends the warm-up when the measurement does not start again, instead of
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

  Future<void> start(WarmupKind kind, List<WarmupStep> steps) async {
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
      _samples = ref
          .read(progressorProvider.notifier)
          .sampleBatches
          .listen(addSamples);
      state = WarmupState(kind: kind, steps: steps);
      _next(0);
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
    final target = state.current.seconds;
    for (final sample in samples) {
      hold.add(sample);
      _max?.add(sample);
      if (hold.failed || hold.heldSeconds >= target) break;
    }
    if (hold.failed) {
      _endStep();
      return;
    }
    if (hold.heldSeconds >= target) {
      _cue(WorkoutCue.go);
      _endStep();
      return;
    }
    // Publish at the displayed resolution, a tenth of a second.
    final heldSeconds = (hold.heldSeconds * 10).floor() / 10;
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

  /// Skips the current hold or rest.
  void skip() {
    switch (state.phase) {
      case WorkoutPhase.hold:
        _endStep();
      case WorkoutPhase.rest:
        _startHold();
      case WorkoutPhase.idle || WorkoutPhase.done:
        return;
    }
  }

  /// Pauses or resumes the rest countdown. Holds follow the force.
  void togglePause() => state = state.copyWith(paused: !state.paused);

  /// Abandons the warm-up, without storing a readiness check.
  Future<void> stop() async {
    // Idle first, so stopping the measurement does not restart it.
    state = const WarmupState();
    await _release();
  }

  /// Returns to the setup after the results.
  void reset() => state = const WarmupState();

  /// Rests before step [index] if it has a rest, or holds at once.
  void _next(int index) {
    _hold = null;
    _max = null;
    state = state.copyWith(step: index, paused: false);
    final seconds = state.current.restSeconds;
    if (seconds == 0) {
      _startHold();
      return;
    }
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
      _startHold();
    });
  }

  /// Starts the current step's hold, which waits for the pull however long
  /// the rest was. Without a rest, it waits for any load already on to drop.
  void _startHold() {
    _restTimer?.cancel();
    final leftOn = _restLoad?.leftOn ?? false;
    _restLoad = null;
    _hold = HoldTracker(
      thresholdKg: _thresholdKg,
      waitForRelease: leftOn || state.current.restSeconds == 0,
    );
    _max = state.current.forceKg == null ? FiveSecondMax() : null;
    state = state.copyWith(
      phase: WorkoutPhase.hold,
      paused: false,
      holding: false,
      waitingForRelease: leftOn,
      heldSeconds: 0,
    );
    _cue(WorkoutCue.go);
  }

  void _endStep() {
    if (state.phase != WorkoutPhase.hold) return;
    final hold = _hold!;
    final fullWindow =
        hold.heldSeconds * Duration.microsecondsPerSecond >=
        FiveSecondMax.windowUs;
    state = state.copyWith(
      bestKg: [...state.bestKg, fullWindow ? _max?.bestKg : null],
    );
    if (state.step + 1 < state.steps.length) {
      _next(state.step + 1);
      return;
    }
    _hold = null;
    state = state.copyWith(phase: WorkoutPhase.done);
    unawaited(_release());
    unawaited(_saveReadiness());
  }

  /// Ends the warm-up without the device's samples. A readiness check keeps
  /// the pulls done.
  void _endEarly(WorkoutEnd reason) {
    _cancel();
    // The measurement ended with the connection, or did not start again.
    _startedMeasurement = false;
    state = state.copyWith(phase: WorkoutPhase.done, endedEarly: reason);
    unawaited(_saveReadiness());
  }

  /// Stores the readiness pulls of at least 5 s, if any.
  Future<void> _saveReadiness() async {
    final done = state;
    if (done.kind != WarmupKind.readiness) return;
    final pulls = [
      for (final (index, forceKg) in done.bestKg.indexed)
        if (forceKg != null)
          (
            hand: done.steps[index].hand,
            forceKg: forceKg,
            benchmarkKg: done.steps[index].benchmarkKg,
          ),
    ];
    if (pulls.isEmpty) return;
    await ref
        .read(trainingLogProvider.notifier)
        .addReadiness(
          ReadinessCheck(
            date: DateTime.now(),
            tool: readinessTool,
            pulls: pulls,
          ),
        );
    // Leaving the results meanwhile starts over with another warm-up.
    if (identical(state, done)) state = state.copyWith(saved: true);
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

  void _cancel() {
    _restTimer?.cancel();
    _restTimer = null;
    _hold = null;
    _max = null;
    _samples?.cancel();
    _samples = null;
  }

  /// Stops timing, and the measurement if the warm-up started it.
  Future<void> _release() async {
    _cancel();
    if (_startedMeasurement) {
      _startedMeasurement = false;
      await ref.read(progressorProvider.notifier).stopMeasurement();
    }
  }
}
