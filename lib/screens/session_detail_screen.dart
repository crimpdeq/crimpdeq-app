import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/session_models.dart';
import '../providers/database_provider.dart';
import '../services/export_service.dart';
import '../theme/app_theme.dart';
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
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Set ${setIdx + 1}',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...trainingSet.reps.asMap().entries.map((repEntry) {
                            final repIdx = repEntry.key;
                            final rep = repEntry.value;
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Rep ${repIdx + 1}',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Peak: ${rep.peakForceKg.toStringAsFixed(1)} kg  '
                                    'Avg: ${rep.avgForceKg.toStringAsFixed(1)} kg  '
                                    '${(rep.durationMs / 1000).toStringAsFixed(1)}s',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 12,
                                      color: webMuted,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
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

class _WeightReplayChart extends StatelessWidget {
  const _WeightReplayChart({required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    final allSamples = session.sets
        .expand((s) => s.reps)
        .expand((r) => r.weightSamples)
        .toList();

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
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      curveSmoothness: 0.2,
                      color: webAccent,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: webAccent.withValues(alpha: 0.1),
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
