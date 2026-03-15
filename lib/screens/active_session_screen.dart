import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/session_models.dart';
import '../providers/progressor_provider.dart';
import '../providers/session_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/session/session_summary_card.dart';

class ActiveSessionScreen extends ConsumerWidget {
  const ActiveSessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final progressorState = ref.watch(progressorProvider);
    if (session == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final liveWeight = progressorState.measurement.currentWeight;

    return Scaffold(
      backgroundColor: webBg,
      body: SafeArea(
        child: session.phase == SessionPhase.complete
            ? _CompletedView(session: session, ref: ref)
            : _ActiveView(
                session: session,
                ref: ref,
                liveWeight: liveWeight,
              ),
      ),
    );
  }
}

// ──────────────────────────── Active view ─────────────────────────────

class _ActiveView extends StatelessWidget {
  const _ActiveView({
    required this.session,
    required this.ref,
    required this.liveWeight,
  });

  final ActiveSessionState session;
  final WidgetRef ref;
  final double liveWeight;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final targetWeight = session.protocol.targetWeightKg;
    final weight = liveWeight < 0 ? 0.0 : liveWeight;

    // Color feedback
    Color heroColor;
    if (targetWeight > 0) {
      final tolerance = targetWeight * 0.1;
      if (weight >= targetWeight - tolerance &&
          weight <= targetWeight + tolerance) {
        heroColor = Colors.greenAccent.shade400;
      } else if (weight > targetWeight + tolerance) {
        heroColor = Colors.amber;
      } else {
        heroColor = colorScheme.primary;
      }
    } else {
      heroColor = colorScheme.primary;
    }

    final phaseLabel = _phaseLabel(session.phase);
    final isMaxHangHanging = session.protocol.type == ProtocolType.maxHang &&
        session.phase == SessionPhase.hanging;
    final timerMs = isMaxHangHanging
        ? session.phaseElapsedMs
        : session.phaseRemainingMs;
    final phaseTime = _formatDuration(timerMs);
    final showTimerUnit = timerMs < 60000;

