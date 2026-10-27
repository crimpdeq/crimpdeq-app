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
            Text('Entries', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (workouts.isEmpty)
              const Text('No workout results found.')
            else
              for (final workout in workouts) ...[
                _Entry(
                  workout: workout,
                  vsPrevious: _vsPrevious(workout, log.workouts),
                ),
                const SizedBox(height: 12),
              ],
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

/// Colors of a change in seconds, like OpenGrips: green above the target or
/// the previous workout, red below, and neutral without a change.
const _gainColor = Color(0xFF10B981);
const _lossColor = Color(0xFFF43F5E);

Color? _deltaColor(double? seconds) => seconds == null || seconds.abs() < 0.05
    ? null
    : seconds > 0
    ? _gainColor
    : _lossColor;

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// "Tue 27 Oct · 07:20".
String _formatDay(DateTime date) {
  final local = date.toLocal();
  return '${_weekdays[local.weekday - 1]} ${local.day} '
      '${_months[local.month - 1]} · '
      '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
}

class _Entry extends StatelessWidget {
  const _Entry({required this.workout, required this.vsPrevious});

  final WorkoutRecord workout;
  final double? vsPrevious;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final sectionColor = sectionColors[workout.section]!;
    final forceKg = workout.forceKg;
    final held = forceKg != null;
    final notes = workout.notes;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showDialog<void>(
          context: context,
          builder: (context) => _Details(workout: workout),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 5, color: sectionColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 8, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              workout.section.label,
                              style: textTheme.titleMedium?.copyWith(
                                // Yellow and orange lack contrast on white.
                                color: theme.brightness == Brightness.light
                                    ? Color.lerp(
                                        sectionColor,
                                        Colors.black,
                                        0.3,
                                      )
                                    : sectionColor,
                              ),
                            ),
                          ),
                          Text(
                            _formatDay(workout.date),
                            style: textTheme.bodySmall,
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: textTheme.bodySmall?.color,
                          ),
                        ],
                      ),
                      Text(
                        '${workout.tool} · ${workout.hand.label} hand',
                        style: textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Metric(
                            label: 'Force',
                            value: held ? formatKg(forceKg) : '—',
                          ),
                          _Metric(
                            label: 'Hang',
                            value:
                                '${workout.meanActualSeconds.round()}'
                                ' / ${workout.meanTargetSeconds.round()} s',
                          ),
                          _Metric(
                            label: 'Avg Δ',
                            value: formatDelta(workout.meanDeltaSeconds, 's'),
                            color: _deltaColor(workout.meanDeltaSeconds),
                          ),
                          _Metric(
                            label: 'Effort',
                            value: '${workout.perceivedExertion}/10',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _RepBars(workout: workout, color: sectionColor),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              held
                                  ? '${workout.actualSeconds.where((s) => s > 0).length}'
                                        ' of ${workout.actualSeconds.length} '
                                        'reps held'
                                  : 'No rep held',
                              style: textTheme.bodySmall,
                            ),
                          ),
                          if (vsPrevious case final vsPrevious?)
                            _Trend(seconds: vsPrevious),
                        ],
                      ),
                      if (notes.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          notes,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: textTheme.bodySmall),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One bar per rep, filled by the share of its target held: in the workout
/// type's color, green once the target is reached.
class _RepBars extends StatelessWidget {
  const _RepBars({required this.workout, required this.color});

  final WorkoutRecord workout;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final track = Theme.of(context).colorScheme.outlineVariant;
    return Row(
      children: [
        for (final (rep, actual) in workout.actualSeconds.indexed) ...[
          if (rep > 0) const SizedBox(width: 4),
          Expanded(
            child: Tooltip(
              message:
                  'Rep ${rep + 1}: ${actual.round()} of '
                  '${workout.targetSeconds[rep]} s',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: (actual / workout.targetSeconds[rep]).clamp(0, 1),
                  minHeight: 6,
                  backgroundColor: track,
                  color: actual >= workout.targetSeconds[rep]
                      ? _gainColor
                      : color,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Change of the mean Δ since the previous workout with the tool and hand.
class _Trend extends StatelessWidget {
  const _Trend({required this.seconds});

  final double seconds;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = _deltaColor(seconds) ?? textTheme.bodySmall?.color;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          seconds > 0
              ? Icons.trending_up
              : seconds < 0
              ? Icons.trending_down
              : Icons.trending_flat,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          '${formatDelta(seconds, 's')} vs previous',
          style: textTheme.bodySmall?.copyWith(color: color),
        ),
      ],
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
