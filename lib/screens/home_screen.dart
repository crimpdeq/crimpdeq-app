import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../models/progressor_models.dart' as models;
import '../providers/progressor_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common/background_gradient.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(progressorProvider);
    final connection = state.connection;

    return BackgroundGradient(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Start Training CTA
          _ActionCard(
            title: 'Start Training',
            icon: LucideIcons.play,
            enabled: true,
            onTap: () {
              if (connection.isConnected) {
                context.go('/session/setup');
                return;
              }
              _showTrainingModePicker(
                context,
                onPair: () {
                  ref.read(progressorProvider.notifier).startScanning();
                  _showDevicePicker(context);
                },
              );
            },
          ),
          const SizedBox(height: 12),

          // Workouts CTA
          _ActionCard(
            title: 'Workouts',
            icon: LucideIcons.listChecks,
            enabled: true,
            primary: false,
            onTap: () => context.go('/session/setup?mode=manage'),
          ),
        ],
      ),
    );
  }
}

void _showTrainingModePicker(
  BuildContext context, {
  required VoidCallback onPair,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showModalBottomSheet(
    context: context,
    backgroundColor: isDark ? webPanel : lightPanel,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Start training',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? webText : lightText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Use the timer without a device, or pair a Progressor to track force.',
              style: GoogleFonts.inter(fontSize: 14, color: webMuted),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(sheetContext);
                context.go('/session/setup?mode=timer');
              },
              icon: const Icon(Icons.timer_outlined),
              label: const Text('Use timer'),
              style: FilledButton.styleFrom(minimumSize: const Size(0, 52)),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(sheetContext);
                onPair();
              },
              icon: const Icon(Icons.bluetooth),
              label: const Text('Pair a device'),
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 52)),
            ),
          ],
        ),
      ),
    ),
  );
}

// ──────────────────────────── Action cards ─────────────────────────────

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.icon,
    required this.enabled,
    required this.onTap,
    this.primary = true,
  });

  final String title;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPrimary = primary && enabled;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 100,
        decoration: BoxDecoration(
          color: isDark ? webPanel : lightPanel,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isPrimary
                ? brandAccent.withValues(alpha: 0.6)
                : isDark
                ? webBorder.withValues(alpha: 0.5)
                : lightBorder.withValues(alpha: 0.5),
            width: isPrimary ? 1.5 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        color: enabled
                            ? (isDark ? webText : lightText)
                            : webMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                icon,
                size: 40,
                color: enabled
                    ? (isPrimary ? brandAccent : webMuted)
                    : webMuted.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────── Device picker ──────────────────────────

void _showDevicePicker(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showModalBottomSheet(
    context: context,
    backgroundColor: isDark ? webPanel : lightPanel,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => const _DevicePickerSheet(),
  );
}

class _DevicePickerSheet extends ConsumerWidget {
  const _DevicePickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(progressorProvider);
    final devices = state.discoveredDevices;
    final isScanning = state.connection.isScanning;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Auto-dismiss when connected.
    if (state.connection.isConnected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.pop(context);
      });
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: webMuted.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Devices',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: isDark ? webText : lightText,
                  ),
                ),
                const Spacer(),
                if (isScanning)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: brandAccent,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (devices.isEmpty && isScanning)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Searching nearby...',
                  style: GoogleFonts.inter(fontSize: 14, color: webMuted),
                ),
              )
            else if (devices.isEmpty && !isScanning)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'No devices found',
                  style: GoogleFonts.inter(fontSize: 14, color: webMuted),
                ),
              )
            else
              ...devices.map(
                (d) => _DeviceTile(
                  device: d,
                  onTap: () {
                    ref
                        .read(progressorProvider.notifier)
                        .connectToDiscoveredDevice(d.id);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  const _DeviceTile({required this.device, required this.onTap});

  final models.DiscoveredDevice device;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCrane = device.type == models.DeviceType.craneScale;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? webBgSoft : lightBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? webBorder.withValues(alpha: 0.6)
                : lightBorder.withValues(alpha: 0.7),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isCrane ? Icons.scale : Icons.fitness_center,
              size: 20,
              color: brandAccent,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.name,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isDark ? webText : lightText,
                    ),
                  ),
                  Text(
                    isCrane ? 'Crane Scale' : 'Progressor',
                    style: GoogleFonts.inter(fontSize: 12, color: webMuted),
                  ),
                ],
              ),
            ),
            Text(
              '${device.rssi} dBm',
              style: GoogleFonts.spaceGrotesk(fontSize: 12, color: webMuted),
            ),
          ],
        ),
      ),
    );
  }
}
