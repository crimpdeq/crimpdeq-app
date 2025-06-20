import 'package:flutter/material.dart';

import '../models/progressor_models.dart' as progressor_models;

class DeviceInfoCard extends StatelessWidget {
  const DeviceInfoCard({super.key, required this.deviceInfo});

  final progressor_models.DeviceInfo deviceInfo;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Device Info', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (deviceInfo.firmwareVersion.isNotEmpty)
              Text('Firmware: ${deviceInfo.firmwareVersion}'),
            if (deviceInfo.batteryVoltage.isNotEmpty)
              Text('Battery: ${deviceInfo.batteryVoltage} mV'),
            if (deviceInfo.tareValue != 0.0)
              Text('Tare: ${deviceInfo.tareValue.toStringAsFixed(2)} kg'),
          ],
        ),
      ),
    );
  }
}

class PerformanceCard extends StatelessWidget {
  const PerformanceCard({super.key, required this.performance});

  final progressor_models.PerformanceMetrics performance;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Performance', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${performance.currentHz.toStringAsFixed(1)} Hz',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const Text('Data rate'),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${performance.currentNotifyIntervalMs.toStringAsFixed(2)} ms',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const Text('Notify interval'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Packets: ${performance.dataPacketCount}'),
                Text('Samples/packet: ${performance.samplesPerPacket}'),
              ],
            ),
            if (performance.duplicatePacketCount > 0)
              Text(
                '🔴 Duplicates: ${performance.duplicatePacketCount}',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
