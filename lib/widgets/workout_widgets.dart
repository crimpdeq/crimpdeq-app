import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analysis/hold_tracker.dart';
import '../analysis/opengrips_curve.dart';
import '../models/training_models.dart';
import '../providers/progressor_provider.dart';
import '../providers/training_provider.dart';
import 'training_charts.dart';
import 'training_common.dart';

/// The OpenGrips workout timer, with the Crimpdeq as the weight.
class WorkoutTab extends ConsumerWidget {
  const WorkoutTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phase = ref.watch(workoutProvider.select((state) => state.phase));
    return TrainingLogView(
      builder: (context, log) => TitledCard(
        title: 'Workout Timer',
        child: switch (phase) {
          WorkoutPhase.idle => _WorkoutSetup(log: log),
          WorkoutPhase.done => const _WorkoutResults(),
          _ => const _WorkoutTimer(),
        },
      ),
    );
  }
}

class _WorkoutSetup extends ConsumerStatefulWidget {
  const _WorkoutSetup({required this.log});

  final TrainingLog log;

  @override
  ConsumerState<_WorkoutSetup> createState() => _WorkoutSetupState();
}

class _WorkoutSetupState extends ConsumerState<_WorkoutSetup> {
  // Null follows the latest benchmark, so a new benchmark unlocks workouts.
  String? _tool;
  Hand? _hand;
  // Null follows the suggestion.
  CurveSection? _section;
  // Null uses the section defaults.
  WorkoutPlan? _plan;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final log = widget.log;
    final tools = [
      for (final tool in trainingTools)
        if (log.benchmarks.any((benchmark) => benchmark.tool == tool)) tool,
    ];
    if (tools.isEmpty) {
      return const Text(
        'Record a benchmark in the Benchmarks tab first: the workout targets '
        'are fractions of it.',
      );
    }

