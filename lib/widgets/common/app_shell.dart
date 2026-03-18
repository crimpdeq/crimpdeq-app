import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../providers/progressor_provider.dart';
import '../../theme/app_theme.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  bool? _lastConnected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = ref.watch(progressorProvider);
    final notifier = ref.read(progressorProvider.notifier);
    final connection = state.connection;

    // Show toast on connection state changes
    final isConnected = connection.isConnected;
    if (_lastConnected != null && _lastConnected != isConnected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        final message = isConnected
            ? 'Device connected'
            : 'Device disconnected';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 2),
          ),
        );
      });
    }
    if (!connection.bluetoothReady && _lastConnected == null) {
      // Show bluetooth unavailable on first build if needed
    }
    _lastConnected = isConnected;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 48,
        leadingWidth: 0,
        leading: const SizedBox.shrink(),
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
        child: widget.navigationShell,
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
                selected: widget.navigationShell.currentIndex == 0,
                onTap: () => widget.navigationShell.goBranch(0,
                    initialLocation: widget.navigationShell.currentIndex == 0),
              ),
              _NavItem(
                icon: Icons.history_outlined,
                activeIcon: Icons.history,
                selected: widget.navigationShell.currentIndex == 1,
                onTap: () => widget.navigationShell.goBranch(1,
                    initialLocation: widget.navigationShell.currentIndex == 1),
              ),
              _NavItem(
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings,
                selected: widget.navigationShell.currentIndex == 2,
                onTap: () => widget.navigationShell.goBranch(2,
                    initialLocation: widget.navigationShell.currentIndex == 2),
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
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: Icon(
              selected ? activeIcon : icon,
              key: ValueKey(selected),
              size: 24,
              color: selected
                  ? (isDark ? webText : lightText)
                  : (isDark ? webMuted.withValues(alpha: 0.6) : lightMuted.withValues(alpha: 0.6)),
            ),
          ),
        ),
      ),
    );
  }
}
