import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analysis/opengrips_curve.dart';
import '../analysis/warmup.dart';
import '../models/training_models.dart';
import '../providers/navigation_provider.dart';
import '../providers/progressor_provider.dart';
import '../providers/training_provider.dart';
import '../providers/warmup_provider.dart';
import '../theme.dart';
import 'connection_widgets.dart';
import 'training_charts.dart';
import 'training_common.dart';

/// Warm-ups before climbing and before gripper training, and the readiness
/// checks after a climbing warm-up.
class WarmupTab extends ConsumerWidget {
  const WarmupTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phase = ref.watch(warmupProvider.select((state) => state.phase));
    final isConnected = watchConnected(ref);
    if (phase == WorkoutPhase.hold || phase == WorkoutPhase.rest) {
      return const TimerLayout(child: _WarmupTimer());
    }
    return TrainingLogView(
      builder: (context, log) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isConnected && phase == WorkoutPhase.idle) ...[
            const ConnectCard(),
            const SizedBox(height: 16),
          ],
          if (phase == WorkoutPhase.idle)
            _WarmupSetup(log: log)
          else
            _WarmupResults(log: log),
          if (phase == WorkoutPhase.idle) ...[
            const SizedBox(height: 16),
            _ReadinessHistory(
              checks: log.readiness,
              benchmarks: log.benchmarks,
            ),
          ],
        ],
      ),
    );
  }
}

const _howWarmupsWork =
    'Each hold is a fraction of your benchmark for that tool and hand, and '
    'alternates the hands, so one rests while the other holds. Each hand '
    'rests at least 15 s between its holds: the next hold starts when you '
    'pull, once its hand has rested. The forces climb while the holds '
    'shorten, and no hold goes near failure: it ends at its target. Pull '
    'close to the target force.\n\n'
    'Before climbing: Spark, the larger muscle, then Photon, the fingertips '
    'for small holds. Then rest 10 min, climb easy moves, rest 10 min more, '
    'and go for your hardest attempts.\n\n'
    'Before training: a ramp on the tool you train. A heavy session, such '
    'as Power/Strength, Power or a benchmark, adds a short hold at 85%.\n\n'
    'Adapted from the GripGains warm-up for the Hand of God grippers. The '
    'values are starting points, not validated ones: stop if anything hurts.';

class _WarmupSetup extends ConsumerStatefulWidget {
  const _WarmupSetup({required this.log});

  final TrainingLog log;

  @override
  ConsumerState<_WarmupSetup> createState() => _WarmupSetupState();
}

class _WarmupSetupState extends ConsumerState<_WarmupSetup> {
  WarmupKind _kind = WarmupKind.climbing;
  // Null follows the next workout's section.
  bool? _heavy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final benchmarks = widget.log.benchmarks;
    // The workout's tool, which the training warm-up prepares for, and its
    // section, which makes it a heavy session.
    final setup = ref.watch(workoutSetupProvider);
    final tool =
        setup.tool ?? benchmarks.lastOrNull?.tool ?? trainingTools.first;
    final hand = setup.hand ?? benchmarks.lastOrNull?.hand;
    final nextSection =
        setup.section ??
        (hand == null
            ? null
            : suggestedSection(benchmarks, widget.log.workouts, tool, hand));
    final heavyNext = const {
      CurveSection.powerStrength,
      CurveSection.power,
    }.contains(nextSection);
    final heavy = _heavy ?? heavyNext;
    final thresholdKg = watchHoldThreshold(ref);
    final missing = missingBenchmarks(
      benchmarks,
      _kind == WarmupKind.climbing ? trainingTools : [tool],
    );
    final steps = missing.isNotEmpty
        ? null
        : _kind == WarmupKind.climbing
        ? climbingWarmup(benchmarks)
        : trainingWarmup(benchmarks, tool, heavy: heavy);
    // A hold only counts above the threshold, which a light force is not.
    final lightestKg = steps
        ?.map((step) => step.forceKg!)
        .reduce((a, b) => a < b ? a : b);
    final holdsCount = lightestKg != null && lightestKg > thresholdKg;
    final blocked = watchStartBlocked(ref);

