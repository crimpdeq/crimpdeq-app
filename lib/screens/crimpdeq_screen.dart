import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/training_models.dart';
import '../providers/navigation_provider.dart';
import '../providers/progressor_provider.dart';
import '../providers/theme_mode_provider.dart';
import '../providers/training_provider.dart';
import '../providers/warmup_provider.dart';
import '../theme.dart';
import '../widgets/benchmark_widgets.dart';
import '../widgets/body_weight_widgets.dart';
import '../widgets/calibration_widgets.dart';
import '../widgets/connection_widgets.dart';
import '../widgets/history_widgets.dart';
import '../widgets/measurement_widgets.dart';
import '../widgets/schedule_widgets.dart';
import '../widgets/warmup_widgets.dart';
import '../widgets/workout_widgets.dart';

const _pages = {
  TrainingPage.warmup: (
    'Warm-up',
    Icons.local_fire_department_outlined,
    Icons.local_fire_department,
    WarmupTab(),
  ),
  TrainingPage.workout: (
    'Workout',
    Icons.timer_outlined,
    Icons.timer,
    WorkoutTab(),
  ),
  TrainingPage.benchmarks: (
    'Benchmarks',
    Icons.emoji_events_outlined,
    Icons.emoji_events,
    BenchmarksTab(),
  ),
  TrainingPage.history: (
    'History',
    Icons.insights_outlined,
    Icons.insights,
    HistoryTab(),
  ),
};

/// The training pages, which work without a device until they measure.
class CrimpdeqScreen extends ConsumerWidget {
  const CrimpdeqScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = ref.watch(trainingPageProvider);
    // A running workout or warm-up keeps the whole screen, and cannot be
    // left by a stray tap.
    final running =
        ref.watch(workoutProvider.select((state) => state.isRunning)) ||
        ref.watch(warmupProvider.select((state) => state.isRunning));
    final unsaved = ref.watch(
      workoutProvider.select(
        (state) => state.phase == WorkoutPhase.done && !state.saved,
      ),
    );

    // Nor by the back gesture, which would close the app, and with it the
    // results not saved yet.
    return PopScope(
      canPop: !running && !unsaved,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                running
                    ? 'Stop the workout or warm-up to leave.'
                    : 'Save or discard the workout to leave.',
              ),
            ),
          );
      },
      child: Scaffold(
        appBar: const _CrimpdeqAppBar(),
        bottomNavigationBar: running
            ? null
            : NavigationBar(
                selectedIndex: page.index,
                onDestinationSelected: (index) => ref
                    .read(trainingPageProvider.notifier)
                    .open(TrainingPage.values[index]),
                destinations: [
                  for (final (label, icon, selectedIcon, _) in _pages.values)
                    NavigationDestination(
                      icon: Icon(icon),
                      selectedIcon: Icon(selectedIcon),
                      label: label,
                    ),
                ],
              ),
        body: _AppBody(child: _pages[page]!.$4),
      ),
    );
  }
}

/// Calibration and the raw measurements, which few need.
class DeviceToolsScreen extends ConsumerWidget {
  const DeviceToolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected = ref.watch(
      progressorProvider.select((state) => state.connection.isConnected),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Device tools')),
      body: _AppBody(
        child: isConnected
            ? const DefaultTabController(
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
                      child: TabBarView(
                        children: [CalibrationTab(), MeasurementTab()],
                      ),
                    ),
                  ],
                ),
              )
            : const ConnectView(),
      ),
    );
  }
}

/// The rest between grippers and the training reminders.
class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
      body: const _AppBody(child: ScheduleTab()),
    );
  }
}

/// The body weight log.
class BodyWeightScreen extends StatelessWidget {
  const BodyWeightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Body weight')),
      body: const _AppBody(child: BodyWeightTab()),
    );
  }
}

/// The background and the low battery warning around a page.
class _AppBody extends ConsumerWidget {
  const _AppBody({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lowBattery = ref.watch(
      progressorProvider.select((state) => state.deviceInfo.lowBattery),
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              children: [
                if (lowBattery) ...[
                  const LowBatteryBanner(),
                  const SizedBox(height: 12),
                ],
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _MenuAction { schedule, bodyWeight, deviceTools, theme }

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
                onDisconnect: ref.read(progressorProvider.notifier).disconnect,
              ),
            ),
          ),
        ],
      ),
      actions: [
        PopupMenuButton<_MenuAction>(
          tooltip: 'More',
          onSelected: (action) => switch (action) {
            _MenuAction.schedule => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const ScheduleScreen(),
              ),
            ),
            _MenuAction.bodyWeight => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const BodyWeightScreen(),
              ),
            ),
            _MenuAction.deviceTools => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const DeviceToolsScreen(),
              ),
            ),
            _MenuAction.theme =>
              ref.read(themeModeProvider.notifier).setDarkMode(!isDarkMode),
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: _MenuAction.schedule,
              child: ListTile(
                leading: Icon(Icons.alarm),
                title: Text('Schedule'),
                subtitle: Text('Reminders and rest between grippers'),
              ),
            ),
            const PopupMenuItem(
              value: _MenuAction.bodyWeight,
              child: ListTile(
                leading: Icon(Icons.monitor_weight_outlined),
                title: Text('Body weight'),
                subtitle: Text('Strength to weight'),
              ),
            ),
            const PopupMenuItem(
              value: _MenuAction.deviceTools,
              child: ListTile(
                leading: Icon(Icons.tune),
                title: Text('Device tools'),
                subtitle: Text('Calibration and measurements'),
              ),
            ),
            PopupMenuItem(
              value: _MenuAction.theme,
              child: ListTile(
                leading: Icon(
                  isDarkMode
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                ),
                title: Text(isDarkMode ? 'Light mode' : 'Dark mode'),
              ),
            ),
          ],
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
