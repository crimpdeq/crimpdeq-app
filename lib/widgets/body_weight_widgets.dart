import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/training_models.dart';
import '../providers/training_provider.dart';
import 'training_common.dart';

/// Body weights outside this range are likely typos.
const _minBodyKg = 20.0;
const _maxBodyKg = 300.0;

/// The body weight log, which the benchmarks and workouts compare with.
class BodyWeightTab extends ConsumerWidget {
  const BodyWeightTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weights = ref.watch(bodyWeightsProvider).value ?? const [];
    return TrainingLogView(
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TitledCard(
            title: 'Log body weight',
            trailing: InfoButton(
              title: 'About body weight',
              content:
                  'Benchmarks and workouts show their force as a share of '
                  'your body weight (% BW): the latest weight logged on or '
                  'before their day. Forces before your first weight show '
                  'only in kg.\n\n'
                  'Your body weight is optional and stays on this device.',
            ),
            child: _AddBodyWeight(),
          ),
          const SizedBox(height: 16),
          TitledCard(
            title: 'Your body weights',
            child: weights.isEmpty
                ? const Text('No body weights yet.')
                : Column(
                    children: [
                      // Latest first.
                      for (var index = weights.length - 1; index >= 0; index--)
                        _Entry(
                          weight: weights[index],
                          vsPreviousKg: index == 0
                              ? null
                              : weights[index].kg - weights[index - 1].kg,
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _AddBodyWeight extends ConsumerStatefulWidget {
  const _AddBodyWeight();

  @override
  ConsumerState<_AddBodyWeight> createState() => _AddBodyWeightState();
}

class _AddBodyWeightState extends ConsumerState<_AddBodyWeight> {
  final _kg = TextEditingController();
  DateTime _day = _today();

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    _kg.dispose();
    super.dispose();
  }

  Future<void> _pickDay() async {
    final day = await showDatePicker(
      context: context,
      initialDate: _day,
      firstDate: DateTime(2000),
      lastDate: _today(),
    );
    if (day != null) setState(() => _day = day);
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    final kg = double.tryParse(_kg.text.trim().replaceAll(',', '.'));
    // NaN parses, but passes no comparison and cannot be stored.
    if (kg == null || !kg.isFinite || kg < _minBodyKg || kg > _maxBodyKg) {
      messenger
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Enter your body weight, from ${_minBodyKg.round()} to '
              '${_maxBodyKg.round()} kg.',
            ),
          ),
        );
      return;
    }
    await ref
        .read(bodyWeightsProvider.notifier)
        .add(BodyWeight(day: _day, kg: kg));
    _kg.clear();
    messenger
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Body weight saved: ${formatKg(kg)}, ${formatDay(_day)}.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _kg,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Body weight (kg)',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickDay,
                icon: const Icon(Icons.calendar_today),
                label: Text(formatDay(_day)),
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'A weight for a day that has one replaces it.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        FilledButton(onPressed: _save, child: const Text('Save Body Weight')),
      ],
    );
  }
}

class _Entry extends ConsumerWidget {
  const _Entry({required this.weight, required this.vsPreviousKg});

  final BodyWeight weight;
  final double? vsPreviousKg;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vsPreviousKg = this.vsPreviousKg;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(formatKg(weight.kg)),
      subtitle: Text(
        '${formatDay(weight.day)}'
        '${vsPreviousKg == null ? '' : ' · ${formatDelta(vsPreviousKg, 'kg')} vs previous'}',
      ),
      trailing: IconButton(
        tooltip: 'Delete body weight',
        icon: const Icon(Icons.delete_outline),
        onPressed: () async {
          if (await confirm(
            context,
            title: 'Delete the body weight?',
            content:
                '${formatKg(weight.kg)}, ${formatDay(weight.day)}. The forces '
                'of its days compare with the previous weight instead.',
            action: 'Delete',
          )) {
            await ref.read(bodyWeightsProvider.notifier).delete(weight);
          }
        },
      ),
    );
  }
}
