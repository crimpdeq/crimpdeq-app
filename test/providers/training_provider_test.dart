import 'dart:async';

import 'package:crimpdeq/analysis/opengrips_curve.dart';
import 'package:crimpdeq/analysis/warmup.dart';
import 'package:crimpdeq/models/progressor_models.dart';
import 'package:crimpdeq/models/training_models.dart';
import 'package:crimpdeq/protocol/progressor_protocol.dart';
import 'package:crimpdeq/providers/progressor_provider.dart';
import 'package:crimpdeq/providers/training_provider.dart';
import 'package:crimpdeq/providers/warmup_provider.dart';
import 'package:crimpdeq/providers/workout_feedback_provider.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Measures without Bluetooth; the test feeds the samples to the workout.
class _MeasuringProgressor extends ProgressorNotifier {
  final samples = StreamController<List<WeightMeasurement>>.broadcast();

  @override
  ProgressorState build() =>
      const ProgressorState(measurement: MeasurementState(isMeasuring: true));

  @override
  Stream<List<WeightMeasurement>> get sampleBatches => samples.stream;

  int starts = 0;

  /// Like a failed write: marked measuring, then not.
  bool failStarts = false;

  @override
  Future<void> startMeasurement() async {
    starts++;
    setMeasuring(true);
    if (failStarts) {
      await Future<void>.value();
      setMeasuring(false);
    }
  }

  @override
  Future<void> stopMeasurement() async => setMeasuring(false);

  void setMeasuring(bool isMeasuring) =>
      state = state.copyWith.measurement(isMeasuring: isMeasuring);

  void link() => state = state.copyWith.connection(
    device: BluetoothDevice.fromId('00:11:22:33:44:55'),
    writeCharacteristic: BluetoothCharacteristic(
      remoteId: const DeviceIdentifier('00:11:22:33:44:55'),
      serviceUuid: Guid(progressorServiceUuid),
      characteristicUuid: Guid(progressorWriteCharUuid),
    ),
  );

  /// Like the device: the connection and the measurement end together.
  void drop() => state = const ProgressorState();
}

/// Samples every 100 ms.
List<WeightMeasurement> _pull(double weightKg, double seconds, int startMs) => [
  for (var i = 0; i < seconds * 10; i++)
    WeightMeasurement(
      weightKg: weightKg,
      timestampUs: (startMs + i * 100) * 1000,
    ),
];

/// Records the cues and the screen instead of using the platform.
class _Feedback extends WorkoutFeedback {
  final events = <String>[];

  @override
  Future<void> play(WorkoutCue cue) async => events.add(cue.name);

  @override
  Future<void> keepScreenOn(bool on) async => events.add('screen $on');
}

/// Kept alive like the screen keeps the device state.
ProviderContainer _measuring([_Feedback? feedback]) => ProviderContainer(
  overrides: [
    progressorProvider.overrideWith(_MeasuringProgressor.new),
    workoutFeedbackProvider.overrideWithValue(feedback ?? _Feedback()),
  ],
)..listen(progressorProvider, (_, _) {});

