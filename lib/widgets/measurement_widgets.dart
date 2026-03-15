import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/progressor_models.dart' as progressor_models;

const _paleRed = Color(0xFFE57373);

class MeasurementControlCard extends StatelessWidget {
  const MeasurementControlCard({
    super.key,
    required this.measurement,
    required this.onStartMeasurement,
    required this.onStopMeasurement,
    required this.onTareScale,
  });

  final progressor_models.MeasurementState measurement;
  final VoidCallback onStartMeasurement;
  final VoidCallback onStopMeasurement;
  final VoidCallback onTareScale;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: measurement.isMeasuring
                  ? onStopMeasurement
                  : onStartMeasurement,
              icon: Icon(
                measurement.isMeasuring ? Icons.stop : Icons.play_arrow,
              ),
              label: Text(measurement.isMeasuring ? 'Stop' : 'Start'),
              style: ElevatedButton.styleFrom(
                backgroundColor: measurement.isMeasuring
                    ? _paleRed
                    : colorScheme.primary,
                foregroundColor: measurement.isMeasuring
                    ? colorScheme.onError
                    : colorScheme.onPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onTareScale,
              icon: const Icon(Icons.adjust),
              label: const Text('Tare Scale'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CurrentWeightCard extends StatelessWidget {
  const CurrentWeightCard({super.key, required this.measurement});

  final progressor_models.MeasurementState measurement;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Weight',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Current', style: textTheme.bodySmall),
                      Text(
                        '${measurement.currentWeight.toStringAsFixed(2)} kg',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (measurement.maxWeight > 0) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Min', style: textTheme.bodySmall),
                        Text(
                          '${measurement.minWeight.toStringAsFixed(2)} kg',
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Max', style: textTheme.bodySmall),
                        Text(
                          '${measurement.maxWeight.toStringAsFixed(2)} kg',
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (measurement.isMeasuring)
                  Icon(
                    Icons.radio_button_checked,
                    color: colorScheme.error,
                    size: 24,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Timestamp (ms): ${measurement.sampleCount ~/ 1000}'),
          ],
        ),
      ),
    );
  }
}

class CalibrationCard extends StatefulWidget {
  const CalibrationCard({
    super.key,
    required this.connection,
    required this.onAddCalibrationPoint,
    required this.onGetCalibration,
    required this.onDefaultCalibration,
    this.calibrationInfo,
  });

  final progressor_models.ConnectionState connection;
  final ValueChanged<double> onAddCalibrationPoint;
  final VoidCallback onGetCalibration;
  final VoidCallback onDefaultCalibration;
  final String? calibrationInfo;

  @override
  State<CalibrationCard> createState() => _CalibrationCardState();
}

class _CalibrationCardState extends State<CalibrationCard> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitCalibration() {
    final raw = _controller.text.trim().replaceAll(',', '.');
    final weight = double.tryParse(raw);
    if (weight == null || weight < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid weight in kg.')),
      );
      return;
    }
    widget.onAddCalibrationPoint(weight);
    _controller.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Weight ${weight.toStringAsFixed(2)} kg sent.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = widget.connection.isConnected;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? const Color(0xFF8B8B8B) : const Color(0xFF6E6E6E);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input row
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: isConnected,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    decoration: const InputDecoration(
                      hintText: 'Weight (kg)',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: isConnected ? _submitCalibration : null,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Action buttons as 3 columns
        Row(
          children: [
            Expanded(
              child: _CalibrationAction(
                icon: Icons.add_circle_outline,
                label: 'Add Point',
                onTap: isConnected ? _submitCalibration : null,
                color: colorScheme.onSurface,
                mutedColor: mutedColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _CalibrationAction(
                icon: Icons.refresh,
                label: 'Get',
                onTap: isConnected ? widget.onGetCalibration : null,
                color: colorScheme.onSurface,
                mutedColor: mutedColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _CalibrationAction(
                icon: Icons.settings_backup_restore,
                label: 'Reset',
                onTap: isConnected ? widget.onDefaultCalibration : null,
                color: colorScheme.onSurface,
                mutedColor: mutedColor,
              ),
            ),
          ],
        ),
        if ((widget.calibrationInfo ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            widget.calibrationInfo!,
            style: TextStyle(fontSize: 12, color: mutedColor),
          ),
        ],
      ],
    );
  }
}

class _CalibrationAction extends StatelessWidget {
  const _CalibrationAction({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    required this.mutedColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color color;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final disabled = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            children: [
              Icon(
                icon,
                size: 26,
                color: disabled
                    ? colorScheme.outline.withValues(alpha: 0.4)
                    : color,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: disabled
                      ? colorScheme.outline.withValues(alpha: 0.4)
                      : mutedColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
