import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/session_models.dart';
import '../providers/database_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common/background_gradient.dart';

class SessionHistoryScreen extends ConsumerWidget {
  const SessionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(sessionHistoryProvider);

    return BackgroundGradient(
      child: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (sessions) {
          if (sessions.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history, size: 64, color: webMuted),
                  const SizedBox(height: 16),
                  Text(
                    'No sessions yet',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: webMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete a training session to see it here',
                    style: GoogleFonts.inter(fontSize: 14, color: webMuted),
                  ),
                ],
              ),
            );
          }

          // Group by date
          final grouped = <String, List<Session>>{};
          for (final session in sessions) {
            final key = _formatDate(session.startedAt);
            grouped.putIfAbsent(key, () => []).add(session);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: grouped.length,
            itemBuilder: (context, index) {
              final date = grouped.keys.elementAt(index);
              final daySessions = grouped[date]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      date,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: webAccent,
                      ),
                    ),
                  ),
                  ...daySessions.map(
                    (s) => _SessionListTile(session: s, ref: ref),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _SessionListTile extends StatelessWidget {
  const _SessionListTile({required this.session, required this.ref});

  final Session session;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final totalReps =
        session.sets.fold<int>(0, (sum, s) => sum + s.reps.length);
    final duration = session.endedAt != null
        ? session.endedAt!.difference(session.startedAt)
        : Duration.zero;

    return Dismissible(
      key: ValueKey(session.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: paleRed.withValues(alpha: 0.2),
        child: const Icon(Icons.delete, color: paleRed),
      ),
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
            color: webAccent,
          ),
          title: Text(
            _protocolLabel(session.protocolType),
            style: GoogleFonts.inter(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            '${session.sets.length} sets, $totalReps reps, '
            '${_formatTime(session.startedAt)}',
            style: GoogleFonts.inter(fontSize: 12, color: webMuted),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${session.peakForceKg.toStringAsFixed(1)} kg',
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: webAccent,
                ),
              ),
              Text(
                _formatDuration(duration),
                style: GoogleFonts.inter(fontSize: 11, color: webMuted),
              ),
            ],
          ),
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
