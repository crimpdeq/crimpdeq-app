import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/training_models.dart';
import '../providers/training_provider.dart';

String formatKg(double kg) => '${kg.toStringAsFixed(1)} kg';

String formatClock(int seconds) =>
    '${(seconds ~/ 60).toString().padLeft(2, '0')}:'
    '${(seconds % 60).toString().padLeft(2, '0')}';

/// Seconds as OpenGrips shows hang durations: "45 s" or "1:05".
String formatDuration(int seconds) => seconds < 60
    ? '$seconds s'
    : '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

String formatDate(DateTime date) => date.toLocal().toString().substring(0, 16);

/// A change with its sign, or a dash without a value.
String formatDelta(double? value, String unit) => value == null
    ? '—'
    : '${value > 0 ? '+' : ''}${value.toStringAsFixed(1)} $unit';

/// Builds a training page once the log is loaded.
class TrainingLogView extends ConsumerWidget {
  const TrainingLogView({super.key, required this.builder});

  final Widget Function(BuildContext context, TrainingLog log) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(trainingLogProvider)) {
      // The top padding keeps the floating label of a leading field visible.
      AsyncData(value: final log) => SingleChildScrollView(
        padding: const EdgeInsets.only(top: 8),
        child: builder(context, log),
      ),
      AsyncError(:final error) => Center(
        child: Text('Could not load the training log: $error'),
      ),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}

class TitledCard extends StatelessWidget {
  const TitledCard({super.key, required this.title, required this.child});

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

/// Tool and hand selection, without the hand when [onHandChanged] is null.
/// A null tool stands for every tool.
class ToolAndHand extends StatelessWidget {
  const ToolAndHand({
    super.key,
    required this.tools,
    required this.tool,
    required this.onToolChanged,
    this.hand,
    this.onHandChanged,
    this.toolLabel = 'Training tool',
  });

  final List<String?> tools;
  final String? tool;
  final ValueChanged<String?> onToolChanged;
  final Hand? hand;
  final ValueChanged<Hand?>? onHandChanged;
  final String toolLabel;

  @override
  Widget build(BuildContext context) {
    final onHandChanged = this.onHandChanged;
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: tool,
            decoration: InputDecoration(labelText: toolLabel),
            items: [
              for (final tool in tools)
                DropdownMenuItem(value: tool, child: Text(tool ?? 'All tools')),
            ],
            onChanged: onToolChanged,
          ),
        ),
        if (onHandChanged != null) ...[
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
      ],
    );
  }
}
