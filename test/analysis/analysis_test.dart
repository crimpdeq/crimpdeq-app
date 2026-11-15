import 'dart:math';

import 'package:crimpdeq/analysis/battery.dart';
import 'package:crimpdeq/analysis/calibration_check.dart';
import 'package:crimpdeq/analysis/calibration_curve.dart';
import 'package:crimpdeq/analysis/force_stats.dart';
import 'package:crimpdeq/analysis/steady_load.dart';
import 'package:crimpdeq/analysis/timestamp_unwrapper.dart';
import 'package:crimpdeq/models/progressor_models.dart';
import 'package:crimpdeq/protocol/progressor_protocol.dart';
import 'package:flutter_test/flutter_test.dart';

WeightMeasurement _sample(double weightKg, int timestampMs) =>
    WeightMeasurement(weightKg: weightKg, timestampUs: timestampMs * 1000);

/// Samples every [intervalMs] from 0 to [durationMs], weighing [weightAt].
List<WeightMeasurement> _samples(
  int durationMs,
  int intervalMs,
  double Function(int timestampMs) weightAt,
) => [
  for (var ms = 0; ms <= durationMs; ms += intervalMs)
    _sample(weightAt(ms), ms),
];

void main() {
  group('ForceStats', () {
    test('tracks min and peak, including negative loads', () {
      final stats = ForceStats();
      for (final sample in [_sample(-2, 0), _sample(-0.5, 10)]) {
        stats.add(sample);
      }

      expect(stats.minKg, -2);
      expect(stats.peakKg, -0.5);
    });

    test('measures the steepest rise over the RFD span', () {
      final stats = ForceStats();
      // 10 kg/s, then 100 kg/s from 500 ms, then flat from 600 ms.
      for (final sample in _samples(1000, 10, (ms) {
        if (ms < 500) return ms / 100;
        if (ms < 600) return 5 + (ms - 500) / 10;
        return 15;
      })) {
        stats.add(sample);
      }

      expect(stats.peakRfdKgPerS, closeTo(100, 1e-9));
      expect(stats.peakKg, 15);
    });

    test('needs samples spanning the RFD span', () {
      final stats = ForceStats()
        ..add(_sample(0, 0))
        ..add(_sample(5, 10));

      expect(stats.peakRfdKgPerS, isNull);
    });

    test('uses consecutive samples when they are further apart', () {
      // 20 SPS: 50 ms between samples.
      final stats = ForceStats();
      for (final sample in _samples(200, 50, (ms) => ms / 10)) {
        stats.add(sample);
      }

      expect(stats.peakRfdKgPerS, closeTo(100, 1e-9));
    });
  });

  group('SteadyLoadDetector', () {
    test('is steady once a still load spans the window', () {
      final detector = SteadyLoadDetector();

      expect(detector.add(_samples(900, 10, (_) => 20)), isFalse);
      expect(detector.steadyLoadKg, isNull);
      expect(detector.add([_sample(20, 1000)]), isTrue);
      expect(detector.steadyLoadKg, closeTo(20, 1e-9));
    });

    test('averages out noise below the tolerance', () {
      final detector = SteadyLoadDetector();

      expect(
        detector.add(
          _samples(1000, 10, (ms) => (ms ~/ 10).isEven ? 20.05 : 19.95),
        ),
        isTrue,
      );
    });

    test('scales the tolerance with the load', () {
      List<WeightMeasurement> swinging(double loadKg, double peakToPeakKg) =>
          _samples(
            1000,
            10,
            (ms) => loadKg + peakToPeakKg / 2 * sin(2 * pi * ms / 500),
          );

      expect(SteadyLoadDetector().add(swinging(20, 0.05)), isTrue);
      expect(SteadyLoadDetector().add(swinging(20, 0.08)), isFalse);
      expect(SteadyLoadDetector().add(swinging(2, 0.03)), isFalse);
    });

    test('ignores BLE spikes in fewer than half of a slice', () {
      // Spikes every 30 ms in the first half of the window: their mean offset
      // of up to 64 g in those slices would exceed the 30 g tolerance.
      final samples = _samples(
        1000,
        10,
        (ms) => ms < 500 && ms % 30 == 0 ? 10.16 : 10,
      );

      expect(SteadyLoadDetector().add(samples), isTrue);
    });

    test('rejects a creeping load', () {
      final detector = SteadyLoadDetector();

      expect(
        detector.add(_samples(2000, 10, (ms) => 20 + ms / 10000)),
        isFalse,
      );
    });

    test('rejects a window with a gap in the samples', () {
      final detector = SteadyLoadDetector();

      expect(detector.add([_sample(20, 0), _sample(20, 1000)]), isFalse);
    });

    test('starts a new window when the timeline restarts', () {
      final detector = SteadyLoadDetector()..add(_samples(1000, 10, (_) => 5));

      expect(detector.add([_sample(5, 0)]), isFalse);
      expect(detector.receivedSamples, isTrue);
    });

    test('reports whether samples arrived', () {
      final detector = SteadyLoadDetector();

      expect(detector.add(const []), isFalse);
      expect(detector.receivedSamples, isFalse);
    });
  });

  group('TimestampUnwrapper', () {
    test('continues the timeline across the u32 wrap', () {
      final unwrapper = TimestampUnwrapper();

      expect(unwrapper.unwrap(0xFFFFFF00), 0xFFFFFF00);
      expect(unwrapper.unwrap(0x100), 0x100000100);
      expect(unwrapper.unwrap(0x200), 0x100000200);
    });

    test('does not treat a small step back as a wrap', () {
      final unwrapper = TimestampUnwrapper()..unwrap(5000000);

      expect(unwrapper.unwrap(1000), 1000);
    });
  });

  group('batteryStateOfCharge', () {
    test('clamps outside the curve', () {
      expect(batteryStateOfCharge(3000), 0);
      expect(batteryStateOfCharge(3300), 0);
      expect(batteryStateOfCharge(4300), 100);
    });

    test('interpolates between curve points', () {
      expect(batteryStateOfCharge(3840), 50);
      expect(batteryStateOfCharge(3845), 53);
      expect(batteryStateOfCharge(4200), 100);
    });
  });

  group('CalibrationCheck', () {
    test('needs two points', () {
      expect(CalibrationCheck.of([(raw: 1000, weightKg: 5)], 1), isNull);
    });

    test('finds no error when the factor fits the points', () {
      // 1 g per count: 5 kg at 5000 counts above the 1000 count offset.
      final check = CalibrationCheck.of([
        (raw: 1000, weightKg: 0),
        (raw: 6000, weightKg: 5),
        (raw: 21000, weightKg: 20),
      ], 1)!;

      expect(check.maxErrorKg, closeTo(0, 1e-9));
      expect(check.rmsErrorKg, closeTo(0, 1e-9));
      expect(check.verifiesFit, isTrue);
    });

    test('does not verify a fit of two distinct weights', () {
      final check = CalibrationCheck.of([
        (raw: 1000, weightKg: 0),
        (raw: 1001, weightKg: 0),
        (raw: 1002, weightKg: 20),
      ], 1)!;

      expect(check.verifiesFit, isFalse);
    });

    test('reports the error of each point against the device line', () {
      final check = CalibrationCheck.of([
        (raw: 0, weightKg: 0),
        (raw: 10000, weightKg: 10.3),
        (raw: 20000, weightKg: 20),
      ], 1)!;

      // Line through the zero-weight point with 1 g per count.
      expect(
        [for (final residual in check.residuals) residual.errorKg],
        [closeTo(0, 1e-9), closeTo(-0.3, 1e-9), closeTo(0, 1e-9)],
      );
      expect(check.maxErrorKg, closeTo(0.3, 1e-9));
      expect(check.maxErrorPercentOfSpan, closeTo(1.5, 1e-9));
    });

    test('anchors at the average zero-weight point', () {
      final check = CalibrationCheck.of([
        (raw: 0, weightKg: 0),
        (raw: 200, weightKg: 0),
        (raw: 10100, weightKg: 10),
      ], 1)!;

      // Line through (100, 0) with 1 g per count.
      expect(
        [for (final residual in check.residuals) residual.errorKg],
        [closeTo(-0.1, 1e-9), closeTo(0.1, 1e-9), closeTo(0, 1e-9)],
      );
    });

    test('uses the mean point without a zero-weight point', () {
      final check = CalibrationCheck.of([
        (raw: 10000, weightKg: 10.3),
        (raw: 20000, weightKg: 20),
        (raw: 30000, weightKg: 30.3),
      ], 1)!;

      // Line through the mean (20000, 20.2) with 1 g per count.
      expect(
        [for (final residual in check.residuals) residual.errorKg],
        [closeTo(-0.1, 1e-9), closeTo(0.2, 1e-9), closeTo(-0.1, 1e-9)],
      );
    });
  });

  group('CalibrationCurve', () {
    // The same curves and values as the firmware test
    // `evaluates_the_curves_the_app_previews`.
    test('evaluates like the firmware, extrapolating straight', () {
      const linear = CalibrationCurve(
        model: CalibrationModel.linear,
        coefficients: [0.1, 0.5, 0, 0],
        referenceRaw: 1000,
        scale: 50000,
        xMin: 0,
        xMax: 1,
      );
      expect(linear.kg(21000), closeTo(2.5, 1e-9));
      expect(linear.kg(-9000), closeTo(-0.5, 1e-9));

      const quadratic = CalibrationCurve(
        model: CalibrationModel.quadratic,
        coefficients: [-10, 100, 0, 0],
        referenceRaw: 0,
        scale: 1e6,
        xMin: 0,
        xMax: 1,
      );
      expect(quadratic.kg(500000), closeTo(47.5, 1e-9));
      // Straight with the end slopes, 80 and 100 kg per x, so it cannot turn
      // back like the unrestricted quadratic.
      expect(quadratic.kg(3e6), closeTo(250, 1e-9));
      expect(quadratic.kg(-5e5), closeTo(-50, 1e-9));
      expect(quadratic.kgAt(10), greaterThan(quadratic.kgAt(5)));

      // Reversed wiring: the raw value falls with the load.
      const piecewise = CalibrationCurve(
        model: CalibrationModel.piecewise,
        coefficients: [0.2, 90, 100, 0.5],
        referenceRaw: -2000,
        scale: -1e6,
        xMin: 0,
        xMax: 1,
      );
      expect(piecewise.kg(-252000), closeTo(22.7, 1e-9));
      expect(piecewise.kg(-752000), closeTo(70.2, 1e-9));
      expect(piecewise.kg(-2002000), closeTo(195.2, 1e-9));
      expect(piecewise.kg(98000), closeTo(-8.8, 1e-9));
      // Continuous at the breakpoint.
      expect(
        piecewise.kgAt(0.5 + 1e-9) - piecewise.kgAt(0.5 - 1e-9),
        closeTo(0, 1e-6),
      );
      expect(piecewise.breakpointRaw, -502000);
      expect(piecewise.rawRange, (-2000, -1002000));
    });
  });

  group('CalibrationDetails', () {
    CalibrationDetails details({double? tareLoadKg, bool hasFit = true}) =>
        CalibrationDetails(
          info: CalibrationInfo(
            version: 1,
            supportedModels: CalibrationModel.values.toSet(),
            model: CalibrationModel.quadratic,
            pointCount: 0,
            hasFit: hasFit,
            pending: null,
            lastCommand: null,
          ),
          coefficients: const [-10, 100, 0, 0],
          coordinates: CalibrationCoordinates(0, 1e6, 0, 0.9),
          fit: CalibrationFitSummary(0.1, 0.2, 0, hasFit ? 81.9 : null),
          tare: CalibrationTare(tareLoadKg, 0),
          points: const [],
        );

    test('flags readings outside the calibrated range', () {
      final unloaded = details(tareLoadKg: 0);
      // Half a percent of the range, 0.41 kg, counts as inside.
      expect(unloaded.isOutsideRange(-0.3), isFalse);
      expect(unloaded.isOutsideRange(-0.5), isTrue);
      expect(unloaded.isOutsideRange(82.2), isFalse);
      expect(unloaded.isOutsideRange(82.5), isTrue);

      // Tared under 30 kg, a 55 kg reading is 85 kg of load.
      final preloaded = details(tareLoadKg: 30);
      expect(preloaded.isOutsideRange(45), isFalse);
      expect(preloaded.isOutsideRange(55), isTrue);
      expect(preloaded.isOutsideRange(-31), isTrue);

      expect(details().isOutsideRange(200), isNull);
      expect(details(hasFit: false, tareLoadKg: 0).isOutsideRange(200), isNull);
    });

    test('has an average sensitivity for a nonlinear curve', () {
      // 81.9 kg over 900000 counts.
      expect(details().gramsPerCount, closeTo(0.091, 1e-9));
      expect(details().linearFactor, isNull);
    });
  });

  group('isReadingUnchanged', () {
    // 1 g per count unless stated otherwise.
    bool unchanged(double weightKg, double counts, {double factor = 1}) =>
        isReadingUnchanged(
          previousWeightKg: 0,
          previousCounts: 10,
          weightKg: weightKg,
          counts: counts,
          factor: factor,
        );

    test('flags a reading that did not follow the weight', () {
      expect(unchanged(20, 20), isTrue);
      expect(unchanged(20, 1900), isTrue);
    });

    test('accepts a reading that followed the weight', () {
      expect(unchanged(20, 2100), isFalse);
      expect(unchanged(20, 18000), isFalse);
    });

    test('compares the counts with the current factor', () {
      // 10 g per count: 300 counts are 3 kg.
      expect(unchanged(20, 310, factor: 10), isFalse);
      expect(unchanged(20, 110, factor: 10), isTrue);
    });

    test('accepts the same weight again', () {
      expect(unchanged(0, 10), isFalse);
    });
  });
}
