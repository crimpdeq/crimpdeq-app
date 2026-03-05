import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

import 'providers/progressor_provider.dart';
import 'widgets/progressor_widgets.dart';

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
const _paleRed = Color(0xFFE57373);
const _webBg = Color(0xFF0B1118);
const _webBgSoft = Color(0xFF101A26);
const _webPanel = Color(0xFF162333);
const _webPanelDeep = Color(0xFF0C131D);
const _webText = Color(0xFFECF2F8);
const _webMuted = Color(0xFF9EB1C5);
const _webAccent = Color(0xFF4FC3F7);
const _webAccentStrong = Color(0xFF7CD6FF);
const _webBorder = Color(0xFF2B3F53);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.dark;

  void setDarkMode(bool isDark) {
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }
}

class CrimpdeqApp extends ConsumerWidget {
  const CrimpdeqApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Crimpdeq',
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: themeMode,
      home: const CrimpdeqScreen(),
    );
  }
}

ThemeData _buildDarkTheme() {
  final colorScheme = const ColorScheme.dark(
    primary: _webAccent,
    onPrimary: Color(0xFF00111C),
    secondary: _webAccentStrong,
    onSecondary: Color(0xFF00111C),
    surface: _webPanel,
    onSurface: _webText,
    error: _paleRed,
    onError: Colors.white,
    outline: _webBorder,
    outlineVariant: Color(0xFF223447),
  );
  final baseText = GoogleFonts.spaceGroteskTextTheme(
    ThemeData.dark().textTheme,
  );
  final textTheme = baseText.copyWith(
    headlineSmall: GoogleFonts.inter(
      textStyle: baseText.headlineSmall,
      fontWeight: FontWeight.w800,
      color: _webText,
    ),
    titleLarge: GoogleFonts.inter(
      textStyle: baseText.titleLarge,
      fontWeight: FontWeight.w700,
      color: _webText,
    ),
    titleMedium: GoogleFonts.inter(
      textStyle: baseText.titleMedium,
      fontWeight: FontWeight.w700,
      color: _webText,
    ),
    bodySmall: GoogleFonts.spaceGrotesk(
      textStyle: baseText.bodySmall,
      color: _webMuted,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: _webBg,
    canvasColor: _webBg,
    dividerColor: _webBorder,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: _webPanel.withValues(alpha: 0.95),
      foregroundColor: _webText,
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.inter(
        fontWeight: FontWeight.w700,
        fontSize: 20,
        color: _webText,
      ),
    ),
    cardTheme: CardThemeData(
      color: _webPanel.withValues(alpha: 0.94),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: _webBorder),
      ),
      margin: EdgeInsets.zero,
    ),
    tabBarTheme: TabBarThemeData(
      indicator: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_webAccent, _webAccentStrong],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: _webBorder,
      labelColor: const Color(0xFF00111C),
      unselectedLabelColor: _webMuted,
      labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13),
      unselectedLabelStyle: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      splashBorderRadius: BorderRadius.circular(12),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: _webAccent,
        foregroundColor: const Color(0xFF00111C),
        disabledBackgroundColor: _webPanelDeep,
        disabledForegroundColor: _webMuted,
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _webAccent,
        foregroundColor: const Color(0xFF00111C),
        disabledBackgroundColor: _webPanelDeep,
        disabledForegroundColor: _webMuted,
        elevation: 0,
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _webText,
        side: const BorderSide(color: _webBorder),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _webBgSoft.withValues(alpha: 0.95),
      labelStyle: const TextStyle(color: _webMuted),
      hintStyle: const TextStyle(color: _webMuted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _webBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _webBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _webAccentStrong, width: 1.4),
      ),
    ),
    dataTableTheme: DataTableThemeData(
      headingRowColor: WidgetStatePropertyAll(
        _webBgSoft.withValues(alpha: 0.8),
      ),
      headingTextStyle: GoogleFonts.inter(
        color: _webText,
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
      dataTextStyle: GoogleFonts.spaceGrotesk(color: _webText, fontSize: 12),
      dividerThickness: 0.5,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: _webPanelDeep,
      contentTextStyle: GoogleFonts.spaceGrotesk(color: _webText),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: _webBorder),
      ),
    ),
  );
}

