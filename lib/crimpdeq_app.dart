import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/progressor_provider.dart';
import 'widgets/progressor_widgets.dart';

class CrimpdeqApp extends StatelessWidget {
  const CrimpdeqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crimpdeq',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2F6EB8),
          primary: const Color(0xFF2F6EB8),
          secondary: const Color(0xFF6F7B8A),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F6F8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2F6EB8),
          foregroundColor: Colors.white,
        ),
        textTheme: GoogleFonts.interTextTheme(),
      ),
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

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
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
            ConnectionControlsCard(
              connection: state.connection,
              onStartScanning: notifier.startScanning,
              onDisconnect: notifier.disconnectDevice,
            ),
            const SizedBox(height: 16),
            if (state.connection.device != null) ...[
              CalibrationCard(
                connection: state.connection,
                onAddCalibrationPoint: notifier.addCalibrationPoint,
                onGetCalibration: notifier.getCalibration,
                onDefaultCalibration: notifier.defaultCalibration,
                calibrationInfo: state.errorMessage,
              ),
              const SizedBox(height: 16),
              DeviceInfoCard(deviceInfo: state.deviceInfo),
              const SizedBox(height: 16),
              PerformanceCard(performance: state.performance),
              const SizedBox(height: 16),
              MeasurementControlCard(
                measurement: state.measurement,
                onStartMeasurement: notifier.startMeasurement,
                onStopMeasurement: notifier.stopMeasurement,
                onTareScale: notifier.tareScale,
              ),
              const SizedBox(height: 16),
              CurrentWeightCard(measurement: state.measurement),
              const SizedBox(height: 16),
              if (state.measurement.weightHistory.isNotEmpty) ...[
                WeightHistoryCard(measurement: state.measurement),
                const SizedBox(height: 16),
              ],
              if (state.performance.notifyIntervalHistory.isNotEmpty) ...[
                NotifyIntervalCard(performance: state.performance),
                const SizedBox(height: 16),
              ],
              ReceivedDataCard(measurements: state.measurement.receivedData),
            ],
          ],
        ),
      ),
    );
  }
}
