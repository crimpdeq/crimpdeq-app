import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/progressor_provider.dart';
import '../providers/theme_mode_provider.dart';
import '../theme.dart';
import '../widgets/calibration_widgets.dart';
import '../widgets/connection_widgets.dart';
import '../widgets/measurement_widgets.dart';

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
    // Below this width the status takes the leading slot and the title moves
    // to the flexible space, so it stays centered.
    final compact = MediaQuery.sizeOf(context).width < 700;
    final hasDevice = connection.device != null;
    final title = _AppTitle(compact: compact);

    return AppBar(
      centerTitle: true,
      toolbarHeight: preferredSize.height,
      leadingWidth: switch ((compact, hasDevice)) {
        (true, true) => 220,
        (true, false) => 145,
        (false, true) => 330,
        (false, false) => 190,
      },
      leading: ConnectionHeader(
        connection: connection,
        deviceInfo: deviceInfo,
        compact: compact,
        onDisconnect: ref.read(progressorProvider.notifier).disconnect,
      ),
      title: compact ? null : title,
      flexibleSpace: compact
          ? SafeArea(
              child: IgnorePointer(child: Center(child: title)),
            )
          : null,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _ThemeSlider(
            isDarkMode: isDarkMode,
            onChanged: ref.read(themeModeProvider.notifier).setDarkMode,
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
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
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
          const SizedBox(width: 10),
          Text(
            'Crimpdeq',
            style: theme.appBarTheme.titleTextStyle?.copyWith(
              fontSize: compact ? 14 : null,
            ),
          ),
        ],
      ),
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
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: 'Calibration'),
              Tab(text: 'Measurements'),
            ],
          ),
          SizedBox(height: 12),
          Expanded(
            child: TabBarView(children: [CalibrationTab(), MeasurementTab()]),
          ),
        ],
      ),
    );
  }
}

class _ThemeSlider extends StatelessWidget {
  const _ThemeSlider({required this.isDarkMode, required this.onChanged});

  final bool isDarkMode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => onChanged(!isDarkMode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 58,
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isDarkMode
              ? webBgSoft.withValues(alpha: 0.92)
              : Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isDark
                ? webBorder.withValues(alpha: 0.95)
                : const Color(0xFFD7E3EE),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('🌞', style: TextStyle(fontSize: 10)),
                Text('🌙', style: TextStyle(fontSize: 10)),
              ],
            ),
            AnimatedAlign(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              alignment: isDarkMode
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? webAccent.withValues(alpha: 0.95)
                      : const Color(0xFFE5E7EB),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  isDarkMode ? '🌙' : '🌞',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDarkMode ? const Color(0xFF00111C) : null,
                  ),
                ),
              ),
            ),
          ],
        ),
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
