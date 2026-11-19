import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analysis/opengrips_curve.dart';
import '../models/training_models.dart';
import '../providers/navigation_provider.dart';
import '../providers/progressor_provider.dart';
import '../providers/training_provider.dart';
import '../theme.dart';
import 'connection_widgets.dart';
import 'schedule_widgets.dart';
import 'training_charts.dart';
import 'training_common.dart';

/// The OpenGrips workout timer, with the Crimpdeq as the weight.
class WorkoutTab extends ConsumerWidget {
  const WorkoutTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phase = ref.watch(workoutProvider.select((state) => state.phase));
    final isConnected = watchConnected(ref);
    return TrainingLogView(
      builder: (context, log) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isConnected && phase == WorkoutPhase.idle) ...[
            const ConnectCard(),
            const SizedBox(height: 16),
          ],
          switch (phase) {
            WorkoutPhase.idle => _WorkoutSetup(log: log),
            WorkoutPhase.done => const _WorkoutResults(),
            _ => const _WorkoutTimer(),
          },
        ],
      ),
    );
  }
}

String _howWorkoutsWork(double thresholdKg) =>
    'The workout type is suggested from your history: first the type with '
    'the fewest workouts, then the one whose first holds fall furthest below '
    'the ideal force curve.\n\n'
    'Tare the Crimpdeq unloaded before you start. Each hold waits for you, '
    'even after its rest: it counts down from its target while you pull more '
    'than ${formatKg(thresholdKg)}, and ends a second after you let go. '
    'Change the threshold in Customize. Pull close to the target force: the '
    'force you actually pull is what the workout records.\n\n'
    'If the first hold misses its target by more than $repToleranceSeconds s, '
    'the later targets scale with it. A rep that falls that short, such as a '
    'pull ended by accident, can be redone during the rest after it.\n\n'
    'Both hands train the same plan, each at its own benchmark, starting '
    'with the selected hand. In turn does every rep of one hand, then of the '
    'other. Alternate switches hands after each rep and holds the other hand '
    'during each rest, so it needs a rest longer than the longest hold, with '
    '${alternateMarginSeconds ~/ 2} s to change hands each way. Then each '
    'hand rests as planned.';

class _WorkoutSetup extends ConsumerWidget {
  const _WorkoutSetup({required this.log});

  final TrainingLog log;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final setup = ref.watch(workoutSetupProvider);
    final setupNotifier = ref.read(workoutSetupProvider.notifier);
    final tools = [
      for (final tool in trainingTools)
        if (log.benchmarks.any((benchmark) => benchmark.tool == tool)) tool,
    ];
    if (tools.isEmpty) {
      return const TitledCard(
        title: 'Record your first benchmark',
        child: RecordBenchmark(
          message:
              'Workout targets are fractions of your strongest 5-second '
              'pull. Record one with each tool and hand you train.',
        ),
      );
    }

