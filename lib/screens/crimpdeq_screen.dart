import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/progressor_provider.dart';
import '../providers/theme_mode_provider.dart';
import '../theme.dart';
import '../widgets/calibration_widgets.dart';
import '../widgets/connection_widgets.dart';
import '../widgets/measurement_widgets.dart';
import '../widgets/training_widgets.dart';

class CrimpdeqScreen extends ConsumerWidget {
  const CrimpdeqScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected = ref.watch(
      progressorProvider.select((state) => state.connection.isConnected),
    );
    final lowBattery = ref.watch(
      progressorProvider.select((state) => state.deviceInfo.lowBattery),
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const _CrimpdeqAppBar(),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const [webBg, Color(0xFF070C12)]
                : const [Color(0xFFF5FAFF), Color(0xFFEAF3FB)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              left: -40,
              child: _BackgroundGlow(
                size: 260,
                color: webAccent.withValues(alpha: 0.14),
              ),
            ),
            Positioned(
              top: 30,
              right: -70,
              child: _BackgroundGlow(
                size: 220,
                color: webAccentStrong.withValues(alpha: 0.10),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (lowBattery) ...[
                    const LowBatteryBanner(),
                    const SizedBox(height: 12),
                  ],
                  Expanded(
                    child: isConnected
                        ? const _DeviceTabs()
                        : const _ConnectView(),
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

class _CrimpdeqAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const _CrimpdeqAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connection = ref.watch(
      progressorProvider.select((state) => state.connection),
    );
    final deviceInfo = ref.watch(
      progressorProvider.select((state) => state.deviceInfo),
    );
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    final compact = MediaQuery.sizeOf(context).width < 700;

    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: preferredSize.height,
      titleSpacing: 12,
      title: Row(
        children: [
          _AppTitle(compact: compact),
          const SizedBox(width: 8),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: DeviceStatusChip(
                connection: connection,
                deviceInfo: deviceInfo,
                compact: compact,
              ),
            ),
          ),
          if (connection.device != null) ...[
            const SizedBox(width: 4),
            IconButton.outlined(
              tooltip: 'Disconnect',
              onPressed: ref.read(progressorProvider.notifier).disconnect,
              icon: const Icon(Icons.bluetooth_disabled, color: paleRed),
              visualDensity: VisualDensity.compact,
              style: IconButton.styleFrom(
                backgroundColor: paleRed.withValues(alpha: 0.18),
                side: const BorderSide(color: paleRed),
              ),
            ),
          ],
        ],
      ),
      actions: [
        IconButton(
          tooltip: isDarkMode ? 'Light mode' : 'Dark mode',
          visualDensity: VisualDensity.compact,
          onPressed: () =>
              ref.read(themeModeProvider.notifier).setDarkMode(!isDarkMode),
          icon: Icon(
            isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          ),
        ),
      ],
    );
  }
}

class _AppTitle extends StatelessWidget {
  const _AppTitle({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logoSize = compact ? 26.0 : 30.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: logoSize,
          height: logoSize,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            // Light background so the logo stands out from the app bar.
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : const Color(0xFFE8EEF4),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Image.asset(
            'assets/Logo_app_512x512.png',
            fit: BoxFit.contain,
          ),
        ),
        // Narrow screens keep the width for the device status.
        if (!compact) ...[
          const SizedBox(width: 10),
          Text('Crimpdeq', style: theme.appBarTheme.titleTextStyle),
        ],
      ],
    );
  }
}

class _ConnectView extends ConsumerWidget {
  const _ConnectView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(progressorProvider.notifier);
    return ConnectPanel(
      connection: ref.watch(
        progressorProvider.select((state) => state.connection),
      ),
      onStartScanning: notifier.startScanning,
      onConnect: notifier.connect,
    );
  }
}

class _DeviceTabs extends StatelessWidget {
  const _DeviceTabs();

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: 'Calibration'),
              Tab(text: 'Measurements'),
              Tab(text: 'Training'),
            ],
          ),
          SizedBox(height: 12),
          Expanded(
            child: TabBarView(
              children: [CalibrationTab(), MeasurementTab(), TrainingTab()],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}
