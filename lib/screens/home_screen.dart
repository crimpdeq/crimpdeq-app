import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/progressor_models.dart' as models;
import '../providers/progressor_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common/background_gradient.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(progressorProvider);
    final notifier = ref.read(progressorProvider.notifier);
    final connection = state.connection;

    return BackgroundGradient(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Connection pill
          _ConnectionPill(
            connection: connection,
            onScan: () {
              notifier.startScanning();
              _showDevicePicker(context);
            },
            onSimulator: notifier.connectSimulator,
          ),
          const SizedBox(height: 24),

          // Start Training CTA
          _ActionCard(
            title: 'Start Training',
            icon: Icons.play_circle_filled,
            enabled: connection.isConnected,
            disabledHint: 'Connect a device to start',
            onTap: () => context.go('/session/setup'),
          ),
          const SizedBox(height: 12),

          // Workouts CTA
          _ActionCard(
            title: 'Workouts',
            icon: Icons.list_alt,
            enabled: true,
            primary: false,
            onTap: () => context.go('/session/setup?mode=manage'),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────── Connection pill ──────────────────────────

class _ConnectionPill extends StatelessWidget {
  const _ConnectionPill({
    required this.connection,
    required this.onScan,
    required this.onSimulator,
  });

  final models.ConnectionState connection;
  final VoidCallback onScan;
  final VoidCallback onSimulator;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color dotColor;
    String label;
    VoidCallback? onTap;

    if (!connection.bluetoothReady) {
      dotColor = webMuted;
      label = 'Bluetooth Off';
      onTap = null;
    } else if (connection.isConnected) {
      dotColor = const Color(0xFF3FB950);
      label = connection.isSimulator
          ? 'Simulator'
          : connection.isCraneScale
              ? 'Crane Scale'
              : 'Connected';
      onTap = null;
    } else if (connection.isScanning || connection.isConnecting) {
      dotColor = brandAccent;
      label = connection.isScanning ? 'Scanning...' : 'Connecting...';
      onTap = null;
    } else {
      dotColor = webMuted;
      label = 'Connect device';
      onTap = onScan;
    }

    return Row(
      children: [
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? webPanel : lightPanel,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? webBorder.withValues(alpha: 0.6)
                    : lightBorder.withValues(alpha: 0.7),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _AnimatedDot(color: dotColor, pulsing: connection.isScanning),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: isDark ? webText : lightText,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (kDebugMode && !connection.isConnected && !connection.isScanning) ...[
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onSimulator,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? webPanel : lightPanel,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? webBorder.withValues(alpha: 0.6)
                      : lightBorder.withValues(alpha: 0.7),
                ),
              ),
              child: Icon(
                Icons.bug_report,
                size: 16,
                color: isDark ? webMuted : lightMuted,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _AnimatedDot extends StatefulWidget {
  const _AnimatedDot({required this.color, this.pulsing = false});

  final Color color;
  final bool pulsing;

  @override
  State<_AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<_AnimatedDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    if (widget.pulsing) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_AnimatedDot old) {
    super.didUpdateWidget(old);
    if (widget.pulsing && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.pulsing && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withValues(
              alpha: widget.pulsing ? 0.4 + 0.6 * _controller.value : 1.0,
            ),
          ),
        );
      },
    );
  }
}

// ──────────────────────────── Action cards ─────────────────────────────

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.icon,
    required this.enabled,
    required this.onTap,
    this.disabledHint,
    this.primary = true,
  });

  final String title;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final String? disabledHint;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final useGradient = primary && enabled;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: useGradient
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [brandAccent, brandAccent.withValues(alpha: 0.8)],
                )
              : null,
          color: useGradient ? null : (isDark ? webPanel : lightPanel),
          border: useGradient
              ? null
              : Border.all(
                  color: isDark
                      ? webBorder.withValues(alpha: 0.5)
                      : lightBorder.withValues(alpha: 0.5),
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
                        color: useGradient
                            ? Colors.white
                            : enabled
                                ? (isDark ? webText : lightText)
                                : webMuted,
                      ),
                    ),
                    if (!enabled && disabledHint != null)
                      Text(
                        disabledHint!,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: webMuted.withValues(alpha: 0.7),
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                icon,
                size: 40,
                color: useGradient
                    ? Colors.white.withValues(alpha: 0.9)
                    : enabled
                        ? brandAccent
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
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: webMuted,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${device.rssi} dBm',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                color: webMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
