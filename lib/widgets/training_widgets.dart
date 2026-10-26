import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analysis/hold_tracker.dart';
import '../analysis/opengrips_curve.dart';
import '../models/training_models.dart';
import '../providers/progressor_provider.dart';
import '../providers/training_provider.dart';

/// OpenGrips training with the Crimpdeq as the weight: benchmarks, the
/// workout timer and the workout history.
class TrainingTab extends ConsumerWidget {
  const TrainingTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(trainingLogProvider)) {
      AsyncData(value: final log) => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TitledCard(
              title: 'Workout',
              child: _Workout(log: log),
            ),
            const SizedBox(height: 16),
            _TitledCard(
              title: 'Benchmarks',
              child: _Benchmarks(benchmarks: log.benchmarks),
            ),
            const SizedBox(height: 16),
            _TitledCard(
              title: 'History',
              child: _History(workouts: log.workouts),
            ),
          ],
        ),
      ),
      AsyncError(:final error) => Center(
        child: Text('Could not load the training log: $error'),
      ),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}

String _kg(double kg) => '${kg.toStringAsFixed(1)} kg';

String _clock(int seconds) =>
    '${(seconds ~/ 60).toString().padLeft(2, '0')}:'
    '${(seconds % 60).toString().padLeft(2, '0')}';

String _date(DateTime date) => date.toLocal().toString().substring(0, 16);

class _TitledCard extends StatelessWidget {
  const _TitledCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _Workout extends ConsumerWidget {
  const _Workout({required this.log});

  final TrainingLog log;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(workoutProvider.select((state) => state.phase))) {
      WorkoutPhase.idle => _WorkoutSetup(log: log),
      WorkoutPhase.done => const _WorkoutResults(),
      _ => const _WorkoutTimer(),
    };
  }
}

class _ToolAndHand extends StatelessWidget {
  const _ToolAndHand({
    required this.tools,
    required this.tool,
    required this.hand,
    required this.onToolChanged,
    required this.onHandChanged,
  });

