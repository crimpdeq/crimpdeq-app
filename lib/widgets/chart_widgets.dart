import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/progressor_models.dart' as progressor_models;
import '../theme/app_theme.dart';

class WeightHistoryCard extends StatelessWidget {
  const WeightHistoryCard({super.key, required this.measurement});

  final progressor_models.MeasurementState measurement;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Clamp all Y values to >= 0
    final weightHistory = measurement.weightHistory
        .map((s) => FlSpot(s.x, s.y < 0 ? 0 : s.y))
        .toList();
    final dataMaxX = weightHistory.isNotEmpty ? weightHistory.last.x : 0.0;
    final peakY = measurement.maxWeight < 0 ? 0.0 : measurement.maxWeight;

    // X-axis: 15s chunks, always show 0 → end
    const chunk = 15.0;
    final resolvedMaxX =
        ((dataMaxX / chunk).ceil() * chunk).clamp(chunk, double.infinity);

    // Y-axis: 0 → max, minimal headroom so dotted line hugs the label
    final chartMaxY = peakY < 5 ? 5.0 : (peakY * 1.02).ceilToDouble();

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.4),
          ),
          color: colorScheme.surface.withValues(alpha: 0.5),
        ),
        padding: const EdgeInsets.only(top: 8, left: 4, right: 24, bottom: 4),
        child: Stack(
          children: [
            // Max KPI overlay — top-right inside chart
            if (peakY > 0)
              Positioned(
                top: 0,
                right: 2,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: webAccentStrong.withValues(alpha: 0.2),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      topRight: Radius.circular(14),
                    ),
                  ),
                  child: Text(
                    'MAX ${peakY.toStringAsFixed(1)} kg',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: webAccentStrong,
                    ),
                  ),
                ),
              ),
            // Chart
            LineChart(
              duration: Duration.zero,
              LineChartData(
                minX: 0,
                maxX: resolvedMaxX,
                minY: 0,
                maxY: chartMaxY,
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
                              '${spot.y.toStringAsFixed(1)} kg',
                              GoogleFonts.spaceGrotesk(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
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
                      reservedSize: 50,
                      interval: _yInterval(0, chartMaxY),
                      getTitlesWidget: (value, meta) {
                        final v = value < 0 ? 0.0 : value;
                        if (v == meta.max) return const SizedBox.shrink();
                        // Skip 0 on Y — shared with X origin
                        if (v == 0) return const SizedBox.shrink();
                        return Padding(
                          padding:
                              const EdgeInsets.only(left: 8, right: 2),
                          child: Text(
                            '${v.toStringAsFixed(0)} kg',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              color: webMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: _xInterval(resolvedMaxX),
                      getTitlesWidget: (value, meta) {
                        if (value != value.roundToDouble()) {
                          return const SizedBox.shrink();
                        }
                        // At origin show shared "0"
                        final label = value == 0
                            ? '0'
                            : _formatSeconds(value);
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            label,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              color: webMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
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
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: colorScheme.outline.withValues(alpha: 0.15),
                    strokeWidth: 0.5,
                  ),
                ),
                borderData: FlBorderData(show: false),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    if (peakY > 0)
                      HorizontalLine(
                        y: peakY,
                        color: webAccentStrong.withValues(alpha: 0.4),
                        strokeWidth: 1,
                        dashArray: [6, 4],
                      ),
                  ],
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: weightHistory,
                    isCurved: true,
                    curveSmoothness: 0.15,
                    color: colorScheme.primary,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          colorScheme.primary.withValues(alpha: 0.2),
                          colorScheme.primary.withValues(alpha: 0.02),
                        ],
                      ),
                    ),
                  ),
                ],
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
    final history = performance.notifyIntervalHistory;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notify Interval',
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
                        getTitlesWidget: (value, meta) {
                          if (value == meta.min || value == meta.max) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            '${value.toInt()} ms',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 10,
                              color: webMuted,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
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
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: colorScheme.outline.withValues(alpha: 0.15),
                      strokeWidth: 0.5,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
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
                      isCurved: true,
                      curveSmoothness: 0.15,
                      color: colorScheme.primary,
                      barWidth: 1.5,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            colorScheme.primary.withValues(alpha: 0.15),
                            colorScheme.primary.withValues(alpha: 0.02),
                          ],
                        ),
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
                  'Min: ${history.isNotEmpty ? history.reduce((a, b) => a < b ? a : b).toStringAsFixed(1) : "0.0"} ms',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: webMuted,
                  ),
                ),
                Text(
                  'Max: ${history.isNotEmpty ? history.reduce((a, b) => a > b ? a : b).toStringAsFixed(1) : "0.0"} ms',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: webMuted,
                  ),
                ),
                Text(
                  'Avg: ${history.isNotEmpty ? (history.reduce((a, b) => a + b) / history.length).toStringAsFixed(1) : "0.0"} ms',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: webMuted,
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

/// Pick X-axis interval: 1s per label up to 15s, then scale up.
double _xInterval(double maxX) {
  if (maxX <= 15) return 1;
  if (maxX <= 30) return 2;
  if (maxX <= 60) return 5;
  if (maxX <= 120) return 10;
  return 15;
}

/// Pick a clean Y-axis interval so labels don't duplicate.
double _yInterval(double minY, double maxY) {
  final range = (maxY - minY).abs();
  if (range <= 4) return 1;
  if (range <= 10) return 2;
  if (range <= 25) return 5;
  return 10;
}

/// Formats seconds for chart axis labels.
String _formatSeconds(double seconds) {
  if (seconds < 0) return '';
  if (seconds < 60) {
    final rounded = seconds.round();
    return '${rounded}s';
  }
  final m = seconds ~/ 60;
  final s = (seconds % 60).round();
  return '$m:${s.toString().padLeft(2, '0')}';
}
