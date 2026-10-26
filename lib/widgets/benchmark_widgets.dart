import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analysis/opengrips_curve.dart';
import '../models/training_models.dart';
import '../providers/progressor_provider.dart';
import '../providers/training_provider.dart';
import 'training_common.dart';

/// OpenGrips benchmarks: the highest force held for 5 s with each tool and
/// hand. The first one for a tool and hand unlocks its workouts.
class BenchmarksTab extends StatelessWidget {
  const BenchmarksTab({super.key});

  @override
  Widget build(BuildContext context) {
    return TrainingLogView(
      builder: (context, log) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TitledCard(title: 'Add Benchmark', child: _AddBenchmark()),
          const SizedBox(height: 16),
          TitledCard(
            title: 'Entries',
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
  String? _tool;
  Hand? _hand;

  @override
  void dispose() {
    _weightKg.dispose();
    _heldSeconds.dispose();
    super.dispose();
  }

  Future<void> _save(double forceKg) async {
    final messenger = ScaffoldMessenger.of(context);
    final tabs = DefaultTabController.maybeOf(context);
    final benchmark = Benchmark(
      date: DateTime.now(),
      tool: _tool!,
      hand: _hand!,
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
          action: tabs == null
              ? null
              : SnackBarAction(
                  label: 'Open Workout',
                  onPressed: () => tabs.animateTo(0),
                ),
        ),
      );
  }

  Future<void> _saveHold() async {
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
    await _save(deriveBenchmarkKg(weightKg, heldSeconds));
    _weightKg.clear();
    _heldSeconds.text = '5';
  }

  void _showError(String message) => ScaffoldMessenger.of(context)
    ..removeCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

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
    final selected = _tool != null && _hand != null;
    final bestKg = recording.bestKg;
    final isConnected = watchConnected(ref);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Record the highest force you can hold for at least 5 s with a '
          'tool and hand. Once a benchmark is recorded, its workouts unlock '
          'in the Workout tab.',
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        ToolAndHand(
          tools: trainingTools,
          tool: _tool,
          onToolChanged: (tool) => setState(() => _tool = tool),
          hand: _hand,
          onHandChanged: (hand) => setState(() => _hand = hand),
        ),
        const SizedBox(height: 16),
        Text('Measure with the Crimpdeq', style: textTheme.titleSmall),
        Text(
          isConnected
              ? 'Tare it unloaded, then pull as hard as you can for at least '
                    '5 s. The benchmark is the highest mean force over 5 s.'
              : 'Connect a Crimpdeq in the Workout tab to measure a pull, or '
                    'enter a hold below.',
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Force: ${currentKg == null ? '—' : formatKg(currentKg)} · '
          'Elapsed: ${recording.elapsedSeconds.toStringAsFixed(1)} s · '
          'Best 5 s: ${bestKg == null ? '—' : formatKg(bestKg)}',
        ),
        if (!recording.recording &&
            recording.elapsedSeconds > 0 &&
            bestKg == null)
          const Text('Pull for at least 5 s.'),
        const SizedBox(height: 8),
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
                    )
                  : FilledButton.icon(
                      onPressed: workoutRunning || !isConnected
                          ? null
                          : recorder.start,
                      icon: const Icon(Icons.fiber_manual_record),
                      label: const Text('Start Pull'),
                    ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: recording.recording || bestKg == null || !selected
                    ? null
                    : () async {
                        await _save(bestKg);
                        recorder.clear();
                      },
                child: const Text('Save Benchmark'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Or enter a hold', style: textTheme.titleSmall),
        Text(
          'A weight held for longer than 5 s counts as the higher weight you '
          'could hold for 5 s on the ideal force curve.',
          style: textTheme.bodySmall,
        ),
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
                decoration: const InputDecoration(labelText: 'Time held (s)'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: selected ? _saveHold : null,
          child: const Text('Save Hold'),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ToolAndHand(
          tools: const [null, ...trainingTools],
          tool: _tool,
          toolLabel: 'Filter by training tool',
          onToolChanged: (tool) => setState(() => _tool = tool),
        ),
        const SizedBox(height: 8),
        if (shown.isEmpty)
          const Text('No benchmarks found. Add one to get started!')
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
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Row(
        children: [
          Flexible(
            child: Text(
              '${benchmark.tool} · ${benchmark.hand.label}: '
              '${formatKg(benchmark.forceKg)}',
            ),
          ),
          const SizedBox(width: 8),
          Chip(
            label: Text(comparison.isBest ? 'PB' : 'Tracking'),
            visualDensity: VisualDensity.compact,
            backgroundColor: comparison.isBest
                ? const Color(0xFFEAB308).withValues(alpha: 0.3)
                : null,
          ),
        ],
      ),
      subtitle: Text(
        '${formatDate(benchmark.date)} · '
        'vs Prev ${formatDelta(comparison.vsPrevious, 'kg')} · '
        'vs Best ${formatDelta(comparison.vsBest, 'kg')}',
      ),
      trailing: IconButton(
        tooltip: 'Delete benchmark',
        icon: const Icon(Icons.delete_outline),
        onPressed: onDelete,
      ),
    );
  }
}
