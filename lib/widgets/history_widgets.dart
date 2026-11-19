import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/training_models.dart';
import '../providers/navigation_provider.dart';
import '../providers/training_provider.dart';
import 'training_charts.dart';
import 'training_common.dart';

/// OpenGrips workout history: the workouts on the force curve, and each
/// workout's hands and reps, like the Frez workout log.
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
        if (log.workouts.isEmpty) {
          return const TitledCard(
            title: 'No workouts yet',
            child: _StartWorkout(),
          );
        }
        final sessions = workoutSessions(log.workouts);
        final monthNumbers = _monthNumbers(sessions);
        // Newest first.
        final shown = [
          for (final (index, session) in sessions.indexed.toList().reversed)
            if (_tool == null || session.first.tool == _tool)
              (session: session, monthNumber: monthNumbers[index]),
        ];
        // A curve per tool, since each follows its own benchmark.
        final curveTools = [
          for (final tool in trainingTools)
            if (shown.any((entry) => entry.session.first.tool == tool)) tool,
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ToolAndHand(
              tools: const [null, ...trainingTools],
              tool: _tool,
              onToolChanged: (tool) => setState(() => _tool = tool),
            ),
            for (final tool in curveTools) ...[
              const SizedBox(height: 16),
              _ToolForceCurve(
                tool: tool,
                benchmarks: log.benchmarks,
                workouts: [
                  for (final (:session, monthNumber: _) in shown)
                    if (session.first.tool == tool) ...session,
                ],
              ),
            ],
            const SizedBox(height: 16),
            Text('Workouts', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (shown.isEmpty)
              Text('No workouts with $_tool yet.')
            else
              for (final (:session, :monthNumber) in shown) ...[
                _SessionCard(
                  session: session,
                  monthNumber: monthNumber,
                  workouts: log.workouts,
                ),
                const SizedBox(height: 12),
              ],
          ],
        );
      },
    );
  }

  /// Each workout's place in its local month: 1 for the month's first.
  static List<int> _monthNumbers(List<List<WorkoutRecord>> sessions) {
    final counts = <(int, int), int>{};
    return [
      for (final session in sessions)
        counts.update(
          (
            session.first.date.toLocal().year,
            session.first.date.toLocal().month,
          ),
          (count) => count + 1,
          ifAbsent: () => 1,
        ),
    ];
  }
}

/// The workouts of [tool] on the curve of its strongest benchmark.
class _ToolForceCurve extends StatelessWidget {
  const _ToolForceCurve({
    required this.tool,
    required this.benchmarks,
    required this.workouts,
  });

  final String tool;

  /// Of every tool.
  final List<Benchmark> benchmarks;

  /// Of [tool].
  final List<WorkoutRecord> workouts;

  @override
  Widget build(BuildContext context) {
    final benchmarkKg = benchmarks
        .where((benchmark) => benchmark.tool == tool)
        .map((benchmark) => benchmark.forceKg)
        .fold<double?>(
          null,
          (best, kg) => best == null || kg > best ? kg : best,
        );
    return TitledCard(
      title: '$tool force curve',
      child: benchmarkKg == null
          ? Text('Record a $tool benchmark to draw its force curve.')
          : ForceCurveGraph(
              benchmarkKg: benchmarkKg,
              workouts: [for (final workout in workouts) ?workout.curvePoint],
            ),
    );
  }
}

class _StartWorkout extends ConsumerWidget {
  const _StartWorkout();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Finished workouts appear here, with each rep and your force curve.',
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => ref
              .read(trainingPageProvider.notifier)
              .open(TrainingPage.workout),
          icon: const Icon(Icons.timer_outlined),
          label: const Text('Go to Workout'),
        ),
      ],
    );
  }
}

/// "Photon · #3 in Oct".
String _sessionLabel(List<WorkoutRecord> session, int monthNumber) =>
    '${session.first.tool} · #$monthNumber in '
    '${formatMonth(session.first.date)}';

