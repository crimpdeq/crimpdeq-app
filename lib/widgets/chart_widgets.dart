import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/progressor_models.dart' as progressor_models;

class WeightHistoryCard extends StatelessWidget {
  const WeightHistoryCard({super.key, required this.measurement});

  final progressor_models.MeasurementState measurement;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final weightHistory = measurement.weightHistory;
    final minX = weightHistory.isNotEmpty ? weightHistory.first.x : 0.0;
    final maxX = weightHistory.isNotEmpty ? weightHistory.last.x : 1.0;
    final resolvedMaxX = maxX <= minX ? minX + 1.0 : maxX;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weight History',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: LineChart(
                duration: Duration.zero,
                LineChartData(
                  minX: minX,
                  maxX: resolvedMaxX,
                  minY: measurement.minWeight - 1,
                  maxY: measurement.maxWeight + 1,
                  clipData: const FlClipData.all(),
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots
                            .map(
                              (spot) => LineTooltipItem(
                                '${spot.y.toStringAsFixed(3)} kg\n${(spot.x * 1000).toStringAsFixed(0)} ms',
                                TextStyle(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            )
                            .toList();
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toStringAsFixed(1)}kg',
                          style: textTheme.bodySmall?.copyWith(fontSize: 10),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}',
                          style: textTheme.bodySmall?.copyWith(fontSize: 10),
                        ),
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                      strokeWidth: 1,
                    ),
                    getDrawingVerticalLine: (_) => FlLine(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: colorScheme.outline),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: weightHistory,
                      isCurved: false,
                      color: colorScheme.primary,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: colorScheme.primary.withValues(alpha: 0.12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotifyIntervalCard extends StatelessWidget {
  const NotifyIntervalCard({super.key, required this.performance});

  final progressor_models.PerformanceMetrics performance;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final history = performance.notifyIntervalHistory;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notify Interval Graph',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: history.isNotEmpty
                      ? history.reduce((a, b) => a > b ? a : b) * 1.2
                      : 100,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}ms',
                          style: textTheme.bodySmall?.copyWith(fontSize: 10),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) => Text(
                          '-${(history.length - value.toInt()).toString()}',
                          style: textTheme.bodySmall?.copyWith(fontSize: 10),
                        ),
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 10,
                    verticalInterval: 10,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                      strokeWidth: 1,
                    ),
                    getDrawingVerticalLine: (_) => FlLine(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: colorScheme.outline),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: history
                          .asMap()
                          .entries
                          .map(
                            (entry) =>
                                FlSpot(entry.key.toDouble(), entry.value),
                          )
                          .toList(),
                      isCurved: false,
                      color: colorScheme.primary,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: colorScheme.primary.withValues(alpha: 0.12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'Min: ${history.isNotEmpty ? history.reduce((a, b) => a < b ? a : b).toStringAsFixed(2) : "0.00"}ms',
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Max: ${history.isNotEmpty ? history.reduce((a, b) => a > b ? a : b).toStringAsFixed(2) : "0.00"}ms',
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Avg: ${history.isNotEmpty ? (history.reduce((a, b) => a + b) / history.length).toStringAsFixed(2) : "0.00"}ms',
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
