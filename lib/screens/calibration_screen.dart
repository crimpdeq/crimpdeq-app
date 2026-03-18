import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/progressor_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common/background_gradient.dart';
import '../widgets/progressor_widgets.dart';

class CalibrationScreen extends ConsumerWidget {
  const CalibrationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(progressorProvider);
    final notifier = ref.read(progressorProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final calibrationFactor = _extractCalibrationFactor(state.errorMessage);
    final calibrationFactorValue = double.tryParse(calibrationFactor ?? '');
    final calibrationPoints = _extractCalibrationPoints(state.errorMessage);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => context.go('/settings'),
        ),
        title: Text(
          'Calibration',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      body: BackgroundGradient(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Explainer
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: brandAccent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: brandAccent.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: brandAccent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Calibrate your device by adding known weight points. '
                      'Use at least 3 points for best accuracy.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: isDark ? webText : lightText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (calibrationFactor != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 4),
                child: Text(
                  'Factor: $calibrationFactor',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: isDark ? webMuted : const Color(0xFF656D76),
                  ),
                ),
              ),

            if (calibrationPoints.isNotEmpty) ...[
              CalibrationGraphCard(
                calibrationPoints: calibrationPoints,
                calibrationFactor: calibrationFactorValue,
              ),
              const SizedBox(height: 12),
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
    );
  }
}

String? _extractCalibrationFactor(String? calibrationInfo) {
  if (calibrationInfo == null || calibrationInfo.isEmpty) return null;
  final match = RegExp(
    r'Calibration factor:\s*([0-9.+\-eE]+)',
  ).firstMatch(calibrationInfo);
  return match?.group(1);
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
