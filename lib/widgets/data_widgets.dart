import 'package:flutter/material.dart';

import '../models/progressor_models.dart' as progressor_models;

class ReceivedDataCard extends StatelessWidget {
  const ReceivedDataCard({super.key, required this.measurements});

  final List<progressor_models.WeightMeasurement> measurements;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Received Data (Weight kg, Sample #)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (measurements.isEmpty)
                  const Text(
                    'No data received yet. Start measurement to see data.',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  )
                else
                  for (int i = 0; i < measurements.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Text(
                        '[$i]: (${measurements[i].weight.toStringAsFixed(2)} kg, ${measurements[i].timestampSec.toStringAsFixed(6)}s)',
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
