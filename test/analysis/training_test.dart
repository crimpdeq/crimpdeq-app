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

    test('predicts the ideal first hang', () {
      expect(idealFirstHangSeconds(13.96, 35), 54);
      expect(idealFirstHangSeconds(35, 35), 5);
      expect(idealFirstHangSeconds(7.95, 35), 83);
      expect(idealFirstHangSeconds(60, 90), 40);
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
    test('times the hang from reaching 90% of the target to failing', () {
      final tracker = HoldTracker(10);
      final samples = _samples([
        ..._repeat(0, 0.5),
        ..._repeat(10, 3),
        // A dip under a second counts as hanging.
        ..._repeat(8, 0.5),
        ..._repeat(10, 1),
        ..._repeat(0, 0.9),
      ]);
      samples.forEach(tracker.add);
      expect(tracker.started, isTrue);
      expect(tracker.failed, isFalse);
      expect(tracker.heldSeconds, closeTo(4.4, 1e-9));
      expect(tracker.meanKg, closeTo(43 / 4.4, 1e-9));

      tracker.add(const WeightMeasurement(weightKg: 0, timestampUs: 5900000));
      expect(tracker.failed, isTrue);
      expect(tracker.heldSeconds, closeTo(4.4, 1e-9));
    });

    test('waits for the force to reach the threshold', () {
      final tracker = HoldTracker(10);
      _samples(_repeat(8.9, 3)).forEach(tracker.add);
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
