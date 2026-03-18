import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/session_models.dart';
import '../providers/database_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common/background_gradient.dart';
import '../widgets/common/skeleton_loader.dart';

class SessionHistoryScreen extends ConsumerStatefulWidget {
  const SessionHistoryScreen({super.key});

  @override
  ConsumerState<SessionHistoryScreen> createState() =>
      _SessionHistoryScreenState();
}

class _SessionHistoryScreenState extends ConsumerState<SessionHistoryScreen> {
  ProtocolType? _filterType;
  bool _sortByPeak = false;

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(sessionHistoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BackgroundGradient(
      child: historyAsync.when(
        loading: () => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: List.generate(
              4,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SkeletonLoader(width: double.infinity, height: 72),
              ),
            ),
          ),
        ),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (sessions) {
          if (sessions.isEmpty) {
            return _EmptyState();
          }

          // Filter
          var filtered = sessions;
          if (_filterType != null) {
            filtered = sessions
                .where((s) => s.protocolType == _filterType)
                .toList();
          }

          // Sort
          if (_sortByPeak) {
            filtered = List.from(filtered)
              ..sort((a, b) => b.peakForceKg.compareTo(a.peakForceKg));
          }

          // Group by date (only when sorted by date)
          final grouped = <String, List<Session>>{};
          for (final session in filtered) {
            final key = _sortByPeak ? 'Results' : _formatDate(session.startedAt);
            grouped.putIfAbsent(key, () => []).add(session);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Weekly summary
              _WeeklySummary(sessions: sessions),
              const SizedBox(height: 16),

              // Filter & sort controls
              _FilterBar(
                selectedType: _filterType,
                sortByPeak: _sortByPeak,
                onFilterChanged: (type) => setState(() => _filterType = type),
                onSortToggled: () => setState(() => _sortByPeak = !_sortByPeak),
              ),
              const SizedBox(height: 12),

              // Session list
              ...grouped.entries.expand((entry) => [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        entry.key,
                        style: tsInterW700S14.copyWith(
                          color: isDark ? dataAccent : lightDataAccent,
                        ),
                      ),
                    ),
                    ...entry.value.map(
                      (s) => _SessionListTile(session: s, ref: ref),
                    ),
                  ]),
            ],
          );
        },
      ),
    );
  }
}

// ──────────────────────────── Weekly summary ───────────────────────────

class _WeeklySummary extends StatelessWidget {
  const _WeeklySummary({required this.sessions});

  final List<Session> sessions;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek = DateTime(weekStart.year, weekStart.month, weekStart.day);

    final thisWeek = sessions
        .where((s) => s.startedAt.isAfter(startOfWeek))
        .toList();

    final totalSessions = thisWeek.length;
    final totalHangTimeMs = thisWeek
        .expand((s) => s.sets)
        .expand((s) => s.reps)
        .fold<int>(0, (sum, r) => sum + r.durationMs);
    final bestPeak = thisWeek.isEmpty
        ? 0.0
        : thisWeek.map((s) => s.peakForceKg).reduce((a, b) => a > b ? a : b);

    // Sessions per day (Mon-Sun)
    final perDay = List.filled(7, 0);
    for (final s in thisWeek) {
      final day = (s.startedAt.weekday - 1).clamp(0, 6);
      perDay[day]++;
    }
    final maxPerDay = perDay.reduce((a, b) => a > b ? a : b).clamp(1, 100);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? webPanel : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? webBorder.withValues(alpha: 0.6)
              : lightBorder.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Week',
            style: tsInterW700S14.copyWith(
              color: isDark ? webText : lightText,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _MiniStat(label: 'Sessions', value: '$totalSessions'),
              const SizedBox(width: 20),
              _MiniStat(
                label: 'Hang Time',
                value: '${(totalHangTimeMs / 1000).toStringAsFixed(0)}s',
              ),
              const SizedBox(width: 20),
              if (bestPeak > 0)
                _MiniStat(
                  label: 'Best Peak',
                  value: '${bestPeak.toStringAsFixed(1)} kg',
                ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 32,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                final height = perDay[i] > 0 ? (perDay[i] / maxPerDay * 20) + 4 : 4.0;
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 12,
                        height: height,
                        decoration: BoxDecoration(
                          color: perDay[i] > 0 ? brandAccent : webBorder,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dayLabels[i],
                        style: tsInterS9.copyWith(
                          color: webMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: tsGrotesk700S16.copyWith(color: dataAccent),
        ),
        Text(
          label,
          style: tsInterS11.copyWith(color: webMuted),
        ),
      ],
    );
  }
}

