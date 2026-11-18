import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../analysis/force_trace.dart';
import '../analysis/opengrips_curve.dart';
import 'training_common.dart';

/// OpenGrips colors of the curve sections.
const sectionColors = {
  CurveSection.endurance: Color(0xFF22C55E),
  CurveSection.strengthEndurance: Color(0xFF3B82F6),
  CurveSection.strength: Color(0xFFEAB308),
  CurveSection.powerStrength: Color(0xFFF97316),
  CurveSection.power: Color(0xFFEF4444),
};

/// A section's color for text, darker on a light background, where yellow and
/// orange lack contrast.
Color sectionTextColor(BuildContext context, CurveSection section) {
  final color = sectionColors[section]!;
  return Theme.of(context).brightness == Brightness.light
      ? Color.lerp(color, Colors.black, 0.3)!
      : color;
}

const _idealCurveColor = Color(0xFFEF4444);
const _workoutColor = Color(0xFFF97316);

const _hiddenTitles = AxisTitles(sideTitles: SideTitles(showTitles: false));

/// Titles with a unit. Fractional bounds would overlap the interval labels,
/// so they are labeled only when [minIncluded] or [maxIncluded].
AxisTitles _titles(
  BuildContext context,
  String Function(double value) label, {
  double reservedSize = 30,
  double? interval,
  bool minIncluded = true,
  bool maxIncluded = true,
}) => AxisTitles(
  sideTitles: SideTitles(
    showTitles: true,
    reservedSize: reservedSize,
    interval: interval,
    minIncluded: minIncluded,
    maxIncluded: maxIncluded,
    getTitlesWidget: (value, meta) => Text(
      label(value),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
    ),
  ),
);

FlGridData _grid(ColorScheme colorScheme) => FlGridData(
  getDrawingHorizontalLine: (_) => FlLine(
    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
    strokeWidth: 1,
  ),
  getDrawingVerticalLine: (_) => FlLine(
    color: colorScheme.outlineVariant.withValues(alpha: 0.35),
    strokeWidth: 1,
  ),
);

LineTooltipItem _tooltip(BuildContext context, String text) => LineTooltipItem(
  text,
  TextStyle(
    color: Theme.of(context).colorScheme.onSurface,
    fontWeight: FontWeight.w600,
    fontSize: 11,
  ),
);

List<FlSpot> _repSpots(List<num> seconds) => [
  for (final (rep, value) in seconds.indexed) FlSpot(rep + 1, value.toDouble()),
];

class _Legend extends StatelessWidget {
  const _Legend(this.entries);

  final List<(Color, String)> entries;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      children: [
        for (final (color, label) in entries)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, size: 10, color: color),
              const SizedBox(width: 4),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
      ],
    );
  }
}

/// The forecast of each rep's target, in the section's color.
class TargetWorkoutGraph extends StatelessWidget {
  const TargetWorkoutGraph({
    super.key,
    required this.targets,
    required this.section,
  });

  final List<int> targets;
  final CurveSection section;

  @override
  Widget build(BuildContext context) {
    final color = sectionColors[section]!;
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: LineChart(
            duration: Duration.zero,
            LineChartData(
              minX: 1,
              maxX: max(targets.length, 2).toDouble(),
              minY: 0,
              maxY: max(targets.reduce(max), 50).toDouble(),
              lineBarsData: [
                LineChartBarData(
                  spots: _repSpots(targets),
                  color: color,
                  barWidth: 2.5,
                  dashArray: [8, 6],
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        color.withValues(alpha: 0.22),
                        color.withValues(alpha: 0.07),
                      ],
                    ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipItems: (spots) => [
                    for (final spot in spots)
                      _tooltip(
                        context,
                        'Rep ${spot.x.round()}: ${spot.y.round()} s',
                      ),
                  ],
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: _hiddenTitles,
                rightTitles: _hiddenTitles,
                leftTitles: _titles(
                  context,
                  (value) => '${value.round()} s',
                  reservedSize: 40,
                  maxIncluded: false,
                ),
                bottomTitles: _titles(
                  context,
                  (value) => 'Rep ${value.round()}',
                  interval: 1,
                ),
              ),
              gridData: _grid(Theme.of(context).colorScheme),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        _Legend([(color, 'Forecasted')]),
      ],
    );
  }
}

