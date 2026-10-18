import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analysis/calibration_check.dart';
import '../models/progressor_models.dart';
import '../protocol/progressor_protocol.dart';
import '../providers/progressor_provider.dart';

class CalibrationTab extends ConsumerWidget {
  const CalibrationTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calibration = ref.watch(
      progressorProvider.select((state) => state.calibration),
    );
    final notifier = ref.read(progressorProvider.notifier);
    final factor = calibration.factor;
    final busy = calibration.waitingForSteadyLoad || calibration.removingPoint;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Current Calibration Factor: '
            '${factor == null ? 'Not available' : factor.toStringAsFixed(6)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          if (calibration.points.isNotEmpty) ...[
            CalibrationCheckCard(
              points: calibration.points,
              factor: factor,
              onRemovePoint: busy
                  ? null
                  : (index) => _removeCalibrationPoint(
                      context,
                      notifier,
                      index,
                      calibration.points[index],
                    ),
            ),
            const SizedBox(height: 16),
          ],
          CalibrationCard(
            pointCount: calibration.points.length,
            waitingForSteadyLoad: calibration.waitingForSteadyLoad,
            removingPoint: calibration.removingPoint,
            onAddCalibrationPoint: notifier.addCalibrationPoint,
            onGetCalibration: notifier.getCalibration,
            onDefaultCalibration: notifier.defaultCalibration,
          ),
        ],
      ),
    );
  }
}

Future<void> _removeCalibrationPoint(
  BuildContext context,
  ProgressorNotifier notifier,
  int index,
  CalibrationPoint point,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final label = 'point ${index + 1} (${point.weightKg.toStringAsFixed(3)} kg)';
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Remove $label?'),
      content: const Text(
        'The device deletes the point and refits the calibration to the '
        'remaining points.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Remove'),
        ),
      ],
    ),
  );
  if (!(confirmed ?? false)) return;

  final result = await notifier.removeCalibrationPoint(index);
  messenger.showSnackBar(
    SnackBar(
      content: Text(switch (result) {
        CalibrationPointRemoval.removed => 'Removed $label.',
        CalibrationPointRemoval.kept =>
          'The device kept $label. Its firmware may not support removing '
              'points, or the remaining points do not give a plausible '
              'calibration.',
        CalibrationPointRemoval.sendFailed =>
          'Sending the removal to the device failed.',
        CalibrationPointRemoval.disconnected =>
          'The device disconnected before confirming the removal.',
      }),
    ),
  );
}

class CalibrationCard extends StatefulWidget {
  const CalibrationCard({
    super.key,
    required this.pointCount,
    required this.waitingForSteadyLoad,
    required this.removingPoint,
    required this.onAddCalibrationPoint,
    required this.onGetCalibration,
    required this.onDefaultCalibration,
  });

  final int pointCount;
  final bool waitingForSteadyLoad;
  final bool removingPoint;
  final Future<CalibrationPointResult> Function(double weightKg)
  onAddCalibrationPoint;
  final VoidCallback onGetCalibration;
  final VoidCallback onDefaultCalibration;

  @override
  State<CalibrationCard> createState() => _CalibrationCardState();
}

