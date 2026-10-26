// Runs the app against a device advertising as DEVICE_NAME, such as the
// crimpdeq-firmware `esp-rust-board` build with its simulated pulls:
//
//   flutter test integration_test/board_test.dart -d macos
//
// The simulated load cell repeats 8.5 s cycles from each start: 2 s unloaded,
// then a pull above 2 kg for about 6 s, peaking at 18, 30, 24, 12 and 27 kg.
import 'package:crimpdeq/analysis/opengrips_curve.dart';
import 'package:crimpdeq/app.dart';
import 'package:crimpdeq/models/training_models.dart';
import 'package:crimpdeq/models/progressor_models.dart';
import 'package:crimpdeq/providers/progressor_provider.dart';
import 'package:crimpdeq/providers/training_provider.dart';
import 'package:crimpdeq/screens/crimpdeq_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _deviceName = String.fromEnvironment(
  'DEVICE_NAME',
  defaultValue: 'Progressor_7125',
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('trains with a real device', (tester) async {
    // Keeps the training log of this computer untouched.
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ProviderScope(child: CrimpdeqApp()));
    final container = ProviderScope.containerOf(
      tester.element(find.byType(CrimpdeqScreen)),
    );
    ProgressorState device() => container.read(progressorProvider);
    WorkoutState workout() => container.read(workoutProvider);

    /// Waits in real time, rendering, until [done] or the [timeout].
    Future<void> waitUntil(
      bool Function() done,
      String what, {
      Duration timeout = const Duration(seconds: 30),
    }) async {
      final deadline = DateTime.now().add(timeout);
      while (!done()) {
        if (DateTime.now().isAfter(deadline)) {
          fail('Timed out waiting for $what (${device().connection.status})');
        }
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump();
      }
    }

    Future<void> tap(Finder finder) async {
      await tester.ensureVisible(finder);
      await tester.pump();
      await tester.tap(finder);
      await tester.pump();
    }

    Future<void> connect() async {
      await waitUntil(
        () => device().connection.bluetoothReady,
        'Bluetooth to be ready',
      );
      await tap(find.text('Scan'));
      await waitUntil(
        () => find.text(_deviceName).evaluate().isNotEmpty,
        '$_deviceName to be found',
      );
      final row = find
          .ancestor(of: find.text(_deviceName), matching: find.byType(Row))
          .first;
      await tap(
        find.descendant(
          of: row,
          matching: find.widgetWithText(FilledButton, 'Connect'),
        ),
      );
      await waitUntil(
        () => device().deviceInfo.firmwareVersion.isNotEmpty,
        'the device info',
      );
    }

    // Training is reachable without a device, and connects from the workout.
    await waitUntil(
      () => find.text('Connect a Crimpdeq to start').evaluate().isNotEmpty,
      'the training part',
    );
    await connect();
    debugPrint('Connected: firmware ${device().deviceInfo.firmwareVersion}');
    await waitUntil(
      () => device().calibration.factor != null,
      'the calibration factor',
    );
    await waitUntil(
      () => device().deviceInfo.batteryMillivolts != null,
      'the battery',
    );

    // Debugging: the measurement reaches the simulated peaks.
    await tap(find.widgetWithText(NavigationDestination, 'Debugging'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Current Calibration Factor: '), findsOne);
    await tap(find.text('Measurements'));
    await tester.pumpAndSettle();
    await tap(find.widgetWithText(ElevatedButton, 'Start'));
    await waitUntil(
      () => (device().measurement.peakKg ?? 0) > 15,
      'a simulated pull',
      timeout: const Duration(seconds: 15),
    );
    debugPrint('Measured peak ${device().measurement.peakKg} kg');
    await tap(find.widgetWithText(ElevatedButton, 'Stop'));
    await waitUntil(
      () => !device().measurement.isMeasuring,
      'the measurement to stop',
    );

    // Benchmark: a pull over two simulated cycles, the second to 30 kg.
    await tap(find.widgetWithText(NavigationDestination, 'Training'));
    await tester.pumpAndSettle();
    await tap(find.text('Benchmarks'));
    await tester.pumpAndSettle();
    Future<void> select<T>(String option) async {
      await tap(find.byType(DropdownButton<T>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(option).last);
      await tester.pumpAndSettle();
    }

    await select<String>('Photon');
    await select<Hand>('Right');
    await tap(find.widgetWithText(FilledButton, 'Start Pull'));
    await waitUntil(
      () => container.read(benchmarkRecorderProvider).elapsedSeconds >= 17,
      'two simulated pulls',
    );
    await tap(find.widgetWithText(FilledButton, 'Stop'));
    final bestKg = container.read(benchmarkRecorderProvider).bestKg;
    debugPrint('Best 5 s: $bestKg kg');
    expect(bestKg, inInclusiveRange(20, 30));
    await tap(find.widgetWithText(OutlinedButton, 'Save Benchmark'));
    await tester.pumpAndSettle();
    await tap(find.text('Open Workout'));
    await tester.pumpAndSettle();

    // Workout: two reps, each ended by the simulated release.
    Future<void> startWorkout(int reps) async {
      final setup = container.read(workoutSetupProvider.notifier);
      final benchmark = bestBenchmark(
        container.read(trainingLogProvider).value!.benchmarks,
        'Photon',
        Hand.right,
      )!;
      setup.updatePlan(
        WorkoutPlan.forSection(
          tool: 'Photon',
          hand: Hand.right,
          section: CurveSection.values.first,
          benchmarkKg: benchmark.forceKg,
        ).copyWith(reps: reps, restSeconds: 5),
      );
      await tester.pumpAndSettle();
      await tap(find.widgetWithText(FilledButton, 'Start Workout'));
      await waitUntil(
        () => workout().phase == WorkoutPhase.preRest,
        'the pre-workout rest',
      );
    }

    await startWorkout(2);
    await waitUntil(
      () => workout().phase == WorkoutPhase.done,
      'the workout to end',
      timeout: const Duration(seconds: 45),
    );
    debugPrint(
      'Hangs: ${workout().actualSeconds}, ${workout().meanForceKg} kg',
    );
    expect(workout().actualSeconds, hasLength(2));
    expect(workout().actualSeconds.first, inInclusiveRange(3, 7));
    expect(workout().meanForceKg, isNotNull);
    // The workout started the measurement, so it stops it.
    await waitUntil(
      () => !device().measurement.isMeasuring,
      'the workout to stop the measurement',
      timeout: const Duration(seconds: 5),
    );
    await tap(find.widgetWithText(FilledButton, 'Save Results'));
    await waitUntil(() => workout().saved, 'the workout to save');
    await tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Photon Right'), findsOne);

    // A disconnect mid-workout keeps the reps done.
    await tap(find.text('Workout'));
    await tester.pumpAndSettle();
    await tap(find.widgetWithText(OutlinedButton, 'Start New Workout'));
    await tester.pumpAndSettle();
    await startWorkout(3);
    await waitUntil(
      () => workout().actualSeconds.length == 1,
      'the first rep',
      timeout: const Duration(seconds: 20),
    );
    await tap(find.byTooltip('Disconnect'));
    await waitUntil(
      () => workout().phase == WorkoutPhase.done,
      'the workout to end on the disconnect',
    );
    expect(workout().disconnected, isTrue);
    expect(find.textContaining('disconnected after rep 1'), findsOne);
    await tap(find.widgetWithText(OutlinedButton, 'Start New Workout'));
    await tester.pumpAndSettle();
    await tap(find.widgetWithText(OutlinedButton, 'Leave without saving?'));
    await tester.pumpAndSettle();

    // And the device connects again.
    await connect();
    debugPrint('Reconnected');

    // The hangs time alike at the highest sample rate, whose stored setting
    // the test restores.
    Future<void> setSampleRate(int samplesPerSecond) async {
      await tap(find.widgetWithText(NavigationDestination, 'Debugging'));
      await tester.pumpAndSettle();
      await tap(find.text('Measurements'));
      await tester.pumpAndSettle();
      await tap(find.byType(DropdownButton<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('· $samplesPerSecond SPS').last);
      await waitUntil(
        () => device().deviceInfo.sampleRate == samplesPerSecond,
        'the $samplesPerSecond SPS sample rate',
      );
      await tap(find.widgetWithText(NavigationDestination, 'Training'));
      await tester.pumpAndSettle();
      await tap(find.text('Workout'));
      await tester.pumpAndSettle();
    }

    // Read last after connecting.
    await waitUntil(
      () => device().deviceInfo.sampleRate != null,
      'the sample rate',
    );
    final sampleRate = device().deviceInfo.sampleRate!;
    // Restores the stored setting also when the test fails.
    addTearDown(
      () =>
          container.read(progressorProvider.notifier).setSampleRate(sampleRate),
    );
    await setSampleRate(1000);
    final frames = <FrameTiming>[];
    void addFrames(List<FrameTiming> timings) => frames.addAll(timings);
    SchedulerBinding.instance.addTimingsCallback(addFrames);
    await startWorkout(2);
    await waitUntil(
      () => workout().phase == WorkoutPhase.done,
      'the workout at 1000 SPS to end',
      timeout: const Duration(seconds: 45),
    );
    SchedulerBinding.instance.removeTimingsCallback(addFrames);
    debugPrint('Hangs at 1000 SPS: ${workout().actualSeconds}');
    int worstMs(Duration Function(FrameTiming) duration) =>
        frames.map(duration).reduce((a, b) => a > b ? a : b).inMilliseconds;
    debugPrint(
      'Frames at 1000 SPS: ${frames.length}, worst build '
      '${worstMs((frame) => frame.buildDuration)} ms, worst raster '
      '${worstMs((frame) => frame.rasterDuration)} ms',
    );
    expect(workout().actualSeconds.first, inInclusiveRange(4.5, 6));
    await tap(find.widgetWithText(OutlinedButton, 'Start New Workout'));
    await tester.pumpAndSettle();
    await tap(find.widgetWithText(OutlinedButton, 'Leave without saving?'));
    await tester.pumpAndSettle();
    await setSampleRate(sampleRate);
    debugPrint('Restored $sampleRate SPS');
  });
}
