import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analysis/calibration_check.dart';
import '../analysis/calibration_curve.dart';
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
    final measuring = ref.watch(
      progressorProvider.select((state) => state.measurement.isMeasuring),
    );
    final notifier = ref.read(progressorProvider.notifier);
    final factor = calibration.factor;
    final details = calibration.details;
    final busy =
        calibration.waitingForSteadyLoad ||
        calibration.removingPoint ||
        calibration.changingModel;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CalibrationModelCard(
            supportsModels: calibration.supportsModels,
            details: details,
            factor: factor,
            busy: busy,
            measuring: measuring,
            changingModel: calibration.changingModel,
            onSelectModel: (model) => _selectModel(context, ref, model),
            onSetZero: () => _setZero(context, notifier),
          ),
          const SizedBox(height: 16),
          if (calibration.points.isNotEmpty) ...[
            CalibrationCheckCard(
              points: calibration.points,
              factor: factor,
              details: details,
              onRemovePoint: busy
                  ? null
                  : (index) => _removeCalibrationPoint(
                      context,
                      ref,
                      index,
                      calibration.points[index],
                    ),
            ),
            const SizedBox(height: 16),
          ],
          CalibrationCard(
            pointCount: calibration.points.length,
            waitingForSteadyLoad: calibration.waitingForSteadyLoad,
            removingPoint:
                calibration.removingPoint || calibration.changingModel,
            onAddCalibrationPoint: notifier.addCalibrationPoint,
            onGetCalibration: notifier.getCalibration,
            onDefaultCalibration: notifier.defaultCalibration,
          ),
        ],
      ),
    );
  }
}

Future<void> _selectModel(
  BuildContext context,
  WidgetRef ref,
  CalibrationModel model,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final result = await ref
      .read(progressorProvider.notifier)
      .selectCalibrationModel(model);
  final inUse = ref.read(progressorProvider).calibration.details?.model;
  messenger.showSnackBar(
    SnackBar(
      content: Text(switch (result) {
        null =>
          'The device did not answer. Tap Get Calibration to see which model '
              'it uses.',
        (disposition: CalibrationDisposition.applied, error: _, opCode: _) =>
          'The device now uses ${model.label}.',
        (:final error, disposition: _, opCode: _) =>
          'Could not use ${model.label}. ${error?.message ?? ''}'
              '${inUse == null ? '' : ' The device keeps ${inUse.label}.'}',
      }),
    ),
  );
}

Future<void> _setZero(BuildContext context, ProgressorNotifier notifier) async {
  final messenger = ScaffoldMessenger.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Set unloaded zero?'),
      content: const Text(
        'Remove everything from the Crimpdeq that was not attached for the '
        '0 kg calibration point, such as plates or a hangboard.\n\n'
        'The device takes the current reading as 0 kg and moves the '
        'calibration curve with it. This corrects drift of the zero since '
        'you calibrated, so the curve bends at the right load.\n\n'
        'To zero a hangboard or sling that stays attached, use Tare instead.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Set Zero'),
        ),
      ],
    ),
  );
  if (!(confirmed ?? false)) return;

  final result = await notifier.setZero();
  messenger.showSnackBar(
    SnackBar(
      content: Text(switch (result) {
        null => 'The device did not answer, so the zero may not be set.',
        (disposition: CalibrationDisposition.applied, error: _, opCode: _) =>
          'Zero set.',
        (:final error, disposition: _, opCode: _) =>
          'Zero not set. ${error?.message ?? ''}',
      }),
    ),
  );
}

/// Short label for the model selector, which fits a phone.
String _shortLabel(CalibrationModel model) =>
    model == CalibrationModel.piecewise ? 'Piecewise' : model.label;

/// Plain description of each model, with the data it needs.
const _modelDescriptions = {
  CalibrationModel.linear: (
    'A straight line: the same sensitivity at every load. The default.',
    '2 different loads. Add a third to check the fit.',
  ),
  CalibrationModel.quadratic: (
    'A smooth curve, for a sensitivity that changes gradually with the load.',
    '4 different loads, one of them in the middle half of the range.',
  ),
  CalibrationModel.piecewise: (
    'Two straight lines joined at a break the device finds, for a '
        'sensitivity that changes around one load.',
    '6 different loads, 3 on each side of the break.',
  ),
};

