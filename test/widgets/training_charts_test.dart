import 'package:crimpdeq/analysis/opengrips_curve.dart';
import 'package:crimpdeq/models/training_models.dart';
import 'package:crimpdeq/widgets/training_charts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
}
