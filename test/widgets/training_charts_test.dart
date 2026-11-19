import 'package:crimpdeq/analysis/opengrips_curve.dart';
import 'package:crimpdeq/models/progressor_models.dart';
import 'package:crimpdeq/models/training_models.dart';
import 'package:crimpdeq/providers/progressor_provider.dart';
import 'package:crimpdeq/widgets/training_charts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:crimpdeq/widgets/training_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Without Bluetooth, for the tare button.
class _Disconnected extends ProgressorNotifier {
  @override
  ProgressorState build() => const ProgressorState();
}

void main() {
  group('ForceCurveGraph', () {
    Future<LineChartData> pumpGraph(
      WidgetTester tester,
      List<CurvePoint> workouts,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ForceCurveGraph(benchmarkKg: 100, workouts: workouts),
          ),
        ),
      );
      return tester.widget<LineChart>(find.byType(LineChart)).data;
    }

    testWidgets('spans the curve from the floor to the benchmark', (
      tester,
    ) async {
      final data = await pumpGraph(tester, [
        (forceKg: 40, firstHangSeconds: 100),
      ]);
      expect(data.minX, closeTo(12.73, 0.01));
      expect(data.maxX, 100);
    });

    testWidgets('widens to the workouts outside the curve', (tester) async {
      final data = await pumpGraph(tester, [
        (forceKg: 8, firstHangSeconds: 120),
        (forceKg: 105, firstHangSeconds: 4),
      ]);
      expect(data.minX, 8);
      expect(data.maxX, 105);
    });
  });

  testWidgets('BenchmarkProgressGraph draws a line per hand over four dates', (
    tester,
  ) async {
    Benchmark benchmark(int day, Hand hand, double forceKg) => Benchmark(
      date: DateTime(2026, 6, day),
      tool: 'Photon',
      hand: hand,
      forceKg: forceKg,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BenchmarkProgressGraph(
            benchmarks: [
              benchmark(1, Hand.left, 20),
              benchmark(1, Hand.right, 22),
              benchmark(31, Hand.right, 25),
            ],
          ),
        ),
      ),
    );
    final data = tester.widget<LineChart>(find.byType(LineChart)).data;
    expect(data.lineBarsData.map((bar) => bar.spots.length), [1, 2]);
    expect(data.lineBarsData.last.spots.last.x, 3);
    for (final date in ['1 Jun', '11 Jun', '21 Jun', '1 Jul']) {
      expect(find.text(date), findsOne);
    }
  });

  for (final (currentKg, onTarget) in [(19.5, true), (18.5, false)]) {
    testWidgets('LiveForceGraph shows $currentKg kg '
        '${onTarget ? 'on' : 'off'} a 20 kg target', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [progressorProvider.overrideWith(_Disconnected.new)],
          child: MaterialApp(
            home: Scaffold(
              body: LiveForceGraph(
                trace: const [],
                currentKg: currentKg,
                target: (kg: 20, thresholdKg: 2, section: CurveSection.power),
              ),
            ),
          ),
        ),
      );
      final reading = tester.widget<Text>(find.text('$currentKg kg'));
      expect(reading.style?.color == gainColor, onTarget);
      // The band around the target.
      final band = tester
          .widget<LineChart>(find.byType(LineChart))
          .data
          .rangeAnnotations
          .horizontalRangeAnnotations
          .single;
      expect((band.y1, band.y2), (19, 21));
    });
  }

  test('holdDeltaColor keeps a hold within the tolerance neutral', () {
    expect(holdDeltaColor(-2), isNull);
    expect(holdDeltaColor(3), isNull);
    expect(holdDeltaColor(-3.5), lossColor);
    expect(holdDeltaColor(4), gainColor);
  });

  test('formatHeld shows a short hold in tenths, not as 0 s', () {
    expect(formatHeld(0.4), '0.4 s');
    expect(formatHeld(7.46), '7.5 s');
    expect(formatHeld(9.96), '10 s');
    expect(formatHeld(14.9), '15 s');
    // The delta follows the time as shown.
    expect(shownHeldSeconds(0.4) - 4, closeTo(-3.6, 1e-9));
  });
}