void main() {
  const plan = WorkoutPlan(
    tool: 'Photon',
    hand: Hand.right,
    section: CurveSection.strength,
    benchmarkKg: 30,
    firstHangSeconds: 10,
    reps: 3,
    restSeconds: 6,
  );

  testWidgets('runs and saves a workout', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final container = _measuring();
    addTearDown(container.dispose);
    final workout = container.read(workoutProvider.notifier);
    WorkoutState state() => container.read(workoutProvider);

    // The first hold, without a rest before it.
    await workout.start(plan);
    expect(state().phase, WorkoutPhase.hold);
    expect(state().rep, 1);

    // The hold starts with a pull of more than 2 kg.
    workout.addSamples(_pull(1.5, 1, 0));
    expect(state().holding, isFalse);
    workout.addSamples([..._pull(12, 15, 1000), ..._pull(0, 1.1, 16000)]);
    expect(state().phase, WorkoutPhase.rest);
    expect(state().actualSeconds.single, closeTo(14.9, 1e-9));
    // 4.9 s over the 10 s target, so the later targets scale.
    expect(state().targets, [10, 5, 4]);

    await tester.pump(const Duration(seconds: 5));
    expect(state().restRemainingSeconds, 1);
    workout.togglePause();
    await tester.pump(const Duration(seconds: 3));
    expect(state().restRemainingSeconds, 1);
    workout.togglePause();
    await tester.pump(const Duration(seconds: 1));
    expect(state().phase, WorkoutPhase.hold);
    expect(state().rep, 2);

    workout.addSamples(_pull(14, 3, 20000));
    // One trace through the holds and rests: a point every 0.1 s of the
    // latest 15 s, here one per sample.
    final trace = state().forceTrace;
    expect(trace.first.x, inInclusiveRange(7.7, 7.9));
    expect(trace.last.x, closeTo(22.9, 1e-9));
    expect(trace.last.y, 14);
    workout.finishRep();
    workout.skip();
    expect(state().rep, 3);
    workout.skip();
    expect(state().phase, WorkoutPhase.done);
    expect(state().actualSeconds, [closeTo(14.9, 1e-9), closeTo(2.9, 1e-9), 0]);
    expect(state().meanForceKg, closeTo(12 + 2 * 2.9 / 17.8, 1e-9));

    await workout.save(perceivedExertion: 7, notes: 'Felt good');
    expect(state().saved, isTrue);
    final saved = (await container.read(trainingLogProvider.future)).workouts;
    expect(saved.single.targetSeconds, [
      idealFirstHangSeconds(state().meanForceKg!, 30),
      5,
      4,
    ]);
    expect(saved.single.perceivedExertion, 7);

    // A new container reads the workout back from the storage.
    final reloaded = ProviderContainer();
    addTearDown(reloaded.dispose);
    final workouts = (await reloaded.read(trainingLogProvider.future)).workouts;
    expect(workouts.single.toJson(), saved.single.toJson());
  });

  testWidgets('stores every one of overlapping log updates', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final log = container.read(trainingLogProvider.notifier);
    Benchmark benchmark(double forceKg) => Benchmark(
      date: DateTime(2026, 10, 26),
      tool: 'Photon',
      hand: Hand.right,
      forceKg: forceKg,
    );

    await Future.wait([
      log.addBenchmark(benchmark(30)),
      log.addBenchmark(benchmark(31)),
    ]);
    final reloaded = ProviderContainer();
    addTearDown(reloaded.dispose);
    for (final container in [container, reloaded]) {
      final benchmarks = (await container.read(trainingLogProvider.future))
          .benchmarks;
      expect([for (final entry in benchmarks) entry.forceKg], [30, 31]);
    }
  });

  testWidgets('saves a workout once for a second tap', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final container = _measuring();
    addTearDown(container.dispose);
    final workout = container.read(workoutProvider.notifier);

    // Both holds and the rest between them.
    await workout.start(plan.copyWith(reps: 2));
    for (var i = 0; i < 3; i++) {
      workout.skip();
    }
    expect(container.read(workoutProvider).phase, WorkoutPhase.done);
    await Future.wait([
      workout.save(perceivedExertion: 5, notes: ''),
      workout.save(perceivedExertion: 5, notes: ''),
    ]);
    final saved = (await container.read(trainingLogProvider.future)).workouts;
    expect(saved, hasLength(1));

    // Leaving before the save is stored keeps the next workout unsaved.
    workout.reset();
    await workout.start(plan.copyWith(reps: 2));
    for (var i = 0; i < 3; i++) {
      workout.skip();
    }
    final save = workout.save(perceivedExertion: 5, notes: '');
    workout.reset();
    await save;
    expect(container.read(workoutProvider).saved, isFalse);
  });

  testWidgets('records the best 5 s of a benchmark pull', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final container = _measuring();
    addTearDown(container.dispose);
    final recorder = container.read(benchmarkRecorderProvider.notifier);

    await recorder.start();
    expect(container.read(benchmarkRecorderProvider).recording, isTrue);
    final device =
        container.read(progressorProvider.notifier) as _MeasuringProgressor;
    device.samples.add([..._pull(10, 1, 0), ..._pull(25, 6, 1000)]);
    await tester.pump();
    await recorder.stop();
    device.samples.add(_pull(40, 6, 7000));
    await tester.pump();

    final recording = container.read(benchmarkRecorderProvider);
    expect(recording.recording, isFalse);
    expect(recording.elapsedSeconds, 6.9);
    expect(recording.bestKg, closeTo(25, 1e-9));
    // The force until the stop, one point per sample.
    expect(recording.trace, hasLength(70));
    expect(recording.trace.last.x, closeTo(6.9, 1e-9));
    expect(recording.trace.last.y, 25);
  });

  testWidgets('keeps the reps done when the device disconnects', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final container = _measuring();
    addTearDown(container.dispose);
    final workout = container.read(workoutProvider.notifier);
    final device =
        container.read(progressorProvider.notifier) as _MeasuringProgressor;
    WorkoutState state() => container.read(workoutProvider);

    await workout.start(plan);
    device.link();
    workout.addSamples([
      ..._pull(0, 1, 0),
      ..._pull(12, 5, 1000),
      ..._pull(0, 1.1, 6000),
    ]);
    expect(state().phase, WorkoutPhase.rest);

    device.drop();
    expect(state().phase, WorkoutPhase.done);
    expect(state().endedEarly, WorkoutEnd.disconnected);
    expect(state().actualSeconds, [closeTo(4.9, 1e-9)]);
    // The rest timer stopped with it.
    await tester.pump(const Duration(seconds: 10));
    expect(state().phase, WorkoutPhase.done);

    await workout.save(perceivedExertion: 5, notes: '');
    final saved = (await container.read(trainingLogProvider.future)).workouts;
    // The averages cover the rep done, whose target saves as the ideal one.
    expect(saved.single.targetSeconds, hasLength(3));
    expect(saved.single.meanTargetSeconds, idealFirstHangSeconds(12, 30));
  });

  testWidgets('abandons a workout disconnected before the first rep', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final container = _measuring();
    addTearDown(container.dispose);
    final device =
        container.read(progressorProvider.notifier) as _MeasuringProgressor;

    await container.read(workoutProvider.notifier).start(plan);
    device.link();
    device.drop();
    expect(container.read(workoutProvider).phase, WorkoutPhase.idle);
  });

  testWidgets('measures again when the measurement stops mid-workout', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final container = _measuring();
    addTearDown(container.dispose);
    final device =
        container.read(progressorProvider.notifier) as _MeasuringProgressor;

    await container.read(workoutProvider.notifier).start(plan);
    device.link();
    device.setMeasuring(false);
    expect(device.starts, 1);
    await container.read(workoutProvider.notifier).stop();
    // Stopping the workout does not restart the measurement.
    expect(device.starts, 1);
  });

  testWidgets('ends a workout and a pull when measuring cannot restart', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final container = _measuring();
    addTearDown(container.dispose);
    final device =
        container.read(progressorProvider.notifier) as _MeasuringProgressor;
    final workout = container.read(workoutProvider.notifier);
    final recorder = container.read(benchmarkRecorderProvider.notifier);
    WorkoutState state() => container.read(workoutProvider);

    await workout.start(plan);
    device.link();
    workout.addSamples([
      ..._pull(0, 1, 0),
      ..._pull(12, 5, 1000),
      ..._pull(0, 1.1, 6000),
    ]);
    device.failStarts = true;
    device.setMeasuring(false);
    await tester.pump();
    // One restart, not one per failure, then the reps done stay to save.
    expect(device.starts, 1);
    expect(state().phase, WorkoutPhase.done);
    expect(state().endedEarly, WorkoutEnd.measurementFailed);

    device.failStarts = false;
    await recorder.start();
    expect(device.starts, 2);
    device.failStarts = true;
    device.setMeasuring(false);
    await tester.pump();
    expect(device.starts, 3);
    expect(container.read(benchmarkRecorderProvider).recording, isFalse);
  });

  testWidgets('cues the rests and holds and keeps the screen on', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final feedback = _Feedback();
    final container = _measuring(feedback);
    addTearDown(container.dispose);
    final workout = container.read(workoutProvider.notifier);
    final events = feedback.events;

    await workout.start(plan.copyWith(restSeconds: 6, reps: 2));
    expect(events, ['screen true', 'go']);
    events.clear();

    // The 10 s target, reached once.
    workout.addSamples([..._pull(0, 1, 0), ..._pull(12, 10.2, 1000)]);
    workout.addSamples(_pull(12, 1, 11200));
    expect(events, ['go']);
    workout.addSamples(_pull(0, 1.1, 12200));
    // The 6 s rest: 5 s left, then 2 and 1 s.
    await tester.pump(const Duration(seconds: 6));
    expect(events.sublist(1), ['restWarning', 'countdown', 'countdown', 'go']);
    events.clear();

    workout.skip();
    expect(events, ['screen false']);

    await container.read(soundsMutedProvider.notifier).toggle();
    events.clear();
    await workout.start(plan);
    workout.skip();
    await tester.pump(const Duration(seconds: 6));
    expect(events, ['screen true']);
    await workout.stop();
    expect(events, ['screen true', 'screen false']);
  });

  testWidgets('keeps a stored mute from the first cue', (tester) async {
    SharedPreferences.setMockInitialValues({'training.muted': true});
    final feedback = _Feedback();
    final container = _measuring(feedback);
    addTearDown(container.dispose);
    final workout = container.read(workoutProvider.notifier);

    await workout.start(plan);
    expect(container.read(workoutProvider).phase, WorkoutPhase.hold);
    expect(feedback.events, ['screen true']);
    await workout.stop();
  });

  testWidgets('measures again when the measurement stops mid-pull', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final container = _measuring();
    addTearDown(container.dispose);
    final device =
        container.read(progressorProvider.notifier) as _MeasuringProgressor;
    final recorder = container.read(benchmarkRecorderProvider.notifier);

    device.setMeasuring(false);
    await recorder.start();
    device.link();
    expect(device.starts, 1);
    device.setMeasuring(false);
    expect(device.starts, 2);
    await recorder.stop();
    // Stopping the pull stops the measurement without restarting it.
    expect(device.starts, 2);
    expect(container.read(progressorProvider).measurement.isMeasuring, isFalse);
  });

  testWidgets('starts a workout and a pull once for a second tap', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final container = _measuring();
    addTearDown(container.dispose);
    final device =
        container.read(progressorProvider.notifier) as _MeasuringProgressor;
    final workout = container.read(workoutProvider.notifier);
    final recorder = container.read(benchmarkRecorderProvider.notifier);

    // A tap while the measurement starts must not subscribe again, or the
    // stop leaves a subscription behind.
    device.setMeasuring(false);
    await Future.wait([workout.start(plan), workout.start(plan)]);
    await workout.stop();
    expect(device.samples.hasListener, isFalse);

    device.setMeasuring(false);
    await Future.wait([recorder.start(), recorder.start()]);
    await recorder.stop();
    expect(device.samples.hasListener, isFalse);
  });

  for (final (name, loadedSeconds, waits) in [
    ('waits for a load left on through the rest to drop', 4.0, true),
    ('starts with a pull begun in the last seconds of rest', 2.0, false),
  ]) {
    testWidgets(name, (tester) async {
      SharedPreferences.setMockInitialValues({});
      final container = _measuring();
      addTearDown(container.dispose);
      final workout = container.read(workoutProvider.notifier);
      WorkoutState state() => container.read(workoutProvider);

      // The 10 s rest after the first rep, loaded for its last seconds.
      await workout.start(plan.copyWith(restSeconds: 10));
      workout.skip();
      final loadedFromMs = ((10 - loadedSeconds) * 1000).round();
      workout.addSamples([
        ..._pull(0, loadedFromMs / 1000, 0),
        ..._pull(5, loadedSeconds, loadedFromMs),
      ]);
      await tester.pump(const Duration(seconds: 10));
      expect(state().phase, WorkoutPhase.hold);
      expect(state().waitingForRelease, waits);

      workout.addSamples(_pull(5, 1, 10000));
      expect(state().holding, !waits);
      await workout.stop();
    });
  }

  testWidgets('waits for a load on at the start to drop', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final container = _measuring();
    addTearDown(container.dispose);
    final workout = container.read(workoutProvider.notifier);
    WorkoutState state() => container.read(workoutProvider);

    await workout.start(plan);
    // Until a sample shows the load, nothing is reported.
    expect(state().waitingForRelease, isFalse);
    workout.addSamples(_pull(5, 2, 0));
    expect(state().waitingForRelease, isTrue);
    expect(state().holding, isFalse);

    workout.addSamples([..._pull(0, 0.5, 2000), ..._pull(5, 1, 2500)]);
    expect(state().waitingForRelease, isFalse);
    expect(state().holding, isTrue);
    await workout.stop();
  });

  testWidgets('waits after the rest for a pull above the stored threshold', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'training.holdThresholdKg': 5.0});
    final container = _measuring();
    addTearDown(container.dispose);
    final workout = container.read(workoutProvider.notifier);
    WorkoutState state() => container.read(workoutProvider);

    await workout.start(plan.copyWith(restSeconds: 6));
    workout.skip();
    await tester.pump(const Duration(seconds: 6));
    expect(state().phase, WorkoutPhase.hold);
    expect(state().rep, 2);

    // 10 s at 5 kg or less, as time passes.
    for (var second = 0; second < 10; second++) {
      workout.addSamples(_pull(second.isEven ? 5 : 0.5, 1, second * 1000));
      await tester.pump(const Duration(seconds: 1));
    }
    expect(state().holding, isFalse);
    expect(state().heldSeconds, 0);
    expect(state().phase, WorkoutPhase.hold);

    // The first sample above 5 kg starts the hold, so 2 s of samples hold
    // 1.9 s.
    workout.addSamples(_pull(12, 2, 10000));
    expect(state().holding, isTrue);
    expect(state().heldSeconds, 1.9);
    await workout.stop();
  });

  testWidgets('stores the hold threshold', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(await container.read(holdThresholdProvider.future), 2);
    await container.read(holdThresholdProvider.notifier).set(3.5);

    final reloaded = ProviderContainer();
    addTearDown(reloaded.dispose);
    expect(await reloaded.read(holdThresholdProvider.future), 3.5);
  });
  testWidgets('ends each warm-up hold at its target or release', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final feedback = _Feedback();
    final container = _measuring(feedback);
    addTearDown(container.dispose);
    final warmup = container.read(warmupProvider.notifier);
    WarmupState state() => container.read(warmupProvider);
    const steps = <WarmupStep>[
      (
        tool: 'Spark',
        hand: Hand.left,
        benchmarkKg: 40,
        forceKg: 16,
        seconds: 3,
        restSeconds: 0,
      ),
      (
        tool: 'Spark',
        hand: Hand.right,
        benchmarkKg: 50,
        forceKg: 20,
        seconds: 2,
        restSeconds: 4,
      ),
    ];

    // The first hold, without a rest before it.
    await warmup.start(WarmupKind.climbing, steps);
    expect(state().phase, WorkoutPhase.hold);
    expect(feedback.events, ['screen true', 'go']);

    // 3 s held, so the rest starts without waiting for the release.
    warmup.addSamples([..._pull(0, 0.5, 0), ..._pull(16, 4, 500)]);
    expect(state().phase, WorkoutPhase.rest);
    expect(state().step, 1);
    expect(state().restRemainingSeconds, 4);
    expect(state().bestKg, [null]);

    await tester.pump(const Duration(seconds: 4));
    expect(state().phase, WorkoutPhase.hold);
    warmup.addSamples(_pull(20, 1, 10000));
    expect(state().holding, isTrue);
    expect(state().heldSeconds, 0.9);
    // Released before the target, the last hold ends the warm-up.
    warmup.addSamples(_pull(0, 1.1, 11000));
    expect(state().phase, WorkoutPhase.done);
    expect(state().bestKg, [null, null]);
    expect(feedback.events, [
      'screen true',
      'go',
      'go',
      'countdown',
      'countdown',
      'go',
      'screen false',
    ]);

    // A warm-up stores nothing.
    await tester.pump();
    expect(state().saved, isFalse);
    expect((await container.read(trainingLogProvider.future)).readiness, []);
  });

  testWidgets('rests each hand between its own holds', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final feedback = _Feedback();
    final container = _measuring(feedback);
    addTearDown(container.dispose);
    final warmup = container.read(warmupProvider.notifier);
    WarmupState state() => container.read(warmupProvider);
    WarmupStep step(Hand hand, int restSeconds) => (
      tool: 'Photon',
      hand: hand,
      benchmarkKg: 20.0,
      forceKg: 6.0,
      seconds: 2,
      restSeconds: restSeconds,
    );

    await warmup.start(WarmupKind.training, [
      step(Hand.left, 0),
      step(Hand.right, 0),
      step(Hand.left, 15),
    ]);
    warmup.addSamples([..._pull(0, 0.5, 0), ..._pull(6, 2.5, 500)]);
    // The right hand has rested since the start: its hold follows at once,
    // and waits for the left pull, still on, to drop.
    expect(state().phase, WorkoutPhase.hold);
    expect(state().step, 1);
    warmup.addSamples(_pull(6, 1, 3000));
    expect(state().waitingForRelease, isTrue);
    expect(state().holding, isFalse);

    // The left hand rests 10 s of its 15 s through the right hold.
    await tester.pump(const Duration(seconds: 10));
    warmup.addSamples([..._pull(0, 0.5, 4000), ..._pull(6, 2.5, 4500)]);
    expect(state().phase, WorkoutPhase.rest);
    expect(state().step, 2);
    expect(state().restRemainingSeconds, 5);
    await tester.pump(const Duration(seconds: 4));
    expect(state().restRemainingSeconds, 1);
    await tester.pump(const Duration(seconds: 1));
    expect(state().phase, WorkoutPhase.hold);
    // Each hold's end cues the next, and the rest its own.
    expect(feedback.events, [
      'screen true',
      'go',
      'go',
      'go',
      'restWarning',
      'countdown',
      'countdown',
      'go',
    ]);
    await warmup.stop();
  });

  testWidgets('warns once when a hold pulls well over its target', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final feedback = _Feedback();
    final container = _measuring(feedback);
    addTearDown(container.dispose);
    final warmup = container.read(warmupProvider.notifier);
    WarmupState state() => container.read(warmupProvider);

    await warmup.start(WarmupKind.training, const [
      (
        tool: 'Spark',
        hand: Hand.right,
        benchmarkKg: 30.0,
        forceKg: 12.0,
        seconds: 20,
        restSeconds: 0,
      ),
    ]);
    feedback.events.clear();
    warmup.addSamples([..._pull(0, 0.5, 0), ..._pull(12, 2, 500)]);
    expect(state().overshooting, isFalse);

    // More than 15% over 12 kg warns once, and stays on above 10% over.
    warmup.addSamples(_pull(14, 1, 2500));
    expect(state().overshooting, isTrue);
    warmup.addSamples([..._pull(13.5, 0.5, 3500), ..._pull(14, 0.5, 4000)]);
    expect(state().overshooting, isTrue);
    expect(feedback.events, ['easeOff']);

    // Back near the target, a new overshoot warns again.
    warmup.addSamples(_pull(12.5, 1, 4500));
    expect(state().overshooting, isFalse);
    warmup.addSamples(_pull(14, 1, 5500));
    expect(feedback.events, ['easeOff', 'easeOff']);
    await warmup.stop();
  });

  testWidgets('counts the rest down after a training warm-up', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final feedback = _Feedback();
    final container = _measuring(feedback);
    addTearDown(container.dispose);
    final warmup = container.read(warmupProvider.notifier);
    WarmupState state() => container.read(warmupProvider);
    const step = (
      tool: 'Photon',
      hand: Hand.left,
      benchmarkKg: 20.0,
      forceKg: 6.0,
      seconds: 2,
      restSeconds: 0,
    );

    await warmup.start(WarmupKind.training, const [step]);
    warmup.addSamples([..._pull(0, 0.5, 0), ..._pull(6, 3, 500)]);
    expect(state().phase, WorkoutPhase.done);
    expect(state().restRemainingSeconds, workoutRestSeconds);
    feedback.events.clear();

    // The rest cues, then the workout's.
    await tester.pump(const Duration(seconds: workoutRestSeconds - 5));
    expect(state().restRemainingSeconds, 5);
    await tester.pump(const Duration(seconds: 10));
    expect(state().restRemainingSeconds, 0);
    expect(feedback.events, ['restWarning', 'countdown', 'countdown', 'go']);

    // Leaving the results ends the countdown.
    await warmup.start(WarmupKind.training, const [step]);
    warmup.addSamples([..._pull(0, 0.5, 10000), ..._pull(6, 3, 10500)]);
    warmup.reset();
    await tester.pump(const Duration(seconds: 5));
    expect(state().restRemainingSeconds, 0);
  });

  testWidgets('stores the readiness pulls of at least 5 s', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final container = _measuring();
    addTearDown(container.dispose);
    final warmup = container.read(warmupProvider.notifier);
    WarmupState state() => container.read(warmupProvider);
    final steps = readinessCheck([
      for (final (hand, forceKg) in [(Hand.left, 20.0), (Hand.right, 30.0)])
        Benchmark(
          date: DateTime(2026, 10, 26),
          tool: 'Photon',
          hand: hand,
          forceKg: forceKg,
        ),
    ]);

    await warmup.start(WarmupKind.readiness, steps);
    expect(state().phase, WorkoutPhase.rest);
    expect(state().restRemainingSeconds, 180);
    warmup.skip();
    // The best 5 s of a 6 s pull, after its start.
    warmup.addSamples([
      ..._pull(0, 0.5, 0),
      ..._pull(15, 1, 500),
      ..._pull(18, 6, 1500),
    ]);
    expect(state().bestKg, [18]);

    // The right hand rests through the left rest and pull, so its pull
    // follows at once. Under 5 s held, it is not measured.
    expect(state().phase, WorkoutPhase.hold);
    expect(state().step, 1);
    warmup.addSamples([
      ..._pull(0, 0.5, 20000),
      ..._pull(25, 3, 20500),
      ..._pull(0, 1.1, 23500),
    ]);
    expect(state().phase, WorkoutPhase.done);
    expect(state().bestKg, [18, null]);

    await tester.pump();
    expect(state().saved, isTrue);
    final reloaded = ProviderContainer();
    addTearDown(reloaded.dispose);
    final check = (await reloaded.read(trainingLogProvider.future)).readiness;
    expect(check.single.tool, 'Photon');
    expect(check.single.pulls, [
      (hand: Hand.left, forceKg: 18.0, benchmarkKg: 20.0),
    ]);
  });

  testWidgets('gives way to a session started while waiting for the device', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final container = _measuring();
    addTearDown(container.dispose);
    final device =
        container.read(progressorProvider.notifier) as _MeasuringProgressor;
    final workout = container.read(workoutProvider.notifier);
    final warmup = container.read(warmupProvider.notifier);
    final recorder = container.read(benchmarkRecorderProvider.notifier);
    final steps = trainingWarmup(
      [
        for (final hand in Hand.values)
          Benchmark(
            date: DateTime(2026, 10, 26),
            tool: 'Photon',
            hand: hand,
            forceKg: 30,
          ),
      ],
      'Photon',
      heavy: false,
    );

    // Each starts before the other has the device: one runs.
    device.link();
    for (final workoutFirst in [true, false]) {
      device.setMeasuring(false);
      final starts = [
        () => workout.start(plan),
        () => warmup.start(WarmupKind.training, steps),
      ];
      await Future.wait([
        for (final start in workoutFirst ? starts : starts.reversed) start(),
      ]);
      await tester.pump();
      final workoutRunning = container.read(workoutProvider).isRunning;
      expect(container.read(warmupProvider).isRunning, !workoutRunning);
      // Measuring, whichever started the measurement, until the end.
      expect(
        container.read(progressorProvider).measurement.isMeasuring,
        isTrue,
      );
      await recorder.start();
      expect(container.read(benchmarkRecorderProvider).recording, isFalse);
      await (workoutRunning ? workout.stop() : warmup.stop());
      expect(
        container.read(progressorProvider).measurement.isMeasuring,
        isFalse,
      );
      expect(device.samples.hasListener, isFalse);
    }

    // A running warm-up keeps the workout and the pull from starting.
    await warmup.start(WarmupKind.training, steps);
    await workout.start(plan);
    await recorder.start();
    expect(container.read(workoutProvider).phase, WorkoutPhase.idle);
    expect(container.read(benchmarkRecorderProvider).recording, isFalse);
    await warmup.stop();
  });

  testWidgets('leaves a load left on out of the readiness maximum', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final container = _measuring();
    addTearDown(container.dispose);
    final warmup = container.read(warmupProvider.notifier);
    WarmupState state() => container.read(warmupProvider);
    final steps = readinessCheck([
      for (final hand in Hand.values)
        Benchmark(
          date: DateTime(2026, 10, 26),
          tool: 'Photon',
          hand: hand,
          forceKg: 30,
        ),
    ]);

    // 40 kg left on through the end of the rest, and 5 s more after it.
    await warmup.start(WarmupKind.readiness, steps);
    warmup.addSamples(_pull(40, 4, 0));
    await tester.pump(const Duration(seconds: readinessRestSeconds));
    expect(state().phase, WorkoutPhase.hold);
    expect(state().waitingForRelease, isTrue);
    warmup.addSamples([
      ..._pull(40, 5, 4000),
      ..._pull(0, 0.5, 9000),
      ..._pull(20, 7, 9500),
    ]);
    expect(state().bestKg, [20]);
    await warmup.stop();
  });

  testWidgets('keeps the readiness pulls done when the device disconnects', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final container = _measuring();
    addTearDown(container.dispose);
    final warmup = container.read(warmupProvider.notifier);
    final device =
        container.read(progressorProvider.notifier) as _MeasuringProgressor;
    WarmupState state() => container.read(warmupProvider);
    final steps = readinessCheck([
      for (final hand in Hand.values)
        Benchmark(
          date: DateTime(2026, 10, 26),
          tool: 'Photon',
          hand: hand,
          forceKg: 30,
        ),
    ]);

    await warmup.start(WarmupKind.readiness, steps);
    device.link();
    warmup.skip();
    warmup.addSamples([..._pull(0, 0.5, 0), ..._pull(27, 6.5, 500)]);
    device.drop();
    expect(state().phase, WorkoutPhase.done);
    expect(state().endedEarly, WorkoutEnd.disconnected);
    // The rest timer stopped with it.
    await tester.pump(const Duration(seconds: 20));
    expect(state().phase, WorkoutPhase.done);
    expect(state().saved, isTrue);
    final readiness = (await container.read(trainingLogProvider.future))
        .readiness;
    expect(readiness.single.pulls.single.forceKg, 27);

    // Stopping a running check stores nothing more.
    warmup.reset();
    await warmup.start(WarmupKind.readiness, steps);
    await warmup.stop();
    expect(state().phase, WorkoutPhase.idle);
    expect(
      (await container.read(trainingLogProvider.future)).readiness,
      hasLength(1),
    );
  });
}