    return TitledCard(
      title: 'Warm-up',
      trailing: const InfoButton(
        title: 'How warm-ups work',
        content: _howWarmupsWork,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<WarmupKind>(
            segments: [
              for (final kind in [WarmupKind.climbing, WarmupKind.training])
                ButtonSegment(value: kind, label: Text(kind.label)),
            ],
            selected: {_kind},
            showSelectedIcon: false,
            onSelectionChanged: (selection) =>
                setState(() => _kind = selection.single),
          ),
          if (_kind == WarmupKind.training) ...[
            const SizedBox(height: 12),
            ToolAndHand(
              tools: trainingTools,
              tool: tool,
              onToolChanged: ref.read(workoutSetupProvider.notifier).selectTool,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Heavy session'),
              subtitle: Text(
                'Before Power/Strength, Power or a benchmark: adds 3 s at '
                '85%.${heavyNext && _heavy == null ? ' On for your next ${nextSection!.label} workout.' : ''}',
                style: textTheme.bodySmall,
              ),
              value: heavy,
              onChanged: (heavy) => setState(() => _heavy = heavy),
            ),
          ],
          const SizedBox(height: 16),
          if (steps == null)
            RecordBenchmark(
              message:
                  'The forces are fractions of your benchmarks. Record one '
                  'for ${[for (final (tool, hand) in missing) '$tool ${hand.label}'].join(', ')}.',
            )
          else ...[
            StatRow([
              StatTile(label: 'Holds', value: '${steps.length}'),
              StatTile(
                label: 'Total',
                value: formatClock(warmupSeconds(steps)),
              ),
            ]),
            const SizedBox(height: 8),
            _StepTable(steps: steps),
            if (!holdsCount) ...[
              const SizedBox(height: 8),
              Text(
                'The lightest hold, ${formatKg(lightestKg!)}, is too light to '
                'start above ${formatKg(thresholdKg)}. Lower the threshold in '
                'Settings, in the menu.',
                style: textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                const TareButton(),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: blocked != null || !holdsCount
                        ? null
                        : () => ref
                              .read(warmupProvider.notifier)
                              .start(_kind, steps),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Warm-up'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              blocked ??
                  'Tare it unloaded first. Each hold starts when you pull '
                      'more than ${formatKg(thresholdKg)} and ends at its '
                      'target.',
              style: blocked == null
                  ? textTheme.bodySmall
                  : textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// The holds by level: each level holds the left hand, then the right one.
class _StepTable extends StatelessWidget {
  const _StepTable({required this.steps});

  final List<WarmupStep> steps;

  @override
  Widget build(BuildContext context) {
    final small = Theme.of(context).textTheme.bodySmall;
    return Table(
      children: [
        TableRow(
          children: [
            for (final label in ['Tool', 'Force', 'Hold', 'Left', 'Right'])
              Text(label, style: small),
          ],
        ),
        for (var i = 0; i + 1 < steps.length; i += 2)
          TableRow(
            children: [
              Text(steps[i].tool),
              Text(
                '${(steps[i].forceKg! / steps[i].benchmarkKg * 100).round()}%',
              ),
              Text('${steps[i].seconds} s'),
              Text(formatKg(steps[i].forceKg!)),
              Text(formatKg(steps[i + 1].forceKg!)),
            ],
          ),
      ],
    );
  }
}

/// Readable from the grip: the phase in its color, the tool and hand, a
/// large clock and the force, then the controls. Fills the height, the graph
/// taking what is left.
class _WarmupTimer extends ConsumerWidget {
  const _WarmupTimer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final warmup = ref.watch(warmupProvider);
    final currentKg = ref.watch(
      progressorProvider.select((state) => state.measurement.currentKg),
    );
    final thresholdKg = watchHoldThreshold(ref);
    final notifier = ref.read(warmupProvider.notifier);
    final step = warmup.current;
    final forceKg = step.forceKg;
    final holdPhase = warmup.phase == WorkoutPhase.hold;
    final phaseColor = holdPhase ? gainColor : colorScheme.primary;
    final force = forceKg == null
        ? 'as hard as you can'
        : 'at ${formatKg(forceKg)} '
              '(${(forceKg / step.benchmarkKg * 100).round()}%)';

    final String clock;
    final double progress;
    final String instruction;
    String? warning;
    final previous = warmup.step == 0 ? null : warmup.steps[warmup.step - 1];
    final take = previous == null || previous.tool != step.tool
        ? 'Take ${step.tool}. '
        : '';
    if (holdPhase) {
      final remaining = step.seconds - warmup.heldSeconds;
      clock = formatClock(remaining.ceil());
      progress = (warmup.heldSeconds / step.seconds).clamp(0, 1);
      instruction = warmup.holding
          ? 'Hold ${formatClock(step.seconds)} $force'
          : warmup.waitingForRelease
          ? '${take}Release the Crimpdeq, then pull with the '
                '${step.hand.label.toLowerCase()} hand'
          : '$take${step.hand.label} hand: pull more than '
                '${formatKg(thresholdKg)} to start the timer';
      if (warmup.overshooting) {
        warning =
            'Ease off to ${formatKg(forceKg!)}: a warm-up stays far from '
            'your max.';
      }
    } else {
      clock = formatClock(warmup.restRemainingSeconds);
      progress = 1 - warmup.restRemainingSeconds / step.restSeconds;
      instruction =
          '${take}Next: ${step.hand.label} hand, ${formatClock(step.seconds)} '
          '$force';
    }

    final bigButton = FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(56),
    );
    final graph = LiveForceGraph(
      trace: warmup.forceTrace,
      currentKg: currentKg,
      target: forceKg == null
          ? null
          : (
              kg: forceKg,
              thresholdKg: thresholdKg,
              section: CurveSection.of(forceKg, step.benchmarkKg),
            ),
      fill: true,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                PhasePill(
                  label: !holdPhase
                      ? 'Rest'
                      : forceKg == null
                      ? 'Max pull'
                      : 'Hold',
                  color: phaseColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${warmup.kind!.label} · '
                    'step ${warmup.step + 1} of ${warmup.steps.length}',
                    style: textTheme.titleSmall,
                  ),
                ),
                const MuteButton(),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${step.tool} · ${step.hand.label} hand',
              style: textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            // Large already, so the text scale would only push the
            // controls off the screen.
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                clock,
                textScaler: TextScaler.noScaling,
                style: textTheme.displayLarge?.copyWith(
                  fontFamily: interFont,
                  fontWeight: FontWeight.w800,
                  fontSize: 88,
                  color: phaseColor,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                color: phaseColor,
                backgroundColor: colorScheme.outlineVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              instruction,
              style: holdPhase && !warmup.holding
                  ? textTheme.titleMedium?.copyWith(color: colorScheme.primary)
                  : textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Expanded(child: graph),
            if (warning != null)
              Text(
                warning,
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
              ),
            const SizedBox(height: 16),
            if (!holdPhase) ...[
              FilledButton.icon(
                onPressed: notifier.togglePause,
                style: bigButton,
                icon: Icon(warmup.paused ? Icons.play_arrow : Icons.pause),
                label: Text(warmup.paused ? 'Resume' : 'Pause'),
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      if (await confirm(
                        context,
                        title: 'Stop the warm-up?',
                        content: warmup.kind == WarmupKind.readiness
                            ? 'The readiness check so far is discarded.'
                            : 'The warm-up ends here.',
                        action: 'Stop',
                      )) {
                        await notifier.stop();
                      }
                    },
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: notifier.skip,
                    icon: const Icon(Icons.skip_next),
                    label: Text(holdPhase ? 'Skip Hold' : 'Skip Rest'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _percent(double kg, double benchmarkKg) =>
    '${(kg / benchmarkKg * 100).round()}%';

class _WarmupResults extends ConsumerWidget {
  const _WarmupResults({required this.log});

  final TrainingLog log;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final warmup = ref.watch(warmupProvider);
    final notifier = ref.read(warmupProvider.notifier);
    final kind = warmup.kind!;
    final readiness = kind == WarmupKind.readiness;
    // Both would take the same samples.
    final benchmarkRecording = ref.watch(
      benchmarkRecorderProvider.select((recording) => recording.recording),
    );

    return TitledCard(
      title: warmup.endedEarly != null
          ? '${kind.label} ended early'
          : readiness
          ? 'Readiness check complete'
          : 'Warm-up complete',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (warmup.endedEarly case final end?) ...[
            Text(
              '${switch (end) {
                WorkoutEnd.disconnected => 'The Crimpdeq disconnected',
                WorkoutEnd.measurementFailed => 'The Crimpdeq stopped measuring',
                WorkoutEnd.stopped => 'You stopped',
              }} after ${warmup.bestKg.length} of ${warmup.steps.length} '
              'holds.',
              style: textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
          ],
          switch (kind) {
            WarmupKind.training when warmup.endedEarly == null => Column(
              children: [
                Text(
                  warmup.restRemainingSeconds > 0
                      ? 'Rest before your workout'
                      : 'Rested: start your workout.',
                  style: textTheme.titleMedium,
                ),
                Text(
                  formatClock(warmup.restRemainingSeconds),
                  style: textTheme.displayMedium?.copyWith(
                    fontFamily: interFont,
                    fontWeight: FontWeight.w800,
                    color: warmup.restRemainingSeconds > 0
                        ? theme.colorScheme.primary
                        : gainColor,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            WarmupKind.training => const Text('Rest, then start your workout.'),
            WarmupKind.climbing => const Text(
              'Rest 10 min, climb easy moves for 20 to 30 min, rest 10 min '
              'more, then go for your hardest attempts.\n\n'
              'A readiness check rests 3 min, then pulls Photon as hard as '
              'you can for 6 s with each hand, against your benchmarks.',
            ),
            WarmupKind.readiness => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (index, step) in warmup.steps.indexed)
                  if (index < warmup.bestKg.length)
                    Text(switch (warmup.bestKg[index]) {
                      final kg? =>
                        '${step.hand.label}: '
                            '${_percent(kg, step.benchmarkKg)} '
                            'of your benchmark, ${formatKg(kg)} of '
                            '${formatKg(step.benchmarkKg)}',
                      null =>
                        '${step.hand.label}: held under 5 s, not measured',
                    }, style: textTheme.titleSmall),
                const SizedBox(height: 8),
                Text(
                  warmup.saved
                      ? 'Saved to your readiness history.'
                      : warmup.bestKg.every((kg) => kg == null)
                      ? 'No pull of 5 s to save.'
                      : 'Saving…',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          },
          const SizedBox(height: 16),
          switch (kind) {
            WarmupKind.training => Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: notifier.reset,
                    child: const Text('Done'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  // The rest keeps counting on the Workout page, until the
                  // workout starts.
                  child: FilledButton(
                    onPressed: () => ref
                        .read(trainingPageProvider.notifier)
                        .open(TrainingPage.workout),
                    child: const Text('Go to Workout'),
                  ),
                ),
              ],
            ),
            WarmupKind.climbing => Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: notifier.reset,
                    child: const Text('Done'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed:
                        !benchmarkRecording &&
                            watchConnected(ref) &&
                            missingBenchmarks(log.benchmarks, [
                              readinessTool,
                            ]).isEmpty
                        ? () => notifier.start(
                            WarmupKind.readiness,
                            readinessCheck(log.benchmarks),
                          )
                        : null,
                    icon: const Icon(Icons.speed),
                    label: const Text('Readiness Check'),
                  ),
                ),
              ],
            ),
            WarmupKind.readiness => FilledButton(
              onPressed: notifier.reset,
              child: const Text('Done'),
            ),
          },
        ],
      ),
    );
  }
}

/// The rest after a training warm-up, counting down on the Workout page.
/// Nothing once it is over.
class WarmupRestCard extends ConsumerWidget {
  const WarmupRestCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remaining = ref.watch(
      warmupProvider.select(
        (warmup) =>
            warmup.kind == WarmupKind.training &&
                warmup.phase == WorkoutPhase.done &&
                warmup.endedEarly == null
            ? warmup.restRemainingSeconds
            : 0,
      ),
    );
    if (remaining <= 0) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.local_fire_department, color: colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Rest after the warm-up',
                      style: textTheme.titleSmall,
                    ),
                  ),
                  Text(
                    formatClock(remaining),
                    style: textTheme.headlineSmall?.copyWith(
                      color: colorScheme.primary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: 1 - remaining / workoutRestSeconds,
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The readiness checks, newest first, each hand against its benchmark and
/// the previous check.
class _ReadinessHistory extends ConsumerWidget {
  const _ReadinessHistory({required this.checks, required this.benchmarks});

  final List<ReadinessCheck> checks;
  final List<Benchmark> benchmarks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final missing = missingBenchmarks(benchmarks, [readinessTool]);
    final blocked = watchStartBlocked(ref);
    return TitledCard(
      title: 'Readiness',
      trailing: const InfoButton(
        title: 'About readiness',
        content:
            'A readiness check pulls Photon as hard as you can with each '
            'hand, best after a climbing warm-up, which offers one. Its best '
            '5 s, as a share of your benchmark then, shows how ready your '
            'fingers are: lower when tired, higher when fresh. Checks do not '
            'change your benchmarks or workouts.',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (checks.isEmpty)
            const Text(
              'No readiness checks yet. Run one after a climbing warm-up.',
            ),
          for (final (index, check) in checks.indexed.toList().reversed)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('${check.tool} · ${formatDate(check.date)}'),
              subtitle: Text(
                [
                  for (final pull in check.pulls)
                    '${pull.hand.label} ${_percent(pull.forceKg, pull.benchmarkKg)} '
                        '(${formatKg(pull.forceKg)})'
                        '${_vsPrevious(pull, checks.sublist(0, index))}',
                ].join('\n'),
                style: textTheme.bodyMedium,
              ),
              trailing: IconButton(
                tooltip: 'Delete readiness check',
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  if (await confirm(
                    context,
                    title: 'Delete the readiness check?',
                    content: formatDate(check.date),
                    action: 'Delete',
                  )) {
                    await ref
                        .read(trainingLogProvider.notifier)
                        .deleteReadiness(check);
                  }
                },
              ),
            ),
          const SizedBox(height: 12),
          // Also on its own, such as after warming up on the wall.
          OutlinedButton.icon(
            onPressed: blocked == null && missing.isEmpty
                ? () => ref
                      .read(warmupProvider.notifier)
                      .start(WarmupKind.readiness, readinessCheck(benchmarks))
                : null,
            icon: const Icon(Icons.speed),
            label: const Text('Check Readiness'),
          ),
          const SizedBox(height: 4),
          Text(
            missing.isNotEmpty
                ? 'Record a $readinessTool benchmark with each hand to check '
                      'readiness.'
                : blocked ??
                      'Warm up first: each hand pulls as hard as it can.',
            style: textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Change of the share of the benchmark since the latest earlier pull with
  /// the same hand, in percentage points.
  static String _vsPrevious(ReadinessPull pull, List<ReadinessCheck> earlier) {
    for (final check in earlier.reversed) {
      for (final previous in check.pulls) {
        if (previous.hand != pull.hand) continue;
        final points =
            ((pull.forceKg / pull.benchmarkKg -
                        previous.forceKg / previous.benchmarkKg) *
                    100)
                .round();
        return ' · ${points > 0 ? '+' : ''}$points pts vs previous';
      }
    }
    return '';
  }
}