/// The force of the latest [ForceTrace.windowSeconds] over the time since
/// the start, the newest at the right, under the current force, centered,
/// and a tare button. With a [target], also its force and the threshold the
/// hold counts above.
class LiveForceGraph extends StatelessWidget {
  const LiveForceGraph({
    super.key,
    required this.trace,
    required this.currentKg,
    this.target,
  });

  final List<FlSpot> trace;

  /// Null without a reading.
  final double? currentKg;
  final ({double kg, double thresholdKg, CurveSection section})? target;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final target = this.target;
    final currentKg = this.currentKg;
    final targetColor = target == null ? null : sectionColors[target.section]!;
    // The window ends at the newest point, so it scrolls with the force.
    final maxX = max(
      ForceTrace.windowSeconds.toDouble(),
      trace.lastOrNull?.x ?? 0,
    );
    final peakKg = trace.fold(0.0, (peak, spot) => max(peak, spot.y));
    return Column(
      children: [
        Row(
          children: [
            const Spacer(),
            Text(
              currentKg == null ? '—' : formatKg(currentKg),
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: FittedBox(fit: BoxFit.scaleDown, child: TareButton()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: LineChart(
            duration: Duration.zero,
            LineChartData(
              minX: maxX - ForceTrace.windowSeconds,
              maxX: maxX,
              minY: 0,
              maxY: max((target?.kg ?? 8) * 1.25, peakKg * 1.1),
              clipData: const FlClipData.all(),
              lineBarsData: [
                LineChartBarData(
                  spots: trace,
                  color: colorScheme.primary,
                  barWidth: 2.5,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: colorScheme.primary.withValues(alpha: 0.12),
                  ),
                ),
              ],
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  if (target != null) ...[
                    HorizontalLine(
                      y: target.kg,
                      color: targetColor,
                      strokeWidth: 2,
                    ),
                    HorizontalLine(
                      y: target.thresholdKg,
                      color: targetColor!.withValues(alpha: 0.7),
                      strokeWidth: 1.5,
                      dashArray: [6, 4],
                    ),
                  ],
                ],
              ),
              lineTouchData: const LineTouchData(enabled: false),
              titlesData: FlTitlesData(
                topTitles: _hiddenTitles,
                rightTitles: _hiddenTitles,
                leftTitles: _titles(
                  context,
                  (value) => '${value.round()} kg',
                  reservedSize: 44,
                  maxIncluded: false,
                ),
                // The time since the pull or workout started.
                bottomTitles: _titles(
                  context,
                  (value) => formatDuration(value.round()),
                  interval: 5,
                  minIncluded: false,
                  maxIncluded: false,
                ),
              ),
              gridData: _grid(colorScheme),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        if (target != null)
          _Legend([
            (colorScheme.primary, 'Force'),
            (targetColor!, 'Target ${formatKg(target.kg)}'),
            (
              targetColor.withValues(alpha: 0.7),
              '${formatKg(target.thresholdKg)}: hold counts',
            ),
          ]),
      ],
    );
  }
}

/// Past workouts by force and first hold, against the ideal force curve.
/// With a [section], also its force range and the target force.
class ForceCurveGraph extends StatelessWidget {
  const ForceCurveGraph({
    super.key,
    required this.benchmarkKg,
    required this.workouts,
    this.section,
    this.targetForceKg,
  });

  final double benchmarkKg;
  final List<CurvePoint> workouts;
  final CurveSection? section;
  final double? targetForceKg;

  @override
  Widget build(BuildContext context) {
    final section = this.section;
    final targetForceKg = this.targetForceKg;
    final floorKg = curveFloorKg(benchmarkKg);
    final axisKg = forceAxisKg(benchmarkKg, [
      for (final workout in workouts) workout.forceKg,
    ]);
    final sectionKg = section?.rangeKg(benchmarkKg);
    final maxSeconds = [
      CurveSection.endurance.firstRepSeconds.toDouble(),
      for (final workout in workouts) workout.firstHangSeconds,
    ].reduce(max);
    final idealCurve = [
      for (var seconds = 5; seconds <= maxSeconds; seconds += 2)
        if (idealForceKg(seconds.toDouble(), benchmarkKg) case final kg
            when kg >= floorKg)
          FlSpot(kg, seconds.toDouble()),
    ].reversed.toList();

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: LineChart(
            duration: Duration.zero,
            LineChartData(
              minX: axisKg.min,
              maxX: axisKg.max,
              minY: 0,
              // Headroom, so the longest first hang's dot is not cut.
              maxY: maxSeconds * 1.1,
              clipData: const FlClipData.all(),
              rangeAnnotations: RangeAnnotations(
                verticalRangeAnnotations: [
                  if (sectionKg != null)
                    VerticalRangeAnnotation(
                      x1: sectionKg.min,
                      x2: sectionKg.max,
                      color: sectionColors[section]!.withValues(alpha: 0.15),
                    ),
                ],
              ),
              extraLinesData: ExtraLinesData(
                verticalLines: [
                  if (section != null && targetForceKg != null)
                    VerticalLine(
                      x: targetForceKg,
                      color: sectionColors[section]!,
                      strokeWidth: 2,
                      dashArray: [5, 5],
                    ),
                ],
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: idealCurve,
                  color: _idealCurveColor,
                  barWidth: 2.5,
                  dotData: const FlDotData(show: false),
                ),
                // Dots only: the workouts are not a series.
                LineChartBarData(
                  spots: [
                    for (final workout in workouts)
                      FlSpot(workout.forceKg, workout.firstHangSeconds),
                  ],
                  color: Colors.transparent,
                  barWidth: 0,
                  dotData: FlDotData(
                    getDotPainter: (spot, percent, bar, index) =>
                        FlDotCirclePainter(
                          radius: 5,
                          color: _workoutColor,
                          strokeWidth: 1.5,
                          strokeColor: Colors.white,
                        ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipItems: (spots) => [
                    for (final spot in spots)
                      spot.barIndex == 1
                          ? _tooltip(
                              context,
                              '${spot.x.toStringAsFixed(1)} kg, '
                              '${spot.y.round()} s',
                            )
                          : null,
                  ],
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: _hiddenTitles,
                rightTitles: _hiddenTitles,
                leftTitles: _titles(
                  context,
                  (value) => '${value.round()} s',
                  reservedSize: 40,
                  maxIncluded: false,
                ),
                bottomTitles: _titles(
                  context,
                  (value) => '${value.toStringAsFixed(0)} kg',
                  minIncluded: false,
                  maxIncluded: false,
                ),
              ),
              gridData: _grid(Theme.of(context).colorScheme),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        _Legend([
          (_idealCurveColor, 'Ideal force curve'),
          (_workoutColor, 'First holds'),
          if (section != null)
            (sectionColors[section]!, '${section.label} range and target'),
        ]),
      ],
    );
  }
}

/// Each rep's target, in the section's color, and actual hang.
class RepResultsGraph extends StatelessWidget {
  const RepResultsGraph({
    super.key,
    required this.targets,
    required this.actual,
    required this.section,
  });

  final List<int> targets;
  final List<double> actual;
  final CurveSection section;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final targetColor = sectionColors[section]!;
    LineChartBarData line(
      List<num> seconds,
      Color color, {
      bool dashed = false,
    }) => LineChartBarData(
      spots: _repSpots(seconds),
      color: color,
      barWidth: 2.5,
      dashArray: dashed ? [8, 6] : null,
    );

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: LineChart(
            duration: Duration.zero,
            LineChartData(
              minX: 1,
              maxX: max(targets.length, 2).toDouble(),
              minY: 0,
              lineBarsData: [
                line(targets, targetColor, dashed: true),
                line(actual, colorScheme.primary),
              ],
              titlesData: FlTitlesData(
                topTitles: _hiddenTitles,
                rightTitles: _hiddenTitles,
                leftTitles: _titles(
                  context,
                  (value) => '${value.round()} s',
                  reservedSize: 40,
                  maxIncluded: false,
                ),
                bottomTitles: _titles(
                  context,
                  (value) => 'Rep ${value.round()}',
                  interval: 1,
                ),
              ),
              gridData: _grid(colorScheme),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        _Legend([
          (targetColor, 'Target (dashed)'),
          (colorScheme.primary, 'Actual'),
        ]),
      ],
    );
  }
}