ThemeData _buildLightTheme() {
  final dark = _buildDarkTheme();
  final baseText = GoogleFonts.spaceGroteskTextTheme(
    ThemeData.light().textTheme,
  );
  return dark.copyWith(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF0A7FB3),
      onPrimary: Colors.white,
      secondary: Color(0xFF38BDF8),
      onSecondary: Color(0xFF031018),
      surface: Color(0xFFF6FAFD),
      onSurface: Color(0xFF0B1118),
      error: Color(0xFFD64F4F),
      onError: Colors.white,
      outline: Color(0xFFC9D8E6),
      outlineVariant: Color(0xFFE1EAF2),
    ),
    scaffoldBackgroundColor: const Color(0xFFEFF5FB),
    canvasColor: const Color(0xFFEFF5FB),
    dividerColor: const Color(0xFFD7E3EE),
    textTheme: baseText.copyWith(
      headlineSmall: GoogleFonts.inter(
        textStyle: baseText.headlineSmall,
        fontWeight: FontWeight.w800,
      ),
      titleLarge: GoogleFonts.inter(
        textStyle: baseText.titleLarge,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: GoogleFonts.inter(
        textStyle: baseText.titleMedium,
        fontWeight: FontWeight.w700,
      ),
      bodySmall: GoogleFonts.spaceGrotesk(
        textStyle: baseText.bodySmall,
        color: const Color(0xFF5C7187),
      ),
    ),
    appBarTheme: dark.appBarTheme.copyWith(
      backgroundColor: Colors.white.withValues(alpha: 0.92),
      foregroundColor: const Color(0xFF0B1118),
      titleTextStyle: GoogleFonts.inter(
        fontWeight: FontWeight.w700,
        fontSize: 20,
        color: const Color(0xFF0B1118),
      ),
    ),
    cardTheme: dark.cardTheme.copyWith(
      color: Colors.white.withValues(alpha: 0.92),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFD7E3EE)),
      ),
    ),
    tabBarTheme: TabBarThemeData(
      indicator: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A7FB3), Color(0xFF38BDF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: const Color(0xFFD7E3EE),
      labelColor: Colors.white,
      unselectedLabelColor: const Color(0xFF607486),
      labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13),
      unselectedLabelStyle: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      splashBorderRadius: BorderRadius.circular(12),
    ),
    inputDecorationTheme: dark.inputDecorationTheme.copyWith(
      fillColor: Colors.white,
      labelStyle: const TextStyle(color: Color(0xFF607486)),
      hintStyle: const TextStyle(color: Color(0xFF607486)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD7E3EE)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD7E3EE)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0A7FB3), width: 1.4),
      ),
    ),
    dataTableTheme: dark.dataTableTheme.copyWith(
      headingRowColor: const WidgetStatePropertyAll(Color(0xFFF3F8FC)),
      headingTextStyle: GoogleFonts.inter(
        color: const Color(0xFF0B1118),
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
      dataTextStyle: GoogleFonts.spaceGrotesk(
        color: const Color(0xFF0B1118),
        fontSize: 12,
      ),
    ),
    snackBarTheme: dark.snackBarTheme.copyWith(
      backgroundColor: Colors.white,
      contentTextStyle: GoogleFonts.spaceGrotesk(
        color: const Color(0xFF0B1118),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFD7E3EE)),
      ),
    ),
  );
}

