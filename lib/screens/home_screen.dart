import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/progressor_models.dart';
import '../providers/progressor_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common/background_gradient.dart';
import '../widgets/history/pr_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(progressorProvider);
    final notifier = ref.read(progressorProvider.notifier);
    final connection = state.connection;

    final showScanButton = connection.bluetoothReady &&
        !connection.isScanning &&
        !connection.isConnecting &&
        !connection.isConnected;

    return BackgroundGradient(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: !connection.isConnected
            ? _DisconnectedView(
                showScanButton: showScanButton,
                onScan: notifier.startScanning,
                onSimulator: notifier.connectSimulator,
              )
            : _ConnectedView(state: state, notifier: notifier),
      ),
    );
  }
}

class _DisconnectedView extends StatelessWidget {
  const _DisconnectedView({
    required this.showScanButton,
    required this.onScan,
    required this.onSimulator,
  });

  final bool showScanButton;
  final VoidCallback onScan;
  final VoidCallback onSimulator;

  @override
  Widget build(BuildContext context) {
    if (!showScanButton) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 72),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton.icon(
              onPressed: onScan,
              icon: const Icon(Icons.search, size: 24),
              label: const Text('Scan'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(280, 56),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                textStyle: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
            if (kDebugMode) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onSimulator,
                icon: const Icon(Icons.bug_report, size: 20),
                label: const Text('Debug'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(280, 48),
                  textStyle: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
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

class _ConnectedView extends StatelessWidget {
  const _ConnectedView({required this.state, required this.notifier});

  final ProgressorState state;
  final ProgressorNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bluetooth_connected,
              size: 48,
              color: Colors.greenAccent.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Device Connected',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            if (state.deviceInfo.firmwareVersion.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Firmware: ${state.deviceInfo.firmwareVersion}',
                style: GoogleFonts.inter(fontSize: 14, color: webMuted),
              ),
            ],
            if (state.deviceInfo.batteryVoltage.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                'Battery: ${state.deviceInfo.batteryVoltage} mV',
                style: GoogleFonts.inter(fontSize: 14, color: webMuted),
              ),
            ],
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => context.go('/session/setup'),
              icon: const Icon(Icons.play_arrow, size: 24),
              label: const Text('Start Session'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(280, 56),
                textStyle: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.go('/measurements'),
              icon: const Icon(Icons.show_chart, size: 20),
              label: const Text('Freeform Measurement'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(280, 48),
                textStyle: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const PrCard(),
          ],
        ),
      ),
    );
  }
}