/// One workout, with each hand trained in it.
class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.session,
    required this.monthNumber,
    required this.workouts,
  });

  final List<WorkoutRecord> session;
  final int monthNumber;

  /// Every workout, for each hand's previous one.
  final List<WorkoutRecord> workouts;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final first = session.first;
    final sectionColor = sectionColors[first.section]!;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => _SessionDetails(
              session: session,
              monthNumber: monthNumber,
              workouts: workouts,
            ),
          ),
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
                              first.section.label,
                              style: textTheme.titleMedium?.copyWith(
                                color: sectionTextColor(context, first.section),
                              ),
                            ),
                          ),
                          Text(
                            formatDate(first.date),
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
                        _sessionLabel(session, monthNumber),
                        style: textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      _SessionStats(session: session),
                      for (final workout in session) ...[
                        const SizedBox(height: 14),
                        _HandSummary(
                          workout: workout,
                          previous: previousWorkout(workouts, workout),
                        ),
                      ],
                      if (first.notes.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          first.notes,
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

/// The totals of a workout's hands, like the Frez workout log: its time,
/// time under load, effort and workload, last so it scales down to fit.
class _SessionStats extends StatelessWidget {
  const _SessionStats({required this.session});

  final List<WorkoutRecord> session;

  @override
  Widget build(BuildContext context) {
    final first = session.first;
    final heldSeconds = session
        .map((workout) => workout.heldSeconds)
        .reduce((a, b) => a + b);
    final workloadKgS = session
        .map((workout) => workout.workloadKgS)
        .reduce((a, b) => a + b);
    return StatRow([
      StatTile(
        label: 'Time',
        value: switch (first.durationSeconds) {
          final seconds? => formatDuration(seconds),
          null => '—',
        },
      ),
      StatTile(label: 'Under load', value: formatDuration(heldSeconds.round())),
      StatTile(label: 'Effort', value: '${first.perceivedExertion}/10'),
      StatTile(label: 'Workload', value: formatWorkload(workloadKgS)),
    ]);
  }
}

/// One hand's results in the workout card.
class _HandSummary extends StatelessWidget {
  const _HandSummary({required this.workout, required this.previous});

  final WorkoutRecord workout;
  final WorkoutRecord? previous;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final forceKg = workout.forceKg;
    final previous = this.previous;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${workout.hand.label} hand',
                style: textTheme.titleSmall,
              ),
            ),
            if (previous != null)
              _Trend(
                seconds: workout.meanDeltaSeconds - previous.meanDeltaSeconds,
              ),
          ],
        ),
        const SizedBox(height: 6),
        StatRow([
          StatTile(
            label: 'Force',
            value: forceKg == null ? '—' : formatKg(forceKg),
          ),
          StatTile(
            label: 'Hold',
            value:
                '${workout.meanActualSeconds.round()}'
                ' / ${workout.meanTargetSeconds.round()} s',
          ),
          StatTile(
            label: 'Avg Δ',
            value: formatDelta(workout.meanDeltaSeconds, 's'),
            color: deltaColor(workout.meanDeltaSeconds),
          ),
          StatTile(
            label: 'Held',
            value: '${workout.repsHeld}/${workout.actualSeconds.length}',
          ),
        ]),
        const SizedBox(height: 8),
        RepBars(
          targets: workout.targetSeconds
              .take(workout.actualSeconds.length)
              .toList(),
          actual: workout.actualSeconds,
          color: sectionColors[workout.section]!,
        ),
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
    final color = deltaColor(seconds) ?? textTheme.bodySmall?.color;
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

/// A workout in full: its totals, and each hand's reps against their
/// targets and the previous workout.
class _SessionDetails extends ConsumerWidget {
  const _SessionDetails({
    required this.session,
    required this.monthNumber,
    required this.workouts,
  });

  final List<WorkoutRecord> session;
  final int monthNumber;

