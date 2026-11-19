import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analysis/hold_tracker.dart';
import '../analysis/opengrips_curve.dart';
import '../models/training_models.dart';
import '../providers/navigation_provider.dart';
import '../providers/progressor_provider.dart';
import '../providers/training_provider.dart';
import 'connection_widgets.dart';
import 'training_charts.dart';
import 'training_common.dart';

/// The lightest benchmark with a workout whose holds count: the Power target,
/// the balanced force, must pull more than the hold threshold.
double _minBenchmarkKg(double thresholdKg) => thresholdKg / balancedRatio;

/// OpenGrips benchmarks: the highest force held for 5 s with each tool and
/// hand. The first one for a tool and hand unlocks its workouts.
class BenchmarksTab extends ConsumerWidget {
  const BenchmarksTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected = watchConnected(ref);
    return TrainingLogView(
      builder: (context, log) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isConnected) ...[
            const ConnectCard(),
            const SizedBox(height: 16),
          ],
          const TitledCard(
            title: 'New benchmark',
            trailing: InfoButton(
              title: 'About benchmarks',
              content:
                  'A benchmark is the highest force you can hold for 5 s '
                  'with one tool and hand. The workout targets are fractions '
                  'of your best one, so record a new benchmark as you get '
                  'stronger.\n\n'
                  'A weight held for longer than 5 s counts as the higher '
                  'weight you could hold for 5 s on the ideal force curve.',
            ),
            child: _AddBenchmark(),
          ),
          if (log.benchmarks.isEmpty) ...[
            const SizedBox(height: 16),
            const TitledCard(
              title: 'Your benchmarks',
              child: Text(
                'No benchmarks yet. Your first one unlocks workouts.',
              ),
            ),
          ],
          for (final tool in trainingTools)
            if ([
                  for (final benchmark in log.benchmarks)
                    if (benchmark.tool == tool) benchmark,
                ]
                case final benchmarks when benchmarks.isNotEmpty) ...[
              const SizedBox(height: 16),
              _ToolBenchmarks(tool: tool, benchmarks: benchmarks),
            ],
        ],
      ),
    );
  }
}

/// The hand without a benchmark of a tool trained, or the other hand of the
/// latest benchmark. Null without benchmarks, before a first choice.
({String tool, Hand hand})? _nextBenchmark(List<Benchmark> benchmarks) {
  final latest = benchmarks.lastOrNull;
  if (latest == null) return null;
  for (final tool in {for (final benchmark in benchmarks) benchmark.tool}) {
    for (final hand in Hand.values) {
      if (!benchmarks.any(
        (benchmark) => benchmark.tool == tool && benchmark.hand == hand,
      )) {
        return (tool: tool, hand: hand);
      }
    }
  }
  return (
    tool: latest.tool,
    hand: Hand.values.firstWhere((hand) => hand != latest.hand),
  );
}

class _AddBenchmark extends ConsumerStatefulWidget {
  const _AddBenchmark();

  @override
  ConsumerState<_AddBenchmark> createState() => _AddBenchmarkState();
}

class _AddBenchmarkState extends ConsumerState<_AddBenchmark> {
  final _weightKg = TextEditingController();
  final _heldSeconds = TextEditingController(text: '5');

  @override
  void dispose() {
    _weightKg.dispose();
    _heldSeconds.dispose();
    super.dispose();
  }

