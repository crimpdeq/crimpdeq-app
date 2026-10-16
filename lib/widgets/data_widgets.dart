import 'package:flutter/material.dart';

import '../models/progressor_models.dart';

class ReceivedDataCard extends StatelessWidget {
  const ReceivedDataCard({super.key, required this.measurements});

  final List<WeightMeasurement> measurements;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Align(
      alignment: Alignment.topLeft,
      child: IntrinsicWidth(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Last Received Samples',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                if (measurements.isEmpty)
                  Text(
                    'No data received yet. Start measurement to see data.',
                    style: textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
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
                      rows: measurements.map((measurement) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(measurement.weightKg.toStringAsFixed(2)),
                            ),
                            DataCell(
                              Text(measurement.timestampSec.toStringAsFixed(6)),
                            ),
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
