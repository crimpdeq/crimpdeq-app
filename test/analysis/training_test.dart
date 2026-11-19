import 'package:crimpdeq/analysis/force_trace.dart';
import 'package:crimpdeq/analysis/hold_tracker.dart';
import 'package:crimpdeq/analysis/opengrips_curve.dart';
import 'package:crimpdeq/models/progressor_models.dart';
import 'package:crimpdeq/models/training_models.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:crimpdeq/providers/schedule_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/timezone.dart' as tz;

/// Samples every 100 ms from [startMs], one per weight.
List<WeightMeasurement> _samples(List<double> weightsKg, {int startMs = 0}) => [
  for (final (i, weightKg) in weightsKg.indexed)
    WeightMeasurement(
      weightKg: weightKg,
      timestampUs: (startMs + i * 100) * 1000,
    ),
];

List<double> _repeat(double weightKg, double seconds) =>
    List.filled((seconds * 10).round(), weightKg);

void main() {
  group('Gripper rest', () {
    WorkoutRecord workout(String tool, DateTime date) => WorkoutRecord(
      date: date,
      tool: tool,
      hand: Hand.right,
      section: CurveSection.strength,
      targetForceKg: 24,
      forceKg: 24,
      restSeconds: 6,
      targetSeconds: const [10],
      actualSeconds: const [10],
      repForcesKg: const [24],
      durationSeconds: 10,
      perceivedExertion: 5,
      notes: '',
    );
    final photon = workout('Photon', DateTime(2026, 10, 26, 10));

    test('rests after a workout with the other gripper', () {
      const hour = Duration(hours: 1);
      expect(
        gripperRestEnd([photon], 'Spark', hour),
        DateTime(2026, 10, 26, 11),
      );
      // The other hand on the same gripper, or no rest at all.
      expect(gripperRestEnd([photon], 'Photon', hour), isNull);
      expect(gripperRestEnd([photon], 'Spark', Duration.zero), isNull);
      expect(gripperRestEnd([], 'Spark', hour), isNull);
    });

    test('leaves the grippers without a workout that day', () {
      final yesterday = workout('Spark', DateTime(2026, 10, 25, 18));
      expect(toolsLeftToday([yesterday, photon], trainingTools, photon.date), [
        'Spark',
      ]);
    });
  });

  group('Workout history', () {
    WorkoutRecord workout(
      DateTime date,
      Hand hand, {
      CurveSection section = CurveSection.strength,
    }) => WorkoutRecord(
      date: date,
      tool: 'Photon',
      hand: hand,
      section: section,
      targetForceKg: 12,
      forceKg: 12.5,
      restSeconds: 20,
      targetSeconds: const [50, 36, 30],
      actualSeconds: const [46, 34, 0],
      repForcesKg: const [12.6, 12.4, null],
      durationSeconds: 150,
      perceivedExertion: 7,
      notes: '',
    );
    final monday = DateTime(2026, 10, 26, 10);
    final tuesday = DateTime(2026, 10, 27, 10);
    final first = workout(monday, Hand.right);
    final right = workout(tuesday, Hand.right);
    final left = workout(tuesday, Hand.left);

    test('groups the hands saved together into one workout', () {
      expect(workoutSessions([first, right, left]), [
        [first],
        [right, left],
      ]);
    });

    test('compares a workout with the previous one of its hand', () {
      expect(previousWorkout([first, right, left], right), first);
      expect(previousWorkout([first, right, left], left), isNull);
      expect(previousWorkout([first, right, left], first), isNull);
    });

    test('compares a workout only with one of its section', () {
      final power = workout(
        DateTime(2026, 10, 28, 10),
        Hand.right,
        section: CurveSection.power,
      );
      final strength = workout(DateTime(2026, 10, 29, 10), Hand.right);
      expect(previousWorkout([first, power, strength], power), isNull);
      expect(previousWorkout([first, power, strength], strength), first);
    });

    test('sums the time under load and the workload of the reps', () {
      expect(right.repsHeld, 2);
      expect(right.heldSeconds, 80);
      // The mean force is weighted by the time held.
      expect(right.workloadKgS, 12.5 * 80);
    });

    test('reads a workout saved without rep forces or a duration', () {
      final json = right.toJson()
        ..remove('repForcesKg')
        ..remove('durationSeconds');
      final read = WorkoutRecord.fromJson(json);
      expect(read.repForcesKg, isNull);
      expect(read.durationSeconds, isNull);
      expect(
        WorkoutRecord.fromJson(right.toJson()).repForcesKg,
        right.repForcesKg,
      );
    });
  });

  test('compares a force with the latest body weight on its day', () {
    final weights = [
      BodyWeight(day: DateTime(2026, 10, 20), kg: 70),
      BodyWeight(day: DateTime(2026, 10, 26), kg: 68),
    ];
    expect(bodyWeightOn(weights, DateTime(2026, 10, 19, 23)), isNull);
    expect(bodyWeightOn(weights, DateTime(2026, 10, 25, 23)), 70);
    // A weight logged later that day still counts.
    expect(bodyWeightOn(weights, DateTime(2026, 10, 26, 7)), 68);
  });

  test('reminds on the next weekday at the time', () {
    // Monday 26 October 2026, 10:30.
    final now = tz.TZDateTime(tz.UTC, 2026, 10, 26, 10, 30);
    expect(
      nextWeekdayTime(now, DateTime.monday, 15, 0),
      tz.TZDateTime(tz.UTC, 2026, 10, 26, 15),
    );
    expect(
      nextWeekdayTime(now, DateTime.monday, 10, 0),
      tz.TZDateTime(tz.UTC, 2026, 11, 2, 10),
    );
    expect(
      nextWeekdayTime(now, DateTime.wednesday, 10, 0),
      tz.TZDateTime(tz.UTC, 2026, 10, 28, 10),
    );
  });

  group('Workout schedule', () {
    // Targets of 10, 4 and 3 s, with 6 s of rest between the reps.
    const right = WorkoutPlan(
      tool: 'Photon',
      hand: Hand.right,
      section: CurveSection.strength,
      benchmarkKg: 30,
      firstHangSeconds: 10,
      reps: 3,
      restSeconds: 6,
    );
    final left = right.copyWith(hand: Hand.left, benchmarkKg: 28);

    test('takes the hands in turn or rep by rep', () {
      expect(workoutSchedule([right, left], alternating: false), [
        for (final plan in [0, 1])
          for (final rep in [1, 2, 3]) (plan: plan, rep: rep),
      ]);
      expect(workoutSchedule([right, left], alternating: true), [
        for (final rep in [1, 2, 3])
          for (final plan in [0, 1]) (plan: plan, rep: rep),
      ]);
    });

    test('estimates the time with the rests the other hand covers', () {
      expect(workoutSeconds([right], alternating: false), 17 + 2 * 6);
      // The left hand starts rested, after a hand change.
      expect(workoutSeconds([right, left], alternating: false), 29 + 5 + 29);
      // The other hand's hold and the hand changes cover every rest.
      expect(workoutSeconds([right, left], alternating: true), 2 * 17 + 5 * 5);
    });
  });

  // Expected values come from the OpenGrips formulas run on the same inputs.
  group('OpenGrips curve', () {
    test('targets a fraction of the balanced force', () {
      expect(CurveSection.strength.targetForceKg(35), 13.96);
      expect(CurveSection.power.targetForceKg(35), 23.33);
      expect(CurveSection.endurance.targetForceKg(35), 7.95);
    });

    test('scales the later targets with a first hang off by over 3 s', () {
      List<int> strength([double? actual]) => repTargetSeconds(
        CurveSection.strength,
        reps: 5,
        firstHangSeconds: 101,
        firstHangActualSeconds: actual,
      );
      expect(strength(), [101, 36, 29, 26, 23]);
      expect(strength(90), [101, 32, 26, 23, 21]);
      expect(strength(99), [101, 36, 29, 26, 23]);
      expect(strength(0), [101, 36, 29, 26, 23]);
    });

    test('repeats the last ratio for extra reps', () {
      expect(
        repTargetSeconds(CurveSection.power, reps: 8, firstHangSeconds: 40),
        [40, 15, 10, 9, 8, 8, 8, 8],
      );
    });

    test('shapes the targets with the energy systems', () {
      expect(
        repTargetSeconds(
          CurveSection.strength,
          reps: 5,
          firstHangSeconds: 101,
          energySystems: (power: 0.52, powerEndurance: 0.27, endurance: 0.15),
        ),
        [101, 54, 46, 41, 39],
      );
      expect(
        repTargetSeconds(
          CurveSection.power,
          reps: 8,
          firstHangSeconds: 40,
          energySystems: (power: 0.3, powerEndurance: 0.17, endurance: 0.05),
        ),
        [40, 13, 10, 8, 8, 7, 7, 7],
      );
      expect(
        repTargetSeconds(
          CurveSection.endurance,
          reps: 4,
          firstHangSeconds: 193,
          firstHangActualSeconds: 150,
          energySystems: CurveSection.endurance.energySystems,
        ),
        [193, 112, 111, 110],
      );
      // A first hang ended at once still leaves a second for each rep.
      expect(
        repTargetSeconds(
          CurveSection.power,
          reps: 6,
          firstHangSeconds: 40,
          firstHangActualSeconds: 0.2,
          energySystems: CurveSection.power.energySystems,
        ),
        [40, 1, 1, 1, 1, 1],
      );
    });

    test('bounds each energy system by the previous one', () {
      expect(powerEnduranceRange(0.15), (min: 0.19, max: 0.37));
      expect(powerRange(0.27), (min: 0.29, max: 0.79));
      expect(powerRange(0.17), (min: 0.22, max: 0.73));
      expect(powerRange(0.37), (min: 0.4, max: 0.85));
      expect(
        clampEnergySystems((power: 0.9, powerEndurance: 0.1, endurance: 0.3)),
        (power: 0.75, powerEndurance: 0.2, endurance: 0.2),
      );
      for (final section in CurveSection.values) {
        expect(
          clampEnergySystems(section.energySystems),
          section.energySystems,
          reason: section.label,
        );
      }
    });

    test('draws the ideal curve from the benchmark to the floor', () {
      expect(curveFloorKg(30), 1);
      expect(idealForceKg(5, 30), 30);
      expect(idealForceKg(7, 30), closeTo(28.9339, 1e-4));
      expect(idealForceKg(191, 30), closeTo(1.0368, 1e-4));
    });

    test('keeps a force axis under a benchmark below the floor', () {
      expect(forceAxisKg(0.5, []), (min: 1, max: 2));
    });

    test('predicts the ideal first hang', () {
      expect(idealFirstHangSeconds(13.96, 35), 54);
      expect(idealFirstHangSeconds(35, 35), 5);
      expect(idealFirstHangSeconds(7.95, 35), 83);
      expect(idealFirstHangSeconds(60, 90), 40);
    });

    test('derives the 5 s max from a longer hold', () {
      expect(deriveBenchmarkKg(30, 10), closeTo(32.92, 0.005));
      expect(deriveBenchmarkKg(20, 30), closeTo(31.66, 0.005));
      expect(deriveBenchmarkKg(25, 7), closeTo(25.88, 0.005));
      expect(deriveBenchmarkKg(10, 60), closeTo(25.91, 0.005));
      expect(deriveBenchmarkKg(35, 5), 35);
    });

    test('classifies a force into its section', () {
      expect(CurveSection.of(10, 30), CurveSection.strengthEndurance);
      expect(CurveSection.of(19, 30), CurveSection.power);
      expect(CurveSection.of(5, 30), CurveSection.endurance);
      expect(CurveSection.of(50, -10), CurveSection.power);
    });

    test('suggests the section with the fewest workouts first', () {
      expect(suggestSection([], 30), CurveSection.endurance);
      expect(
        suggestSection([
          (forceKg: 6.82, firstHangSeconds: 190),
          (forceKg: 11.97, firstHangSeconds: 100),
        ], 30),
        CurveSection.strengthEndurance,
      );
    });

    test('then the section furthest below the ideal curve', () {
      CurvePoint point(CurveSection section, double belowIdealSeconds) {
        final forceKg = section.targetForceKg(30);
        return (
          forceKg: forceKg,
          firstHangSeconds:
              idealFirstHangSeconds(forceKg, 30) - belowIdealSeconds,
        );
      }

      expect(
        suggestSection([
          for (final section in CurveSection.values) point(section, 1),
          point(CurveSection.powerStrength, 10),
        ], 30),
        CurveSection.powerStrength,
      );
    });
  });

  group('HoldTracker', () {
    test('counts the time pulling more than 2 kg until released', () {
      final tracker = HoldTracker(thresholdKg: 2);
      _samples([
        ..._repeat(0, 0.5),
        ..._repeat(10, 3),
        // The time of a dip to 2 kg or less does not count.
        ..._repeat(1.5, 0.5),
        ..._repeat(10, 1),
        ..._repeat(0, 0.9),
      ]).forEach(tracker.add);
      expect(tracker.started, isTrue);
      expect(tracker.failed, isFalse);
      // 2.9 s from the first pulling sample, then 1 s from the end of the dip.
      expect(tracker.heldSeconds, closeTo(3.9, 1e-9));
      expect(tracker.meanKg, closeTo(10, 1e-9));

      tracker.add(const WeightMeasurement(weightKg: 0, timestampUs: 5900000));
      expect(tracker.failed, isTrue);
      expect(tracker.heldSeconds, closeTo(3.9, 1e-9));
    });

    test('waits for a load left on to drop first', () {
      final tracker = HoldTracker(thresholdKg: 2, waitForRelease: true);
      _samples(_repeat(5, 2)).forEach(tracker.add);
      expect(tracker.started, isFalse);
      expect(tracker.waitForRelease, isTrue);
      _samples([
        ..._repeat(0, 0.5),
        ..._repeat(10, 2),
      ], startMs: 2000).forEach(tracker.add);
      expect(tracker.waitForRelease, isFalse);
      expect(tracker.heldSeconds, closeTo(1.9, 1e-9));
    });

    test('waits for a pull of more than the threshold', () {
      final tracker = HoldTracker(thresholdKg: 5);
      _samples(_repeat(5, 3)).forEach(tracker.add);
      expect(tracker.started, isFalse);
      expect(tracker.failed, isFalse);
      expect(tracker.meanKg, isNull);
      _samples(_repeat(5.5, 1), startMs: 3000).forEach(tracker.add);
      expect(tracker.started, isTrue);
    });
  });

  group('ForceTrace', () {
    test('keeps a mean point every 0.1 s of the latest 15 s', () {
      final trace = ForceTrace();
      // Samples every 50 ms, two per point.
      trace.addAll([
        for (var i = 0; i < 400; i++)
          WeightMeasurement(
            weightKg: i.isEven ? 10 : 12,
            timestampUs: i * 50000,
          ),
      ]);
      final points = trace.points;
      expect(points.last.x, closeTo(19.9, 1e-9));
      // From the last point before the window, so the line reaches its edge.
      final fromX = points.last.x - ForceTrace.windowSeconds;
      expect(points.first.x, lessThanOrEqualTo(fromX));
      expect(points[1].x, greaterThan(fromX));
      expect(points[1].y, 11);
    });

    test('continues after the timeline restarts', () {
      final trace = ForceTrace();
      _samples(_repeat(10, 2)).forEach((sample) => trace.addAll([sample]));
      _samples(
        _repeat(20, 1),
        startMs: 0,
      ).forEach((sample) => trace.addAll([sample]));
      expect(trace.points.last, const FlSpot(2.8, 20));
    });
  });

  group('FiveSecondMax', () {
    test('needs 5 s of samples', () {
      final max = FiveSecondMax();
      _samples(_repeat(30, 4.9)).forEach(max.add);
      expect(max.bestKg, isNull);
      expect(max.elapsedUs, 4800000);
    });

    test('keeps the highest 5 s mean', () {
      final max = FiveSecondMax();
      _samples([..._repeat(10, 3), ..._repeat(20, 6), ..._repeat(5, 3)])
          .forEach(max.add);
      expect(max.bestKg, closeTo(20, 1e-9));
    });

    test('continues the elapsed time after the timeline restarts', () {
      final max = FiveSecondMax();
      _samples(_repeat(10, 2)).forEach(max.add);
      _samples(_repeat(10, 2), startMs: 0).forEach(max.add);
      expect(max.elapsedUs, 1900000 + 1900000);
      expect(max.bestKg, isNull);
    });
  });
}