  final List<String> tools;
  final String? tool;
  final Hand? hand;
  final ValueChanged<String?> onToolChanged;
  final ValueChanged<Hand?> onHandChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: tool,
            decoration: const InputDecoration(labelText: 'Training tool'),
            items: [
              for (final tool in tools)
                DropdownMenuItem(value: tool, child: Text(tool)),
            ],
            onChanged: onToolChanged,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<Hand>(
            initialValue: hand,
            decoration: const InputDecoration(labelText: 'Hand'),
            items: [
              for (final hand in Hand.values)
                DropdownMenuItem(value: hand, child: Text(hand.label)),
            ],
            onChanged: onHandChanged,
          ),
        ),
      ],
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
        'Record a benchmark below first: the workout targets are fractions '
        'of it.',
      );
    }

    final tool = _tool;
    final hand = _hand;
    final benchmark = tool == null || hand == null
        ? null
        : bestBenchmark(log.benchmarks, tool, hand);
    final children = <Widget>[
      _ToolAndHand(
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
    if (tool == null || hand == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [...children, const Text('Select a tool and a hand.')],
      );
    }
    if (benchmark == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...children,
          Text('Record a benchmark for $tool with the ${hand.label} hand.'),
        ],
      );
    }

    final suggested = suggestSection([
      for (final workout in log.workouts)
        if (workout.tool == tool && workout.hand == hand) ?workout.curvePoint,
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
    final benchmarkRecording = ref.watch(
      benchmarkRecorderProvider.select((recording) => recording.recording),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...children,
        Text('Workout type', style: textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in CurveSection.values)
              ChoiceChip(
                label: Text(
                  option == suggested
                      ? '${option.label} · suggested'
                      : option.label,
                ),
                selected: option == section,
                onSelected: (_) => setState(() {
                  _section = option;
                  _plan = null;
                }),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Suggested from your history: the type with the fewest workouts, '
          'then the one whose first hangs fall furthest below the ideal '
          'force curve.',
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        Text(
          'Target force: ${_kg(plan.targetForceKg)} '
          '(benchmark ${_kg(benchmark.forceKg)})',
          style: textTheme.titleMedium,
        ),
        _SliderRow(
          label: 'First hang target: ${plan.firstHangSeconds} s',
          value: plan.firstHangSeconds,
          min: 10,
          max: 300,
          onChanged: (value) => update(plan.copyWith(firstHangSeconds: value)),
        ),
        _SliderRow(
          label: 'Reps: ${plan.reps}',
          value: plan.reps,
          min: 2,
          max: 20,
          onChanged: (value) => update(plan.copyWith(reps: value)),
        ),
        _SliderRow(
          label: 'Rest between reps: ${plan.restSeconds} s',
          value: plan.restSeconds,
          min: 5,
          max: 60,
          onChanged: (value) => update(plan.copyWith(restSeconds: value)),
        ),
        Text(
          'Rep targets: ${plan.targets().map((seconds) => '$seconds s').join(' · ')}',
        ),
        Text('Total time: ${_clock(plan.totalSeconds)}'),
        const SizedBox(height: 8),
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
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Slider(
          value: value.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: max - min,
          onChanged: (value) => onChanged(value.round()),
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
          ? 'Pull ≥ ${_kg(plan.targetForceKg * HoldTracker.thresholdRatio)}'
          : remaining >= 0
          ? _clock(remaining.ceil())
          : '+${_clock((-remaining).floor())}';
      details = [
        Text('Target: ${_clock(target)} at ${_kg(plan.targetForceKg)}'),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: ((currentKg ?? 0) / plan.targetForceKg).clamp(0, 1),
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
        ),
        const SizedBox(height: 4),
        Text('Force: ${currentKg == null ? '—' : _kg(currentKg)}'),
      ];
    } else {
      final upcoming = preRest ? 1 : workout.rep + 1;
      final target = targets[upcoming - 1];
      final planned = plan.targets()[upcoming - 1];
      title = preRest ? 'Pre-workout rest' : 'Rest after Rep ${workout.rep}';
      clock = _clock(workout.restRemainingSeconds);
      details = [
        Text(
          'Upcoming target (Rep $upcoming of ${plan.reps}): ${_clock(target)}'
          '${target == planned ? '' : ' (previously ${_clock(planned)})'}',
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
    final colorScheme = Theme.of(context).colorScheme;
    final workout = ref.watch(workoutProvider);
    final notifier = ref.read(workoutProvider.notifier);
    final targets = workout.targets;
    final actual = workout.actualSeconds;
    final meanForceKg = workout.meanForceKg;
    LineChartBarData line(
      List<num> seconds,
      Color color, {
      bool dashed = false,
    }) => LineChartBarData(
      spots: [
        for (final (rep, value) in seconds.indexed)
          FlSpot(rep + 1, value.toDouble()),
      ],
      color: color,
      barWidth: 2.5,
      dashArray: dashed ? [8, 6] : null,
      dotData: const FlDotData(show: true),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 180,
          child: LineChart(
            LineChartData(
              minY: 0,
              lineBarsData: [
                line(targets, colorScheme.secondary, dashed: true),
                line(actual, colorScheme.primary),
              ],
              titlesData: const FlTitlesData(
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, interval: 1),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    // The maximum is the longest hang, so its label would
                    // overlap the interval labels.
                    maxIncluded: false,
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Dashed: target · Solid: actual (s)',
          style: Theme.of(context).textTheme.bodySmall,
        ),
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
              : 'Mean force: ${_kg(meanForceKg)} '
                    '(target ${_kg(workout.plan!.targetForceKg)})',
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

class _Benchmarks extends ConsumerStatefulWidget {
  const _Benchmarks({required this.benchmarks});

  final List<Benchmark> benchmarks;

  @override
  ConsumerState<_Benchmarks> createState() => _BenchmarksState();
}

class _BenchmarksState extends ConsumerState<_Benchmarks> {
  String? _tool;
  Hand? _hand;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final recording = ref.watch(benchmarkRecorderProvider);
    final recorder = ref.read(benchmarkRecorderProvider.notifier);
    final currentKg = ref.watch(
      progressorProvider.select((state) => state.measurement.currentKg),
    );
    final workoutRunning = ref.watch(
      workoutProvider.select((state) => state.isRunning),
    );
    final tool = _tool;
    final hand = _hand;
    final bestKg = recording.bestKg;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Tare the Crimpdeq unloaded, then pull as hard as you can for at '
          'least 5 s. The benchmark is the highest mean force over 5 s: the '
          'weight you could hold for 5 s.',
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        _ToolAndHand(
          tools: trainingTools,
          tool: tool,
          hand: hand,
          onToolChanged: (tool) => setState(() => _tool = tool),
          onHandChanged: (hand) => setState(() => _hand = hand),
        ),
        const SizedBox(height: 12),
        Text(
          'Force: ${currentKg == null ? '—' : _kg(currentKg)} · '
          'Elapsed: ${recording.elapsedSeconds.toStringAsFixed(1)} s · '
          'Best 5 s: ${bestKg == null ? '—' : _kg(bestKg)}',
        ),
        if (!recording.recording &&
            recording.elapsedSeconds > 0 &&
            bestKg == null)
          const Text('Pull for at least 5 s.'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: recording.recording
                  ? FilledButton.icon(
                      onPressed: recorder.stop,
                      icon: const Icon(Icons.stop),
                      label: const Text('Stop'),
                    )
                  : FilledButton.icon(
                      onPressed: workoutRunning ? null : recorder.start,
                      icon: const Icon(Icons.fiber_manual_record),
                      label: const Text('Start Pull'),
                    ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed:
                    recording.recording ||
                        bestKg == null ||
                        tool == null ||
                        hand == null
                    ? null
                    : () async {
                        await ref
                            .read(trainingLogProvider.notifier)
                            .addBenchmark(
                              Benchmark(
                                date: DateTime.now(),
                                tool: tool,
                                hand: hand,
                                forceKg: bestKg,
                              ),
                            );
                        recorder.clear();
                      },
                child: const Text('Save Benchmark'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final benchmark in widget.benchmarks.reversed)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(
              '${benchmark.tool} · ${benchmark.hand.label}: '
              '${_kg(benchmark.forceKg)}',
            ),
            subtitle: Text(_date(benchmark.date)),
            trailing: IconButton(
              tooltip: 'Delete benchmark',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => ref
                  .read(trainingLogProvider.notifier)
                  .deleteBenchmark(benchmark),
            ),
          ),
      ],
    );
  }
}

class _History extends StatelessWidget {
  const _History({required this.workouts});

  final List<WorkoutRecord> workouts;

  @override
  Widget build(BuildContext context) {
    if (workouts.isEmpty) return const Text('No workouts yet.');
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final workout in workouts.reversed)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_date(workout.date)} · ${workout.tool} '
                  '${workout.hand.label} · ${workout.section.label}',
                  style: textTheme.titleSmall,
                ),
                Text(
                  'Force ${workout.forceKg == null ? '—' : _kg(workout.forceKg!)} '
                  '(target ${_kg(workout.targetForceKg)}) · '
                  'exertion ${workout.perceivedExertion}/10',
                ),
                Text(
                  'Hangs (actual/target s): ${[for (final (rep, seconds) in workout.actualSeconds.indexed) '${seconds.round()}/${workout.targetSeconds[rep]}'].join(' · ')}',
                ),
                if (workout.notes.isNotEmpty)
                  Text(workout.notes, style: textTheme.bodySmall),
              ],
            ),
          ),
      ],
    );
  }
}