// ──────────────────────────── Filter bar ────────────────────────────────

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.selectedType,
    required this.sortByPeak,
    required this.onFilterChanged,
    required this.onSortToggled,
  });

  final ProtocolType? selectedType;
  final bool sortByPeak;
  final ValueChanged<ProtocolType?> onFilterChanged;
  final VoidCallback onSortToggled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FilterChip(
          label: 'All',
          selected: selectedType == null,
          onTap: () => onFilterChanged(null),
        ),
        const SizedBox(width: 6),
        _FilterChip(
          label: 'Max Hang',
          selected: selectedType == ProtocolType.maxHang,
          onTap: () => onFilterChanged(ProtocolType.maxHang),
        ),
        const SizedBox(width: 6),
        _FilterChip(
          label: 'Repeater',
          selected: selectedType == ProtocolType.repeater,
          onTap: () => onFilterChanged(ProtocolType.repeater),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onSortToggled,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: sortByPeak
                  ? brandAccent.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.sort,
              size: 18,
              color: sortByPeak ? brandAccent : webMuted,
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? brandAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: selected
              ? null
              : Border.all(color: webBorder.withValues(alpha: 0.5)),
        ),
        child: Text(
          label,
          style: tsInterW600S12.copyWith(
            color: selected ? Colors.white : webMuted,
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────── Session tile ──────────────────────────────

class _SessionListTile extends StatelessWidget {
  const _SessionListTile({required this.session, required this.ref});

  final Session session;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalReps =
        session.sets.fold<int>(0, (sum, s) => sum + s.reps.length);
    final duration = session.endedAt != null
        ? session.endedAt!.difference(session.startedAt)
        : Duration.zero;

    // Build sparkline data (lightweight — just doubles, no FlSpot objects)
    final allSamples = session.sets
        .expand((s) => s.reps)
        .expand((r) => r.weightSamples)
        .toList();
    final sparklineValues = _downsampleValues(allSamples, 20);

    return Dismissible(
      key: ValueKey(session.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: paleRed.withValues(alpha: 0.2),
        child: const Icon(Icons.delete, color: paleRed),
      ),
      confirmDismiss: (_) async {
        HapticFeedback.mediumImpact();
        return true;
      },
      onDismissed: (_) async {
        final dao = await ref.read(sessionDaoProvider.future);
        await dao.deleteSession(session.id);
        ref.invalidate(sessionHistoryProvider);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          onTap: () => context.go('/history/${session.id}'),
          leading: Icon(
            _protocolIcon(session.protocolType),
            color: brandAccent,
          ),
          title: Text(
            _protocolLabel(session.protocolType),
            style: tsInterW700S14,
          ),
          subtitle: Text(
            '${session.sets.length} sets, $totalReps reps, '
            '${_formatTime(session.startedAt)}',
            style: tsInterS12.copyWith(color: webMuted),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (sparklineValues.length >= 2)
                RepaintBoundary(
                  child: CustomPaint(
                    size: const Size(40, 20),
                    painter: _SparklinePainter(sparklineValues),
                  ),
                ),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${session.peakForceKg.toStringAsFixed(1)} kg',
                    style: tsGrotesk700S16.copyWith(
                      color: isDark ? dataAccent : lightDataAccent,
                    ),
                  ),
                  Text(
                    _formatDuration(duration),
                    style: tsInterS11.copyWith(color: webMuted),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

List<double> _downsampleValues(List<WeightSample> samples, int targetCount) {
  if (samples.isEmpty) return [];
  if (samples.length <= targetCount) {
    return samples.map((s) => s.weight).toList();
  }
  final step = samples.length / targetCount;
  return List.generate(targetCount, (i) {
    final idx = (i * step).round().clamp(0, samples.length - 1);
    return samples[idx].weight;
  });
}

// Lightweight sparkline painter — replaces full fl_chart LineChart per tile
const _sparklineColor = Color(0xB3FF6B35); // brandAccent @ 0.7
const _sparklineFill = Color(0x14FF6B35); // brandAccent @ 0.08

class _SparklinePainter extends CustomPainter {
  _SparklinePainter(this.values);

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    var minY = values[0], maxY = values[0];
    for (final v in values) {
      if (v < minY) minY = v;
      if (v > maxY) maxY = v;
    }
    final range = maxY - minY;
    if (range == 0) return;

    final stepX = size.width / (values.length - 1);
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = i * stepX;
      final y = size.height - ((values[i] - minY) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Fill area below line
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(fillPath, Paint()..color = _sparklineFill);

    // Draw line
    canvas.drawPath(
      path,
      Paint()
        ..color = _sparklineColor
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeJoin = ui.StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter old) => !identical(values, old.values);
}

// ──────────────────────────── Empty state ───────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.fitness_center, size: 72, color: webMuted.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(
            'No sessions yet',
            style: tsInterW700S20.copyWith(color: webMuted),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete your first training session\nto see your history here',
            textAlign: TextAlign.center,
            style: tsInterS14.copyWith(color: webMuted.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.go('/session/setup'),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Training'),
          ),
        ],
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

String _formatDate(DateTime dt) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final date = DateTime(dt.year, dt.month, dt.day);
  if (date == today) return 'Today';
  if (date == today.subtract(const Duration(days: 1))) return 'Yesterday';
  return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}

String _formatTime(DateTime dt) {
  return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

String _formatDuration(Duration d) {
  if (d.inMinutes < 1) return '${d.inSeconds}s';
  return '${d.inMinutes}m ${d.inSeconds % 60}s';
}