    return Column(
      children: [
        // Header: set/rep + progress
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                session.protocol.type == ProtocolType.freeform
                    ? 'FREEFORM'
                    : 'SET ${session.currentSetIndex + 1} / ${session.protocol.sets}',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: webText,
                ),
              ),
              Text(
                '${session.completedSets.expand((s) => s.reps).length + session.currentSetReps.length} reps',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: webMuted,
                ),
              ),
            ],
          ),
        ),
        if (session.protocol.type != ProtocolType.freeform)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LinearProgressIndicator(
              value: session.protocol.sets > 0
                  ? session.currentSetIndex / session.protocol.sets
                  : 0,
              backgroundColor: webBorder,
              valueColor: AlwaysStoppedAnimation(colorScheme.primary),
              borderRadius: BorderRadius.circular(4),
              minHeight: 4,
            ),
          ),

        // Phase + timer
        Expanded(
          flex: 4,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  phaseLabel,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    letterSpacing: 1.2,
                    color: webMuted,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      phaseTime,
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w800,
                        fontSize: 72,
                        color: colorScheme.primary,
                        height: 1,
                      ),
                    ),
                    if (showTimerUnit) ...[
                      const SizedBox(width: 4),
                      Text(
                        's',
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w600,
                          fontSize: 24,
                          color: webMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),

        // Weight gauge — the main visual
        Expanded(
          flex: 8,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _WeightGauge(
              currentWeight: weight,
              targetWeight: targetWeight,
              thresholdWeight: session.protocol.hangThresholdKg,
              peakWeight: session.peakWeightKg,
              heroColor: heroColor,
            ),
          ),
        ),

        // Completed reps row (grouped by set)
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _RepGrid(
              completedSets: session.completedSets,
              currentSetReps: session.currentSetReps,
              currentSetIndex: session.currentSetIndex,
              targetWeight: targetWeight,
              thresholdWeight: session.protocol.hangThresholdKg,
              protocolType: session.protocol.type,
            ),
          ),
        ),

        const SizedBox(height: 4),

        // Pause + End session buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    final notifier = ref.read(sessionProvider.notifier);
                    if (session.isPaused) {
                      notifier.resumeSession();
                    } else {
                      notifier.pauseSession();
                    }
                  },
                  icon: Icon(
                    session.isPaused ? Icons.play_arrow : Icons.pause,
                    color: colorScheme.primary,
                  ),
                  label: Text(
                    session.isPaused ? 'Resume' : 'Pause',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    side: BorderSide(color: colorScheme.primary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ref.read(sessionProvider.notifier).endSession();
                    if (context.mounted) context.go('/');
                  },
                  icon: const Icon(Icons.stop, color: paleRed),
                  label: Text(
                    'End Session',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      color: paleRed,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    side: const BorderSide(color: paleRed),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────── Weight gauge ────────────────────────────

class _WeightGauge extends StatelessWidget {
  const _WeightGauge({
    required this.currentWeight,
    required this.targetWeight,
    required this.thresholdWeight,
    required this.peakWeight,
    required this.heroColor,
  });

  final double currentWeight;
  final double targetWeight;
  final double thresholdWeight;
  final double peakWeight;
  final Color heroColor;

  @override
  Widget build(BuildContext context) {
    // Scale: 0 → max(target*1.3, peak*1.15, 25)
    final scaleMax = [
      if (targetWeight > 0) targetWeight * 1.3,
      if (peakWeight > 0) peakWeight * 1.15,
      25.0,
    ].reduce(max);
    final fillRatio = (currentWeight / scaleMax).clamp(0.0, 1.0);
    final thresholdRatio =
        thresholdWeight > 0 ? (thresholdWeight / scaleMax).clamp(0.0, 1.0) : 0.0;
    final peakRatio =
        peakWeight > 0 ? (peakWeight / scaleMax).clamp(0.0, 1.0) : 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final gaugeHeight = constraints.maxHeight;
        final gaugeWidth = constraints.maxWidth;

        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Background track
            Container(
              width: gaugeWidth,
              height: gaugeHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: webPanel.withValues(alpha: 0.6),
                border: Border.all(
                  color: webBorder.withValues(alpha: 0.5),
                ),
              ),
            ),

            // Fill bar
            AnimatedContainer(
              duration: const Duration(milliseconds: 80),
              width: gaugeWidth,
              height: gaugeHeight * fillRatio,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    heroColor.withValues(alpha: 0.25),
                    heroColor.withValues(alpha: 0.08),
                  ],
                ),
              ),
            ),

            // Top fade: blend gauge into app background above peak
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: gaugeHeight * (1.0 - peakRatio).clamp(0.2, 0.5),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      webBg,
                      webBg.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),

            // Threshold line (min weight to count as a hang)
            if (thresholdRatio > 0)
              Positioned(
                bottom: gaugeHeight * thresholdRatio,
                left: 0,
                right: 0,
                child: _DottedLine(
                  color: Colors.greenAccent.shade400,
                  label: 'MIN ${thresholdWeight.toStringAsFixed(0)} kg',
                ),
              ),

            // Peak line
            if (peakRatio > 0 && peakWeight > 0.5)
              Positioned(
                bottom: gaugeHeight * peakRatio,
                left: 0,
                right: 0,
                child: _DottedLine(
                  color: webAccentStrong,
                  label: 'MAX ${peakWeight.toStringAsFixed(1)} kg',
                ),
              ),

            // Hero weight overlay
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currentWeight.toStringAsFixed(1),
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w800,
                      fontSize: 72,
                      color: heroColor,
                      height: 1,
                    ),
                  ),
                  Text(
                    'kg',
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      color: webMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DottedLine extends StatelessWidget {
  const _DottedLine({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            margin: const EdgeInsets.only(right: 8, bottom: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        // Dashed line
        SizedBox(
          height: 1,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final dashCount = (constraints.maxWidth / 8).floor();
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(dashCount, (_) {
                  return SizedBox(
                    width: 4,
                    height: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: color),
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────── Rep grid ────────────────────────────────

class _RepGrid extends StatelessWidget {
  const _RepGrid({
    required this.completedSets,
    required this.currentSetReps,
    required this.targetWeight,
    required this.thresholdWeight,
    required this.protocolType,
    required this.currentSetIndex,
  });

  final List<TrainingSet> completedSets;
  final List<Rep> currentSetReps;
  final double targetWeight;
  final double thresholdWeight;
  final ProtocolType protocolType;
  final int currentSetIndex;

  @override
  Widget build(BuildContext context) {
    final setCards = <Widget>[];

    for (var si = 0; si < completedSets.length; si++) {
      setCards.add(_setCard(context, si, completedSets[si].reps));
    }

    if (currentSetReps.isNotEmpty) {
      setCards.add(_setCard(context, currentSetIndex, currentSetReps));
    }

    if (setCards.isEmpty) {
      return const SizedBox.expand();
    }

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: setCards.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (_, index) => setCards[index],
    );
  }

  Widget _setCard(BuildContext context, int setIndex, List<Rep> reps) {
    return IntrinsicWidth(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                'SET ${setIndex + 1}',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: webMuted,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < reps.length; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  _repChip(reps[i]),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _repChip(Rep rep) {
    final isBad = thresholdWeight > 0 && rep.avgForceKg < thresholdWeight;
    final accent = isBad ? paleRed : webAccent;
    final durationSec = rep.durationMs / 1000.0;
    final isMaxHang = protocolType == ProtocolType.maxHang;

    final heroText = isMaxHang
        ? '${durationSec.toStringAsFixed(1)}s'
        : '${rep.avgForceKg.toStringAsFixed(1)} kg';
    final secondaryLeft = isMaxHang
        ? 'avg ${rep.avgForceKg.toStringAsFixed(1)} kg'
        : '${durationSec.toStringAsFixed(1)}s';
    final secondaryRight = isMaxHang
        ? 'max ${rep.peakForceKg.toStringAsFixed(1)} kg'
        : 'max ${rep.peakForceKg.toStringAsFixed(1)} kg';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            heroText,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            secondaryLeft,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: webMuted,
            ),
          ),
          Text(
            secondaryRight,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: webMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────── Completed view ──────────────────────────

class _CompletedView extends StatelessWidget {
  const _CompletedView({required this.session, required this.ref});

  final ActiveSessionState session;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: Colors.greenAccent.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Session Complete',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w800,
              fontSize: 24,
              color: webText,
            ),
          ),
          const SizedBox(height: 24),
          SessionSummaryCard(
            sets: session.completedSets,
            peakWeightKg: session.peakWeightKg,
            protocolType: session.protocol.type,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () {
              ref.read(sessionProvider.notifier).endSession();
              if (context.mounted) context.go('/');
            },
            icon: const Icon(Icons.home),
            label: const Text('Done'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(280, 56),
              textStyle: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────── Helpers ─────────────────────────────────

String _phaseLabel(SessionPhase phase) {
  switch (phase) {
    case SessionPhase.idle:
      return 'READY';
    case SessionPhase.countdown:
      return 'GET READY';
    case SessionPhase.hanging:
      return 'HANG';
    case SessionPhase.resting:
      return 'REST';
    case SessionPhase.restBetweenSets:
      return 'SET REST';
    case SessionPhase.complete:
      return 'COMPLETE';
  }
}

String _formatDuration(int ms) {
  final totalSeconds = ms / 1000;
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  if (minutes > 0) {
    return '$minutes:${seconds.toStringAsFixed(1).padLeft(4, '0')}';
  }
  return seconds.toStringAsFixed(1);
}
