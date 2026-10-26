import 'package:crimpdeq/analysis/hold_tracker.dart';
import 'package:crimpdeq/analysis/opengrips_curve.dart';
import 'package:crimpdeq/models/progressor_models.dart';
import 'package:flutter_test/flutter_test.dart';

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

    test('predicts the ideal first hang', () {
      expect(idealFirstHangSeconds(13.96, 35), 54);
      expect(idealFirstHangSeconds(35, 35), 5);
      expect(idealFirstHangSeconds(7.95, 35), 83);
      expect(idealFirstHangSeconds(60, 90), 40);
    });

    test('derives the 5 s max from a longer hold', () {
      expect(deriveBenchmarkKg(30, 10), 32.92);
      expect(deriveBenchmarkKg(20, 30), 31.66);
      expect(deriveBenchmarkKg(25, 7), 25.88);
      expect(deriveBenchmarkKg(10, 60), 25.91);
      expect(deriveBenchmarkKg(35, 5), 35);
    });

    test('classifies a force into its section', () {
      expect(CurveSection.of(10, 30), CurveSection.strengthEndurance);
      expect(CurveSection.of(19, 30), CurveSection.power);
      expect(CurveSection.of(5, 30), CurveSection.endurance);
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
      final tracker = HoldTracker();
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

    test('waits for a pull of more than 2 kg', () {
      final tracker = HoldTracker();
      _samples(_repeat(2, 3)).forEach(tracker.add);
      expect(tracker.started, isFalse);
      expect(tracker.failed, isFalse);
      expect(tracker.meanKg, isNull);
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
