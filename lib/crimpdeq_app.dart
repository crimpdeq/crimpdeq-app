import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'providers/progressor_provider.dart';
import 'widgets/progressor_widgets.dart';

class CrimpdeqApp extends StatelessWidget {
  const CrimpdeqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crimpdeq',
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
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
        title: const Text('Crimpdeq'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConnectionStatusCard(
              connection: state.connection,
              onStartScanning: notifier.startScanning,
              onDisconnect: notifier.disconnectDevice,
            ),
            const SizedBox(height: 16),
            ControlButtonsCard(
              connection: state.connection,
              onStartScanning: notifier.startScanning,
              onDisconnect: notifier.disconnectDevice,
            ),
            const SizedBox(height: 16),
            if (state.connection.device != null) ...[
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
