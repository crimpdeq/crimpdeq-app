import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/progressor_models.dart' as progressor_models;

class ConnectionControlsCard extends StatelessWidget {
  const ConnectionControlsCard({
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
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Connection', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
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
                      color: connection.device != null
                          ? Colors.greenAccent.shade400
                          : connection.isScanning || connection.isConnecting
                          ? colorScheme.primary
                          : Colors.orangeAccent.shade200,
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
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
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
                      backgroundColor: colorScheme.error,
                      foregroundColor: colorScheme.onError,
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

class DiscoveredDevicesCard extends StatelessWidget {
  const DiscoveredDevicesCard({
    super.key,
    required this.connection,
    required this.onConnect,
  });

  final progressor_models.ConnectionState connection;
  final ValueChanged<progressor_models.DiscoveredDevice> onConnect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final devices = connection.discoveredDevices;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Possible devices',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                if (connection.isScanning)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(connection.status, style: theme.textTheme.bodyMedium),
            if (devices.isEmpty) ...[
              const SizedBox(height: 12),
              Text(
                connection.isScanning
                    ? 'Scanning for compatible devices...'
                    : 'Start a scan to see available devices.',
                style: theme.textTheme.bodySmall,
              ),
            ] else ...[
              const SizedBox(height: 12),
              ...devices.map(
                (device) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.25,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.bluetooth_searching,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  device.name,
                                  style: theme.textTheme.titleSmall,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  device.id,
                                  style: theme.textTheme.bodySmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'RSSI: ${device.rssi} dBm',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          FilledButton(
                            onPressed: connection.isConnecting
                                ? null
                                : () => onConnect(device),
                            child: const Text('Connect'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
