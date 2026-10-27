import 'dart:async';

import 'package:crimpdeq/analysis/opengrips_curve.dart';
import 'package:crimpdeq/models/progressor_models.dart';
import 'package:crimpdeq/models/training_models.dart';
import 'package:crimpdeq/protocol/progressor_protocol.dart';
import 'package:crimpdeq/providers/progressor_provider.dart';
import 'package:crimpdeq/providers/training_provider.dart';
import 'package:crimpdeq/providers/workout_feedback_provider.dart';
import 'package:fl_chart/fl_chart.dart';
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

  @override
  Future<void> startMeasurement() async {
    starts++;
    setMeasuring(true);
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

    await workout.start(plan);
    expect(state().phase, WorkoutPhase.preRest);
    expect(state().restRemainingSeconds, 3);
    await tester.pump(const Duration(seconds: 3));
    expect(state().phase, WorkoutPhase.hang);
    expect(state().rep, 1);

    // The hang starts with a pull of more than 2 kg.
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
    expect(state().phase, WorkoutPhase.hang);
    expect(state().rep, 2);

    workout.addSamples(_pull(14, 3, 20000));
    // A new trace for each hang: a mean point every 0.1 s from its first
    // sample, here one per sample.
    final trace = state().forceTrace;
    expect(trace.length, 30);
    expect(trace.first, const FlSpot(0, 14));
    expect(trace.last.x, closeTo(2.9, 1e-9));
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
    workout.skip();
    workout.addSamples([..._pull(12, 5, 0), ..._pull(0, 1.1, 5000)]);
    expect(state().phase, WorkoutPhase.rest);

    device.drop();
    expect(state().phase, WorkoutPhase.done);
    expect(state().disconnected, isTrue);
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

  testWidgets('cues the rests and hangs and keeps the screen on', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final feedback = _Feedback();
    final container = _measuring(feedback);
    addTearDown(container.dispose);
    final workout = container.read(workoutProvider.notifier);
    final events = feedback.events;

    // A 6 s rest between reps, so its pre-rest lasts 3 s.
    await workout.start(plan.copyWith(restSeconds: 6, reps: 2));
    expect(events, ['screen true']);
    await tester.pump(const Duration(seconds: 3));
    // 2 and 1 s left, then the hang starts.
    expect(events.sublist(1), ['countdown', 'countdown', 'go']);
    events.clear();

    // The 10 s target, reached once.
    workout.addSamples(_pull(12, 10.2, 0));
    workout.addSamples(_pull(12, 1, 10200));
    expect(events, ['go']);
    workout.addSamples(_pull(0, 1.1, 11200));
    // The 6 s rest: 5 s left, then 2 and 1 s.
    await tester.pump(const Duration(seconds: 6));
    expect(events.sublist(1), ['restWarning', 'countdown', 'countdown', 'go']);
    events.clear();

    workout.skip();
    expect(events, ['screen false']);

    await container.read(soundsMutedProvider.notifier).toggle();
    events.clear();
    await workout.start(plan);
    await tester.pump(const Duration(seconds: 10));
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

    await workout.start(plan.copyWith(restSeconds: 5));
    await tester.pump(const Duration(seconds: 3));
    expect(container.read(workoutProvider).phase, WorkoutPhase.hang);
    expect(feedback.events, ['screen true']);
    await workout.stop();
  });
}
