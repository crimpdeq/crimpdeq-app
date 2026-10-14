import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analysis/force_stats.dart';
import '../constants/progressor_constants.dart';
import '../models/progressor_models.dart';
import '../providers/progressor_provider.dart';
import '../theme.dart';
import 'chart_widgets.dart';
import 'data_widgets.dart';

class MeasurementTab extends ConsumerWidget {
  const MeasurementTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final measurement = ref.watch(
      progressorProvider.select((state) => state.measurement),
    );
    final performance = ref.watch(
      progressorProvider.select((state) => state.performance),
    );
    final sampleRate = ref.watch(
      progressorProvider.select((state) => state.deviceInfo.sampleRate),
    );
    final notifier = ref.read(progressorProvider.notifier);

    return SingleChildScrollView(
      child: Column(
        children: [
          MeasurementControls(
            isMeasuring: measurement.isMeasuring,
            onStartMeasurement: notifier.startMeasurement,
            onStopMeasurement: notifier.stopMeasurement,
            onTareScale: notifier.tareScale,
            onResetMeasurement: notifier.resetMeasurement,
          ),
          const SizedBox(height: 16),
          _ResponsivePair(
            breakpoint: 900,
            first: ForceSummaryCard(measurement: measurement),
            second: PerformanceCard(
              performance: performance,
              sampleRate: sampleRate,
              onSampleRateChanged: notifier.setSampleRate,
            ),
          ),
          if (measurement.receivedData.isNotEmpty) ...[
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final charts = [
                  WeightHistoryCard(measurement: measurement),
                  const SizedBox(height: 16),
                  NotifyIntervalCard(performance: performance),
                ];
                final samples = ReceivedDataCard(
                  measurements: measurement.receivedData,
                );
                if (constraints.maxWidth < 1200) {
                  return Column(
                    children: [...charts, const SizedBox(height: 16), samples],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Column(children: charts)),
                    const SizedBox(width: 16),
                    samples,
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// Side by side from [breakpoint] wide, stacked below it.
class _ResponsivePair extends StatelessWidget {
  const _ResponsivePair({
    required this.breakpoint,
    required this.first,
    required this.second,
  });

  final double breakpoint;
  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [first, const SizedBox(height: 16), second],
          );
        }
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: first),
              const SizedBox(width: 16),
              Expanded(child: second),
            ],
          ),
        );
      },
    );
  }
}

class MeasurementControls extends StatelessWidget {
  const MeasurementControls({
    super.key,
    required this.isMeasuring,
    required this.onStartMeasurement,
    required this.onStopMeasurement,
    required this.onTareScale,
    required this.onResetMeasurement,
  });

  final bool isMeasuring;
  final VoidCallback onStartMeasurement;
  final VoidCallback onStopMeasurement;
  final VoidCallback onTareScale;
  final VoidCallback onResetMeasurement;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: isMeasuring ? onStopMeasurement : onStartMeasurement,
              icon: Icon(isMeasuring ? Icons.stop : Icons.play_arrow),
              label: Text(isMeasuring ? 'Stop' : 'Start'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isMeasuring ? paleRed : colorScheme.primary,
                foregroundColor: isMeasuring
                    ? colorScheme.onError
                    : colorScheme.onPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onTareScale,
              icon: const Icon(Icons.adjust),
              label: const Text('Tare'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onResetMeasurement,
              icon: const Icon(Icons.restart_alt),
              label: const Text('Reset'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Current force and the summary of the window since start, tare or reset.
class ForceSummaryCard extends StatelessWidget {
  const ForceSummaryCard({super.key, required this.measurement});

  final MeasurementState measurement;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    String kg(double? value) =>
        value == null ? '—' : '${value.toStringAsFixed(2)} kg';
    final peakRfd = measurement.peakRfdKgPerS;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('Force', style: textTheme.titleMedium)),
                if (measurement.isMeasuring)
                  Icon(
                    Icons.radio_button_checked,
                    color: colorScheme.error,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 24,
              runSpacing: 12,
              children: [
                _Metric(label: 'Current', value: kg(measurement.currentKg)),
                _Metric(label: 'Min', value: kg(measurement.minKg)),
                _Metric(label: 'Peak', value: kg(measurement.peakKg)),
                _Metric(
                  label: 'Peak RFD',
                  value: peakRfd == null
                      ? '—'
                      : '${peakRfd.toStringAsFixed(1)} kg/s',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Elapsed: ${(measurement.elapsedUs / Duration.microsecondsPerSecond).toStringAsFixed(1)} s · '
              'RFD over ${ForceStats.rfdSpanUs ~/ Duration.microsecondsPerMillisecond} ms',
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.bodySmall),
        Text(
          value,
          style: textTheme.headlineSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

class PerformanceCard extends StatelessWidget {
  const PerformanceCard({
    super.key,
    required this.performance,
    required this.sampleRate,
    required this.onSampleRateChanged,
  });

  final PerformanceMetrics performance;
  // Rate reported by the device; null hides the selector.
  final int? sampleRate;
  final ValueChanged<int> onSampleRateChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final sampleRate = this.sampleRate;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Performance', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Data sample', style: textTheme.bodySmall),
                    Text(
                      '${performance.currentHz.toStringAsFixed(1)} Hz',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Notify interval', style: textTheme.bodySmall),
                    Text(
                      '${performance.currentNotifyIntervalMs.toStringAsFixed(2)} ms',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.primary,
                      ),
                    ),
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
            if (sampleRate != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Sample rate'),
                  DropdownButton<int>(
                    value: sampleRate,
                    onChanged: (value) {
                      if (value != null) onSampleRateChanged(value);
                    },
                    items: [
                      for (final MapEntry(key: rate, value: useCase)
                          in AppConstants.sampleRateUseCases.entries)
                        DropdownMenuItem(
                          value: rate,
                          child: Text('$useCase · $rate SPS'),
                        ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
