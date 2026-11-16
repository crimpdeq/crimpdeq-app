import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../analysis/battery.dart';
import '../models/progressor_models.dart';
import '../providers/progressor_provider.dart';
import '../theme.dart';

String _volts(int millivolts) => '${(millivolts / 1000).toStringAsFixed(2)} V';

/// Status chip for the app bar: the connection state, or the device name and
/// battery once connected. Tapping it opens the device details, which can
/// disconnect: two taps, so a workout does not end by accident.
class DeviceStatusChip extends StatelessWidget {
  const DeviceStatusChip({
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
        const Divider(height: 1),
        MenuItemButton(
          leadingIcon: const Icon(Icons.bluetooth_disabled, color: paleRed),
          onPressed: onDisconnect,
          child: const Text('Disconnect'),
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

/// Scans for devices and connects to the selected one, centered on a page
/// that needs a device.
class ConnectView extends StatelessWidget {
  const ConnectView({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: const ConnectCard(),
        ),
      ),
    );
  }
}

/// Scan button, settings shortcut and the devices found.
class ConnectCard extends ConsumerWidget {
  const ConnectCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final notifier = ref.read(progressorProvider.notifier);
    final connection = ref.watch(
      progressorProvider.select((state) => state.connection),
    );
    final busy = connection.isScanning || connection.isConnecting;
    final canScan =
        connection.bluetoothReady && !busy && connection.device == null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  connection.bluetoothReady
                      ? Icons.bluetooth_searching
                      : Icons.bluetooth_disabled,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Connect your Crimpdeq',
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(connection.status, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                if (busy)
                  const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            if (canScan) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: notifier.startScanning,
                icon: const Icon(Icons.search),
                label: const Text('Scan'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
            if (connection.needsSettings && !kIsWeb) ...[
              const SizedBox(height: 8),
              const OutlinedButton(
                onPressed: openAppSettings,
                child: Text('Open App Settings'),
              ),
            ],
            for (final device in connection.discoveredDevices) ...[
              const SizedBox(height: 8),
              _DeviceRow(
                device: device,
                onConnect: connection.isConnecting
                    ? null
                    : () => notifier.connect(device),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DeviceRow extends StatelessWidget {
  const _DeviceRow({required this.device, required this.onConnect});

  final DiscoveredDevice device;
  final VoidCallback? onConnect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(device.name, style: theme.textTheme.titleSmall),
                  // Tells devices with the same name apart, the nearest by
                  // the strongest signal.
                  Text(
                    '${device.id} · ${device.rssi} dBm',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(onPressed: onConnect, child: const Text('Connect')),
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
