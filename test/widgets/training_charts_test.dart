import 'package:crimpdeq/analysis/opengrips_curve.dart';
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
}