  /// Every workout when the page opened, for each hand's previous one: the
  /// page closes before a deletion changes them.
  final List<WorkoutRecord> workouts;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final navigator = Navigator.of(context);
    final log = ref.read(trainingLogProvider.notifier);
    if (!await confirm(
      context,
      title: 'Delete the workout?',
      content: session.length == 1
          ? 'Its results leave the history and the force curve.'
          : 'The results of both hands leave the history and the force '
                'curve.',
      action: 'Delete',
    )) {
      return;
    }
    // Closed first, so the page does not show the deleted workout.
    navigator.pop();
    await log.deleteWorkouts(session);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final first = session.first;
    final bodyKg = bodyWeightOn(
      ref.watch(bodyWeightsProvider).value ?? const [],
      first.date,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('${first.section.label} · ${first.tool}'),
        actions: [
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _delete(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxPageWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${formatDate(first.date)} · '
                  '${_sessionLabel(session, monthNumber)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _SessionStats(session: session),
                  ),
                ),
                for (final workout in session) ...[
                  const SizedBox(height: 16),
                  TitledCard(
                    title: '${workout.hand.label} hand',
                    child: _HandDetails(
                      workout: workout,
                      previous: previousWorkout(workouts, workout),
                      bodyKg: bodyKg,
                    ),
                  ),
                ],
                if (first.notes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  TitledCard(title: 'Notes', child: Text(first.notes)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One hand's reps in full: the time and force of each, like the sets of the
/// Frez workout log.
class _HandDetails extends StatelessWidget {
  const _HandDetails({
    required this.workout,
    required this.previous,
    required this.bodyKg,
  });

  final WorkoutRecord workout;
  final WorkoutRecord? previous;
  final double? bodyKg;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final forceKg = workout.forceKg;
    final bodyKg = this.bodyKg;
    final previous = this.previous;
    final previousKg = previous?.forceKg;
    final repForcesKg = workout.repForcesKg;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StatRow([
          StatTile(
            label: 'Force',
            value: forceKg == null ? '—' : formatKg(forceKg),
          ),
          StatTile(label: 'Target', value: formatKg(workout.targetForceKg)),
          StatTile(
            label: 'Avg Δ',
            value: formatDelta(workout.meanDeltaSeconds, 's'),
            color: deltaColor(workout.meanDeltaSeconds),
          ),
          StatTile(
            label: 'Held',
            value: '${workout.repsHeld}/${workout.actualSeconds.length}',
          ),
        ]),
        const SizedBox(height: 4),
        Text(
          [
            if (forceKg != null && bodyKg != null)
              formatBodyWeightShare(forceKg, bodyKg),
            '${formatDuration(workout.restSeconds)} rest',
            'under load ${formatDuration(workout.heldSeconds.round())}',
            formatWorkload(workout.workloadKgS),
          ].join(' · '),
          style: textTheme.bodySmall,
        ),
        if (previous != null)
          Text(
            'vs ${formatDate(previous.date)}: ${[if (forceKg != null && previousKg != null) 'force ${formatDelta(forceKg - previousKg, 'kg')}', 'Avg Δ ${formatDelta(workout.meanDeltaSeconds - previous.meanDeltaSeconds, 's')}', 'workload ${formatDelta(workout.workloadKgS - previous.workloadKgS, 'kg·s', digits: 0)}'].join(', ')}',
            style: textTheme.bodySmall,
          ),
        const SizedBox(height: 12),
        RepResultsGraph(
          targets: workout.targetSeconds,
          actual: workout.actualSeconds,
          section: workout.section,
        ),
        const SizedBox(height: 8),
        Table(
          children: [
            TableRow(
              children: [
                for (final label in ['Rep', 'Target', 'Held', 'Δ', 'Force'])
                  Text(label, style: textTheme.bodySmall),
              ],
            ),
            for (final (rep, seconds) in workout.actualSeconds.indexed)
              TableRow(
                children: [
                  Text('${rep + 1}'),
                  Text('${workout.targetSeconds[rep]} s'),
                  Text('${seconds.round()} s'),
                  Text(
                    formatDelta(
                      (seconds.round() - workout.targetSeconds[rep]).toDouble(),
                      's',
                    ),
                    style: TextStyle(
                      color: deltaColor(
                        (seconds.round() - workout.targetSeconds[rep])
                            .toDouble(),
                      ),
                    ),
                  ),
                  Text(switch (repForcesKg?[rep]) {
                    final kg? => formatKg(kg),
                    null => '—',
                  }),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
