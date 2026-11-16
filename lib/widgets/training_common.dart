import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analysis/hold_tracker.dart';
import '../models/training_models.dart';
import '../providers/progressor_provider.dart';
import '../providers/training_provider.dart';

String formatKg(double kg) => '${kg.toStringAsFixed(1)} kg';

String formatClock(int seconds) =>
    '${(seconds ~/ 60).toString().padLeft(2, '0')}:'
    '${(seconds % 60).toString().padLeft(2, '0')}';

/// Seconds as OpenGrips shows hang durations: "45 s" or "1:05".
String formatDuration(int seconds) => seconds < 60
    ? '$seconds s'
    : '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

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

/// "27 Oct 2026".
String formatDay(DateTime date) {
  final local = date.toLocal();
  return '${local.day} ${_months[local.month - 1]} ${local.year}';
}

/// "Tue 27 Oct · 07:20".
String formatDate(DateTime date) {
  final local = date.toLocal();
  return '${_weekdays[local.weekday - 1]} ${local.day} '
      '${_months[local.month - 1]} · '
      '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
}

/// A change with its sign, or a dash without a value.
String formatDelta(double? value, String unit) => value == null
    ? '—'
    : '${value > 0 ? '+' : ''}${value.toStringAsFixed(1)} $unit';

/// Colors of a change, like OpenGrips: green above the target or the previous
/// result, red below, and neutral without a change.
const gainColor = Color(0xFF10B981);
const lossColor = Color(0xFFF43F5E);

Color? deltaColor(double? value) => value == null || value.abs() < 0.05
    ? null
    : value > 0
    ? gainColor
    : lossColor;

/// Widest training page, so a desktop window does not stretch the controls.
const _maxPageWidth = 760.0;

/// Builds a training page once the log is loaded.
class TrainingLogView extends ConsumerWidget {
  const TrainingLogView({super.key, required this.builder});

  final Widget Function(BuildContext context, TrainingLog log) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(trainingLogProvider)) {
      // The top padding keeps the floating label of a leading field visible.
      AsyncData(value: final log) => SingleChildScrollView(
        padding: const EdgeInsets.only(top: 4, bottom: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxPageWidth),
            child: builder(context, log),
          ),
        ),
      ),
      AsyncError(:final error) => Center(
        child: Text('Could not load the training log: $error'),
      ),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}

class TitledCard extends StatelessWidget {
  const TitledCard({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;

  /// Beside the title, such as an info button.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

/// A labeled value, such as a workout result.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.bodySmall),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

/// Stat tiles sharing a row evenly.
class StatRow extends StatelessWidget {
  const StatRow(this.tiles, {super.key});

  final List<StatTile> tiles;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [for (final tile in tiles) Expanded(child: tile)],
    );
  }
}

/// One bar per rep target, filled by the share of it held: in [color], green
/// once the target is reached. Reps without a time yet stay empty.
class RepBars extends StatelessWidget {
  const RepBars({
    super.key,
    required this.targets,
    required this.actual,
    required this.color,
  });

  final List<int> targets;
  final List<double> actual;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final track = Theme.of(context).colorScheme.outlineVariant;
    return Row(
      children: [
        for (final (rep, target) in targets.indexed) ...[
          if (rep > 0) const SizedBox(width: 4),
          Expanded(
            child: Tooltip(
              message: switch (actual.elementAtOrNull(rep)) {
                null => 'Rep ${rep + 1}: $target s target',
                final seconds =>
                  'Rep ${rep + 1}: ${seconds.round()} of $target s',
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: ((actual.elementAtOrNull(rep) ?? 0) / target).clamp(
                    0,
                    1,
                  ),
                  minHeight: 6,
                  backgroundColor: track,
                  color: (actual.elementAtOrNull(rep) ?? 0) >= target
                      ? gainColor
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

/// Tool and hand selection, without the hand when [onHandChanged] is null.
/// A null tool stands for every tool, and nothing is selected before a
/// first choice.
class ToolAndHand extends StatelessWidget {
  const ToolAndHand({
    super.key,
    required this.tools,
    required this.tool,
    required this.onToolChanged,
    this.hand,
    this.onHandChanged,
  });

  final List<String?> tools;
  final String? tool;
  final ValueChanged<String?> onToolChanged;
  final Hand? hand;
  final ValueChanged<Hand>? onHandChanged;

  @override
  Widget build(BuildContext context) {
    final onHandChanged = this.onHandChanged;
    final tool = this.tool;
    final hand = this.hand;
    // Nothing selected before a first choice, except "All tools".
    final toolSelected = tool != null || tools.contains(null);
    return Row(
      children: [
        Expanded(
          flex: tools.length,
          child: SegmentedButton<String?>(
            segments: [
              for (final tool in tools)
                ButtonSegment(value: tool, label: Text(tool ?? 'All')),
            ],
            selected: {if (toolSelected) tool},
            emptySelectionAllowed: !toolSelected,
            showSelectedIcon: false,
            onSelectionChanged: (selection) {
              if (selection.isNotEmpty) onToolChanged(selection.single);
            },
          ),
        ),
        if (onHandChanged != null) ...[
          const SizedBox(width: 12),
          Expanded(
            flex: Hand.values.length,
            child: SegmentedButton<Hand>(
              segments: [
                for (final hand in Hand.values)
                  ButtonSegment(value: hand, label: Text(hand.label)),
              ],
              selected: {?hand},
              emptySelectionAllowed: hand == null,
              showSelectedIcon: false,
              onSelectionChanged: (selection) {
                if (selection.isNotEmpty) onHandChanged(selection.single);
              },
            ),
          ),
        ],
      ],
    );
  }
}

/// Whether a device is connected, which measuring needs.
bool watchConnected(WidgetRef ref) => ref.watch(
  progressorProvider.select((state) => state.connection.isConnected),
);

/// The force a hold counts above, the default while it loads.
double watchHoldThreshold(WidgetRef ref) =>
    ref.watch(holdThresholdProvider).value ?? HoldTracker.defaultThresholdKg;

/// Tares the Crimpdeq, unloaded, so the forces start from zero.
class TareButton extends ConsumerWidget {
  const TareButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      onPressed: watchConnected(ref)
          ? ref.read(progressorProvider.notifier).tareScale
          : null,
      icon: const Icon(Icons.adjust),
      label: const Text('Tare'),
      style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
    );
  }
}

/// Asks before an action that cannot be undone, such as a deletion.
Future<bool> confirm(
  BuildContext context, {
  required String title,
  required String content,
  required String action,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      ),
    ) ??
    false;

/// Opens a dialog that explains a page, so the page keeps only the controls.
class InfoButton extends StatelessWidget {
  const InfoButton({super.key, required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.info_outline),
      tooltip: title,
      visualDensity: VisualDensity.compact,
      onPressed: () => showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(child: Text(content)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
