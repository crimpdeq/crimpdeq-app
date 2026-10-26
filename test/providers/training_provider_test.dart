import 'dart:async';

import 'package:crimpdeq/analysis/opengrips_curve.dart';
import 'package:crimpdeq/models/progressor_models.dart';
import 'package:crimpdeq/models/training_models.dart';
import 'package:crimpdeq/providers/progressor_provider.dart';
import 'package:crimpdeq/providers/training_provider.dart';
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
}

/// Samples every 100 ms.
List<WeightMeasurement> _pull(double weightKg, double seconds, int startMs) => [
  for (var i = 0; i < seconds * 10; i++)
    WeightMeasurement(
      weightKg: weightKg,
      timestampUs: (startMs + i * 100) * 1000,
    ),
];

/// Kept alive like the screen keeps the device state.
ProviderContainer _measuring() => ProviderContainer(
  overrides: [progressorProvider.overrideWith(_MeasuringProgressor.new)],
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

    // 11.97 kg target, so the hang starts at 10.77 kg.
    workout.addSamples(_pull(5, 1, 0));
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
}