class CrimpdeqScreen extends ConsumerWidget {
  const CrimpdeqScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompactHeader = screenWidth < 700;
    const compactLeadingWidth = 220.0;
    final state = ref.watch(progressorProvider);
    final notifier = ref.read(progressorProvider.notifier);
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    final connection = state.connection;
    final showScanButton =
        connection.bluetoothReady &&
        !connection.isScanning &&
        !connection.isConnecting &&
        connection.device == null;
    final showDisconnectButton = connection.device != null;
    final statusColor = connection.device != null
        ? Colors.greenAccent.shade400
        : connection.isScanning || connection.isConnecting
        ? colorScheme.primary
        : Colors.orangeAccent.shade200;
    final statusLabel = connection.device != null
        ? 'Connected'
        : connection.isScanning
        ? 'Scanning'
        : connection.isConnecting
        ? 'Connecting'
        : connection.bluetoothReady
        ? 'Ready'
        : 'Offline';
    final isDeviceNotConnected =
        connection.device == null &&
        connection.bluetoothReady &&
        !connection.isScanning &&
        !connection.isConnecting;
    final connectedStatusLines = <String>[
      'Device Connected',
      if (state.deviceInfo.firmwareVersion.isNotEmpty)
        'Firmware: ${state.deviceInfo.firmwareVersion}',
      if (state.deviceInfo.batteryVoltage.isNotEmpty)
        'Battery: ${state.deviceInfo.batteryVoltage} mV',
    ];
    final statusText = connection.device != null
        ? connectedStatusLines.join('\n')
        : isDeviceNotConnected
        ? 'Device Not Connected'
        : 'Connection: $statusLabel';
    final compactStatusText = connection.device != null
        ? 'Connected'
        : 'Not Connected';
    final compactFirmwareText = state.deviceInfo.firmwareVersion.isNotEmpty
        ? 'FW: ${state.deviceInfo.firmwareVersion}'
        : null;
    final compactBatteryText = state.deviceInfo.batteryVoltage.isNotEmpty
        ? 'Bat: ${state.deviceInfo.batteryVoltage} mV'
        : null;
    final compactLeadingWidthCurrent = isCompactHeader
        ? (isDeviceNotConnected ? 145.0 : compactLeadingWidth)
        : null;
    final calibrationFactor = _extractCalibrationFactor(state.errorMessage);
    final calibrationFactorValue = double.tryParse(calibrationFactor ?? '');
    final calibrationPoints = _extractCalibrationPoints(state.errorMessage);
    final appBarForeground =
        theme.appBarTheme.foregroundColor ?? colorScheme.onSurface;
    final appBarLogoBackground = theme.brightness == Brightness.dark
        ? Colors.white
        : const Color(0xFFE8EEF4); // Light gray so logo stands out from app bar

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 64,
        leadingWidth: isCompactHeader
            ? compactLeadingWidthCurrent
            : (showDisconnectButton ? 330 : 170),
        leading: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 80 || constraints.maxHeight < 24) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (showDisconnectButton && isCompactHeader)
                    Container(
                      decoration: BoxDecoration(
                        color: _paleRed.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        border: Border.all(color: _paleRed),
                      ),
                      child: IconButton(
                        tooltip: 'Disconnect',
                        onPressed: notifier.disconnectDevice,
                        icon: const Icon(
                          Icons.bluetooth_disabled,
                          color: _paleRed,
                        ),
                        iconSize: 18,
                        visualDensity: VisualDensity.compact,
                        constraints: const BoxConstraints(
                          minWidth: 34,
                          minHeight: 34,
                        ),
                      ),
                    ),
                  if (showDisconnectButton && isCompactHeader)
                    const SizedBox(width: 8),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.zero,
                      child: Row(
                        crossAxisAlignment: isCompactHeader
                            ? CrossAxisAlignment.center
                            : CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            margin: isCompactHeader
                                ? const EdgeInsets.only(right: 6)
                                : const EdgeInsets.only(right: 6, top: 2),
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child:
                                isCompactHeader &&
                                    (compactFirmwareText != null ||
                                        compactBatteryText != null)
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        compactStatusText,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          color: appBarForeground,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11,
                                          height: 1.1,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      if (compactFirmwareText != null)
                                        Text(
                                          compactFirmwareText,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.inter(
                                            color: appBarForeground,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 10,
                                            height: 1.1,
                                          ),
                                        ),
                                      if (compactBatteryText != null)
                                        Text(
                                          compactBatteryText,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.inter(
                                            color: appBarForeground,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 10,
                                            height: 1.1,
                                          ),
                                        ),
                                    ],
                                  )
                                : Text(
                                    isCompactHeader
                                        ? compactStatusText
                                        : statusText,
                                    maxLines: isCompactHeader ? 1 : 4,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.start,
                                    style: GoogleFonts.inter(
                                      color: appBarForeground,
                                      fontWeight: FontWeight.w600,
                                      fontSize: isCompactHeader ? 11 : 12,
                                      height: 1.15,
                                    ),
                                  ),
                          ),
                          if (connection.isScanning || connection.isConnecting)
                            Padding(
                              padding: EdgeInsets.only(left: 6),
                              child: SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: appBarForeground,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (showDisconnectButton) const SizedBox(width: 8),
                  if (showDisconnectButton)
                    !isCompactHeader
                        ? FilledButton.icon(
                            onPressed: notifier.disconnectDevice,
                            icon: const Icon(
                              Icons.bluetooth_disabled,
                              size: 16,
                            ),
                            label: const Text('Disconnect'),
                            style: FilledButton.styleFrom(
                              backgroundColor: _paleRed,
                              foregroundColor: colorScheme.onError,
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                ],
              ),
            );
          },
        ),
        actions: [
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 70 || constraints.maxHeight < 24) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _ThemeSlider(
                  isDarkMode: isDarkMode,
                  onChanged: (isDark) {
                    ref.read(themeModeProvider.notifier).setDarkMode(isDark);
                  },
                ),
              );
            },
          ),
        ],
        flexibleSpace: isCompactHeader
            ? SafeArea(
                child: IgnorePointer(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: appBarLogoBackground,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Image.asset(
                              'assets/Logo_app_512x512.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.image_not_supported),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Crimpdeq',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              color: appBarForeground,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : null,
        title: isCompactHeader
            ? null
            : FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: appBarLogoBackground,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Image.asset(
                        'assets/Logo_app_512x512.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image_not_supported),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Crimpdeq',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        color: appBarForeground,
                      ),
                    ),
                  ],
                ),
              ),
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: Theme.of(context).brightness == Brightness.dark
                ? const [_webBg, Color(0xFF070C12)]
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
                color: _webAccent.withValues(alpha: 0.14),
              ),
            ),
            Positioned(
              top: 30,
              right: -70,
              child: _BackgroundGlow(
                size: 220,
                color: _webAccentStrong.withValues(alpha: 0.10),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: state.connection.device == null
                  ? Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 72),
                        child: showScanButton
                            ? FilledButton.icon(
                                onPressed: notifier.startScanning,
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
                              )
                            : const SizedBox.shrink(),
                      ),
                    )
                  : DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          TabBar(
                            tabs: const [
                              Tab(text: 'Calibration'),
                              Tab(text: 'Measurements'),
                            ],
                            labelStyle: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: TabBarView(
                              children: [
                                SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          calibrationFactor != null
                                              ? 'Current Calibration Factor: $calibrationFactor'
                                              : 'Current Calibration Factor: Not available',
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      if (calibrationPoints.isNotEmpty) ...[
                                        _CalibrationGraphCard(
                                          calibrationPoints: calibrationPoints,
                                          calibrationFactor:
                                              calibrationFactorValue,
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                      CalibrationCard(
                                        connection: state.connection,
                                        onAddCalibrationPoint:
                                            notifier.addCalibrationPoint,
                                        onGetCalibration:
                                            notifier.getCalibration,
                                        onDefaultCalibration:
                                            notifier.defaultCalibration,
                                        calibrationInfo: state.errorMessage,
                                      ),
                                    ],
                                  ),
                                ),
                                SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      MeasurementControlCard(
                                        measurement: state.measurement,
                                        onStartMeasurement:
                                            notifier.startMeasurement,
                                        onStopMeasurement:
                                            notifier.stopMeasurement,
                                        onTareScale: notifier.tareScale,
                                      ),
                                      const SizedBox(height: 16),
                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          final useTwoColumns =
                                              constraints.maxWidth >= 900;
                                          if (!useTwoColumns) {
                                            return Column(
                                              children: [
                                                PerformanceCard(
                                                  performance:
                                                      state.performance,
                                                ),
                                                const SizedBox(height: 16),
                                                CurrentWeightCard(
                                                  measurement:
                                                      state.measurement,
                                                ),
                                              ],
                                            );
                                          }

                                          return IntrinsicHeight(
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                Expanded(
                                                  child: PerformanceCard(
                                                    performance:
                                                        state.performance,
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: CurrentWeightCard(
                                                    measurement:
                                                        state.measurement,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          final hasWeightHistory = state
                                              .measurement
                                              .weightHistory
                                              .isNotEmpty;
                                          final hasNotifyHistory = state
                                              .performance
                                              .notifyIntervalHistory
                                              .isNotEmpty;
                                          final hasSamplesSection =
                                              state.measurement.isMeasuring ||
                                              state
                                                  .measurement
                                                  .receivedData
                                                  .isNotEmpty;
                                          final isWide =
                                              constraints.maxWidth >= 1200;

                                          if (isWide &&
                                              hasSamplesSection &&
                                              (hasWeightHistory ||
                                                  hasNotifyHistory)) {
                                            return IntrinsicHeight(
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  Expanded(
                                                    child:
                                                        hasWeightHistory &&
                                                            hasNotifyHistory
                                                        ? Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .stretch,
                                                            children: [
                                                              Expanded(
                                                                child: WeightHistoryCard(
                                                                  measurement: state
                                                                      .measurement,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 16,
                                                              ),
                                                              Expanded(
                                                                child: NotifyIntervalCard(
                                                                  performance: state
                                                                      .performance,
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        : hasWeightHistory
                                                        ? WeightHistoryCard(
                                                            measurement: state
                                                                .measurement,
                                                          )
                                                        : NotifyIntervalCard(
                                                            performance: state
                                                                .performance,
                                                          ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  ReceivedDataCard(
                                                    measurements: state
                                                        .measurement
                                                        .receivedData,
                                                  ),
                                                ],
                                              ),
                                            );
                                          }

                                          return Column(
                                            children: [
                                              if (hasWeightHistory) ...[
                                                WeightHistoryCard(
                                                  measurement:
                                                      state.measurement,
                                                ),
                                                const SizedBox(height: 16),
                                              ],
                                              if (hasNotifyHistory &&
                                                  hasSamplesSection) ...[
                                                NotifyIntervalCard(
                                                  performance:
                                                      state.performance,
                                                ),
                                                const SizedBox(height: 16),
                                                ReceivedDataCard(
                                                  measurements: state
                                                      .measurement
                                                      .receivedData,
                                                ),
                                              ] else if (hasNotifyHistory) ...[
                                                NotifyIntervalCard(
                                                  performance:
                                                      state.performance,
                                                ),
                                              ] else if (hasSamplesSection)
                                                ReceivedDataCard(
                                                  measurements: state
                                                      .measurement
                                                      .receivedData,
                                                ),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

String? _extractCalibrationFactor(String? calibrationInfo) {
  if (calibrationInfo == null || calibrationInfo.isEmpty) return null;

  final match = RegExp(
    r'Calibration factor:\s*([0-9.+\-eE]+)',
  ).firstMatch(calibrationInfo);
  if (match == null) return null;
  return match.group(1);
}

List<FlSpot> _extractCalibrationPoints(String? calibrationInfo) {
  if (calibrationInfo == null || calibrationInfo.isEmpty) return const [];

  final matches = RegExp(
    r'\(\s*([0-9.+\-eE]+)\s*,\s*([0-9.+\-eE]+)\s*\)',
  ).allMatches(calibrationInfo);

  final points = <FlSpot>[];
  for (final match in matches) {
    final raw = double.tryParse(match.group(1) ?? '');
    final known = double.tryParse(match.group(2) ?? '');
    if (raw != null && known != null) {
      points.add(FlSpot(raw, known));
    }
  }
  return points;
}

String _formatCompactAxis(double value) {
  final abs = value.abs();
  if (abs >= 1000) {
    final compact = value / 1000;
    return '${compact.toStringAsFixed(compact.abs() >= 100 ? 0 : 1)}k';
  }
  return value.toStringAsFixed(0);
}

class _CalibrationGraphCard extends StatelessWidget {
  const _CalibrationGraphCard({
    required this.calibrationPoints,
    required this.calibrationFactor,
  });

  final List<FlSpot> calibrationPoints;
  final double? calibrationFactor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasPoints = calibrationPoints.isNotEmpty;
    final knownMin = hasPoints
        ? calibrationPoints
              .map((point) => point.y)
              .reduce((a, b) => a < b ? a : b)
        : 0.0;
    final knownWeightOffset = knownMin < 0 ? -knownMin : 0.0;
    final graphPoints = calibrationPoints
        .map((point) => FlSpot(point.x, point.y + knownWeightOffset))
        .toList();
    final xs = hasPoints
        ? graphPoints.map((point) => point.x).toList()
        : <double>[0, 1];
    final ys = hasPoints
        ? graphPoints.map((point) => point.y).toList()
        : <double>[0, 1];

    final dataMinX = xs.reduce((a, b) => a < b ? a : b);
    final dataMaxX = xs.reduce((a, b) => a > b ? a : b);
    final resolvedMaxX = dataMaxX <= dataMinX ? dataMinX + 1 : dataMaxX;
    final xSpan = (resolvedMaxX - dataMinX).abs();
    final xPadding = (xSpan * 0.06) < 1.0 ? 1.0 : (xSpan * 0.06);
    final chartMinX = dataMinX - xPadding;
    final chartMaxX = resolvedMaxX + xPadding;
    final xInterval = (chartMaxX - chartMinX) <= 1
        ? 1.0
        : ((chartMaxX - chartMinX) / 6);
    final minYPoints = ys.reduce((a, b) => a < b ? a : b);
    final maxYPoints = ys.reduce((a, b) => a > b ? a : b);

    double? lineSlope;
    final fitLineSpots = hasPoints && graphPoints.length >= 2
        ? () {
            final avgX =
                graphPoints.map((point) => point.x).reduce((a, b) => a + b) /
                graphPoints.length;
            final avgY =
                graphPoints.map((point) => point.y).reduce((a, b) => a + b) /
                graphPoints.length;

            final slopeFromFactor = calibrationFactor != null
                ? calibrationFactor! / 1000.0
                : null;
            double slope;
            if (slopeFromFactor != null) {
              slope = slopeFromFactor;
            } else {
              final denominator = graphPoints
                  .map((point) => (point.x - avgX) * (point.x - avgX))
                  .reduce((a, b) => a + b);
              if (denominator == 0) return const <FlSpot>[];
              final numerator = graphPoints
                  .map((point) => (point.x - avgX) * (point.y - avgY))
                  .reduce((a, b) => a + b);
              slope = numerator / denominator;
            }
            lineSlope = slope;
            final intercept = avgY - (slope * avgX);

            return <FlSpot>[
              FlSpot(chartMinX, (slope * chartMinX) + intercept),
              FlSpot(chartMaxX, (slope * chartMaxX) + intercept),
            ];
          }()
        : const <FlSpot>[];
    final fitYs = fitLineSpots.map((point) => point.y).toList();

    final minY = fitYs.isEmpty
        ? minYPoints
        : [
            minYPoints,
            fitYs.reduce((a, b) => a < b ? a : b),
          ].reduce((a, b) => a < b ? a : b);
    final maxY = fitYs.isEmpty
        ? maxYPoints
        : [
            maxYPoints,
            fitYs.reduce((a, b) => a > b ? a : b),
          ].reduce((a, b) => a > b ? a : b);
    final ySpan = (maxY - minY).abs();
    final yPadding = (ySpan * 0.08) < 0.5 ? 0.5 : (ySpan * 0.08);
    final chartMinY = -yPadding * 0.3;
    final chartMaxY = (maxY + yPadding) <= chartMinY
        ? chartMinY + 1
        : (maxY + yPadding);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calibration Graph',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
            if (knownWeightOffset > 0) const SizedBox(height: 4),
            if (knownWeightOffset > 0)
              Text(
                'Known weight offset applied: +${knownWeightOffset.toStringAsFixed(3)} kg',
                style: GoogleFonts.inter(fontSize: 12),
              ),
            const SizedBox(height: 8),
            if (!hasPoints)
              Text(
                'No calibration points received yet.',
                style: GoogleFonts.inter(),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final sideBySide = constraints.maxWidth >= 900;
                  final graphWidget = SizedBox(
                    height: 240,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: colorScheme.outline),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LineChart(
                          LineChartData(
                            minX: chartMinX,
                            maxX: chartMaxX,
                            minY: chartMinY,
                            maxY: chartMaxY,
                            clipData: const FlClipData.all(),
                            lineTouchData: LineTouchData(
                              enabled: true,
                              handleBuiltInTouches: true,
                              touchTooltipData: LineTouchTooltipData(
                                fitInsideHorizontally: true,
                                fitInsideVertically: true,
                                getTooltipItems: (touchedSpots) {
                                  final pointSpots = touchedSpots
                                      .where((spot) => spot.barIndex == 0)
                                      .toList();
                                  return pointSpots.map((spot) {
                                    return LineTooltipItem(
                                      'Raw: ${spot.x.toStringAsFixed(3)}\nKnown: ${spot.y.toStringAsFixed(3)} kg',
                                      GoogleFonts.inter(
                                        color: colorScheme.onSurface,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                    );
                                  }).toList();
                                },
                              ),
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: true,
                              getDrawingHorizontalLine: (_) => FlLine(
                                color: colorScheme.outlineVariant.withValues(
                                  alpha: 0.5,
                                ),
                                strokeWidth: 1,
                              ),
                              getDrawingVerticalLine: (_) => FlLine(
                                color: colorScheme.outlineVariant.withValues(
                                  alpha: 0.35,
                                ),
                                strokeWidth: 1,
                              ),
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                axisNameWidget: Text(
                                  'Known weight (kg)',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: textTheme.bodySmall?.color,
                                  ),
                                ),
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 44,
                                  maxIncluded: false,
                                  getTitlesWidget: (value, meta) => Text(
                                    value.toStringAsFixed(1),
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: textTheme.bodySmall?.color,
                                    ),
                                  ),
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                axisNameWidget: Text(
                                  'Raw measurement',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: textTheme.bodySmall?.color,
                                  ),
                                ),
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 32,
                                  interval: xInterval,
                                  maxIncluded: false,
                                  getTitlesWidget: (value, meta) => Text(
                                    _formatCompactAxis(value),
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: textTheme.bodySmall?.color,
                                    ),
                                  ),
                                ),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: graphPoints,
                                isCurved: false,
                                color: colorScheme.primary,
                                barWidth: 0,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter:
                                      (spot, percent, barData, index) {
                                        return FlDotCirclePainter(
                                          radius: 4,
                                          color: colorScheme.primary,
                                          strokeColor: colorScheme.surface,
                                          strokeWidth: 1.5,
                                        );
                                      },
                                ),
                                belowBarData: BarAreaData(show: false),
                              ),
                              if (fitLineSpots.isNotEmpty)
                                LineChartBarData(
                                  spots: fitLineSpots,
                                  isCurved: false,
                                  color: colorScheme.primary,
                                  barWidth: 2,
                                  dotData: const FlDotData(show: false),
                                  dashArray: const [6, 4],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );

                  const indexColumnWidth = 24.0;
                  const rawValueColumnWidth = 120.0;
                  const knownWeightColumnWidth = 140.0;

                  final pointsListWidget = IntrinsicWidth(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: colorScheme.outline),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              'Calibration Points',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 190,
                            child: Scrollbar(
                              thumbVisibility: true,
                              child: SingleChildScrollView(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    headingRowHeight: 34,
                                    dataRowMinHeight: 30,
                                    dataRowMaxHeight: 34,
                                    horizontalMargin: 8,
                                    columnSpacing: 8,
                                    headingTextStyle: GoogleFonts.inter(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                    dataTextStyle: GoogleFonts.inter(
                                      fontSize: 11,
                                    ),
                                    columns: const [
                                      DataColumn(
                                        label: SizedBox(
                                          width: indexColumnWidth,
                                          child: Center(child: Text('#')),
                                        ),
                                      ),
                                      DataColumn(
                                        label: SizedBox(
                                          width: rawValueColumnWidth,
                                          child: Center(
                                            child: Text('Raw Value'),
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: SizedBox(
                                          width: knownWeightColumnWidth,
                                          child: Center(
                                            child: Text('Known Weight (kg)'),
                                          ),
                                        ),
                                      ),
                                    ],
                                    rows: graphPoints.asMap().entries.map((
                                      entry,
                                    ) {
                                      final index = entry.key + 1;
                                      final point = entry.value;
                                      return DataRow(
                                        cells: [
                                          DataCell(
                                            SizedBox(
                                              width: indexColumnWidth,
                                              child: Center(
                                                child: Text(index.toString()),
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            SizedBox(
                                              width: rawValueColumnWidth,
                                              child: Center(
                                                child: Text(
                                                  point.x.toStringAsFixed(3),
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            SizedBox(
                                              width: knownWeightColumnWidth,
                                              child: Center(
                                                child: Text(
                                                  point.y.toStringAsFixed(3),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );

                  if (!sideBySide) {
                    return Column(
                      children: [
                        graphWidget,
                        const SizedBox(height: 12),
                        pointsListWidget,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: graphWidget),
                      const SizedBox(width: 12),
                      pointsListWidget,
                    ],
                  );
                },
              ),
            if (hasPoints) const SizedBox(height: 8),
            if (hasPoints)
              Text(
                lineSlope != null
                    ? 'Slope: ${lineSlope!.toStringAsFixed(6)}'
                    : 'Slope unavailable.',
                style: GoogleFonts.inter(fontSize: 12),
              ),
          ],
        ),
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
              ? _webBgSoft.withValues(alpha: 0.92)
              : Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isDark
                ? _webBorder.withValues(alpha: 0.95)
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
                      ? _webAccent.withValues(alpha: 0.95)
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