    // The latest benchmark by default, so a new benchmark unlocks workouts.
    // Deleting the last benchmark of the selected tool removes it.
    final latest = log.benchmarks.last;
    final tool = tools.contains(setup.tool) ? setup.tool! : latest.tool;
    final hand = setup.hand ?? latest.hand;
    final benchmark = bestBenchmark(log.benchmarks, tool, hand);
    final thresholdKg = watchHoldThreshold(ref);
    final toolAndHand = ToolAndHand(
      tools: tools,
      tool: tool,
      hand: hand,
      onToolChanged: setupNotifier.selectTool,
      onHandChanged: setupNotifier.selectHand,
    );
    final info = InfoButton(
      title: 'How workouts work',
      content: _howWorkoutsWork(thresholdKg),
    );
    if (benchmark == null) {
      return TitledCard(
        title: 'Next workout',
        trailing: info,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            toolAndHand,
            const SizedBox(height: 16),
            RecordBenchmark(
              message:
                  'Record a benchmark for $tool with the ${hand.label} hand '
                  'to unlock its workouts.',
            ),
          ],
        ),
      );
    }

    final workouts = [
      for (final workout in log.workouts)
        if (workout.tool == tool && workout.hand == hand) ?workout.withPoint,
    ];
    final suggested = suggestSection([
      for (final (_, point) in workouts) point,
    ], benchmark.forceKg);
    final section = setup.section ?? suggested;
    // An edited plan follows the current best benchmark. A new benchmark or
    // workout can move the default tool, hand or section away from it.
    final edited = setup.plan;
    final defaults = WorkoutPlan.forSection(
      tool: tool,
      hand: hand,
      section: section,
      benchmarkKg: benchmark.forceKg,
    );
    final plan =
        edited != null &&
            edited.tool == tool &&
            edited.hand == hand &&
            edited.section == section
        ? edited.copyWith(benchmarkKg: benchmark.forceKg)
        : defaults;
    final sessions = [
      for (final (workout, point) in workouts.reversed)
        if (CurveSection.of(point.forceKg, benchmark.forceKg) == section)
          workout,
    ];
    final otherHand = Hand.values.firstWhere((other) => other != hand);
    final otherBenchmark = bestBenchmark(log.benchmarks, tool, otherHand);
    final bothHands = setup.hands != WorkoutHands.one;
    final alternating = setup.hands == WorkoutHands.alternating;
    // Both hands train the plan, each at its own benchmark.
    final plans = [
      plan,
      if (bothHands && otherBenchmark != null)
        plan.copyWith(hand: otherHand, benchmarkKg: otherBenchmark.forceKg),
    ];
    final missingOtherHand = bothHands && otherBenchmark == null;
    // Both hands share the targets and the rest.
    final alternateRest = alternateRestSeconds(plan);
    final canAlternate = plan.restSeconds >= alternateRest;
    final alternateBlocked = alternating && !canAlternate;
    final benchmarks = plans.length == 1
        ? '${formatKg(benchmark.forceKg)} benchmark'
        : '${[for (final plan in plans) '${plan.hand.label} ${formatKg(plan.benchmarkKg)}'].join(' and ')} '
              'benchmarks';
    // A hold only counts above the threshold, which a light target is not.
    final lightestKg = plans
        .map((plan) => plan.targetForceKg)
        .reduce((a, b) => a < b ? a : b);
    final holdsCount = lightestKg > thresholdKg;
    final benchmarkRecording = ref.watch(
      benchmarkRecorderProvider.select((recording) => recording.recording),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GripperRestCard(workouts: log.workouts, tool: tool),
        TitledCard(
          title: 'Next workout',
          trailing: info,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              toolAndHand,
              const SizedBox(height: 12),
              SegmentedButton<WorkoutHands>(
                segments: [
                  for (final hands in WorkoutHands.values)
                    ButtonSegment(
                      value: hands,
                      label: Text(hands.label),
                      enabled:
                          hands != WorkoutHands.alternating || canAlternate,
                    ),
                ],
                selected: {setup.hands},
                showSelectedIcon: false,
                onSelectionChanged: (selection) =>
                    setupNotifier.selectHands(selection.single),
              ),
              if (bothHands) ...[
                const SizedBox(height: 4),
                Text(
                  alternating
                      ? 'Each rep with the ${hand.label} hand, then the '
                            '${otherHand.label}: the other hand holds during '
                            'each rest.'
                      : 'Every rep with the ${hand.label} hand, then with '
                            'the ${otherHand.label}.',
                  style: textTheme.bodySmall,
                ),
                if (!canAlternate) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Alternate needs at least $alternateRest s of rest '
                    'between reps: the other hand\'s longest hold, '
                    '${formatDuration(alternateRest - alternateMarginSeconds)}, '
                    'and ${alternateMarginSeconds ~/ 2} s to change hands '
                    'each way. Raise the rest or shorten the first hold in '
                    'Customize.',
                    style: alternateBlocked
                        ? textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          )
                        : textTheme.bodySmall,
                  ),
                ],
              ],
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final option in CurveSection.values)
                    ChoiceChip(
                      avatar: Icon(Icons.circle, color: sectionColors[option]),
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(option.label),
                          if (option == suggested) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.auto_awesome, size: 14),
                          ],
                        ],
                      ),
                      tooltip: option == suggested
                          ? 'Suggested from your history'
                          : null,
                      selected: option == section,
                      showCheckmark: false,
                      onSelected: (_) => setupNotifier.selectSection(option),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      section.label,
                      style: textTheme.titleLarge?.copyWith(
                        color: sectionTextColor(context, section),
                      ),
                    ),
                  ),
                  if (section == suggested)
                    Text('Suggested', style: textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 8),
              StatRow([
                for (final plan in plans)
                  StatTile(
                    label: plans.length > 1
                        ? '${plan.hand.label} force'
                        : 'Force',
                    value: formatKg(plan.targetForceKg),
                  ),
                StatTile(
                  label: 'First hold',
                  value: formatDuration(plan.firstHangSeconds),
                ),
                StatTile(
                  label: 'Reps',
                  value: plans.length > 1 ? '2 × ${plan.reps}' : '${plan.reps}',
                ),
                StatTile(
                  label: 'Total',
                  value: formatClock(
                    workoutSeconds(plans, alternating: alternating),
                  ),
                ),
              ]),
              const SizedBox(height: 4),
              Text(
                '${(plan.targetForceKg / benchmark.forceKg * 100).round()}% '
                'of your $benchmarks.',
                style: textTheme.bodySmall,
              ),
              if (missingOtherHand) ...[
                const SizedBox(height: 12),
                RecordBenchmark(
                  message:
                      'Record a benchmark for $tool with the '
                      '${otherHand.label} hand to train both hands.',
                ),
              ],
              if (!holdsCount) ...[
                const SizedBox(height: 8),
                Text(
                  'The ${formatKg(lightestKg)} target is too light to '
                  'start a hold above ${formatKg(thresholdKg)}. Choose a '
                  'heavier workout type or a lower threshold.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
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
                      onPressed:
                          benchmarkRecording ||
                              !holdsCount ||
                              missingOtherHand ||
                              alternateBlocked ||
                              !watchConnected(ref)
                          ? null
                          : () => ref
                                .read(workoutProvider.notifier)
                                .start(plans, alternating: alternating),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start Workout'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Tare it unloaded first. Each hold starts when you pull more '
                'than ${formatKg(thresholdKg)}.',
                style: textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TitledCard(
          title: 'Rep targets',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TargetWorkoutGraph(targets: plan.targets(), section: section),
              _PlanSettings(
                plan: plan,
                section: section,
                edited: plan != defaults,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TitledCard(
          title: 'Force curve',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ForceCurveGraph(
                benchmarkKg: benchmark.forceKg,
                section: section,
                targetForceKg: plan.targetForceKg,
                workouts: [for (final (_, point) in workouts) point],
              ),
              const SizedBox(height: 12),
              Text(
                sessions.isEmpty
                    ? 'No ${section.label} workouts yet.'
                    : 'Latest ${section.label} workouts',
                style: textTheme.titleSmall,
              ),
              for (final workout in sessions.take(3))
                Text(
                  '${formatDate(workout.date)} · '
                  '${formatKg(workout.forceKg!)} · '
                  '${formatDuration(workout.meanHangSeconds.round())} '
                  'average hold',
                  style: textTheme.bodySmall,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The reps, rest and rep target shape, which few change.
class _PlanSettings extends ConsumerWidget {
  const _PlanSettings({
    required this.plan,
    required this.section,
    required this.edited,
  });

  final WorkoutPlan plan;
  final CurveSection section;

  /// Whether the plan differs from the section's defaults.
  final bool edited;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final setupNotifier = ref.read(workoutSetupProvider.notifier);
    final update = setupNotifier.updatePlan;
    final thresholdKg = watchHoldThreshold(ref);
    final energySystems = clampEnergySystems(
      plan.energySystems ?? section.energySystems,
    );
    void updateEnergySystems(EnergySystems systems) =>
        update(plan.copyWith(energySystems: clampEnergySystems(systems)));
    final powerEndurance = powerEnduranceRange(energySystems.endurance);
    final power = powerRange(energySystems.powerEndurance);

    return ExpansionTile(
      title: const Text('Customize'),
      subtitle: Text(
        edited
            ? 'Changed from the ${section.label} defaults'
            : 'First hold, reps, rest, threshold and rep targets',
        style: textTheme.bodySmall,
      ),
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
      shape: const Border(),
      children: [
        _SliderRow(
          label: 'First hold target: ${plan.firstHangSeconds} s',
          value: plan.firstHangSeconds.toDouble(),
          range: (min: 10, max: 300),
          step: 1,
          onChanged: (value) =>
              update(plan.copyWith(firstHangSeconds: value.round())),
        ),
        _SliderRow(
          label: 'Reps: ${plan.reps}',
          value: plan.reps.toDouble(),
          range: (min: 2, max: 20),
          step: 1,
          onChanged: (value) => update(plan.copyWith(reps: value.round())),
        ),
        _SliderRow(
          label: 'Rest between reps: ${plan.restSeconds} s',
          value: plan.restSeconds.toDouble(),
          range: (min: 5, max: 60),
          step: 1,
          onChanged: (value) =>
              update(plan.copyWith(restSeconds: value.round())),
        ),
        _SliderRow(
          label:
              'Hold threshold: ${formatKg(thresholdKg)} '
              '(the timer runs while you pull more)',
          value: thresholdKg,
          range: (min: 0.5, max: 10),
          step: 0.5,
          onChanged: ref.read(holdThresholdProvider.notifier).set,
        ),
        const SizedBox(height: 8),
        // The template and the energy systems are different formulas, so the
        // switch, not a slider's first move, changes the targets.
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Shape by energy systems'),
          subtitle: Text(
            plan.energySystems == null
                ? 'Off: the rep targets follow the ${section.label} '
                      'template.'
                : 'The rep targets follow the values below.',
            style: textTheme.bodySmall,
          ),
          value: plan.energySystems != null,
          onChanged: (on) => update(
            plan.copyWith(
              energySystems: on
                  ? clampEnergySystems(section.energySystems)
                  : null,
            ),
          ),
        ),
        if (plan.energySystems != null) ...[
          _SliderRow(
            label:
                'Power: ${energySystems.power.toStringAsFixed(2)} '
                '(rep 2 target as a fraction of the first hold)',
            value: energySystems.power,
            range: power,
            step: 0.01,
            onChanged: (value) => updateEnergySystems((
              power: value,
              powerEndurance: energySystems.powerEndurance,
              endurance: energySystems.endurance,
            )),
          ),
          _SliderRow(
            label:
                'Power-Endurance: '
                '${energySystems.powerEndurance.toStringAsFixed(2)} '
                '(how far the later reps fall)',
            value: energySystems.powerEndurance,
            range: powerEndurance,
            step: 0.01,
            onChanged: (value) => updateEnergySystems((
              power: energySystems.power,
              powerEndurance: value,
              endurance: energySystems.endurance,
            )),
          ),
          _SliderRow(
            label:
                'Endurance: ${energySystems.endurance.toStringAsFixed(2)} '
                '(the tail of the later reps)',
            value: energySystems.endurance,
            range: enduranceRange,
            step: 0.01,
            onChanged: (value) => updateEnergySystems((
              power: energySystems.power,
              powerEndurance: energySystems.powerEndurance,
              endurance: value,
            )),
          ),
        ],
        if (edited)
          TextButton.icon(
            onPressed: () => setupNotifier.selectSection(section),
            icon: const Icon(Icons.restart_alt),
            label: Text('Reset to the ${section.label} defaults'),
          ),
      ],
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.range,
    required this.step,
    required this.onChanged,
  });

  final String label;
  final double value;
  final Range range;
  final double step;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Slider(
          value: value.clamp(range.min, range.max),
          min: range.min,
          max: range.max,
          divisions: ((range.max - range.min) / step).round(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

/// A reading further from zero, unloaded, offsets every force.
const _unloadedToleranceKg = 0.5;

/// Readable from the hangboard: the phase in its color, a large clock and
/// the force, then the controls.
class _WorkoutTimer extends ConsumerWidget {
  const _WorkoutTimer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final workout = ref.watch(workoutProvider);
    final currentKg = ref.watch(
      progressorProvider.select((state) => state.measurement.currentKg),
    );
    final thresholdKg = watchHoldThreshold(ref);
    final notifier = ref.read(workoutProvider.notifier);
    final plan = workout.plan;
    final targets = workout.targetsOf(workout.current.plan);
    final bothHands = workout.plans.length > 1;
    final hand = bothHands ? '${plan.hand.label} hand · ' : '';
    final holdPhase = workout.phase == WorkoutPhase.hold;
    final phaseColor = holdPhase ? gainColor : colorScheme.primary;

    final String phase;
    final String reps;
    final String clock;
    final double progress;
    final Widget instruction;
    final Widget? warning;
    Widget? redo;
    if (holdPhase) {
      final target = workout.target;
      final remaining = target - workout.heldSeconds;
      phase = 'Hold';
      reps = '${hand}Rep ${workout.rep} of ${plan.reps}';
      // Counts down from the target while pulling, then up past it.
      clock = remaining >= 0
          ? formatClock(remaining.ceil())
          : '+${formatClock((-remaining).floor())}';
      progress = (workout.heldSeconds / target).clamp(0, 1);
      instruction = Text(
        workout.holding
            ? 'Hold ${formatClock(target)} at ${formatKg(plan.targetForceKg)}'
            : workout.waitingForRelease
            ? 'Release the Crimpdeq, then pull to start the timer'
            : bothHands
            ? '${plan.hand.label} hand: pull more than '
                  '${formatKg(thresholdKg)} to start the timer'
            : 'Pull more than ${formatKg(thresholdKg)} to start the timer',
        style: workout.holding
            ? textTheme.bodyLarge
            : textTheme.titleMedium?.copyWith(color: colorScheme.primary),
        textAlign: TextAlign.center,
      );
      warning = null;
    } else {
      final upcoming = workout.rep;
      final target = workout.target;
      final planned = plan.targets()[upcoming - 1];
      phase = 'Rest';
      reps = '${hand}Rep ${upcoming - 1} of ${plan.reps} done';
      clock = formatClock(workout.restRemainingSeconds);
      progress = 1 - workout.restRemainingSeconds / plan.restSeconds;
      instruction = Text(
        'Next: ${bothHands ? '${plan.hand.label} hand, ' : ''}'
        'rep $upcoming, ${formatClock(target)} at '
        '${formatKg(plan.targetForceKg)}'
        '${target == planned ? '' : ' (planned ${formatClock(planned)})'}',
        style: textTheme.bodyLarge,
        textAlign: TextAlign.center,
      );
      // A rep well short of its target may be a pull ended by accident, and a
      // first one scales the later targets: it can hold again.
      final (plan: lastPlan, rep: lastRep) =
          workout.schedule[workout.actualSeconds.length - 1];
      final lastHeld = workout.actualSeconds.last;
      final lastTarget = workout.targetsOf(lastPlan)[lastRep - 1];
      if (lastTarget - lastHeld > repToleranceSeconds) {
        redo = Tooltip(
          message:
              '${bothHands ? '${workout.plans[lastPlan].hand.label} hand, ' : ''}'
              'rep $lastRep held ${lastHeld.round()} s of $lastTarget s',
          child: OutlinedButton.icon(
            onPressed: notifier.redoRep,
            icon: const Icon(Icons.replay),
            label: Text('Redo Rep $lastRep'),
            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 56)),
          ),
        );
      }
      // A reading above the threshold through the rest is taken for a load
      // left on, which the next hold waits to drop.
      warning = (currentKg ?? 0) > thresholdKg
          ? Text(
              'The Crimpdeq reads more than ${formatKg(thresholdKg)} at '
              'rest, so the next hold waits for you to release it. Release '
              'it, or tare it unloaded.',
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
            )
          : (currentKg ?? 0).abs() > _unloadedToleranceKg
          ? Text(
              'It reads ${formatKg(currentKg!)} unloaded: tare it, so the '
              'forces start from zero.',
              style: textTheme.bodySmall,
            )
          : null;
    }

    final bigButton = FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(56),
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                PhasePill(label: phase, color: phaseColor),
                const SizedBox(width: 12),
                Expanded(child: Text(reps, style: textTheme.titleSmall)),
                const MuteButton(),
              ],
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                clock,
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
            instruction,
            const SizedBox(height: 12),
            LiveForceGraph(
              trace: workout.forceTrace,
              currentKg: currentKg,
              target: (
                kg: plan.targetForceKg,
                thresholdKg: thresholdKg,
                section: plan.section,
              ),
            ),
            ?warning,
            const SizedBox(height: 16),
            RepBars(
              targets: targets,
              actual: [
                ...workout.actualSecondsOf(workout.current.plan),
                if (holdPhase) workout.heldSeconds,
              ],
              color: sectionColors[plan.section]!,
            ),
            const SizedBox(height: 16),
            // Before the pull, ending the rep is the same as skipping it.
            if (holdPhase && workout.holding)
              FilledButton(
                onPressed: notifier.finishRep,
                style: bigButton,
                child: Text(
                  workout.heldSeconds < workout.target
                      ? 'Failed Early'
                      : 'Finished Now',
                ),
              )
            else if (!holdPhase)
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: notifier.togglePause,
                      style: bigButton,
                      icon: Icon(
                        workout.paused ? Icons.play_arrow : Icons.pause,
                      ),
                      label: Text(workout.paused ? 'Resume' : 'Pause'),
                    ),
                  ),
                  if (redo != null) ...[const SizedBox(width: 8), redo],
                ],
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmStop(context, notifier),
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: notifier.skip,
                    icon: const Icon(Icons.skip_next),
                    label: Text(holdPhase ? 'Skip Rep' : 'Skip Rest'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmStop(
    BuildContext context,
    WorkoutNotifier notifier,
  ) async {
    final stop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stop the workout?'),
        content: const Text('The workout so far is discarded.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continue'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Stop'),
          ),
        ],
      ),
    );
    if (stop ?? false) await notifier.stop();
  }
}

