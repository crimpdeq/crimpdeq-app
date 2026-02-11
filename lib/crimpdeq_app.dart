import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/progressor_provider.dart';
import 'widgets/progressor_widgets.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

class CrimpdeqApp extends ConsumerWidget {
  const CrimpdeqApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const brandBlue = Color(0xFF2F6EB8);
    const secondary = Color(0xFF6F7B8A);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Crimpdeq',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: brandBlue,
          primary: brandBlue,
          secondary: secondary,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F6F8),
        appBarTheme: const AppBarTheme(
          backgroundColor: brandBlue,
          foregroundColor: Colors.white,
        ),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: brandBlue,
          primary: brandBlue,
          secondary: secondary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: brandBlue,
          foregroundColor: Colors.white,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      themeMode: themeMode,
      home: const CrimpdeqScreen(),
    );
  }
}

class CrimpdeqScreen extends ConsumerWidget {
  const CrimpdeqScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(progressorNotifierProvider);
    final notifier = ref.read(progressorNotifierProvider.notifier);
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    final connection = state.connection;
    final showScanButton =
        connection.bluetoothReady &&
        !connection.isScanning &&
        !connection.isConnecting &&
        connection.device == null;
    final showDisconnectButton = connection.device != null;
    final statusColor =
        connection.device != null
            ? Colors.green
            : connection.isScanning || connection.isConnecting
            ? Colors.blue
            : Colors.orange;
    final statusLabel =
        connection.device != null
            ? 'Connected'
            : connection.isScanning
            ? 'Scanning'
            : connection.isConnecting
            ? 'Connecting'
            : connection.bluetoothReady
            ? 'Ready'
            : 'Offline';
    final isDeviceNotConnected =
        connection.device == null &&
        connection.bluetoothReady &&
        !connection.isScanning &&
        !connection.isConnecting;
    final connectedStatusLines = <String>[
      'Device Connected',
      if (state.deviceInfo.firmwareVersion.isNotEmpty)
        'Firmware: ${state.deviceInfo.firmwareVersion}',
      if (state.deviceInfo.batteryVoltage.isNotEmpty)
        'Battery: ${state.deviceInfo.batteryVoltage} mV',
      if (state.deviceInfo.tareValue != 0.0)
        'Tare ${state.deviceInfo.tareValue.toStringAsFixed(2)} kg',
    ];
    final statusText =
        connection.device != null
            ? connectedStatusLines.join('\n')
            : isDeviceNotConnected
            ? 'Device Not Connected'
            : 'Connection: $statusLabel';

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 64,
        leadingWidth: showDisconnectButton ? 330 : 170,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Row(
            mainAxisAlignment:
                isDeviceNotConnected ? MainAxisAlignment.center : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 6, top: 2),
                      decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                    ),
                    Expanded(
                      child: Text(
                        statusText,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        textAlign: isDeviceNotConnected ? TextAlign.center : TextAlign.start,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          height: 1.15,
                        ),
                      ),
                    ),
                    if (connection.isScanning || connection.isConnecting)
                      const Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (showDisconnectButton) const SizedBox(width: 8),
              if (showDisconnectButton)
                FilledButton.icon(
                  onPressed: notifier.disconnectDevice,
                  icon: const Icon(Icons.bluetooth_disabled, size: 16),
                  label: const Text('Disconnect'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          _ThemeSlider(
            isDarkMode: isDarkMode,
            onChanged: (isDark) {
              ref.read(themeModeProvider.notifier).state =
                  isDark ? ThemeMode.dark : ThemeMode.light;
            },
          ),
          const SizedBox(width: 8),
        ],
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Image.asset(
                'assets/Logo_app_512x512.png',
                fit: BoxFit.contain,
                errorBuilder: (context, _, __) => const Icon(Icons.image_not_supported),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Crimpdeq',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showScanButton) const SizedBox(height: 72),
            if (showScanButton)
              Center(
                child: FilledButton.icon(
                  onPressed: notifier.startScanning,
                  icon: const Icon(Icons.search, size: 24),
                  label: const Text('Scan'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(280, 56),
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    textStyle: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            if (showScanButton) const SizedBox(height: 24),
            if (state.connection.device != null) ...[
              CalibrationCard(
                connection: state.connection,
                onAddCalibrationPoint: notifier.addCalibrationPoint,
                onGetCalibration: notifier.getCalibration,
                onDefaultCalibration: notifier.defaultCalibration,
                calibrationInfo: state.errorMessage,
              ),
              const SizedBox(height: 16),
              MeasurementControlCard(
                measurement: state.measurement,
                onStartMeasurement: notifier.startMeasurement,
                onStopMeasurement: notifier.stopMeasurement,
                onTareScale: notifier.tareScale,
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final useTwoColumns = constraints.maxWidth >= 900;
                  if (!useTwoColumns) {
                    return Column(
                      children: [
                        PerformanceCard(performance: state.performance),
                        const SizedBox(height: 16),
                        CurrentWeightCard(measurement: state.measurement),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: PerformanceCard(performance: state.performance),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CurrentWeightCard(measurement: state.measurement),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              if (state.measurement.weightHistory.isNotEmpty) ...[
                WeightHistoryCard(measurement: state.measurement),
                const SizedBox(height: 16),
              ],
              if (state.performance.notifyIntervalHistory.isNotEmpty) ...[
                NotifyIntervalCard(performance: state.performance),
                const SizedBox(height: 16),
              ],
              if (state.measurement.isMeasuring ||
                  state.measurement.receivedData.isNotEmpty)
                ReceivedDataCard(measurements: state.measurement.receivedData),
            ],
          ],
        ),
      ),
    );
  }
}

class _ThemeSlider extends StatelessWidget {
  const _ThemeSlider({required this.isDarkMode, required this.onChanged});

  final bool isDarkMode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isDarkMode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 58,
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF9CA3AF) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white70),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('🌞', style: TextStyle(fontSize: 10)),
                Text('🌙', style: TextStyle(fontSize: 10)),
              ],
            ),
            AnimatedAlign(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              alignment: isDarkMode ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF6B7280) : const Color(0xFFE5E7EB),
                  shape: BoxShape.circle,
                ),
                child: Text(isDarkMode ? '🌙' : '🌞', style: const TextStyle(fontSize: 11)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