Future<void> _showModelHelp(BuildContext context) {
  final textTheme = Theme.of(context).textTheme;
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Calibration models'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final model in CalibrationModel.values) ...[
              Text(model.label, style: textTheme.titleSmall),
              const SizedBox(height: 2),
              Text(_modelDescriptions[model]!.$1),
              Text(
                'Needs ${_modelDescriptions[model]!.$2}',
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
            ],
            const Text(
              'The device fits the model to the stored points, so switching '
              'needs no new points. Start with Linear, and switch only when '
              'its residuals follow a curve instead of scattering. Check the '
              'result with weights that are not calibration points.\n\n'
              'Readings outside the calibrated range, from the lightest to '
              'the heaviest point, continue straight with the slope at the '
              'nearest end, so they are less certain.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

/// Model selection, the calibrated range and the unloaded zero. The selected
/// model is the one the device reports in use; a selection waits for the
/// device to fit it.
class CalibrationModelCard extends StatelessWidget {
  const CalibrationModelCard({
    super.key,
    required this.supportsModels,
    required this.details,
    required this.factor,
    required this.busy,
    required this.measuring,
    required this.changingModel,
    required this.onSelectModel,
    required this.onSetZero,
  });

  final bool? supportsModels;
  final CalibrationDetails? details;

  /// Linear factor in g per count, null for a nonlinear calibration.
  final double? factor;
  final bool busy;

  /// A model or zero change mid-measurement would mix two calibrations in one
  /// window, as a sample rate change would mix rates.
  final bool measuring;
  final bool changingModel;
  final ValueChanged<CalibrationModel> onSelectModel;
  final VoidCallback onSetZero;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final details = this.details;
    final factor = this.factor;
    final active = details?.model ?? CalibrationModel.linear;
    final supported =
        details?.info.supportedModels ?? const {CalibrationModel.linear};
    final range = details?.loadRangeKg;
    final pending = details?.info.pending;
    final canChange = !busy && !measuring && details != null;
    final hint = switch (supportsModels) {
      false =>
        'This firmware has only the linear model. Update it to use the '
            'others.',
      null => 'Reading the calibration from the device...',
      true when changingModel => 'Waiting for the device to fit the model...',
      true when measuring =>
        'Stop the measurement to change the model or the zero.',
      true => null,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Calibration Model',
                    style: textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  tooltip: 'About the calibration models',
                  onPressed: () => _showModelHelp(context),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 4),
                  SegmentedButton<CalibrationModel>(
                    segments: [
                      for (final model in CalibrationModel.values)
                        ButtonSegment(
                          value: model,
                          label: Text(_shortLabel(model)),
                          tooltip: _modelDescriptions[model]!.$1,
                          enabled: supported.contains(model),
                        ),
                    ],
                    selected: {active},
                    showSelectedIcon: false,
                    onSelectionChanged: canChange
                        ? (selection) {
                            if (selection.single != active) {
                              onSelectModel(selection.single);
                            }
                          }
                        : null,
                  ),
                  if (changingModel) ...[
                    const SizedBox(height: 8),
                    const LinearProgressIndicator(),
                  ],
                  if (hint != null) ...[
                    const SizedBox(height: 8),
                    Text(hint, style: textTheme.bodySmall),
                  ],
                  if (pending != null) ...[
                    const SizedBox(height: 12),
                    _PendingBanner(pending: pending, inUse: active),
                  ],
                  const SizedBox(height: 8),
                  if (factor != null && active == CalibrationModel.linear)
                    _DetailRow(
                      label: 'Factor',
                      value: '${factor.toStringAsFixed(6)} g/count',
                    ),
                  if (details != null)
                    _DetailRow(
                      label: 'Calibrated range',
                      value: range == null
                          ? 'Unknown (default calibration)'
                          : '${range.min.toStringAsFixed(2)} – '
                                '${range.max.toStringAsFixed(2)} kg',
                    ),
                  // A linear reading is the same with any zero, so the zero
                  // only matters for the nonlinear models.
                  if (details?.curve != null &&
                      active != CalibrationModel.linear) ...[
                    const SizedBox(height: 8),
                    Tooltip(
                      message:
                          'With nothing attached, corrects drift of the zero',
                      child: OutlinedButton.icon(
                        onPressed: canChange ? onSetZero : null,
                        icon: const Icon(Icons.anchor),
                        label: const Text('Set Unloaded Zero'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: textTheme.bodyMedium)),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Points the device stores but cannot fit yet.
class _PendingBanner extends StatelessWidget {
  const _PendingBanner({required this.pending, required this.inUse});

  final CalibrationError pending;
  final CalibrationModel inUse;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber, color: colorScheme.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Points not applied yet. ',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text:
                        '${pending.message} The device keeps measuring with '
                        'the previous ${inUse.label} calibration.',
                  ),
                ],
              ),
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _removeCalibrationPoint(
  BuildContext context,
  WidgetRef ref,
  int index,
  CalibrationPoint point,
) async {
  final notifier = ref.read(progressorProvider.notifier);
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
  final pending = ref
      .read(progressorProvider)
      .calibration
      .details
      ?.info
      .pending;
  messenger.showSnackBar(
    SnackBar(
      content: Text(switch (result) {
        CalibrationPointRemoval.removed when pending != null =>
          'Removed $label. The remaining points cannot be applied yet: '
              '${pending.message} The device keeps the previous calibration.',
        CalibrationPointRemoval.removed => 'Removed $label.',
        CalibrationPointRemoval.rejected =>
          'The device kept $label. The remaining points may not give a '
              'plausible calibration, or the device was busy.',
        CalibrationPointRemoval.unsupported =>
          'The device did not answer, so its firmware may not support '
              'removing points. Update it, then reconnect.',
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
  final Future<CalibrationPointOutcome> Function(double weightKg)
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
    final (:result, :error) = await widget.onAddCalibrationPoint(weight);
    if (!mounted) return;
    if (const [
      CalibrationPointResult.added,
      CalibrationPointResult.applied,
      CalibrationPointResult.pending,
    ].contains(result)) {
      _controller.clear();
    }
    final kg = '${weight.toStringAsFixed(2)} kg';
    messenger.showSnackBar(
      SnackBar(
        content: Text(switch (result) {
          CalibrationPointResult.added when firstPoint =>
            'First point ($kg) stored. Add another point to calibrate.',
          CalibrationPointResult.added =>
            'Point ($kg) sent. The device keeps it only if the calibration '
                'is plausible.',
          CalibrationPointResult.applied =>
            'Point ($kg) added. The device fit the points and uses the new '
                'calibration.',
          CalibrationPointResult.pending =>
            'Point ($kg) stored, but not applied yet: '
                '${error?.message ?? ''} The device keeps the previous '
                'calibration.',
          CalibrationPointResult.rejected =>
            'The device discarded the point ($kg): ${error?.message ?? ''}',
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

  Future<void> _confirmDefaultCalibration() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset calibration?'),
        content: const Text(
          'This restores the default linear calibration and deletes every '
          'calibration point stored on the device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) widget.onDefaultCalibration();
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
              onPressed: widget.onGetCalibration,
              icon: const Icon(Icons.refresh),
              label: const Text('Get Calibration'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              // A pending point would land after the reset.
              onPressed: widget.waitingForSteadyLoad
                  ? null
                  : _confirmDefaultCalibration,
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

/// Calibration-fit residuals: the loads the device curve gives the points,
/// against their known weights.
typedef _Residuals = ({
  List<double?> fittedKg,
  double maxAbsKg,
  double rmsKg,

  /// Whether the residuals can show a bad fit: a fit has more points than
  /// parameters.
  bool verifiesFit,
});

_Residuals? _residuals(
  List<CalibrationPoint> points,
  double? factor,
  CalibrationDetails? details,
) {
  if (details != null) {
    final (rms, maxAbs) = (details.fit.rmsKg, details.fit.maxAbsKg);
    if (details.curve == null || rms == null || maxAbs == null) return null;
    final weights = details.points.map((point) => point.weightKg).toSet();
    return (
      fittedKg: [for (final point in details.points) point.fittedKg],
      maxAbsKg: maxAbs,
      rmsKg: rms,
      // Nonlinear fits need a load level more than their parameters.
      verifiesFit:
          details.model != CalibrationModel.linear || weights.length >= 3,
    );
  }
  final check = factor == null ? null : CalibrationCheck.of(points, factor);
  if (check == null) return null;
  return (
    fittedKg: [for (final residual in check.residuals) residual.fittedKg],
    maxAbsKg: check.maxErrorKg,
    rmsKg: check.rmsErrorKg,
    verifiesFit: check.verifiesFit,
  );
}

/// Calibration points against the curve the device applies, with the
/// calibration-fit residual of each point.
class CalibrationCheckCard extends StatelessWidget {
  const CalibrationCheckCard({
    super.key,
    required this.points,
    required this.factor,
    this.details,
    required this.onRemovePoint,
  });

  final List<CalibrationPoint> points;
  final double? factor;

  /// Reported by firmware with calibration models; otherwise the residuals
  /// are of the linear factor.
  final CalibrationDetails? details;

  /// Null while the calibration is busy.
  final void Function(int index)? onRemovePoint;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final details = this.details;
    final residuals = _residuals(points, factor, details);
    final verified = residuals != null && residuals.verifiesFit
        ? residuals
        : null;
    final heaviestKg = points.map((point) => point.weightKg).reduce(max);
    final pending = details?.info.pending != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Calibration Check', style: textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              residuals == null
                  ? 'Add another point to calibrate.'
                  : verified == null
                  ? 'Add a point at a third weight to check the calibration. '
                        'The line fits two weights by construction.'
                  : 'Calibration-fit residuals: max '
                        '${verified.maxAbsKg.toStringAsFixed(3)} kg '
                        '(${(heaviestKg == 0 ? 0 : verified.maxAbsKg / heaviestKg * 100).toStringAsFixed(2)}%) · '
                        'RMS ${verified.rmsKg.toStringAsFixed(3)} kg',
              style: textTheme.bodyMedium,
            ),
            if (verified != null)
              Text(
                pending
                    ? 'Against the calibration in use, which was not fit from '
                          'these points. Not the accuracy at other loads.'
                    : 'How well the curve fits these points, not the accuracy '
                          'at other loads.',
                style: textTheme.bodySmall,
              ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final chart = SizedBox(
                  height: 240,
                  child: _CalibrationChart(
                    points: points,
                    fittedKg: residuals?.fittedKg,
                    curve: details?.curve,
                  ),
                );
                final table = _CalibrationTable(
                  points: points,
                  residuals: verified,
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
  const _CalibrationChart({
    required this.points,
    required this.fittedKg,
    required this.curve,
  });

  final List<CalibrationPoint> points;

  /// Load of each point on the device curve, null without a calibration.
  final List<double?>? fittedKg;

  /// Device curve, drawn across the points; without it, the fitted loads are
  /// joined, which draws a line exactly.
  final CalibrationCurve? curve;

  static const _curveSamples = 60;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final labelStyle = Theme.of(context).textTheme.bodySmall;
    final pointSpots = [
      for (final point in points) FlSpot(point.raw, point.weightKg),
    ];
    final curve = this.curve;
    final rawLow = points.map((point) => point.raw).reduce(min);
    final rawHigh = points.map((point) => point.raw).reduce(max);
    double sampleRaw(int i) => rawLow + (rawHigh - rawLow) * i / _curveSamples;
    final lineSpots = curve != null && rawHigh > rawLow
        ? [
            for (var i = 0; i <= _curveSamples; i++)
              FlSpot(sampleRaw(i), curve.kg(sampleRaw(i))),
          ]
        : ([
            for (final (index, fitted) in (fittedKg ?? const []).indexed)
              if (fitted != null) FlSpot(points[index].raw, fitted),
          ]..sort((a, b) => a.x.compareTo(b.x)));
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
    required this.residuals,
    required this.onRemovePoint,
  });

  final List<CalibrationPoint> points;
  final _Residuals? residuals;
  final void Function(int index)? onRemovePoint;

  @override
  Widget build(BuildContext context) {
    final residuals = this.residuals;
    final onRemovePoint = this.onRemovePoint;
    double? residualKg(int index) {
      final fitted = residuals?.fittedKg.elementAtOrNull(index);
      return fitted == null ? null : fitted - points[index].weightKg;
    }

    final worstKg = residuals?.maxAbsKg;
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
          const DataColumn(
            label: Text('Known'),
            numeric: true,
            tooltip: 'Known weight, kg',
          ),
          if (residuals != null) ...const [
            DataColumn(
              label: Text('Fitted'),
              numeric: true,
              tooltip: 'Load the calibration gives the point, kg',
            ),
            DataColumn(
              label: Text('Residual'),
              numeric: true,
              tooltip: 'Fitted minus known, kg',
            ),
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
                if (residuals != null) ...[
                  DataCell(
                    Text(
                      residuals.fittedKg
                              .elementAtOrNull(index)
                              ?.toStringAsFixed(3) ??
                          '—',
                    ),
                  ),
                  DataCell(
                    Text(
                      residualKg(index)?.toStringAsFixed(3) ?? '—',
                      style:
                          worstKg != null &&
                              ((residualKg(index)?.abs() ?? 0) - worstKg)
                                      .abs() <
                                  5e-4
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
