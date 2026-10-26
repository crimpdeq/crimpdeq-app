import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/training_models.dart';
import '../providers/training_provider.dart';
import 'training_charts.dart';
import 'training_common.dart';

/// OpenGrips workout history: the workouts on the force curve and their
/// results.
class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  // Null shows every tool.
  String? _tool;

  @override
  Widget build(BuildContext context) {
    return TrainingLogView(
      builder: (context, log) {
        final workouts = [
          for (final workout in log.workouts.reversed)
            if (_tool == null || workout.tool == _tool) workout,
        ];
        // The curve of the strongest benchmark among the shown tools.
        final benchmarks = [
          for (final benchmark in log.benchmarks)
            if (_tool == null || benchmark.tool == _tool) benchmark,
        ];
        final benchmarkKg = benchmarks.isEmpty
            ? null
            : benchmarks
                  .map((benchmark) => benchmark.forceKg)
                  .reduce((a, b) => a > b ? a : b);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ToolAndHand(
              tools: const [null, ...trainingTools],
              tool: _tool,
              toolLabel: 'Filter by training tool',
              onToolChanged: (tool) => setState(() => _tool = tool),
            ),
            const SizedBox(height: 16),
            TitledCard(
              title: 'Force Curve Graph',
              child: benchmarkKg == null
                  ? const Text('Record a benchmark to draw the force curve.')
                  : ForceCurveGraph(
                      benchmarkKg: benchmarkKg,
                      workouts: [
                        for (final workout in workouts) ?workout.curvePoint,
                      ],
                    ),
            ),
            const SizedBox(height: 16),
            TitledCard(
              title: 'Entries',
              child: workouts.isEmpty
                  ? const Text('No workout results found.')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final workout in workouts)
                          _Entry(
                            workout: workout,
                            vsPrevious: _vsPrevious(workout, log.workouts),
                          ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }

  /// Change of the mean delta since the previous workout with the same tool
  /// and hand, like OpenGrips.
  static double? _vsPrevious(
    WorkoutRecord workout,
    List<WorkoutRecord> workouts,
  ) {
    final earlier = workouts.sublist(0, workouts.indexOf(workout));
    final previous = earlier.lastWhere(
      (other) => other.tool == workout.tool && other.hand == workout.hand,
      orElse: () => workout,
    );
    return identical(previous, workout)
        ? null
        : workout.meanDeltaSeconds - previous.meanDeltaSeconds;
  }
}

class _Entry extends ConsumerWidget {
  const _Entry({required this.workout, required this.vsPrevious});

  final WorkoutRecord workout;
  final double? vsPrevious;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forceKg = workout.forceKg;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        '${formatDate(workout.date)} · ${workout.tool} '
        '${workout.hand.label} · ${workout.section.label}',
      ),
      subtitle: Text(
        'Force ${forceKg == null ? '—' : formatKg(forceKg)} · '
        'RPE ${workout.perceivedExertion}/10\n'
        'Avg target ${workout.meanTargetSeconds.toStringAsFixed(1)} s · '
        'avg actual ${workout.meanActualSeconds.toStringAsFixed(1)} s · '
        'avg Δ ${formatDelta(workout.meanDeltaSeconds, 's')} · '
        'vs Prev ${formatDelta(vsPrevious, 's')}',
      ),
      isThreeLine: true,
      onTap: () => showDialog<void>(
        context: context,
        builder: (context) => _Details(workout: workout),
      ),
    );
  }
}

class _Details extends ConsumerWidget {
  const _Details({required this.workout});

  final WorkoutRecord workout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forceKg = workout.forceKg;
    return AlertDialog(
      title: Text('${workout.tool} · ${workout.section.label}'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(formatDate(workout.date)),
            Text('Hand: ${workout.hand.label}'),
            Text(
              'Force: ${forceKg == null ? '—' : formatKg(forceKg)} '
              '(target ${formatKg(workout.targetForceKg)})',
            ),
            Text('RPE: ${workout.perceivedExertion}/10'),
            Text('Avg Δ: ${formatDelta(workout.meanDeltaSeconds, 's')}'),
            const SizedBox(height: 8),
            DataTable(
              columnSpacing: 16,
              columns: const [
                DataColumn(label: Text('Rep')),
                DataColumn(label: Text('Target'), numeric: true),
                DataColumn(label: Text('Actual'), numeric: true),
                DataColumn(label: Text('Δ'), numeric: true),
              ],
              rows: [
                for (final (rep, actual) in workout.actualSeconds.indexed)
                  DataRow(
                    cells: [
                      DataCell(Text('${rep + 1}')),
                      DataCell(Text('${workout.targetSeconds[rep]} s')),
                      DataCell(Text('${actual.round()} s')),
                      DataCell(
                        Text(
                          formatDelta(
                            (actual.round() - workout.targetSeconds[rep])
                                .toDouble(),
                            's',
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            if (workout.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Notes: ${workout.notes}'),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final navigator = Navigator.of(context);
            if (!await confirm(
              context,
              title: 'Delete the workout?',
              content: 'Its results leave the history and the force curve.',
              action: 'Delete',
            )) {
              return;
            }
            await ref.read(trainingLogProvider.notifier).deleteWorkout(workout);
            navigator.pop();
          },
          child: const Text('Delete'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
