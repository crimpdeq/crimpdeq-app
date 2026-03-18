import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
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
    // Only watch phase to avoid rebuilding entire tree on timer/weight ticks
    final phase = ref.watch(sessionProvider.select((s) => s?.phase));
    final session = ref.read(sessionProvider);
    if (session == null || phase == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: webBg,
      body: SafeArea(
        child: phase == SessionPhase.complete
            ? _CompletedView(session: session, ref: ref)
            : _ActiveView(
                session: session,
                ref: ref,
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
  });

  final ActiveSessionState session;
  final WidgetRef ref;

  void _showEndSessionConfirmation(BuildContext context, WidgetRef ref) {
    HapticFeedback.heavyImpact();
    final notifier = ref.read(sessionProvider.notifier);
    final wasPaused = ref.read(sessionProvider)?.isPaused ?? false;
    if (!wasPaused) notifier.pauseSession();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'End Session?',
              style: tsInterW700S20,
            ),
            const SizedBox(height: 8),
            Text(
              'Your progress will be saved.',
              style: tsInterS14.copyWith(color: webMuted),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      if (!wasPaused) notifier.resumeSession();
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                    child: Text(
                      'Cancel',
                      style: tsInterW600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      if (context.mounted) {
                        notifier.endSession();
                        context.go('/');
                      }
                    },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      backgroundColor: paleRed,
                    ),
                    child: Text(
                      'End',
                      style: tsInterW700S14.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final targetWeight = session.protocol.targetWeightKg;

    final phaseLabel = _phaseLabel(session.phase);

    final isHanging = session.phase == SessionPhase.hanging;
    final isResting = session.phase == SessionPhase.resting ||
        session.phase == SessionPhase.restBetweenSets;
    final isCountdown = session.phase == SessionPhase.countdown;

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
                style: tsInterW700S16.copyWith(color: webText),
              ),
              Text(
                '${session.completedSets.expand((s) => s.reps).length + session.currentSetReps.length} reps',
                style: tsInterW600S14.copyWith(color: webMuted),
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

        // Phase-adaptive layout: HANG -> gauge dominates, REST/COUNTDOWN -> timer dominates
        if (isHanging) ...[
          // Timer — isolated rebuild + repaint via Consumer.select
          Expanded(
            flex: 3,
            child: Center(
              child: RepaintBoundary(
                child: _TickerTimerDisplay(
                  phaseLabel: phaseLabel,
                  timerFontSize: 72,
                  labelFontSize: 26,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
          // Gauge — reads live weight from progressorProvider (decoupled from timer)
          Expanded(
            flex: 7,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: RepaintBoundary(
                child: Consumer(
                  builder: (context, ref, _) {
                    // Live weight from hardware provider — independent of session timer
                    final liveW = ref.watch(progressorProvider.select((s) =>
                      (s.measurement.currentWeight * 10).roundToDouble() / 10,
                    ));
                    // Peak from session (rarely changes — only on new peak)
                    final peakW = ref.watch(sessionProvider.select((s) =>
                      ((s?.peakWeightKg ?? 0.0) * 10).roundToDouble() / 10,
                    ));
                    final w = liveW < 0 ? 0.0 : liveW;
                    Color color;
                    if (targetWeight > 0) {
                      final tol = targetWeight * 0.1;
                      if (w >= targetWeight - tol && w <= targetWeight + tol) {
                        color = Colors.greenAccent.shade400;
                      } else if (w > targetWeight + tol) {
                        color = Colors.amber;
                      } else {
                        color = brandAccent;
                      }
                    } else {
                      color = brandAccent;
                    }
                    return SizedBox.expand(
                      child: CustomPaint(
                        painter: _WeightGaugePainter(
                          currentWeight: w,
                          targetWeight: targetWeight,
                          thresholdWeight: session.protocol.hangThresholdKg,
                          peakWeight: peakW,
                          heroColor: color,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ] else if (isResting || isCountdown) ...[
          // Timer dominates center
          Expanded(
            flex: 6,
            child: Center(
              child: _TickerTimerDisplay(
                phaseLabel: phaseLabel,
                timerFontSize: 96,
                labelFontSize: 16,
                color: colorScheme.primary,
                timerStyle: tsGrotesk800S96,
                unitStyle: tsGrotesk600S28,
                labelStyle: tsInterW600S16Spaced,
              ),
            ),
          ),
          Expanded(
            flex: 2,
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
        ] else ...[
          // Idle/other: balanced layout
          Expanded(
            flex: 4,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: _TickerTimerDisplay(
                phaseLabel: phaseLabel,
                timerFontSize: 72,
                color: colorScheme.primary,
              ),
            ),
          ),
          Expanded(
            flex: 8,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Consumer(
                builder: (context, ref, _) {
                  final liveW = ref.watch(progressorProvider.select((s) =>
                    (s.measurement.currentWeight * 10).roundToDouble() / 10,
                  ));
                  final peakW = ref.watch(sessionProvider.select((s) =>
                    ((s?.peakWeightKg ?? 0.0) * 10).roundToDouble() / 10,
                  ));
                  final w = liveW < 0 ? 0.0 : liveW;
                  Color color;
                  if (targetWeight > 0) {
                    final tol = targetWeight * 0.1;
                    if (w >= targetWeight - tol && w <= targetWeight + tol) {
                      color = Colors.greenAccent.shade400;
                    } else if (w > targetWeight + tol) {
                      color = Colors.amber;
                    } else {
                      color = brandAccent;
                    }
                  } else {
                    color = brandAccent;
                  }
                  return SizedBox.expand(
                    child: CustomPaint(
                      painter: _WeightGaugePainter(
                        currentWeight: w,
                        targetWeight: targetWeight,
                        thresholdWeight: session.protocol.hangThresholdKg,
                        peakWeight: peakW,
                        heroColor: color,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],

        if (isHanging) const SizedBox(height: 24),

        // Rep grid during idle/other phases
        if (!isHanging && !isResting && !isCountdown) ...[
          Expanded(
            flex: 3,
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
        ],

        const SizedBox(height: 6),

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
                    style: tsInterW700S14.copyWith(color: colorScheme.primary),
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
                  onPressed: () => _showEndSessionConfirmation(context, ref),
                  icon: const Icon(Icons.stop, color: paleRed),
                  label: Text(
                    'End Session',
                    style: tsInterW700S14.copyWith(color: paleRed),
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

// ──────────────────────────── Ticker-driven timer ────────────────────────

class _TickerTimerDisplay extends ConsumerStatefulWidget {
  const _TickerTimerDisplay({
    required this.phaseLabel,
    required this.timerFontSize,
    required this.color,
    this.labelFontSize = 14,
    this.timerStyle,
    this.unitStyle,
    this.labelStyle,
  });

  final String phaseLabel;
  final double timerFontSize;
  final double labelFontSize;
  final Color color;
  final TextStyle? timerStyle;
  final TextStyle? unitStyle;
  final TextStyle? labelStyle;

  @override
  ConsumerState<_TickerTimerDisplay> createState() =>
      _TickerTimerDisplayState();
}

class _TickerTimerDisplayState extends ConsumerState<_TickerTimerDisplay>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  int _lastTenths = -1;
  String _displayTime = '0.0';
  bool _showUnit = true;

  // Cached from provider — updated only via ref.listen, never read in hot path
  int _deadlineMs = 0;
  int _startMs = 0;
  bool _isElapsed = false;
  bool _isPaused = false;
  int _frozenRemainingMs = 0;
  int _frozenElapsedMs = 0;

  @override
  void initState() {
    super.initState();
    _syncFromProvider(ref.read(sessionProvider));
    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _syncFromProvider(ActiveSessionState? s) {
    if (s == null) return;
    _deadlineMs = s.phaseDeadlineMs;
    _startMs = s.phaseStartMs;
    _isElapsed = s.protocol.type == ProtocolType.maxHang &&
        s.phase == SessionPhase.hanging;
    _isPaused = s.isPaused;
    _frozenRemainingMs = s.phaseRemainingMs;
    _frozenElapsedMs = s.phaseElapsedMs;
  }

  void _onTick(Duration elapsed) {
    if (_isPaused) return;

    int ms;
    if (_isElapsed) {
      ms = _startMs > 0
          ? DateTime.now().millisecondsSinceEpoch - _startMs
          : _frozenElapsedMs;
    } else {
      final raw = _deadlineMs - DateTime.now().millisecondsSinceEpoch;
      ms = _deadlineMs > 0 ? (raw < 0 ? 0 : raw) : _frozenRemainingMs;
    }

    final tenths = ms ~/ 100;
    if (tenths != _lastTenths) {
      _lastTenths = tenths;
      setState(() {
        _displayTime = _formatDuration(ms);
        _showUnit = ms < 60000;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sync cached fields when provider state changes (phase transitions, pause/resume)
    ref.listen(sessionProvider, (_, next) => _syncFromProvider(next));

    final timerStyle = widget.timerStyle ??
        tsGrotesk800S72.copyWith(
            fontSize: widget.timerFontSize, color: widget.color);
    final unitStyle = widget.unitStyle ??
        tsGrotesk600S24.copyWith(
            fontSize: widget.timerFontSize * 0.33, color: webMuted);
    final labelStyle = widget.labelStyle ??
        tsInterW600S16Spaced.copyWith(
            fontSize: widget.labelFontSize, color: webMuted);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: animation, child: child),
          ),
          child: Text(
            widget.phaseLabel,
            key: ValueKey(widget.phaseLabel),
            style: labelStyle,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              _displayTime,
              style: timerStyle.copyWith(color: widget.color),
            ),
            if (_showUnit) ...[
              const SizedBox(width: 4),
              Text('s', style: unitStyle),
            ],
          ],
        ),
      ],
    );
  }
}

// ──────────────────────────── Last rep summary ──────────────────────────

class _LastRepSummary extends StatelessWidget {
  const _LastRepSummary({
    required this.rep,
    required this.protocolType,
  });

  final Rep rep;
  final ProtocolType protocolType;

  @override
  Widget build(BuildContext context) {
    final durationSec = rep.durationMs / 1000.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: webPanel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: webBorder.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            'Last Rep',
            style: tsInterW600S13.copyWith(color: webMuted),
          ),
          Text(
            '${rep.peakForceKg.toStringAsFixed(1)} kg',
            style: tsGrotesk700S18.copyWith(color: dataAccent),
          ),
          Text(
            '${durationSec.toStringAsFixed(1)}s',
            style: tsGrotesk600S14.copyWith(color: webMuted),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────── Vertical bar weight gauge ──────────────────

class _WeightGaugePainter extends CustomPainter {
  _WeightGaugePainter({
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

  // Reusable paint objects
  static final _bgPaint = Paint()..color = webPanel;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const radius = Radius.circular(16);
    final rrect = RRect.fromLTRBR(0, 0, w, h, radius);

    // Compute fill ratio first — needed for both fill and border gradient
    final scaleMax = [
      if (targetWeight > 0) targetWeight * 1.3,
      if (peakWeight > 0) peakWeight * 1.15,
      25.0,
    ].reduce(max);
    final fillRatio = (currentWeight / scaleMax).clamp(0.0, 1.0);

    // 1. Background track
    canvas.drawRRect(rrect, _bgPaint);
    final fillHeight = h * fillRatio;

    canvas.save();
    canvas.clipRRect(rrect);
    final fillRect = Rect.fromLTRB(0, h - fillHeight, w, h);
    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [Color(0x30808080), Color(0x10808080)],
      ).createShader(fillRect);
    canvas.drawRect(fillRect, fillPaint);

    // 3. Top fade overlay
    final fadeHeight = h * 0.18;
    final fadeRect = Rect.fromLTRB(0, 0, w, fadeHeight);
    final fadePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [webBg, Color(0x000A0A0A)],
      ).createShader(fadeRect);
    canvas.drawRect(fadeRect, fadePaint);
    canvas.restore();

    // 4. Threshold dotted line + label
    final thresholdRatio =
        thresholdWeight > 0 ? (thresholdWeight / scaleMax).clamp(0.0, 1.0) : 0.0;
    if (thresholdRatio > 0) {
      final y = h - h * thresholdRatio;
      final color = brandAccent.withValues(alpha: 0.7);
      _drawDottedLine(canvas, 12, w - 12, y, color);
      _drawLineLabel(
        canvas, w,
        'goal:  ${thresholdWeight.toStringAsFixed(0)} kg',
        y, color, labelAbove: false,
      );
    }

    // 5. Peak dotted line + label
    final peakRatio =
        peakWeight > 0 ? (peakWeight / scaleMax).clamp(0.0, 1.0) : 0.0;
    if (peakRatio > 0) {
      final y = h - h * peakRatio;
      final color = webAccentStrong.withValues(alpha: 0.6);
      _drawDottedLine(canvas, 12, w - 12, y, color);
      _drawLineLabel(
        canvas, w,
        'max:  ${peakWeight.toStringAsFixed(1)} kg',
        y, color, labelAbove: true,
      );
    }

    // 6. Hero weight text centered
    final heroTp = TextPainter(
      text: TextSpan(
        text: currentWeight.toStringAsFixed(1),
        style: tsGrotesk800S72.copyWith(color: heroColor),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final kgTp = TextPainter(
      text: TextSpan(
        text: 'kg',
        style: tsGrotesk600S24.copyWith(color: webMuted),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final totalTextH = heroTp.height + kgTp.height;
    final textTop = (h - totalTextH) / 2;
    heroTp.paint(canvas, Offset((w - heroTp.width) / 2, textTop));
    kgTp.paint(canvas, Offset((w - kgTp.width) / 2, textTop + heroTp.height));
  }

  void _drawDottedLine(
      Canvas canvas, double x1, double x2, double y, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    const dashW = 4.0;
    const gap = 4.0;
    var x = x1;
    while (x < x2) {
      canvas.drawLine(Offset(x, y), Offset(x + dashW, y), paint);
      x += dashW + gap;
    }
  }

  void _drawLineLabel(
    Canvas canvas, double gaugeWidth, String text,
    double lineY, Color color, {required bool labelAbove,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: tsGrotesk700S14.copyWith(color: color)),
      textDirection: TextDirection.ltr,
    )..layout();

    const px = 8.0, py = 3.0;
    final labelW = tp.width + px * 2;
    final labelH = tp.height + py * 2;
    final left = gaugeWidth - 12 - labelW;
    final top = labelAbove ? lineY - 6 - labelH : lineY + 6;

    // Label background pill
    final labelRect = RRect.fromLTRBR(left, top, left + labelW, top + labelH,
        const Radius.circular(6));
    canvas.drawRRect(labelRect, Paint()..color = color.withValues(alpha: 0.15));
    tp.paint(canvas, Offset(left + px, top + py));
  }

  @override
  bool shouldRepaint(_WeightGaugePainter old) =>
      currentWeight != old.currentWeight ||
      peakWeight != old.peakWeight ||
      heroColor != old.heroColor ||
      targetWeight != old.targetWeight ||
      thresholdWeight != old.thresholdWeight;
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
    final allReps = <(int setIndex, int repIndex, Rep rep)>[];

    for (var si = 0; si < completedSets.length; si++) {
      for (var ri = 0; ri < completedSets[si].reps.length; ri++) {
        allReps.add((si, ri, completedSets[si].reps[ri]));
      }
    }
    for (var ri = 0; ri < currentSetReps.length; ri++) {
      allReps.add((currentSetIndex, ri, currentSetReps[ri]));
    }

    if (allReps.isEmpty) {
      return const SizedBox.expand();
    }

    return ListView.separated(
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: allReps.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (_, index) {
        // reversed list, so newest rep first
        final (setIdx, repIdx, rep) = allReps[allReps.length - 1 - index];
        return _repRow(setIdx, repIdx, rep);
      },
    );
  }

  Widget _repRow(int setIndex, int repIndex, Rep rep) {
    final isBad = thresholdWeight > 0 && rep.avgForceKg < thresholdWeight;
    final accent = isBad ? paleRed : dataAccent;
    final durationSec = rep.durationMs / 1000.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: webPanel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: webBorder.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            'S${setIndex + 1} R${repIndex + 1}',
            style: tsInterW600S13.copyWith(color: webMuted),
          ),
          Text(
            '${rep.peakForceKg.toStringAsFixed(1)} kg',
            style: tsGrotesk700S18.copyWith(color: accent),
          ),
          Text(
            '${durationSec.toStringAsFixed(1)}s',
            style: tsGrotesk600S14.copyWith(color: webMuted),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────── Completed view ──────────────────────────

class _CompletedView extends StatefulWidget {
  const _CompletedView({required this.session, required this.ref});

  final ActiveSessionState session;
  final WidgetRef ref;

  @override
  State<_CompletedView> createState() => _CompletedViewState();
}

class _CompletedViewState extends State<_CompletedView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.greenAccent.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Session Complete',
            style: tsInterW800S24.copyWith(color: webText),
          ),
          const SizedBox(height: 24),
          SessionSummaryCard(
            sets: widget.session.completedSets,
            peakWeightKg: widget.session.peakWeightKg,
            protocolType: widget.session.protocol.type,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () {
              widget.ref.read(sessionProvider.notifier).endSession();
              if (context.mounted) context.go('/');
            },
            icon: const Icon(Icons.home),
            label: const Text('Done'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(280, 56),
              textStyle: tsInterW700S18,
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
  // Truncate to tenths (floor) so every .0–.9 is displayed
  final tenths = ms ~/ 100;
  final totalSeconds = tenths ~/ 10;
  final fractional = tenths % 10;
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  if (minutes > 0) {
    return '$minutes:${seconds.toString().padLeft(2, '0')}.$fractional';
  }
  return '$seconds.$fractional';
}