class _CalibrationCardState extends State<CalibrationCard> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitCalibration() async {
    final messenger = ScaffoldMessenger.of(context);
    final weight = double.tryParse(
      _controller.text.trim().replaceAll(',', '.'),
    );
    if (weight == null || weight < 0) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Enter a valid weight in kg.')),
      );
      return;
    }

    final firstPoint = widget.pointCount == 0;
    final result = await widget.onAddCalibrationPoint(weight);
    if (!mounted) return;
    if (result == CalibrationPointResult.added) _controller.clear();
    final kg = '${weight.toStringAsFixed(2)} kg';
    messenger.showSnackBar(
      SnackBar(
        content: Text(switch (result) {
          CalibrationPointResult.added when firstPoint =>
            'First point ($kg) stored. Add another point to calibrate.',
          CalibrationPointResult.added =>
            'Point ($kg) sent. The device keeps it only if the calibration '
                'is plausible.',
          CalibrationPointResult.notSteady =>
            'The load did not hold steady, so the point was not added.',
          CalibrationPointResult.readingUnchanged =>
            'The reading barely changed since the previous point, so the '
                'point was not added. Hang the $kg weight and try again.',
          CalibrationPointResult.noMeasurements =>
            'No measurements arrived, so the point was not added.',
          CalibrationPointResult.limitReached =>
            'The device holds $maxCalibrationPoints points. Reset the '
                'calibration to start over.',
          CalibrationPointResult.sendFailed =>
            'Sending the point to the device failed.',
          CalibrationPointResult.disconnected =>
            'The device disconnected, so the point was not added.',
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final limitReached = widget.pointCount >= maxCalibrationPoints;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add Calibration Point',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              decoration: InputDecoration(
                labelText: 'Attached weight (kg)',
                hintText: 'e.g. 20.0',
                helperText: limitReached
                    ? 'The device holds $maxCalibrationPoints points. Reset '
                          'the calibration to start over.'
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed:
                  widget.waitingForSteadyLoad ||
                      widget.removingPoint ||
                      limitReached
                  ? null
                  : _submitCalibration,
              icon: widget.waitingForSteadyLoad
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add),
              label: Text(
                widget.waitingForSteadyLoad
                    ? 'Hold the weight still...'
                    : 'Add Calibration Point',
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              // A calibration read would confirm a removal the device refused.
              onPressed: widget.removingPoint ? null : widget.onGetCalibration,
              icon: const Icon(Icons.refresh),
              label: const Text('Get Calibration'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              // A pending point would land after the reset.
              onPressed: widget.waitingForSteadyLoad || widget.removingPoint
                  ? null
                  : widget.onDefaultCalibration,
              icon: const Icon(Icons.settings_backup_restore),
              label: const Text('Reset Calibration To Default'),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatCompactAxis(double value) {
  if (value.abs() < 1000) return value.toStringAsFixed(0);
  final thousands = value / 1000;
  return '${thousands.toStringAsFixed(thousands.abs() >= 100 ? 0 : 1)}k';
}

/// Calibration points against the line the device applies, with the error of
/// each point.
class CalibrationCheckCard extends StatelessWidget {
  const CalibrationCheckCard({
    super.key,
    required this.points,
    required this.factor,
    required this.onRemovePoint,
  });

  final List<CalibrationPoint> points;
  final double? factor;

  /// Null while the calibration is busy.
  final void Function(int index)? onRemovePoint;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final factor = this.factor;
    final check = factor == null ? null : CalibrationCheck.of(points, factor);
    final verifiedCheck = check != null && check.verifiesFit ? check : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Calibration Check', style: textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              check == null
                  ? 'Add another point to calibrate.'
                  : verifiedCheck == null
                  ? 'Add a point at a third weight to check the calibration. '
                        'The line fits two weights by construction.'
                  : 'Max error ${check.maxErrorKg.toStringAsFixed(3)} kg '
                        '(${check.maxErrorPercentOfSpan.toStringAsFixed(2)}% '
                        'of the heaviest weight) · RMS '
                        '${check.rmsErrorKg.toStringAsFixed(3)} kg',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final chart = SizedBox(
                  height: 240,
                  child: _CalibrationChart(points: points, check: check),
                );
                final table = _CalibrationTable(
                  points: points,
                  check: verifiedCheck,
                  onRemovePoint: onRemovePoint,
                );
                if (constraints.maxWidth < 900) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [chart, const SizedBox(height: 12), table],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: chart),
                    const SizedBox(width: 12),
                    Flexible(flex: 2, child: table),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CalibrationChart extends StatelessWidget {
  const _CalibrationChart({required this.points, required this.check});

  final List<CalibrationPoint> points;
  final CalibrationCheck? check;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final labelStyle = Theme.of(context).textTheme.bodySmall;
    final pointSpots = [
      for (final point in points) FlSpot(point.raw, point.weightKg),
    ];
    // Every fitted value lies on the device line.
    final lineSpots = [
      for (final residual in check?.residuals ?? const <CalibrationResidual>[])
        FlSpot(residual.point.raw, residual.fittedKg),
    ]..sort((a, b) => a.x.compareTo(b.x));
    final xs = pointSpots.map((spot) => spot.x);
    final ys = [...pointSpots, ...lineSpots].map((spot) => spot.y);
    (double, double) padded(Iterable<double> values, double minPadding) {
      final low = values.reduce((a, b) => a < b ? a : b);
      final high = values.reduce((a, b) => a > b ? a : b);
      final padding = ((high - low) * 0.08).clamp(minPadding, double.infinity);
      return (low - padding, high + padding);
    }

    final (minX, maxX) = padded(xs, 1);
    final (minY, maxY) = padded(ys, 0.5);

    return LineChart(
      LineChartData(
        minX: minX,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
        clipData: const FlClipData.all(),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItems: (touchedSpots) => [
              for (final spot in touchedSpots)
                spot.barIndex == 0
                    ? LineTooltipItem(
                        'Raw: ${spot.x.toStringAsFixed(0)}\n'
                        'Known: ${spot.y.toStringAsFixed(3)} kg',
                        TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      )
                    : null,
            ],
          ),
        ),
        gridData: FlGridData(
          getDrawingHorizontalLine: (_) => FlLine(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            strokeWidth: 1,
          ),
          getDrawingVerticalLine: (_) => FlLine(
            color: colorScheme.outlineVariant.withValues(alpha: 0.35),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            axisNameWidget: Text('Known weight (kg)', style: labelStyle),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              maxIncluded: false,
              getTitlesWidget: (value, meta) =>
                  Text(value.toStringAsFixed(1), style: labelStyle),
            ),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: Text('Raw measurement', style: labelStyle),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: (maxX - minX) / 5,
              maxIncluded: false,
              getTitlesWidget: (value, meta) =>
                  Text(_formatCompactAxis(value), style: labelStyle),
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: colorScheme.outline),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: pointSpots,
            barWidth: 0,
            color: colorScheme.primary,
            dotData: FlDotData(
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                    radius: 4,
                    color: colorScheme.primary,
                    strokeColor: colorScheme.surface,
                    strokeWidth: 1.5,
                  ),
            ),
          ),
          if (lineSpots.isNotEmpty)
            LineChartBarData(
              spots: lineSpots,
              color: colorScheme.primary,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              dashArray: const [6, 4],
            ),
        ],
      ),
    );
  }
}

