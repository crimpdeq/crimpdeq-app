import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analysis/hold_tracker.dart';
import '../analysis/opengrips_curve.dart';
import '../models/training_models.dart';
import '../providers/navigation_provider.dart';
import '../providers/progressor_provider.dart';
import '../providers/training_provider.dart';
import 'connection_widgets.dart';
import 'training_common.dart';

/// The lightest benchmark with a workout whose hangs count: the Power target,
/// the balanced force, must pull more than the hang threshold.
const _minBenchmarkKg = HoldTracker.thresholdKg / balancedRatio;

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
          const SizedBox(height: 16),
          TitledCard(
            title: 'Your benchmarks',
            child: _Entries(benchmarks: log.benchmarks),
          ),
        ],
      ),
    );
  }
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

  Future<void> _saveHold(String tool, Hand hand) async {
    double? parse(TextEditingController field) =>
        double.tryParse(field.text.trim().replaceAll(',', '.'));
    final weightKg = parse(_weightKg);
    final heldSeconds = parse(_heldSeconds);
    if (weightKg == null || weightKg <= 0) {
      _showError('Enter the weight held, in kg.');
      return;
    }
    if (heldSeconds == null || heldSeconds < 5) {
      _showError('The hold must last at least 5 s.');
      return;
    }
    final benchmarkKg = deriveBenchmarkKg(weightKg, heldSeconds);
    if (benchmarkKg <= _minBenchmarkKg) {
      _showError(
        'The hold is a ${formatKg(benchmarkKg)} benchmark. A workout needs '
        'more than ${formatKg(_minBenchmarkKg)}.',
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
    final currentKg = ref.watch(
      progressorProvider.select((state) => state.measurement.currentKg),
    );
    final workoutRunning = ref.watch(
      workoutProvider.select((state) => state.isRunning),
    );
    // By default the latest benchmark's tool and hand, the likeliest next
    // ones.
    final selection = ref.watch(benchmarkSelectionProvider);
    final latest = ref.watch(trainingLogProvider).value?.benchmarks.lastOrNull;
    final tool = selection.tool ?? latest?.tool;
    final hand = selection.hand ?? latest?.hand;
    final selector = ref.read(benchmarkSelectionProvider.notifier);
    final bestKg = recording.bestKg;
    final pulled = bestKg != null && bestKg > _minBenchmarkKg;
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
              label: 'Force',
              value: currentKg == null ? '—' : formatKg(currentKg),
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
          if (!recording.recording && recording.elapsedSeconds > 0 && !pulled)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Pull more than ${formatKg(_minBenchmarkKg)} for at least 5 s.',
                style: textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              const TareButton(),
              const SizedBox(width: 8),
              Expanded(
                child: recording.recording
                    ? FilledButton.icon(
                        onPressed: recorder.stop,
                        icon: const Icon(Icons.stop),
                        label: const Text('Stop'),
                        style: FilledButton.styleFrom(minimumSize: tall),
                      )
                    // Once pulled, saving is the next step.
                    : pulled
                    ? OutlinedButton.icon(
                        onPressed: workoutRunning || !isConnected
                            ? null
                            : recorder.start,
                        icon: const Icon(Icons.replay),
                        label: const Text('Pull Again'),
                        style: OutlinedButton.styleFrom(minimumSize: tall),
                      )
                    : FilledButton.icon(
                        onPressed: workoutRunning || !isConnected
                            ? null
                            : recorder.start,
                        icon: const Icon(Icons.fiber_manual_record),
                        label: const Text('Start Pull'),
                        style: FilledButton.styleFrom(minimumSize: tall),
                      ),
              ),
            ],
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
            'From a hang with weights, without the Crimpdeq',
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
                    decoration: const InputDecoration(
                      labelText: 'Weight held (kg)',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _heldSeconds,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Time held (s)',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: tool == null || hand == null
                  ? null
                  : () => _saveHold(tool, hand),
              child: const Text('Save Hold'),
            ),
          ],
        ),
      ],
    );
  }
}

class _Entries extends ConsumerStatefulWidget {
  const _Entries({required this.benchmarks});

  final List<Benchmark> benchmarks;

  @override
  ConsumerState<_Entries> createState() => _EntriesState();
}

class _EntriesState extends ConsumerState<_Entries> {
  // Null shows every tool.
  String? _tool;

  @override
  Widget build(BuildContext context) {
    final benchmarks = widget.benchmarks;
    final shown = [
      for (final benchmark in benchmarks.reversed)
        if (_tool == null || benchmark.tool == _tool) benchmark,
    ];

    if (benchmarks.isEmpty) {
      return const Text('No benchmarks yet. Your first one unlocks workouts.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ToolAndHand(
          tools: const [null, ...trainingTools],
          tool: _tool,
          onToolChanged: (tool) => setState(() => _tool = tool),
        ),
        const SizedBox(height: 8),
        if (shown.isEmpty)
          Text('No benchmarks with $_tool yet.')
        else
          for (final benchmark in shown)
            _Entry(
              benchmark: benchmark,
              comparison: _compare(benchmark, benchmarks),
              onDelete: () async {
                if (await confirm(
                  context,
                  title: 'Delete the benchmark?',
                  content:
                      '${benchmark.tool} ${benchmark.hand.label}, '
                      '${formatKg(benchmark.forceKg)}. The workouts of a tool '
                      'and hand lock without a benchmark.',
                  action: 'Delete',
                )) {
                  await ref
                      .read(trainingLogProvider.notifier)
                      .deleteBenchmark(benchmark);
                }
              },
            ),
      ],
    );
  }

  /// Change against the previous benchmark with the same tool and hand, and
  /// against the best of them, like OpenGrips.
  static ({double? vsPrevious, double vsBest, bool isBest}) _compare(
    Benchmark benchmark,
    List<Benchmark> benchmarks,
  ) {
    final comparable = [
      for (final other in benchmarks)
        if (other.tool == benchmark.tool && other.hand == benchmark.hand) other,
    ];
    final index = comparable.indexOf(benchmark);
    final previous = index > 0 ? comparable[index - 1] : null;
    final bestKg = comparable
        .map((other) => other.forceKg)
        .reduce((a, b) => a > b ? a : b);
    return (
      vsPrevious: previous == null
          ? null
          : benchmark.forceKg - previous.forceKg,
      vsBest: benchmark.forceKg - bestKg,
      isBest: benchmark.forceKg == bestKg,
    );
  }
}

const _personalBestColor = Color(0xFFEAB308);

class _Entry extends StatelessWidget {
  const _Entry({
    required this.benchmark,
    required this.comparison,
    required this.onDelete,
  });

  final Benchmark benchmark;
  final ({double? vsPrevious, double vsBest, bool isBest}) comparison;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final vsPrevious = comparison.vsPrevious;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        comparison.isBest ? Icons.emoji_events : Icons.trending_flat,
        color: comparison.isBest
            ? _personalBestColor
            : textTheme.bodySmall?.color,
      ),
      title: Text(
        formatKg(benchmark.forceKg),
        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
      subtitle: Text(
        '${benchmark.tool} · ${benchmark.hand.label} · '
        '${formatDay(benchmark.date)}\n'
        '${comparison.isBest ? 'Personal best' : '${formatDelta(comparison.vsBest, 'kg')} vs best'}'
        '${vsPrevious == null ? '' : ' · ${formatDelta(vsPrevious, 'kg')} vs previous'}',
      ),
      trailing: IconButton(
        tooltip: 'Delete benchmark',
        icon: const Icon(Icons.delete_outline),
        onPressed: onDelete,
      ),
    );
  }
}