    final latest = log.benchmarks.last;
    final tool = _tool ?? latest.tool;
    final hand = _hand ?? latest.hand;
    final benchmark = bestBenchmark(log.benchmarks, tool, hand);
    final children = <Widget>[
      ToolAndHand(
        tools: tools,
        tool: tool,
        hand: hand,
        onToolChanged: (tool) => setState(() {
          _tool = tool;
          _section = null;
          _plan = null;
        }),
        onHandChanged: (hand) => setState(() {
          _hand = hand;
          _section = null;
          _plan = null;
        }),
      ),
      const SizedBox(height: 12),
    ];
    if (benchmark == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...children,
          Text(
            'Record a benchmark for $tool with the ${hand.label} hand in the '
            'Benchmarks tab.',
          ),
        ],
      );
    }

    final workouts = [
      for (final workout in log.workouts)
        if (workout.tool == tool && workout.hand == hand) ?workout.withPoint,
    ];
    final suggested = suggestSection([
      for (final (_, point) in workouts) point,
    ], benchmark.forceKg);
    final section = _section ?? suggested;
    final plan =
        _plan ??
        WorkoutPlan.forSection(
          tool: tool,
          hand: hand,
          section: section,
          benchmarkKg: benchmark.forceKg,
        );
    void update(WorkoutPlan plan) => setState(() => _plan = plan);
    final energySystems = clampEnergySystems(
      plan.energySystems ?? section.energySystems,
    );
    void updateEnergySystems(EnergySystems systems) =>
        update(plan.copyWith(energySystems: clampEnergySystems(systems)));
    final powerEndurance = powerEnduranceRange(energySystems.endurance);
    final power = powerRange(energySystems.powerEndurance);
    final sessions = [
      for (final (workout, point) in workouts.reversed)
        if (CurveSection.of(point.forceKg, benchmark.forceKg) == section)
          workout,
    ];
    final benchmarkRecording = ref.watch(
      benchmarkRecorderProvider.select((recording) => recording.recording),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...children,
        Text('Target Workout Graph', style: textTheme.titleSmall),
        const SizedBox(height: 8),
        TargetWorkoutGraph(targets: plan.targets(), section: section),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 4,
          children: [
            Text('Force: ${formatKg(plan.targetForceKg)}'),
            Text('First hang: ${plan.firstHangSeconds} s'),
            Text('Reps: ${plan.reps}'),
            Text('Total time: ${formatClock(plan.totalSeconds)}'),
          ],
        ),
        Text(
          'The force is ${(plan.targetForceKg / benchmark.forceKg * 100).round()}% '
          'of your ${formatKg(benchmark.forceKg)} benchmark.',
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        Text('Workout Type: ${section.label}', style: textTheme.titleSmall),
        Text(
          'Suggested from your history: the type with the fewest workouts, '
          'then the one whose first hangs fall furthest below the ideal '
          'force curve.',
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in CurveSection.values)
              ChoiceChip(
                avatar: Icon(Icons.circle, color: sectionColors[option]),
                label: Text(
                  '${option.label} (${workouts.where((entry) => CurveSection.of(entry.$2.forceKg, benchmark.forceKg) == option).length})'
                  '${option == suggested ? ' · suggested' : ''}',
                ),
                selected: option == section,
                showCheckmark: false,
                onSelected: (_) => setState(() {
                  _section = option;
                  _plan = null;
                }),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (sessions.isEmpty)
          Text('No ${section.label} sessions yet.', style: textTheme.bodySmall)
        else
          for (final workout in sessions)
            Text(
              '${formatDate(workout.date)} · ${formatKg(workout.forceKg!)} · '
              '${formatDuration(workout.meanHangSeconds.round())} average hang',
              style: textTheme.bodySmall,
            ),
        ExpansionTile(
          title: const Text('Advanced Configuration'),
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
          shape: const Border(),
          children: [
            Text('Session Settings', style: textTheme.titleSmall),
            _SliderRow(
              label: 'First hang target: ${plan.firstHangSeconds} s',
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
            Text('Energy Systems', style: textTheme.titleSmall),
            Text(
              plan.energySystems == null
                  ? 'The rep targets follow the ${section.label} template. '
                        'Moving a slider shapes them with these values.'
                  : 'The rep targets follow these values.',
              style: textTheme.bodySmall,
            ),
            _SliderRow(
              label:
                  'Power: ${energySystems.power.toStringAsFixed(2)} '
                  '(rep 2 target as a fraction of the first hang)',
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
            if (plan.energySystems != null)
              TextButton(
                onPressed: () => update(plan.copyWith(energySystems: null)),
                child: Text('Use the ${section.label} template'),
              ),
          ],
        ),
        Text('Force Curve Graph', style: textTheme.titleSmall),
        const SizedBox(height: 8),
        ForceCurveGraph(
          benchmarkKg: benchmark.forceKg,
          section: section,
          targetForceKg: plan.targetForceKg,
          workouts: [for (final (_, point) in workouts) point],
        ),
        const SizedBox(height: 12),
        Text(
          'Tare the Crimpdeq unloaded first. A hang starts when the force '
          'reaches ${(HoldTracker.thresholdRatio * 100).round()}% of the '
          'target and ends after a second below it, so the timer adapts '
          'to the hangs you actually hold.',
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: benchmarkRecording
              ? null
              : () => ref.read(workoutProvider.notifier).start(plan),
          icon: const Icon(Icons.play_arrow),
          label: const Text('Start Workout'),
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

class _WorkoutTimer extends ConsumerWidget {
  const _WorkoutTimer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final workout = ref.watch(workoutProvider);
    final currentKg = ref.watch(
      progressorProvider.select((state) => state.measurement.currentKg),
    );
    final notifier = ref.read(workoutProvider.notifier);
    final plan = workout.plan!;
    final targets = workout.targets;
    final hanging = workout.phase == WorkoutPhase.hang;
    final preRest = workout.phase == WorkoutPhase.preRest;

    final String title;
    final String clock;
    final List<Widget> details;
    if (hanging) {
      final target = targets[workout.rep - 1];
      final remaining = target - workout.heldSeconds;
      title = 'Rep ${workout.rep} of ${plan.reps}';
      clock = !workout.holding
          ? 'Pull ≥ ${formatKg(plan.targetForceKg * HoldTracker.thresholdRatio)}'
          : remaining >= 0
          ? formatClock(remaining.ceil())
          : '+${formatClock((-remaining).floor())}';
      details = [
        Text(
          'Target: ${formatClock(target)} at ${formatKg(plan.targetForceKg)}',
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: ((currentKg ?? 0) / plan.targetForceKg).clamp(0, 1),
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
        ),
        const SizedBox(height: 4),
        Text('Force: ${currentKg == null ? '—' : formatKg(currentKg)}'),
      ];
    } else {
      final upcoming = preRest ? 1 : workout.rep + 1;
      final target = targets[upcoming - 1];
      final planned = plan.targets()[upcoming - 1];
      title = preRest ? 'Pre-workout rest' : 'Rest after Rep ${workout.rep}';
      clock = formatClock(workout.restRemainingSeconds);
      details = [
        Text(
          'Upcoming target (Rep $upcoming of ${plan.reps}): ${formatClock(target)}'
          '${target == planned ? '' : ' (previously ${formatClock(planned)})'}',
        ),
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: textTheme.titleMedium, textAlign: TextAlign.center),
        if (preRest) const Text('Starting in...', textAlign: TextAlign.center),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            clock,
            style: textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...details,
        const SizedBox(height: 16),
        if (hanging)
          FilledButton(
            onPressed: notifier.finishRep,
            child: Text(
              workout.heldSeconds < targets[workout.rep - 1]
                  ? 'Failed Early'
                  : 'Finished Now',
            ),
          )
        else
          FilledButton.icon(
            onPressed: notifier.togglePause,
            icon: Icon(workout.paused ? Icons.play_arrow : Icons.pause),
            label: Text(workout.paused ? 'Resume' : 'Pause'),
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
                label: Text(hanging ? 'Skip Rep' : 'Skip Rest'),
              ),
            ),
          ],
        ),
      ],
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

class _WorkoutResults extends ConsumerStatefulWidget {
  const _WorkoutResults();

  @override
  ConsumerState<_WorkoutResults> createState() => _WorkoutResultsState();
}

class _WorkoutResultsState extends ConsumerState<_WorkoutResults> {
  final _notes = TextEditingController();
  int _exertion = 5;
  bool _confirmLeave = false;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workout = ref.watch(workoutProvider);
    final notifier = ref.read(workoutProvider.notifier);
    final targets = workout.targets;
    final actual = workout.actualSeconds;
    final meanForceKg = workout.meanForceKg;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RepResultsGraph(targets: targets, actual: actual),
        const SizedBox(height: 8),
        for (final (rep, seconds) in actual.indexed)
          Text(
            'Rep ${rep + 1}: target ${targets[rep]} s · actual '
            '${seconds.round()} s · Δ ${_signed(seconds.round() - targets[rep])} s',
          ),
        const SizedBox(height: 8),
        Text(
          meanForceKg == null
              ? 'No rep held.'
              : 'Mean force: ${formatKg(meanForceKg)} '
                    '(target ${formatKg(workout.plan!.targetForceKg)})',
        ),
        const SizedBox(height: 12),
        Text('Perceived exertion: $_exertion/10'),
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
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: workout.saved
                    ? null
                    : () => notifier.save(
                        perceivedExertion: _exertion,
                        notes: _notes.text.trim(),
                      ),
                child: Text(workout.saved ? 'Results Saved' : 'Save Results'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  if (!workout.saved && !_confirmLeave) {
                    setState(() => _confirmLeave = true);
                    return;
                  }
                  notifier.reset();
                },
                child: Text(
                  _confirmLeave ? 'Leave without saving?' : 'Start New Workout',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static String _signed(int value) => value > 0 ? '+$value' : '$value';
}
