import 'package:flutter/material.dart';

import '../models/progressor_models.dart' as progressor_models;

class ReceivedDataCard extends StatelessWidget {
  const ReceivedDataCard({super.key, required this.measurements});

  final List<progressor_models.WeightMeasurement> measurements;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: IntrinsicWidth(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Last Received Samples', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                if (measurements.isEmpty)
                  const Text(
                    'No data received yet. Start measurement to see data.',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  )
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Weight (kg)')),
                        DataColumn(label: Text('Timestamp (s)')),
                      ],
                      rows:
                          measurements.asMap().entries.map((entry) {
                            final measurement = entry.value;
                            return DataRow(
                              cells: [
                                DataCell(Text(measurement.weight.toStringAsFixed(2))),
                                DataCell(Text(measurement.timestampSec.toStringAsFixed(6))),
                              ],
                            );
                          }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
