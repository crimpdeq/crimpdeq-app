import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/progressor_models.dart' as models;
import '../providers/database_provider.dart';
import '../providers/progressor_provider.dart';
import '../models/session_models.dart';
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
            onScan: notifier.startScanning,
            onSimulator: notifier.connectSimulator,
          ),
          const SizedBox(height: 24),

          // Hero training CTA
          _HeroTrainingCard(isConnected: connection.isConnected),

          const SizedBox(height: 24),

          // PR carousel
          const _PrCarousel(),

          const SizedBox(height: 16),

          // Last session snapshot
          const _LastSessionSnapshot(),
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
      label = connection.isSimulator ? 'Simulator' : 'Connected';
      onTap = null;
    } else if (connection.isScanning || connection.isConnecting) {
      dotColor = brandAccent;
      label = connection.isScanning ? 'Scanning...' : 'Connecting...';
      onTap = null;
    } else {
      dotColor = webMuted;
      label = 'Tap to scan';
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

// ──────────────────────────── Hero training CTA ─────────────────────────

class _HeroTrainingCard extends StatelessWidget {
  const _HeroTrainingCard({required this.isConnected});

  final bool isConnected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isConnected ? () => context.go('/session/setup') : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isConnected
                ? [brandAccent, brandAccent.withValues(alpha: 0.8)]
                : [webPanel, webPanelDeep],
          ),
          border: isConnected
              ? null
              : Border.all(color: webBorder.withValues(alpha: 0.5)),
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
                      'Start Training',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                        color: isConnected ? Colors.white : webMuted,
                      ),
                    ),
                    if (!isConnected)
                      Text(
                        'Connect a device first',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: webMuted.withValues(alpha: 0.7),
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.play_circle_filled,
                size: 48,
                color: isConnected
                    ? Colors.white.withValues(alpha: 0.9)
                    : webMuted.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────── PR carousel ──────────────────────────────

class _PrCarousel extends ConsumerWidget {
  const _PrCarousel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prsAsync = ref.watch(personalRecordsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return prsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (prs) {
        if (prs.isEmpty) {
          return Container(
            height: 100,
            decoration: BoxDecoration(
              color: isDark ? webPanel : lightPanel,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? webBorder.withValues(alpha: 0.5)
                    : lightBorder.withValues(alpha: 0.5),
              ),
            ),
            child: Center(
              child: Text(
                'No records yet',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: webMuted,
                ),
              ),
            ),
          );
        }

        return SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: prs.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final entry = prs.entries.elementAt(index);
              return _PrCarouselCard(
                protocolType: entry.key,
                weight: entry.value,
              );
            },
          ),
        );
      },
    );
  }
}

class _PrCarouselCard extends StatelessWidget {
  const _PrCarouselCard({
    required this.protocolType,
    required this.weight,
  });

  final ProtocolType protocolType;
  final double weight;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 140,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? webPanel : lightPanel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: brandAccent.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _protocolIcon(protocolType),
            size: 18,
            color: brandAccent,
          ),
          const Spacer(),
          Text(
            weight.toStringAsFixed(1),
            style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.w800,
              fontSize: 28,
              color: isDark ? webText : lightText,
              height: 1,
            ),
          ),
          Text(
            'kg',
            style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: webMuted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _protocolLabel(protocolType),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: webMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────── Last session snapshot ─────────────────────

class _LastSessionSnapshot extends ConsumerWidget {
  const _LastSessionSnapshot();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(sessionHistoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return historyAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (sessions) {
        if (sessions.isEmpty) return const SizedBox.shrink();
        final last = sessions.first;
        final timeAgo = _timeAgo(last.startedAt);

        return GestureDetector(
          onTap: () => context.go('/history/${last.id}'),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? webPanel : lightPanel,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? webBorder.withValues(alpha: 0.6)
                    : lightBorder.withValues(alpha: 0.7),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: brandAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    _protocolIcon(last.protocolType),
                    size: 16,
                    color: brandAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Last Session',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: webMuted,
                        ),
                      ),
                      Text(
                        '${_protocolLabel(last.protocolType)} \u2022 $timeAgo',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: webMuted.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${last.peakForceKg.toStringAsFixed(1)} kg',
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: isDark ? dataAccent : lightDataAccent,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: webMuted,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ──────────────────────────── Helpers ─────────────────────────────────

IconData _protocolIcon(ProtocolType type) {
  switch (type) {
    case ProtocolType.maxHang:
      return Icons.fitness_center;
    case ProtocolType.repeater:
      return Icons.repeat;
    case ProtocolType.freeform:
      return Icons.explore;
  }
}

String _protocolLabel(ProtocolType type) {
  switch (type) {
    case ProtocolType.maxHang:
      return 'Max Hang';
    case ProtocolType.repeater:
      return 'Repeater';
    case ProtocolType.freeform:
      return 'Freeform';
  }
}

String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays == 1) return 'Yesterday';
  return '${diff.inDays}d ago';
}