/// Perceived exertion labels, from 1 to 10.
const _effort = [
  'Very easy',
  'Easy',
  'Easy',
  'Moderate',
  'Moderate',
  'Hard',
  'Hard',
  'Very hard',
  'Very hard',
  'Maximal',
];

class _WorkoutResults extends ConsumerStatefulWidget {
  const _WorkoutResults();

  @override
  ConsumerState<_WorkoutResults> createState() => _WorkoutResultsState();
}

class _WorkoutResultsState extends ConsumerState<_WorkoutResults> {
  final _notes = TextEditingController();
  int _exertion = 5;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _discard(WorkoutNotifier notifier) async {
    if (await confirm(
      context,
      title: 'Discard the workout?',
      content: 'Its results do not reach the history.',
      action: 'Discard',
    )) {
      notifier.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final workout = ref.watch(workoutProvider);
    final notifier = ref.read(workoutProvider.notifier);
    final reps = workout.actualSeconds.length;

    return TitledCard(
      title: workout.endedEarly == null
          ? 'Workout complete'
          : 'Workout ended early',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (workout.endedEarly case final end?) ...[
            Text(
              'The Crimpdeq ${switch (end) {
                WorkoutEnd.disconnected => 'disconnected',
                WorkoutEnd.measurementFailed => 'stopped measuring',
              }} after rep $reps of ${workout.schedule.length}. You can '
              'still save the reps done.',
              style: textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
          ],
          for (final (index, plan) in workout.plans.indexed)
            if (workout.actualSecondsOf(index).isNotEmpty) ...[
              if (index > 0) const SizedBox(height: 16),
              _HandResults(
                plan: plan,
                targets: workout.targetsOf(index),
                actual: workout.actualSecondsOf(index),
                meanForceKg: workout.meanForceKgOf(index),
              ),
            ],
          const SizedBox(height: 16),
          Text(
            'Effort: $_exertion/10 · ${_effort[_exertion - 1]}',
            style: textTheme.titleSmall,
          ),
          Slider(
            value: _exertion.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: workout.saved
                ? null
                : (value) => setState(() => _exertion = value.round()),
          ),
          TextField(
            controller: _notes,
            enabled: !workout.saved,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Notes'),
          ),
          const SizedBox(height: 12),
          if (workout.saved) ...[
            Row(
              children: [
                const Icon(Icons.check_circle, color: gainColor, size: 18),
                const SizedBox(width: 8),
                Text('Saved to your history.', style: textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      notifier.reset();
                      ref
                          .read(trainingPageProvider.notifier)
                          .open(TrainingPage.history);
                    },
                    child: const Text('View History'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: notifier.reset,
                    child: const Text('Start New Workout'),
                  ),
                ),
              ],
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _discard(notifier),
                    child: const Text('Discard'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: () => notifier.save(
                      perceivedExertion: _exertion,
                      notes: _notes.text.trim(),
                    ),
                    icon: const Icon(Icons.save_alt),
                    label: const Text('Save Results'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// One hand's reps against their targets.
class _HandResults extends StatelessWidget {
  const _HandResults({
    required this.plan,
    required this.targets,
    required this.actual,
    required this.meanForceKg,
  });

  final WorkoutPlan plan;
  final List<int> targets;

  /// At least one rep.
  final List<double> actual;
  final double? meanForceKg;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final meanForceKg = this.meanForceKg;
    final meanActual = actual.reduce((a, b) => a + b) / actual.length;
    final meanTarget =
        targets.take(actual.length).reduce((a, b) => a + b) / actual.length;
    final meanDelta = meanActual - meanTarget;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${plan.section.label} · ${plan.tool} · ${plan.hand.label} hand',
          style: textTheme.titleSmall?.copyWith(
            color: sectionTextColor(context, plan.section),
          ),
        ),
        const SizedBox(height: 12),
        StatRow([
          StatTile(
            label: 'Force',
            value: meanForceKg == null ? '—' : formatKg(meanForceKg),
          ),
          StatTile(
            label: 'Hold',
            value: '${meanActual.round()} / ${meanTarget.round()} s',
          ),
          StatTile(
            label: 'Avg Δ',
            value: formatDelta(meanDelta, 's'),
            color: deltaColor(meanDelta),
          ),
          StatTile(
            label: 'Held',
            value:
                '${actual.where((seconds) => seconds > 0).length}'
                '/${actual.length}',
          ),
        ]),
        Text(
          meanForceKg == null
              ? 'No rep held.'
              : 'Target force ${formatKg(plan.targetForceKg)}.',
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        RepResultsGraph(
          targets: targets,
          actual: actual,
          section: plan.section,
        ),
        const SizedBox(height: 8),
        Table(
          columnWidths: const {0: FlexColumnWidth(1.2)},
          children: [
            TableRow(
              children: [
                for (final label in ['Rep', 'Target', 'Actual', 'Δ'])
                  Text(label, style: textTheme.bodySmall),
              ],
            ),
            for (final (rep, seconds) in actual.indexed)
              TableRow(
                children: [
                  Text('${rep + 1}'),
                  Text('${targets[rep]} s'),
                  Text('${seconds.round()} s'),
                  Text(
                    formatDelta(
                      (seconds.round() - targets[rep]).toDouble(),
                      's',
                    ),
                    style: TextStyle(
                      color: deltaColor(
                        (seconds.round() - targets[rep]).toDouble(),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
