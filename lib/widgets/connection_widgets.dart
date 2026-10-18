import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../analysis/battery.dart';
import '../models/progressor_models.dart';
import '../theme.dart';

String _volts(int millivolts) => '${(millivolts / 1000).toStringAsFixed(2)} V';

/// Status chip for the app bar: the connection state, or the device name and
/// battery once connected. Tapping it opens the device details.
class DeviceStatusChip extends StatelessWidget {
  const DeviceStatusChip({
    super.key,
    required this.connection,
    required this.deviceInfo,
    required this.compact,
  });

  final DeviceConnection connection;
  final DeviceInfo deviceInfo;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final foreground =
        theme.appBarTheme.foregroundColor ?? colorScheme.onSurface;
    final busy = connection.isScanning || connection.isConnecting;
    final millivolts = deviceInfo.batteryMillivolts;
    final charge =
        deviceInfo.batteryPercent ??
        (millivolts != null ? batteryStateOfCharge(millivolts) : null);
    // Without a fuel gauge the charge is estimated from the voltage.
    final chargeText = charge == null
        ? null
        : '${deviceInfo.batteryPercent == null ? '~' : ''}$charge%';
    final textStyle = TextStyle(
      fontFamily: interFont,
      color: foreground,
      fontWeight: FontWeight.w600,
      fontSize: compact ? 12 : 13,
    );
    final hasDetails = connection.device != null;

    Widget chip(VoidCallback? onTap) => Material(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      shape: StadiumBorder(side: BorderSide(color: colorScheme.outlineVariant)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.fromLTRB(10, 6, hasDetails ? 4 : 12, 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (busy)
                SizedBox.square(
                  dimension: 10,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: colorScheme.primary,
                  ),
                )
              else
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: connection.isConnected
                        ? Colors.greenAccent.shade400
                        : Colors.orangeAccent.shade200,
                    shape: BoxShape.circle,
                  ),
                ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  connection.isConnected
                      ? connection.deviceName
                      : connection.isScanning
                      ? 'Scanning…'
                      : connection.isConnecting
                      ? 'Connecting…'
                      : connection.bluetoothReady
                      ? 'Not connected'
                      : 'Bluetooth unavailable',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (charge != null) ...[
                const SizedBox(width: 10),
                Icon(
                  _batteryIcon(charge, deviceInfo.batteryCharging),
                  size: 16,
                  color: _batteryColor(charge) ?? foreground,
                ),
                const SizedBox(width: 2),
                Text(
                  [
                    chargeText!,
                    if (!compact && millivolts != null) _volts(millivolts),
                  ].join(' · '),
                  style: textStyle.copyWith(color: _batteryColor(charge)),
                ),
              ],
              if (hasDetails)
                Icon(Icons.arrow_drop_down, size: 20, color: foreground),
            ],
          ),
        ),
      ),
    );

    if (!hasDetails) return chip(null);

    final sampleRate = deviceInfo.sampleRate;
    return MenuAnchor(
      alignmentOffset: const Offset(0, 6),
      menuChildren: [
        Padding(
          padding: const EdgeInsets.all(16),
          // Fits a phone; long values, such as the UUID that identifies the
          // device on iOS, macOS and Web, wrap.
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(connection.deviceName, style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                for (final (label, value) in [
                  ('ID', connection.device!.remoteId.str),
                  if (deviceInfo.firmwareVersion.isNotEmpty)
                    ('Firmware', deviceInfo.firmwareVersion),
                  if (chargeText != null)
                    (
                      'Battery',
                      '$chargeText'
                          '${deviceInfo.batteryCharging ? ', charging' : ''}',
                    ),
                  if (millivolts != null) ('Voltage', _volts(millivolts)),
                  if (sampleRate != null) ('Sample rate', '$sampleRate Hz'),
                ])
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 96,
                          child: Text(label, style: theme.textTheme.bodySmall),
                        ),
                        Flexible(
                          child: Text(value, style: theme.textTheme.bodyMedium),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
      builder: (context, controller, _) => chip(
        () => controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }
}

IconData _batteryIcon(int percent, bool charging) {
  if (charging) return Icons.battery_charging_full;
  if (percent >= 95) return Icons.battery_full;
  const bars = [
    Icons.battery_0_bar,
    Icons.battery_1_bar,
    Icons.battery_2_bar,
    Icons.battery_3_bar,
    Icons.battery_4_bar,
    Icons.battery_5_bar,
    Icons.battery_6_bar,
  ];
  return bars[(percent * bars.length ~/ 100).clamp(0, bars.length - 1)];
}

/// Warning color for a low charge, null otherwise.
Color? _batteryColor(int percent) => percent <= 15
    ? paleRed
    : percent <= 30
    ? Colors.orangeAccent.shade200
    : null;

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
