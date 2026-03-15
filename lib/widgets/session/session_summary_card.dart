import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/session_models.dart';
import '../../theme/app_theme.dart';

class SessionSummaryCard extends StatelessWidget {
  const SessionSummaryCard({
    super.key,
    required this.sets,
    required this.peakWeightKg,
    required this.protocolType,
  });

  final List<TrainingSet> sets;
  final double peakWeightKg;
  final ProtocolType protocolType;

  @override
  Widget build(BuildContext context) {
    final totalReps =
        sets.fold<int>(0, (sum, s) => sum + s.reps.length);
    final allReps = sets.expand((s) => s.reps).toList();
    final avgPeak = allReps.isEmpty
        ? 0.0
        : allReps.map((r) => r.peakForceKg).reduce((a, b) => a + b) /
            allReps.length;
    final totalDurationMs = allReps.isEmpty
        ? 0
        : allReps.map((r) => r.durationMs).reduce((a, b) => a + b);
    final avgHangDurationMs = allReps.isEmpty
        ? 0.0
        : totalDurationMs / allReps.length;
    final maxHangDurationMs = allReps.isEmpty
        ? 0
        : allReps.map((r) => r.durationMs).reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(label: 'Sets', value: sets.length.toString()),
                _StatItem(label: 'Reps', value: totalReps.toString()),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(
                  label: 'Peak',
                  value: '${peakWeightKg.toStringAsFixed(1)} kg',
                ),
                _StatItem(
                  label: 'Avg Peak',
                  value: '${avgPeak.toStringAsFixed(1)} kg',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(
                  label: 'Avg Hang',
                  value: '${(avgHangDurationMs / 1000).toStringAsFixed(1)}s',
                ),
                _StatItem(
                  label: 'Max Hang',
                  value: '${(maxHangDurationMs / 1000).toStringAsFixed(1)}s',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _StatItem(
              label: 'Total Hang Time',
              value: '${(totalDurationMs / 1000).toStringAsFixed(1)}s',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w800,
            fontSize: 24,
            color: webAccent,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: webMuted,
          ),
        ),
      ],
    );
  }
}
