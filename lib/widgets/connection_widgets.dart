import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../analysis/battery.dart';
import '../models/progressor_models.dart';
import '../theme.dart';

String _batteryLabel(int millivolts, {required bool compact}) {
  final charge = '~${batteryStateOfCharge(millivolts)}%';
  return compact
      ? charge
      : '$charge (${(millivolts / 1000).toStringAsFixed(2)} V)';
}

/// Connection status for the app bar: a status dot, the state, firmware and
/// battery lines, and a disconnect button.
class ConnectionHeader extends StatelessWidget {
  const ConnectionHeader({
    super.key,
    required this.connection,
    required this.deviceInfo,
    required this.compact,
    required this.onDisconnect,
  });

  final DeviceConnection connection;
  final DeviceInfo deviceInfo;
  final bool compact;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foreground =
        Theme.of(context).appBarTheme.foregroundColor ?? colorScheme.onSurface;
    final busy = connection.isScanning || connection.isConnecting;
    final statusColor = connection.isConnected
        ? Colors.greenAccent.shade400
        : busy
        ? colorScheme.primary
        : Colors.orangeAccent.shade200;
    final batteryMillivolts = deviceInfo.batteryMillivolts;
    final lines = [
      connection.isConnected
          ? 'Connected'
          : connection.isScanning
          ? 'Scanning'
          : connection.isConnecting
          ? 'Connecting'
          : connection.bluetoothReady
          ? 'Not connected'
          : 'Bluetooth unavailable',
      if (deviceInfo.firmwareVersion.isNotEmpty)
        '${compact ? 'FW' : 'Firmware'}: ${deviceInfo.firmwareVersion}',
      if (batteryMillivolts != null)
        '${compact ? 'Bat' : 'Battery'}: '
            '${_batteryLabel(batteryMillivolts, compact: compact)}',
    ];
    final fontSize = compact ? 10.0 : 12.0;

    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Row(
        children: [
          if (connection.device != null && compact) ...[
            IconButton.outlined(
              tooltip: 'Disconnect',
              onPressed: onDisconnect,
              icon: const Icon(Icons.bluetooth_disabled, color: paleRed),
              iconSize: 18,
              visualDensity: VisualDensity.compact,
              style: IconButton.styleFrom(
                backgroundColor: paleRed.withValues(alpha: 0.18),
                side: const BorderSide(color: paleRed),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (index, line) in lines.indexed)
                  Text(
                    line,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: interFont,
                      color: foreground,
                      fontWeight: index == 0
                          ? FontWeight.w700
                          : FontWeight.w600,
                      fontSize: index == 0 ? fontSize + 1 : fontSize,
                      height: 1.15,
                    ),
                  ),
              ],
            ),
          ),
          if (busy)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: SizedBox.square(
                dimension: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foreground,
                ),
              ),
            ),
          if (connection.device != null && !compact) ...[
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: onDisconnect,
              icon: const Icon(Icons.bluetooth_disabled, size: 16),
              label: const Text('Disconnect'),
              style: FilledButton.styleFrom(
                backgroundColor: paleRed,
                foregroundColor: colorScheme.onError,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Scan button, settings shortcut and the devices found.
class ConnectPanel extends StatelessWidget {
  const ConnectPanel({
    super.key,
    required this.connection,
    required this.onStartScanning,
    required this.onConnect,
  });

  final DeviceConnection connection;
  final VoidCallback onStartScanning;
  final ValueChanged<DiscoveredDevice> onConnect;

  @override
  Widget build(BuildContext context) {
    final canScan =
        connection.bluetoothReady &&
        !connection.isScanning &&
        !connection.isConnecting &&
        connection.device == null;

    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Padding(
            padding: const EdgeInsets.only(top: 56),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (canScan) ...[
                  FilledButton.icon(
                    onPressed: onStartScanning,
                    icon: const Icon(Icons.search, size: 24),
                    label: const Text('Scan'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(280, 56),
                      textStyle: const TextStyle(
                        fontFamily: interFont,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (connection.needsSettings && !kIsWeb) ...[
                  const OutlinedButton(
                    onPressed: openAppSettings,
                    child: Text('Open App Settings'),
                  ),
                  const SizedBox(height: 16),
                ],
                DiscoveredDevicesCard(
                  connection: connection,
                  onConnect: onConnect,
                ),
              ],
            ),
          ),
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

  final DeviceConnection connection;
  final ValueChanged<DiscoveredDevice> onConnect;

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
                  child: Text('Devices', style: theme.textTheme.titleMedium),
                ),
                if (connection.isScanning)
                  const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(connection.status, style: theme.textTheme.bodyMedium),
            for (final device in devices) ...[
              const SizedBox(height: 10),
              DecoratedBox(
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
                            Text(device.id, style: theme.textTheme.bodySmall),
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
            ],
          ],
        ),
      ),
    );
  }
}

class LowBatteryBanner extends StatelessWidget {
  const LowBatteryBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: colorScheme.error,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.battery_alert, color: colorScheme.onError),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Battery empty: the device is turning off. Charge it to '
                'continue.',
                style: TextStyle(
                  color: colorScheme.onError,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
