import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CalibrationGraphCard extends StatelessWidget {
  const CalibrationGraphCard({
    super.key,
    required this.calibrationPoints,
    required this.calibrationFactor,
  });

  final List<FlSpot> calibrationPoints;
  final double? calibrationFactor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasPoints = calibrationPoints.isNotEmpty;
    final knownMin = hasPoints
        ? calibrationPoints
              .map((point) => point.y)
              .reduce((a, b) => a < b ? a : b)
        : 0.0;
    final knownWeightOffset = knownMin < 0 ? -knownMin : 0.0;
    final graphPoints = calibrationPoints
        .map((point) => FlSpot(point.x, point.y + knownWeightOffset))
        .toList();
    final xs = hasPoints
        ? graphPoints.map((point) => point.x).toList()
        : <double>[0, 1];
    final ys = hasPoints
        ? graphPoints.map((point) => point.y).toList()
        : <double>[0, 1];

    final dataMinX = xs.reduce((a, b) => a < b ? a : b);
    final dataMaxX = xs.reduce((a, b) => a > b ? a : b);
    final resolvedMaxX = dataMaxX <= dataMinX ? dataMinX + 1 : dataMaxX;
    final xSpan = (resolvedMaxX - dataMinX).abs();
    final xPadding = (xSpan * 0.06) < 1.0 ? 1.0 : (xSpan * 0.06);
    final chartMinX = dataMinX - xPadding;
    final chartMaxX = resolvedMaxX + xPadding;
    final xInterval =
        (chartMaxX - chartMinX) <= 1 ? 1.0 : ((chartMaxX - chartMinX) / 6);
    final minYPoints = ys.reduce((a, b) => a < b ? a : b);
    final maxYPoints = ys.reduce((a, b) => a > b ? a : b);

    double? lineSlope;
    final fitLineSpots = hasPoints && graphPoints.length >= 2
        ? () {
            final avgX =
                graphPoints.map((point) => point.x).reduce((a, b) => a + b) /
                    graphPoints.length;
            final avgY =
                graphPoints.map((point) => point.y).reduce((a, b) => a + b) /
                    graphPoints.length;

            final slopeFromFactor =
                calibrationFactor != null ? calibrationFactor! / 1000.0 : null;
            double slope;
            if (slopeFromFactor != null) {
              slope = slopeFromFactor;
            } else {
              final denominator = graphPoints
                  .map((point) => (point.x - avgX) * (point.x - avgX))
                  .reduce((a, b) => a + b);
              if (denominator == 0) return const <FlSpot>[];
              final numerator = graphPoints
                  .map((point) => (point.x - avgX) * (point.y - avgY))
                  .reduce((a, b) => a + b);
              slope = numerator / denominator;
            }
            lineSlope = slope;
            final intercept = avgY - (slope * avgX);

            return <FlSpot>[
              FlSpot(chartMinX, (slope * chartMinX) + intercept),
              FlSpot(chartMaxX, (slope * chartMaxX) + intercept),
            ];
          }()
        : const <FlSpot>[];
    final fitYs = fitLineSpots.map((point) => point.y).toList();

    final minY = fitYs.isEmpty
        ? minYPoints
        : [minYPoints, fitYs.reduce((a, b) => a < b ? a : b)]
            .reduce((a, b) => a < b ? a : b);
    final maxY = fitYs.isEmpty
        ? maxYPoints
        : [maxYPoints, fitYs.reduce((a, b) => a > b ? a : b)]
            .reduce((a, b) => a > b ? a : b);
    final ySpan = (maxY - minY).abs();
    final yPadding = (ySpan * 0.08) < 0.5 ? 0.5 : (ySpan * 0.08);
    final chartMinY = -yPadding * 0.3;
    final chartMaxY =
        (maxY + yPadding) <= chartMinY ? chartMinY + 1 : (maxY + yPadding);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calibration Graph',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
            if (knownWeightOffset > 0) const SizedBox(height: 4),
            if (knownWeightOffset > 0)
              Text(
                'Known weight offset applied: +${knownWeightOffset.toStringAsFixed(3)} kg',
                style: GoogleFonts.inter(fontSize: 12),
              ),
            const SizedBox(height: 8),
            if (!hasPoints)
              Text(
                'No calibration points received yet.',
                style: GoogleFonts.inter(),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final sideBySide = constraints.maxWidth >= 900;
                  final graphWidget = SizedBox(
                    height: 240,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: colorScheme.outline),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LineChart(
                          LineChartData(
                            minX: chartMinX,
                            maxX: chartMaxX,
                            minY: chartMinY,
                            maxY: chartMaxY,
                            clipData: const FlClipData.all(),
                            lineTouchData: LineTouchData(
                              enabled: true,
                              handleBuiltInTouches: true,
                              touchTooltipData: LineTouchTooltipData(
                                fitInsideHorizontally: true,
                                fitInsideVertically: true,
                                getTooltipItems: (touchedSpots) {
                                  final pointSpots = touchedSpots
                                      .where((spot) => spot.barIndex == 0)
                                      .toList();
                                  return pointSpots.map((spot) {
                                    return LineTooltipItem(
                                      'Raw: ${spot.x.toStringAsFixed(3)}\nKnown: ${spot.y.toStringAsFixed(3)} kg',
                                      GoogleFonts.inter(
                                        color: colorScheme.onSurface,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                    );
                                  }).toList();
                                },
                              ),
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: true,
                              getDrawingHorizontalLine: (_) => FlLine(
                                color: colorScheme.outlineVariant
                                    .withValues(alpha: 0.5),
                                strokeWidth: 1,
                              ),
                              getDrawingVerticalLine: (_) => FlLine(
                                color: colorScheme.outlineVariant
                                    .withValues(alpha: 0.35),
                                strokeWidth: 1,
                              ),
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                axisNameWidget: Text(
                                  'Known weight (kg)',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: textTheme.bodySmall?.color,
                                  ),
                                ),
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 44,
                                  maxIncluded: false,
                                  getTitlesWidget: (value, meta) => Text(
                                    value.toStringAsFixed(1),
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: textTheme.bodySmall?.color,
                                    ),
                                  ),
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                axisNameWidget: Text(
                                  'Raw measurement',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: textTheme.bodySmall?.color,
                                  ),
                                ),
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 32,
                                  interval: xInterval,
                                  maxIncluded: false,
                                  getTitlesWidget: (value, meta) => Text(
                                    _formatCompactAxis(value),
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: textTheme.bodySmall?.color,
                                    ),
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
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: graphPoints,
                                isCurved: false,
                                color: colorScheme.primary,
                                barWidth: 0,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter:
                                      (spot, percent, barData, index) {
                                    return FlDotCirclePainter(
                                      radius: 4,
                                      color: colorScheme.primary,
                                      strokeColor: colorScheme.surface,
                                      strokeWidth: 1.5,
                                    );
                                  },
                                ),
                                belowBarData: BarAreaData(show: false),
                              ),
                              if (fitLineSpots.isNotEmpty)
                                LineChartBarData(
                                  spots: fitLineSpots,
                                  isCurved: false,
                                  color: colorScheme.primary,
                                  barWidth: 2,
                                  dotData: const FlDotData(show: false),
                                  dashArray: const [6, 4],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );

                  const indexColumnWidth = 24.0;
                  const rawValueColumnWidth = 120.0;
                  const knownWeightColumnWidth = 140.0;

                  final pointsListWidget = IntrinsicWidth(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: colorScheme.outline),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              'Calibration Points',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 190,
                            child: Scrollbar(
                              thumbVisibility: true,
                              child: SingleChildScrollView(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    headingRowHeight: 34,
                                    dataRowMinHeight: 30,
                                    dataRowMaxHeight: 34,
                                    horizontalMargin: 8,
                                    columnSpacing: 8,
                                    headingTextStyle: GoogleFonts.inter(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                    dataTextStyle: GoogleFonts.inter(
                                      fontSize: 11,
                                    ),
                                    columns: const [
                                      DataColumn(
                                        label: SizedBox(
                                          width: indexColumnWidth,
                                          child: Center(child: Text('#')),
                                        ),
                                      ),
                                      DataColumn(
                                        label: SizedBox(
                                          width: rawValueColumnWidth,
                                          child: Center(
                                            child: Text('Raw Value'),
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: SizedBox(
                                          width: knownWeightColumnWidth,
                                          child: Center(
                                            child: Text('Known Weight (kg)'),
                                          ),
                                        ),
                                      ),
                                    ],
                                    rows: graphPoints
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      final index = entry.key + 1;
                                      final point = entry.value;
                                      return DataRow(
                                        cells: [
                                          DataCell(
                                            SizedBox(
                                              width: indexColumnWidth,
                                              child: Center(
                                                child:
                                                    Text(index.toString()),
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            SizedBox(
                                              width: rawValueColumnWidth,
                                              child: Center(
                                                child: Text(
                                                  point.x
                                                      .toStringAsFixed(3),
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            SizedBox(
                                              width: knownWeightColumnWidth,
                                              child: Center(
                                                child: Text(
                                                  point.y
                                                      .toStringAsFixed(3),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );

                  if (!sideBySide) {
                    return Column(
                      children: [
                        graphWidget,
                        const SizedBox(height: 12),
                        pointsListWidget,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: graphWidget),
                      const SizedBox(width: 12),
                      pointsListWidget,
                    ],
                  );
                },
              ),
            if (hasPoints) const SizedBox(height: 8),
            if (hasPoints)
              Text(
                lineSlope != null
                    ? 'Slope: ${lineSlope!.toStringAsFixed(6)}'
                    : 'Slope unavailable.',
                style: GoogleFonts.inter(fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }
}

String _formatCompactAxis(double value) {
  final abs = value.abs();
  if (abs >= 1000) {
    final compact = value / 1000;
    return '${compact.toStringAsFixed(compact.abs() >= 100 ? 0 : 1)}k';
  }
  return value.toStringAsFixed(0);
}
