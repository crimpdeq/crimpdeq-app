import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/progressor_models.dart' as progressor_models;

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: measurement.isMeasuring ? onStopMeasurement : onStartMeasurement,
              icon: Icon(measurement.isMeasuring ? Icons.stop : Icons.play_arrow),
              label: Text(measurement.isMeasuring ? 'Stop' : 'Start'),
              style: ElevatedButton.styleFrom(
                backgroundColor: measurement.isMeasuring ? Colors.red : const Color(0xFF2F6EB8),
                foregroundColor: Colors.white,
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
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${measurement.currentWeight.toStringAsFixed(2)} kg',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    Text('Sample: ${measurement.sampleCount}'),
                  ],
                ),
                if (measurement.isMeasuring)
                  const Icon(
                    Icons.radio_button_checked,
                    color: Colors.red,
                    size: 24,
                  ),
              ],
            ),
            if (measurement.maxWeight > 0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'Min: ${measurement.minWeight.toStringAsFixed(2)} kg',
                    style: const TextStyle(color: Colors.green),
                  ),
                  Text(
                    'Max: ${measurement.maxWeight.toStringAsFixed(2)} kg',
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ],
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
    final isConnected = widget.connection.device != null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Calibration Point',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              enabled: isConnected,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Attached weight (kg)',
                hintText: 'e.g. 20.0',
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isConnected ? _submitCalibration : null,
                icon: const Icon(Icons.add),
                label: const Text('Add Calibration Point'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isConnected ? widget.onDefaultCalibration : null,
                icon: const Icon(Icons.settings_backup_restore),
                label: const Text('Reset Calibration To Default'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
