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
    const brandBlue = Color(0xFF2F6EB8);
    const secondary = Color(0xFF6F7B8A);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Crimpdeq',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: brandBlue,
          primary: brandBlue,
          secondary: secondary,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F6F8),
        appBarTheme: const AppBarTheme(
          backgroundColor: brandBlue,
          foregroundColor: Colors.white,
        ),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: brandBlue,
          primary: brandBlue,
          secondary: secondary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: brandBlue,
          foregroundColor: Colors.white,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      themeMode: themeMode,
      home: const CrimpdeqScreen(),
    );
  }
}

class CrimpdeqScreen extends ConsumerWidget {
  const CrimpdeqScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    final statusColor =
        connection.device != null
            ? Colors.green
            : connection.isScanning || connection.isConnecting
            ? Colors.blue
            : Colors.orange;
    final statusLabel =
        connection.device != null
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
      if (state.deviceInfo.tareValue != 0.0)
        'Tare ${state.deviceInfo.tareValue.toStringAsFixed(2)} kg',
    ];
    final statusText =
        connection.device != null
            ? connectedStatusLines.join('\n')
            : isDeviceNotConnected
            ? 'Device Not Connected'
            : 'Connection: $statusLabel';
    final compactStatusText =
        connection.device != null ? 'Connected' : 'Not Connected';
    final compactFirmwareText =
        state.deviceInfo.firmwareVersion.isNotEmpty
            ? 'FW: ${state.deviceInfo.firmwareVersion}'
            : null;
    final compactBatteryText =
        state.deviceInfo.batteryVoltage.isNotEmpty
            ? 'Bat: ${state.deviceInfo.batteryVoltage} mV'
            : null;
    final compactLeadingWidthCurrent =
        isCompactHeader ? (isDeviceNotConnected ? 145.0 : compactLeadingWidth) : null;
    final calibrationFactor = _extractCalibrationFactor(state.errorMessage);
    final calibrationFactorValue = double.tryParse(calibrationFactor ?? '');
    final calibrationPoints = _extractCalibrationPoints(state.errorMessage);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 64,
        leadingWidth:
            isCompactHeader
                ? compactLeadingWidthCurrent
                : (showDisconnectButton ? 330 : 170),
        leading: Padding(
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
                    icon: const Icon(Icons.bluetooth_disabled, color: _paleRed),
                    iconSize: 18,
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                  ),
                ),
              if (showDisconnectButton && isCompactHeader) const SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.zero,
                  child: Row(
                    crossAxisAlignment:
                        isCompactHeader ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin:
                            isCompactHeader
                                ? const EdgeInsets.only(right: 6)
                                : const EdgeInsets.only(right: 6, top: 2),
                        decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                      ),
                      Expanded(
                        child:
                            isCompactHeader &&
                                    (compactFirmwareText != null || compactBatteryText != null)
                                ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      compactStatusText,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
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
                                          color: Colors.white,
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
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 10,
                                          height: 1.1,
                                        ),
                                      ),
                                  ],
                                )
                                : Text(
                                  isCompactHeader ? compactStatusText : statusText,
                                  maxLines: isCompactHeader ? 1 : 4,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.start,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: isCompactHeader ? 11 : 12,
                                    height: 1.15,
                                  ),
                                ),
                      ),
                      if (connection.isScanning || connection.isConnecting)
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
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
                      icon: const Icon(Icons.bluetooth_disabled, size: 16),
                      label: const Text('Disconnect'),
                      style: FilledButton.styleFrom(
                        backgroundColor: _paleRed,
                        foregroundColor: Colors.white,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                    )
                    : const SizedBox.shrink(),
            ],
          ),
        ),
        actions: [
          _ThemeSlider(
            isDarkMode: isDarkMode,
            onChanged: (isDark) {
              ref.read(themeModeProvider.notifier).setDarkMode(isDark);
            },
          ),
          const SizedBox(width: 8),
        ],
        flexibleSpace:
            isCompactHeader
                ? SafeArea(
                  child: IgnorePointer(
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Image.asset(
                              'assets/Logo_app_512x512.png',
                              fit: BoxFit.contain,
                              errorBuilder:
                                  (context, _, __) =>
                                      const Icon(Icons.image_not_supported),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Crimpdeq',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                : null,
        title: isCompactHeader
            ? null
            : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 30,
                height: 30,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Image.asset(
                  'assets/Logo_app_512x512.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, _, __) => const Icon(Icons.image_not_supported),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Crimpdeq',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            state.connection.device == null
                ? SingleChildScrollView(
                  child: Column(
                    children: [
                      if (showScanButton) const SizedBox(height: 72),
                      if (showScanButton)
                        Center(
                          child: FilledButton.icon(
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
                          ),
                        ),
                    ],
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
                        labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700),
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
                                      calibrationFactor: calibrationFactorValue,
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                  CalibrationCard(
                                    connection: state.connection,
                                    onAddCalibrationPoint: notifier.addCalibrationPoint,
                                    onGetCalibration: notifier.getCalibration,
                                    onDefaultCalibration: notifier.defaultCalibration,
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
                                    onStartMeasurement: notifier.startMeasurement,
                                    onStopMeasurement: notifier.stopMeasurement,
                                    onTareScale: notifier.tareScale,
                                  ),
                                  const SizedBox(height: 16),
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final useTwoColumns = constraints.maxWidth >= 900;
                                      if (!useTwoColumns) {
                                        return Column(
                                          children: [
                                            PerformanceCard(performance: state.performance),
                                            const SizedBox(height: 16),
                                            CurrentWeightCard(
                                              measurement: state.measurement,
                                            ),
                                          ],
                                        );
                                      }

                                      return IntrinsicHeight(
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            Expanded(
                                              child: PerformanceCard(
                                                performance: state.performance,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: CurrentWeightCard(
                                                measurement: state.measurement,
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
                                      final hasWeightHistory =
                                          state.measurement.weightHistory.isNotEmpty;
                                      final hasNotifyHistory =
                                          state.performance.notifyIntervalHistory.isNotEmpty;
                                      final hasSamplesSection =
                                          state.measurement.isMeasuring ||
                                          state.measurement.receivedData.isNotEmpty;
                                      final isWide = constraints.maxWidth >= 1200;

                                      if (isWide && hasSamplesSection && (hasWeightHistory || hasNotifyHistory)) {
                                        return IntrinsicHeight(
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: [
                                              Expanded(
                                                child:
                                                    hasWeightHistory && hasNotifyHistory
                                                        ? Column(
                                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                                          children: [
                                                            Expanded(
                                                              child: WeightHistoryCard(
                                                                measurement: state.measurement,
                                                              ),
                                                            ),
                                                            const SizedBox(height: 16),
                                                            Expanded(
                                                              child: NotifyIntervalCard(
                                                                performance: state.performance,
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                        : hasWeightHistory
                                                        ? WeightHistoryCard(
                                                          measurement: state.measurement,
                                                        )
                                                        : NotifyIntervalCard(
                                                          performance: state.performance,
                                                        ),
                                              ),
                                              const SizedBox(width: 16),
                                              ReceivedDataCard(
                                                measurements: state.measurement.receivedData,
                                              ),
                                            ],
                                          ),
                                        );
                                      }

                                      return Column(
                                        children: [
                                          if (hasWeightHistory) ...[
                                            WeightHistoryCard(measurement: state.measurement),
                                            const SizedBox(height: 16),
                                          ],
                                          if (hasNotifyHistory && hasSamplesSection) ...[
                                            NotifyIntervalCard(
                                              performance: state.performance,
                                            ),
                                            const SizedBox(height: 16),
                                            ReceivedDataCard(
                                              measurements: state.measurement.receivedData,
                                            ),
                                          ] else if (hasNotifyHistory) ...[
                                            NotifyIntervalCard(
                                              performance: state.performance,
                                            ),
                                          ] else if (hasSamplesSection)
                                            ReceivedDataCard(
                                              measurements: state.measurement.receivedData,
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
    );
  }
}

String? _extractCalibrationFactor(String? calibrationInfo) {
  if (calibrationInfo == null || calibrationInfo.isEmpty) return null;

  final match = RegExp(r'Calibration factor:\s*([0-9.+\-eE]+)').firstMatch(
    calibrationInfo,
  );
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
    final hasPoints = calibrationPoints.isNotEmpty;
    final knownMin =
        hasPoints
            ? calibrationPoints.map((point) => point.y).reduce((a, b) => a < b ? a : b)
            : 0.0;
    final knownWeightOffset = knownMin < 0 ? -knownMin : 0.0;
    final graphPoints =
        calibrationPoints
            .map((point) => FlSpot(point.x, point.y + knownWeightOffset))
            .toList();
    final xs =
        hasPoints
            ? graphPoints.map((point) => point.x).toList()
            : <double>[0, 1];
    final ys =
        hasPoints
            ? graphPoints.map((point) => point.y).toList()
            : <double>[0, 1];

    final dataMinX = xs.reduce((a, b) => a < b ? a : b);
    final dataMaxX = xs.reduce((a, b) => a > b ? a : b);
    final resolvedMaxX = dataMaxX <= dataMinX ? dataMinX + 1 : dataMaxX;
    final xSpan = (resolvedMaxX - dataMinX).abs();
    final xPadding = (xSpan * 0.06) < 1.0 ? 1.0 : (xSpan * 0.06);
    final chartMinX = dataMinX - xPadding;
    final chartMaxX = resolvedMaxX + xPadding;
    final xInterval = (chartMaxX - chartMinX) <= 1 ? 1.0 : ((chartMaxX - chartMinX) / 6);
    final minYPoints = ys.reduce((a, b) => a < b ? a : b);
    final maxYPoints = ys.reduce((a, b) => a > b ? a : b);

    double? lineSlope;
    final fitLineSpots =
        hasPoints && graphPoints.length >= 2
            ? () {
              final avgX =
                  graphPoints.map((point) => point.x).reduce((a, b) => a + b) /
                  graphPoints.length;
              final avgY =
                  graphPoints.map((point) => point.y).reduce((a, b) => a + b) /
                  graphPoints.length;

              final slopeFromFactor =
                  calibrationFactor != null ? calibrationFactor! / 1000.0 : null;
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

    final minY =
        fitYs.isEmpty
            ? minYPoints
            : [minYPoints, fitYs.reduce((a, b) => a < b ? a : b)]
                .reduce((a, b) => a < b ? a : b);
    final maxY =
        fitYs.isEmpty
            ? maxYPoints
            : [maxYPoints, fitYs.reduce((a, b) => a > b ? a : b)]
                .reduce((a, b) => a > b ? a : b);
    final ySpan = (maxY - minY).abs();
    final yPadding = (ySpan * 0.08) < 0.5 ? 0.5 : (ySpan * 0.08);
    final chartMinY = -yPadding * 0.3;
    final chartMaxY = (maxY + yPadding) <= chartMinY ? chartMinY + 1 : (maxY + yPadding);

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
                        border: Border.all(color: Colors.grey.shade300),
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
                                final pointSpots =
                                    touchedSpots.where((spot) => spot.barIndex == 0).toList();
                                return pointSpots.map((spot) {
                                  return LineTooltipItem(
                                    'Raw: ${spot.x.toStringAsFixed(3)}\nKnown: ${spot.y.toStringAsFixed(3)} kg',
                                    GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                          gridData: FlGridData(show: true, drawVerticalLine: true),
                          titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                        axisNameWidget: Text(
                          'Known weight (kg)',
                          style: GoogleFonts.inter(fontSize: 11),
                        ),
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 44,
                            maxIncluded: false,
                              getTitlesWidget:
                                  (value, meta) => Text(
                                    value.toStringAsFixed(1),
                                    style: GoogleFonts.inter(fontSize: 10),
                                  ),
                            ),
                          ),
                      bottomTitles: AxisTitles(
                        axisNameWidget: Text(
                          'Raw measurement',
                          style: GoogleFonts.inter(fontSize: 11),
                        ),
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 32,
                              interval: xInterval,
                              maxIncluded: false,
                              getTitlesWidget:
                                  (value, meta) => Text(
                                    _formatCompactAxis(value),
                                    style: GoogleFonts.inter(fontSize: 10),
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
                            color: Colors.blue,
                            barWidth: 0,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 4,
                                  color: Colors.blue,
                                  strokeColor: Colors.white,
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
                              color: Colors.blue,
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
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              'Calibration Points',
                              style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12),
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
                                    dataTextStyle: GoogleFonts.inter(fontSize: 11),
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
                                          child: Center(child: Text('Raw Value')),
                                        ),
                                      ),
                                      DataColumn(
                                        label: SizedBox(
                                          width: knownWeightColumnWidth,
                                          child: Center(child: Text('Known Weight (kg)')),
                                        ),
                                      ),
                                    ],
                                    rows:
                                        graphPoints.asMap().entries.map((entry) {
                                          final index = entry.key + 1;
                                          final point = entry.value;
                                          return DataRow(
                                            cells: [
                                              DataCell(
                                                SizedBox(
                                                  width: indexColumnWidth,
                                                  child: Center(child: Text(index.toString())),
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  width: rawValueColumnWidth,
                                                  child: Center(
                                                    child: Text(point.x.toStringAsFixed(3)),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  width: knownWeightColumnWidth,
                                                  child: Center(
                                                    child: Text(point.y.toStringAsFixed(3)),
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
    return GestureDetector(
      onTap: () => onChanged(!isDarkMode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 58,
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF9CA3AF) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white70),
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
              alignment: isDarkMode ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF6B7280) : const Color(0xFFE5E7EB),
                  shape: BoxShape.circle,
                ),
                child: Text(isDarkMode ? '🌙' : '🌞', style: const TextStyle(fontSize: 11)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
