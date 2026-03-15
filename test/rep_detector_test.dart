import 'package:flutter_test/flutter_test.dart';
import 'package:crimpdeq/services/rep_detector.dart';

void main() {
  group('RepDetector', () {
    late RepDetector detector;

    setUp(() {
      detector = RepDetector(
        config: const RepDetectorConfig(
          hangThresholdKg: 5.0,
          debounceMs: 200,
          minHangDurationMs: 1000,
        ),
      );
    });

    test('starts in idle state', () {
      expect(detector.state, RepDetectorState.idle);
    });

    test('stays idle when weight is below threshold', () {
      for (var i = 0; i < 20; i++) {
        final result = detector.process(2.0, i * 100);
        expect(result.state, RepDetectorState.idle);
        expect(result.completedRep, isNull);
      }
    });

    test('transitions to hanging after debounce period above threshold', () {
      // Below threshold
      detector.process(2.0, 0);
      expect(detector.state, RepDetectorState.idle);

      // First sample above threshold — starts debounce
      detector.process(10.0, 100);
      expect(detector.state, RepDetectorState.idle);

      // Still within debounce
      detector.process(10.0, 200);
      expect(detector.state, RepDetectorState.idle);

      // Debounce complete (200ms elapsed since first above-threshold)
      final result = detector.process(12.0, 300);
      expect(result.state, RepDetectorState.hanging);
    });

    test('completes a rep when hang exceeds min duration then drops below threshold', () {
      // Enter hang
      detector.process(10.0, 0);
      detector.process(10.0, 100);
      detector.process(12.0, 200); // transitions to hanging

      // Hold for >1000ms
      for (var t = 300; t <= 1300; t += 100) {
        detector.process(15.0, t);
      }
      expect(detector.state, RepDetectorState.hanging);

      // Drop below threshold
      detector.process(1.0, 1400);
      expect(detector.state, RepDetectorState.hanging); // still in debounce

      // After debounce, rep completes
      final result = detector.process(1.0, 1600);
      expect(result.state, RepDetectorState.resting);
      expect(result.completedRep, isNotNull);
      expect(result.completedRep!.peakForceKg, 15.0);
      expect(result.completedRep!.durationMs, greaterThanOrEqualTo(1000));
      expect(result.completedRep!.weightSamples, isNotEmpty);
    });

    test('discards short hangs below min duration', () {
      // Enter hang
      detector.process(10.0, 0);
      detector.process(10.0, 100);
      detector.process(12.0, 200); // transitions to hanging

      // Only 500ms hang
      for (var t = 300; t <= 600; t += 100) {
        detector.process(15.0, t);
      }

      // Drop below
      detector.process(1.0, 700);
      final result = detector.process(1.0, 900);
      expect(result.state, RepDetectorState.resting);
      expect(result.completedRep, isNull); // discarded, too short
    });

    test('resets debounce when weight drops back below threshold during onset', () {
      detector.process(10.0, 0); // above threshold
      detector.process(10.0, 100); // still debouncing
      detector.process(2.0, 150); // drops below — resets debounce
      detector.process(10.0, 200); // new onset
      detector.process(10.0, 300); // still debouncing

      expect(detector.state, RepDetectorState.idle);

      // Debounce completes from t=200
      final result = detector.process(10.0, 400);
      expect(result.state, RepDetectorState.hanging);
    });

    test('reset clears state', () {
      detector.process(10.0, 0);
      detector.process(10.0, 100);
      detector.process(12.0, 200);
      expect(detector.state, RepDetectorState.hanging);

      detector.reset();
      expect(detector.state, RepDetectorState.idle);
    });

    test('updateConfig changes threshold', () {
      detector.updateConfig(const RepDetectorConfig(hangThresholdKg: 20.0));

      // 10kg is now below threshold
      detector.process(10.0, 0);
      detector.process(10.0, 200);
      detector.process(10.0, 400);
      expect(detector.state, RepDetectorState.idle);

      // 25kg is above
      detector.process(25.0, 500);
      detector.process(25.0, 700);
      expect(detector.state, RepDetectorState.hanging);
    });

    test('captures peak force correctly across a rep', () {
      // Enter hang
      detector.process(10.0, 0);
      detector.process(10.0, 200);

      // Vary weight during hang
      detector.process(12.0, 300);
      detector.process(18.0, 500);
      detector.process(14.0, 700);
      detector.process(20.0, 900);
      detector.process(16.0, 1100);
      detector.process(10.0, 1300);

      // Drop and complete
      detector.process(1.0, 1400);
      final result = detector.process(1.0, 1600);
      expect(result.completedRep, isNotNull);
      expect(result.completedRep!.peakForceKg, 20.0);
      expect(result.completedRep!.avgForceKg, greaterThan(0));
    });

    test('can detect multiple consecutive reps', () {
      final completedReps = <dynamic>[];

      void doHang(int startMs) {
        // Enter
        detector.process(10.0, startMs);
        detector.process(10.0, startMs + 200);
        // Hold
        for (var t = startMs + 300; t <= startMs + 1300; t += 100) {
          detector.process(15.0, t);
        }
        // Release
        detector.process(1.0, startMs + 1400);
        final result = detector.process(1.0, startMs + 1600);
        if (result.completedRep != null) {
          completedReps.add(result.completedRep);
        }
      }

      doHang(0);
      doHang(2000);
      doHang(4000);

      expect(completedReps.length, 3);
    });
  });
}