class _CalibrationTable extends StatelessWidget {
  const _CalibrationTable({
    required this.points,
    required this.check,
    required this.onRemovePoint,
  });

  final List<CalibrationPoint> points;
  final CalibrationCheck? check;
  final void Function(int index)? onRemovePoint;

  @override
  Widget build(BuildContext context) {
    final check = this.check;
    final onRemovePoint = this.onRemovePoint;
    final worstErrorKg = check?.maxErrorKg;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 34,
        dataRowMinHeight: 30,
        dataRowMaxHeight: 34,
        horizontalMargin: 8,
        columnSpacing: 16,
        columns: [
          const DataColumn(label: Text('#')),
          const DataColumn(label: Text('Raw'), numeric: true),
          const DataColumn(label: Text('Known (kg)'), numeric: true),
          if (check != null) ...const [
            DataColumn(label: Text('Fitted (kg)'), numeric: true),
            DataColumn(label: Text('Error (kg)'), numeric: true),
          ],
          const DataColumn(label: SizedBox.shrink()),
        ],
        rows: [
          for (final (index, point) in points.indexed)
            DataRow(
              cells: [
                DataCell(Text('${index + 1}')),
                DataCell(Text(point.raw.toStringAsFixed(0))),
                DataCell(Text(point.weightKg.toStringAsFixed(3))),
                if (check != null) ...[
                  DataCell(
                    Text(check.residuals[index].fittedKg.toStringAsFixed(3)),
                  ),
                  DataCell(
                    Text(
                      check.residuals[index].errorKg.toStringAsFixed(3),
                      style:
                          check.residuals[index].errorKg.abs() == worstErrorKg
                          ? TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w700,
                            )
                          : null,
                    ),
                  ),
                ],
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    iconSize: 20,
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Remove point ${index + 1}',
                    onPressed: onRemovePoint == null
                        ? null
                        : () => onRemovePoint(index),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
