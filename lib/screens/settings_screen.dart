import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/progressor_provider.dart';
import '../providers/session_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common/background_gradient.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(progressorProvider);
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final isMuted = ref.watch(audioServiceProvider).isMuted;

    return BackgroundGradient(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          _SectionHeader(title: 'Preferences'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(
                    'Dark Mode',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  value: isDarkMode,
                  onChanged: (value) {
                    ref.read(themeModeProvider.notifier).setDarkMode(value);
                  },
                  secondary: Icon(
                    isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
                Divider(height: 1, indent: 56, color: colorScheme.outline.withValues(alpha: 0.3)),
                SwitchListTile(
                  title: Text(
                    'Audio Cues',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  value: !isMuted,
                  onChanged: (value) {
                    ref.read(audioServiceProvider).setMuted(!value);
                  },
                  secondary: Icon(
                    isMuted ? Icons.volume_off_outlined : Icons.volume_up_outlined,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),
          Divider(color: colorScheme.outline.withValues(alpha: 0.2)),
          const SizedBox(height: 12),
          _SectionHeader(title: 'Device'),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(
                    label: 'Status',
                    value: state.connection.isConnected
                        ? 'Connected'
                        : 'Not connected',
                    valueColor: state.connection.isConnected
                        ? const Color(0xFF3FB950)
                        : colorScheme.error,
                  ),
                  if (state.deviceInfo.firmwareVersion.isNotEmpty)
                    _InfoRow(
                      label: 'Firmware',
                      value: state.deviceInfo.firmwareVersion,
                    ),
                  if (state.deviceInfo.batteryVoltage.isNotEmpty)
                    _InfoRow(
                      label: 'Battery',
                      value: '${state.deviceInfo.batteryVoltage} mV',
                    ),
                  if (state.deviceInfo.tareValue != 0.0)
                    _InfoRow(
                      label: 'Tare',
                      value: state.deviceInfo.tareValue.toStringAsFixed(2),
                    ),
                ],
              ),
            ),
          ),

          // Calibration nav tile — only when connected and device supports it
          if (state.connection.isConnected && state.connection.supportsCalibration) ...[
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: Icon(Icons.tune, color: colorScheme.primary, size: 20),
                title: Text(
                  'Calibration',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 15),
                ),
                trailing: const Icon(Icons.chevron_right, size: 18, color: webMuted),
                onTap: () => context.go('/settings/calibration'),
              ),
            ),
          ],

          const SizedBox(height: 28),
          Divider(color: colorScheme.outline.withValues(alpha: 0.2)),
          const SizedBox(height: 12),
          _SectionHeader(title: 'About'),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(label: 'App', value: 'Crimpdeq'),
                  _InfoRow(label: 'Version', value: '0.5.0'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4, top: 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          letterSpacing: 0.8,
          color: Theme.of(context).brightness == Brightness.dark
              ? webMuted
              : const Color(0xFF656D76),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: isDark ? webMuted : const Color(0xFF656D76),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: valueColor ?? Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
