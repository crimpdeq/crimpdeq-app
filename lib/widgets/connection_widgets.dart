import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/progressor_models.dart' as progressor_models;

class ConnectionStatusCard extends StatelessWidget {
  const ConnectionStatusCard({
    super.key,
    required this.connection,
    required this.onStartScanning,
    required this.onDisconnect,
  });

  final progressor_models.ConnectionState connection;
  final VoidCallback onStartScanning;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connection Status',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (connection.isScanning || connection.isConnecting)
                  const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                Expanded(
                  child: Text(
                    connection.status,
                    style: TextStyle(
                      color:
                          connection.device != null
                              ? Colors.green
                              : connection.isScanning || connection.isConnecting
                              ? Colors.blue
                              : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (connection.status.contains('permissions required'))
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ElevatedButton(
                  onPressed: openAppSettings,
                  child: const Text('Open App Settings'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ControlButtonsCard extends StatelessWidget {
  const ControlButtonsCard({
    super.key,
    required this.connection,
    required this.onStartScanning,
    required this.onDisconnect,
  });

  final progressor_models.ConnectionState connection;
  final VoidCallback onStartScanning;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Controls', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        connection.bluetoothReady &&
                                !connection.isScanning &&
                                !connection.isConnecting &&
                                connection.device == null
                            ? onStartScanning
                            : null,
                    icon: const Icon(Icons.search),
                    label: const Text('Scan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: connection.device != null ? onDisconnect : null,
                    icon: const Icon(Icons.bluetooth_disabled),
                    label: const Text('Disconnect'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
