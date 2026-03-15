import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../providers/progressor_provider.dart';
import '../../theme/app_theme.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final state = ref.watch(progressorProvider);
    final notifier = ref.read(progressorProvider.notifier);
    final connection = state.connection;

    final statusColor = connection.isConnected
        ? const Color(0xFF3FB950)
        : connection.isScanning || connection.isConnecting
            ? colorScheme.primary
            : isDark
                ? webMuted
                : lightMuted;
    final statusLabel = connection.isConnected
        ? 'Connected'
        : connection.isScanning
            ? 'Scanning'
            : connection.isConnecting
                ? 'Connecting'
                : connection.bluetoothReady
                    ? 'Ready'
                    : 'Offline';

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 48,
        leadingWidth: 180,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                statusLabel,
                style: GoogleFonts.inter(
                  color: isDark ? webMuted : lightMuted,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              if (connection.isScanning || connection.isConnecting)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: SizedBox(
                    width: 11,
                    height: 11,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          if (connection.isConnected)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                tooltip: 'Disconnect',
                onPressed: notifier.disconnectDevice,
                icon: const Icon(Icons.bluetooth_disabled, size: 18),
                style: IconButton.styleFrom(
                  foregroundColor: paleRed,
                ),
              ),
            ),
        ],
      ),
      extendBody: true,
      body: Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: navigationShell,
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          72,
          0,
          72,
          MediaQuery.of(context).padding.bottom + 20,
        ),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF111111).withValues(alpha: 0.9)
                : const Color(0xFFF0F0F0).withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? webBorder.withValues(alpha: 0.35)
                  : lightBorder.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                selected: navigationShell.currentIndex == 0,
                onTap: () => navigationShell.goBranch(0,
                    initialLocation: navigationShell.currentIndex == 0),
              ),
              _NavItem(
                icon: Icons.history_outlined,
                activeIcon: Icons.history,
                selected: navigationShell.currentIndex == 1,
                onTap: () => navigationShell.goBranch(1,
                    initialLocation: navigationShell.currentIndex == 1),
              ),
              _NavItem(
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings,
                selected: navigationShell.currentIndex == 2,
                onTap: () => navigationShell.goBranch(2,
                    initialLocation: navigationShell.currentIndex == 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: Icon(
            selected ? activeIcon : icon,
            size: 24,
            color: selected
                ? (isDark ? webText : lightText)
                : (isDark ? webMuted.withValues(alpha: 0.6) : lightMuted.withValues(alpha: 0.6)),
          ),
        ),
      ),
    );
  }
}
