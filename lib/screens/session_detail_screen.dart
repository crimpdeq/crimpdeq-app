import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/session_models.dart';
import '../providers/database_provider.dart';
import '../services/export_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common/animated_number.dart';
import '../widgets/common/background_gradient.dart';
import '../widgets/session/session_summary_card.dart';

class SessionDetailScreen extends ConsumerWidget {
  const SessionDetailScreen({super.key, required this.sessionId});

  final String sessionId;

  Future<Session?> _getSession(WidgetRef ref) async {
    final dao = await ref.read(sessionDaoProvider.future);
    return dao.getSession(sessionId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/history'),
        ),
        title: Text(
          'Session Detail',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              final session = await _getSession(ref);
              if (session == null || !context.mounted) return;
              switch (value) {
                case 'csv':
                  await ExportService.exportCsv(session);
                case 'json':
                  await ExportService.exportJson(session);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'csv', child: Text('Export CSV')),
              const PopupMenuItem(value: 'json', child: Text('Export JSON')),
            ],
          ),
        ],
      ),
      body: FutureBuilder<Session?>(
        future: _getSession(ref),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final session = snapshot.data;
          if (session == null) {
            return Center(
              child: Text(
                'Session not found',
                style: GoogleFonts.inter(color: webMuted),
              ),
            );
          }
          return BackgroundGradient(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Hero peak weight header
                _HeroPeakHeader(session: session),
                const SizedBox(height: 16),

                SessionSummaryCard(
                  sets: session.sets,
                  peakWeightKg: session.peakForceKg,
                  protocolType: session.protocolType,
                ),
                const SizedBox(height: 16),

                // Weight chart replay
                _WeightReplayChart(session: session),
                const SizedBox(height: 16),

                // Per-set breakdown
                ...session.sets.asMap().entries.map((entry) {
                  final setIdx = entry.key;
                  final trainingSet = entry.value;
                  return _SetBreakdownCard(
                    setIndex: setIdx,
                    trainingSet: trainingSet,
                    targetWeight: session.protocolConfig.targetWeightKg,
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ──────────────────────────── Hero peak header ─────────────────────────

class _HeroPeakHeader extends StatelessWidget {
  const _HeroPeakHeader({required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    final dateStr = _formatDateTime(session.startedAt);

    return Column(
      children: [
        // Protocol badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: brandAccent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _protocolIcon(session.protocolType),
                size: 14,
                color: brandAccent,
              ),
              const SizedBox(width: 6),
              Text(
                _protocolLabel(session.protocolType),
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: brandAccent,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          dateStr,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: webMuted,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedNumber(
          value: session.peakForceKg,
          fractionDigits: 1,
          suffix: ' kg',
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w800,
            fontSize: 48,
            color: brandAccent,
            height: 1,
          ),
        ),
        Text(
          'Peak Force',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: webMuted,
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────── Weight chart ──────────────────────────────

class _WeightReplayChart extends StatelessWidget {
  const _WeightReplayChart({required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    // Collect all samples with set boundary timestamps
    final allSamples = <WeightSample>[];
    final setBoundaries = <double>[];

    for (var si = 0; si < session.sets.length; si++) {
      final trainingSet = session.sets[si];
      for (final rep in trainingSet.reps) {
        allSamples.addAll(rep.weightSamples);
      }
      if (si < session.sets.length - 1 && allSamples.isNotEmpty) {
        setBoundaries.add(allSamples.last.timestampMs / 1000.0);
      }
    }

    if (allSamples.isEmpty) {
      return const SizedBox.shrink();
    }

    final spots = allSamples
        .map((s) => FlSpot(s.timestampMs / 1000.0, s.weight))
        .toList();
    final minX = spots.first.x;
    final maxX = spots.last.x;
    final resolvedMaxX = maxX <= minX ? minX + 1.0 : maxX;
    final weights = allSamples.map((s) => s.weight);
    final minY = weights.reduce((a, b) => a < b ? a : b) - 1;
    final maxY = weights.reduce((a, b) => a > b ? a : b) + 1;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weight Over Time',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  minX: minX,
                  maxX: resolvedMaxX,
                  minY: minY,
                  maxY: maxY,
                  clipData: const FlClipData.all(),
                  gridData: FlGridData(
                    show: true,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: webBorder.withValues(alpha: 0.5),
                      strokeWidth: 0.5,
                    ),
                    getDrawingVerticalLine: (_) => const FlLine(
                      color: Colors.transparent,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(0),
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 10,
                              color: webMuted,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 20,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toStringAsFixed(0)}s',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 9,
                              color: webMuted,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            '${spot.y.toStringAsFixed(1)} kg',
                            GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  extraLinesData: ExtraLinesData(
                    verticalLines: setBoundaries.map((x) {
                      return VerticalLine(
                        x: x,
                        color: webMuted.withValues(alpha: 0.3),
                        strokeWidth: 1,
                        dashArray: [4, 4],
                      );
                    }).toList(),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      curveSmoothness: 0.2,
                      color: brandAccent,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: brandAccent.withValues(alpha: 0.1),
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

// ──────────────────────────── Set breakdown card ────────────────────────

class _SetBreakdownCard extends StatelessWidget {
  const _SetBreakdownCard({
    required this.setIndex,
    required this.trainingSet,
    required this.targetWeight,
  });

  final int setIndex;
  final TrainingSet trainingSet;
  final double targetWeight;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set ${setIndex + 1}',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: trainingSet.reps.asMap().entries.map((entry) {
                final rep = entry.value;
                final durationSec = rep.durationMs / 1000.0;

                // Color code vs target
                Color borderColor = webBorder;
                if (targetWeight > 0) {
                  final tolerance = targetWeight * 0.1;
                  if (rep.peakForceKg >= targetWeight - tolerance &&
                      rep.peakForceKg <= targetWeight + tolerance) {
                    borderColor = Colors.greenAccent.shade400.withValues(alpha: 0.5);
                  } else if (rep.peakForceKg > targetWeight + tolerance) {
                    borderColor = Colors.amber.withValues(alpha: 0.5);
                  }
                }

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? webBgSoft : const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      Text(
                        rep.peakForceKg.toStringAsFixed(1),
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: isDark ? dataAccent : lightDataAccent,
                        ),
                      ),
                      Text(
                        'kg peak',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          color: webMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${rep.avgForceKg.toStringAsFixed(1)} avg',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          color: webMuted,
                        ),
                      ),
                      Text(
                        '${durationSec.toStringAsFixed(1)}s',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          color: webMuted,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────── Helpers ─────────────────────────────────

IconData _protocolIcon(ProtocolType type) {
  switch (type) {
    case ProtocolType.maxHang:
      return Icons.fitness_center;
    case ProtocolType.repeater:
      return Icons.repeat;
    case ProtocolType.freeform:
      return Icons.explore;
  }
}

String _protocolLabel(ProtocolType type) {
  switch (type) {
    case ProtocolType.maxHang:
      return 'Max Hang';
    case ProtocolType.repeater:
      return 'Repeater';
    case ProtocolType.freeform:
      return 'Freeform';
  }
}

String _formatDateTime(DateTime dt) {
  final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${months[dt.month - 1]} ${dt.day}, ${dt.year} at '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