  Future<void> _save(String tool, Hand hand, double forceKg) async {
    final messenger = ScaffoldMessenger.of(context);
    final pages = ref.read(trainingPageProvider.notifier);
    final benchmark = Benchmark(
      date: DateTime.now(),
      tool: tool,
      hand: hand,
      forceKg: forceKg,
    );
    await ref.read(trainingLogProvider.notifier).addBenchmark(benchmark);
    // The tool and hand follow the next suggestion together, such as the
    // other hand, so the next pull is not saved for an unintended pair.
    ref.read(benchmarkSelectionProvider.notifier).clear();
    // Replaces a pending error instead of waiting behind it.
    messenger
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Benchmark saved: ${benchmark.tool} ${benchmark.hand.label} '
            '${formatKg(forceKg)}. Its workouts are unlocked.',
          ),
          action: SnackBarAction(
            label: 'Open Workout',
            onPressed: () => pages.open(TrainingPage.workout),
          ),
          // With an action it would stay until dismissed; the action is a
          // shortcut, so it times out like the other messages.
          persist: false,
        ),
      );
  }

  static double? _parse(TextEditingController field) =>
      double.tryParse(field.text.trim().replaceAll(',', '.'));

  /// The weight entered, null until it is one.
  double? get _weightEnteredKg => switch (_parse(_weightKg)) {
    final kg? when kg > 0 => kg,
    _ => null,
  };

  Future<void> _saveHold(
    String tool,
    Hand hand,
    double weightKg,
    double minBenchmarkKg,
  ) async {
    final heldSeconds = _parse(_heldSeconds);
    if (heldSeconds == null || heldSeconds < 5) {
      _showError('The hold must last at least 5 s.');
      return;
    }
    final benchmarkKg = deriveBenchmarkKg(weightKg, heldSeconds);
    if (benchmarkKg <= minBenchmarkKg) {
      _showError(
        'The hold is a ${formatKg(benchmarkKg)} benchmark. A workout needs '
        'more than ${formatKg(minBenchmarkKg)}.',
      );
      return;
    }
    await _save(tool, hand, benchmarkKg);
    _weightKg.clear();
    _heldSeconds.text = '5';
  }

  void _showError(String message) => ScaffoldMessenger.of(context)
    ..removeCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final recording = ref.watch(benchmarkRecorderProvider);
    final recorder = ref.read(benchmarkRecorderProvider.notifier);
    final measurement = ref.watch(
      progressorProvider.select(
        (state) => (
          isMeasuring: state.measurement.isMeasuring,
          currentKg: state.measurement.currentKg,
        ),
      ),
    );
    final workoutRunning = ref.watch(
      workoutProvider.select((state) => state.isRunning),
    );
    // By default the likeliest next tool and hand: the first without a
    // benchmark, or the other hand of the latest one.
    final selection = ref.watch(benchmarkSelectionProvider);
    final benchmarks = ref.watch(trainingLogProvider).value?.benchmarks;
    final next = benchmarks == null ? null : _nextBenchmark(benchmarks);
    final tool = selection.tool ?? next?.tool;
    final hand = selection.hand ?? next?.hand;
    final selector = ref.read(benchmarkSelectionProvider.notifier);
    final bestKg = recording.bestKg;
    final minBenchmarkKg = _minBenchmarkKg(watchHoldThreshold(ref));
    final pulled = bestKg != null && bestKg > minBenchmarkKg;
    final isConnected = watchConnected(ref);
    final windowSeconds =
        FiveSecondMax.windowUs / Duration.microsecondsPerSecond;
    const tall = Size.fromHeight(48);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Tare the Crimpdeq unloaded, then pull as hard as you can for at '
          'least 5 s.',
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        ToolAndHand(
          tools: trainingTools,
          tool: tool,
          onToolChanged: selector.selectTool,
          hand: hand,
          onHandChanged: selector.selectHand,
        ),
        // Without a device, only a pull recorded before it disconnected.
        if (isConnected || recording.elapsedSeconds > 0) ...[
          const SizedBox(height: 16),
          StatRow([
            StatTile(
              label: 'Best 5 s',
              value: bestKg == null ? '—' : formatKg(bestKg),
              color: pulled ? theme.colorScheme.primary : null,
            ),
            StatTile(
              label: 'Time',
              value: '${recording.elapsedSeconds.toStringAsFixed(1)} s',
            ),
          ]),
          const SizedBox(height: 8),
          // The first 5 s, before which there is no benchmark.
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: (recording.elapsedSeconds / windowSeconds).clamp(0, 1),
              minHeight: 6,
              color: recording.elapsedSeconds >= windowSeconds
                  ? gainColor
                  : theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.outlineVariant,
            ),
          ),
          const SizedBox(height: 12),
          LiveForceGraph(
            trace: recording.trace,
            // A stopped measurement's last reading is not the force now.
            currentKg: measurement.isMeasuring ? measurement.currentKg : null,
          ),
          if (!recording.recording && recording.elapsedSeconds > 0 && !pulled)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Pull more than ${formatKg(minBenchmarkKg)} for at least 5 s.',
                style: textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          const SizedBox(height: 16),
          if (recording.recording)
            FilledButton.icon(
              onPressed: recorder.stop,
              icon: const Icon(Icons.stop),
              label: const Text('Stop'),
              style: FilledButton.styleFrom(minimumSize: tall),
            )
          // Once pulled, saving is the next step.
          else if (pulled)
            OutlinedButton.icon(
              onPressed: workoutRunning || !isConnected ? null : recorder.start,
              icon: const Icon(Icons.replay),
              label: const Text('Pull Again'),
              style: OutlinedButton.styleFrom(minimumSize: tall),
            )
          else
            FilledButton.icon(
              onPressed: workoutRunning || !isConnected ? null : recorder.start,
              icon: const Icon(Icons.fiber_manual_record),
              label: const Text('Start Pull'),
              style: FilledButton.styleFrom(minimumSize: tall),
            ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed:
                recording.recording || !pulled || tool == null || hand == null
                ? null
                : () async {
                    await _save(tool, hand, bestKg);
                    recorder.clear();
                  },
            icon: const Icon(Icons.emoji_events_outlined),
            label: const Text('Save Benchmark'),
            style: FilledButton.styleFrom(minimumSize: tall),
          ),
        ],
        const SizedBox(height: 8),
        ExpansionTile(
          title: const Text('Enter a held weight instead'),
          subtitle: Text(
            'From a hold with weights, without the Crimpdeq',
            style: textTheme.bodySmall,
          ),
          initiallyExpanded: !isConnected,
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
          shape: const Border(),
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightKg,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Weight (kg)'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _heldSeconds,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Held (s)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Off until a weight is entered, instead of an error after a tap.
            ListenableBuilder(
              listenable: _weightKg,
              builder: (context, _) => OutlinedButton(
                onPressed: switch ((tool, hand, _weightEnteredKg)) {
                  (final tool?, final hand?, final weightKg?) =>
                    () => _saveHold(tool, hand, weightKg, minBenchmarkKg),
                  _ => null,
                },
                child: const Text('Save Hold'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// One tool's benchmarks: the best of each hand, which sets its workouts, the
/// progress over time and the history.
class _ToolBenchmarks extends ConsumerWidget {
  const _ToolBenchmarks({required this.tool, required this.benchmarks});

  final String tool;

  /// Of [tool], in date order, at least one.
  final List<Benchmark> benchmarks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final bodyWeights = ref.watch(bodyWeightsProvider).value ?? const [];
    final spansDays =
        benchmarks.last.date.difference(benchmarks.first.date) >=
        const Duration(days: 1);
    return TitledCard(
      title: tool,
      trailing: Text(
        '${benchmarks.length} benchmark${benchmarks.length == 1 ? '' : 's'}',
        style: textTheme.bodySmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'PERSONAL BEST',
            style: textTheme.labelMedium?.copyWith(letterSpacing: 1.2),
          ),
          const SizedBox(height: 8),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final hand in Hand.values) ...[
                  if (hand != Hand.values.first)
                    const VerticalDivider(width: 24),
                  Expanded(
                    child: _HandBest(
                      hand: hand,
                      best: bestBenchmark(benchmarks, tool, hand),
                      latest: benchmarks
                          .where((benchmark) => benchmark.hand == hand)
                          .lastOrNull,
                      bodyWeights: bodyWeights,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (spansDays) ...[
            const SizedBox(height: 20),
            BenchmarkProgressGraph(benchmarks: benchmarks),
          ],
          const SizedBox(height: 8),
          ExpansionTile(
            title: const Text('History'),
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            shape: const Border(),
            children: [
              for (final benchmark in benchmarks.reversed)
                _Entry(
                  benchmark: benchmark,
                  bodyKg: bodyWeightOn(bodyWeights, benchmark.date),
                  comparison: _compare(benchmark, benchmarks),
                  onDelete: () async {
                    if (await confirm(
                      context,
                      title: 'Delete the benchmark?',
                      content:
                          '${benchmark.tool} ${benchmark.hand.label}, '
                          '${formatKg(benchmark.forceKg)}. The workouts of a '
                          'tool and hand lock without a benchmark.',
                      action: 'Delete',
                    )) {
                      await ref
                          .read(trainingLogProvider.notifier)
                          .deleteBenchmark(benchmark);
                    }
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Change against the previous benchmark of the tool with the same hand,
  /// and whether it is the best of them.
  static ({double? vsPrevious, bool isBest}) _compare(
    Benchmark benchmark,
    List<Benchmark> benchmarks,
  ) {
    final comparable = [
      for (final other in benchmarks)
        if (other.hand == benchmark.hand) other,
    ];
    final index = comparable.indexOf(benchmark);
    final previous = index > 0 ? comparable[index - 1] : null;
    return (
      vsPrevious: previous == null
          ? null
          : benchmark.forceKg - previous.forceKg,
      isBest: comparable.every((other) => other.forceKg <= benchmark.forceKg),
    );
  }
}

/// The hand's label after a dot in its color.
class _HandLabel extends StatelessWidget {
  const _HandLabel(this.hand);

  final Hand hand;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.circle, size: 10, color: handColors[hand]),
        const SizedBox(width: 6),
        Text(
          '${hand.label} hand',
          style: Theme.of(context).textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

/// A hand's best benchmark with a tool, and its latest when it is another.
class _HandBest extends StatelessWidget {
  const _HandBest({
    required this.hand,
    required this.best,
    required this.latest,
    required this.bodyWeights,
  });

  final Hand hand;

  /// Null, as [latest], without a benchmark.
  final Benchmark? best;
  final Benchmark? latest;
  final List<BodyWeight> bodyWeights;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final best = this.best;
    final latest = this.latest;
    final bodyKg = best == null ? null : bodyWeightOn(bodyWeights, best.date);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HandLabel(hand),
        const SizedBox(height: 4),
        if (best == null) ...[
          Text('—', style: textTheme.headlineMedium),
          Text('No benchmark yet', style: textTheme.bodySmall),
        ] else ...[
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: best.forceKg.toStringAsFixed(1),
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(text: ' kg', style: textTheme.bodyMedium),
                ],
              ),
            ),
          ),
          Text(
            [
              if (bodyKg != null) formatBodyWeightShare(best.forceKg, bodyKg),
              formatDay(best.date),
            ].join(' · '),
            style: textTheme.bodySmall,
          ),
          if (latest != null && latest != best)
            Text(
              'Latest ${formatKg(latest.forceKg)} · '
              '${formatDayMonth(latest.date)}',
              style: textTheme.bodySmall,
            ),
        ],
      ],
    );
  }
}

const _personalBestColor = Color(0xFFEAB308);

class _Entry extends StatelessWidget {
  const _Entry({
    required this.benchmark,
    required this.bodyKg,
    required this.comparison,
    required this.onDelete,
  });

  final Benchmark benchmark;

  /// Body weight on the benchmark's day, null without one.
  final double? bodyKg;
  final ({double? vsPrevious, bool isBest}) comparison;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final vsPrevious = comparison.vsPrevious;
    final bodyKg = this.bodyKg;
    final handColor = handColors[benchmark.hand]!;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: handColor.withValues(alpha: 0.18),
        foregroundColor: handColor,
        child: Text(
          benchmark.hand.label[0],
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      title: Text(
        '${formatKg(benchmark.forceKg)}'
        '${bodyKg == null ? '' : ' · ${formatBodyWeightShare(benchmark.forceKg, bodyKg)}'}',
        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
      subtitle: Text(
        '${benchmark.hand.label} hand · ${formatDay(benchmark.date)}'
        '${vsPrevious == null ? '' : '\n${formatDelta(vsPrevious, 'kg')} vs previous'}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (comparison.isBest)
            const Tooltip(
              message: 'Personal best',
              child: Icon(Icons.emoji_events, color: _personalBestColor),
            ),
          IconButton(
            tooltip: 'Delete benchmark',
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
