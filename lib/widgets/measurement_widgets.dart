import 'package:flutter/material.dart';

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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Measurement', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        !measurement.isMeasuring ? onStartMeasurement : null,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        measurement.isMeasuring ? onStopMeasurement : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
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
