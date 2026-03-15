import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/progressor_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common/background_gradient.dart';
import '../widgets/progressor_widgets.dart';

class MeasurementScreen extends ConsumerWidget {
  const MeasurementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(progressorProvider);
    final notifier = ref.read(progressorProvider.notifier);
    final measurement = state.measurement;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (measurement.isMeasuring) notifier.stopMeasurement();
            context.go('/');
          },
        ),
        title: Text(
          'Freeform',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
      ),
      body: BackgroundGradient(
        child: Column(
          children: [
            // Hero weight
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    measurement.currentWeight.toStringAsFixed(1),
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w800,
                      fontSize: 56,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'kg',
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      color: webMuted,
                    ),
                  ),
                ],
              ),
            ),

            // Live chart
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: measurement.weightHistory.isNotEmpty
                    ? WeightHistoryCard(measurement: measurement)
                    : Center(
                        child: Text(
                          measurement.isMeasuring
                              ? 'Waiting for data...'
                              : 'Press Start to begin measuring',
                          style:
                              GoogleFonts.inter(fontSize: 16, color: webMuted),
                        ),
                      ),
              ),
            ),

            // Controls
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Tare
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: notifier.tareScale,
                      icon: const Icon(Icons.adjust, size: 20),
                      label: const Text('Tare'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 52),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Start / Stop
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: measurement.isMeasuring
                          ? notifier.stopMeasurement
                          : notifier.startMeasurement,
                      icon: Icon(
                        measurement.isMeasuring
                            ? Icons.stop
                            : Icons.play_arrow,
                        size: 24,
                      ),
                      label: Text(
                        measurement.isMeasuring ? 'Stop' : 'Start',
                      ),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 52),
                        backgroundColor: measurement.isMeasuring
                            ? paleRed
                            : colorScheme.primary,
                        textStyle: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Status bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${state.performance.currentHz.toStringAsFixed(0)} Hz',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: webMuted,
                    ),
                  ),
                  if (measurement.isMeasuring)
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: colorScheme.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Recording',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  Text(
                    '${state.performance.dataPacketCount} samples',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: webMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

