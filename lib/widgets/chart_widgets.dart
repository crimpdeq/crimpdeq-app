import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/progressor_models.dart' as progressor_models;

class WeightHistoryCard extends StatelessWidget {
  const WeightHistoryCard({super.key, required this.measurement});

  final progressor_models.MeasurementState measurement;

  @override
  Widget build(BuildContext context) {
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
                LineChartData(
                  minY: measurement.minWeight - 1,
                  maxY: measurement.maxWeight + 1,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget:
                            (value, meta) => Text(
                              '${value.toStringAsFixed(1)}kg',
                              style: const TextStyle(fontSize: 10),
                            ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget:
                            (value, meta) => Text(
                              '${value.toInt()}',
                              style: const TextStyle(fontSize: 10),
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
                  gridData: FlGridData(show: true, drawVerticalLine: true),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: measurement.weightHistory,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.1),
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
                  maxY:
                      history.isNotEmpty
                          ? history.reduce((a, b) => a > b ? a : b) * 1.2
                          : 100,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget:
                            (value, meta) => Text(
                              '${value.toInt()}ms',
                              style: const TextStyle(fontSize: 10),
                            ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget:
                            (value, meta) => Text(
                              '-${(history.length - value.toInt()).toString()}',
                              style: const TextStyle(fontSize: 10),
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
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots:
                          history
                              .asMap()
                              .entries
                              .map(
                                (entry) =>
                                    FlSpot(entry.key.toDouble(), entry.value),
                              )
                              .toList(),
                      isCurved: false,
                      color: Colors.green,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green.withOpacity(0.1),
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
                  style: const TextStyle(fontSize: 12, color: Colors.green),
                ),
                Text(
                  'Max: ${history.isNotEmpty ? history.reduce((a, b) => a > b ? a : b).toStringAsFixed(2) : "0.00"}ms',
                  style: const TextStyle(fontSize: 12, color: Colors.red),
                ),
                Text(
                  'Avg: ${history.isNotEmpty ? (history.reduce((a, b) => a + b) / history.length).toStringAsFixed(2) : "0.00"}ms',
                  style: const TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
