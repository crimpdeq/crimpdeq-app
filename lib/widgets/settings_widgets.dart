import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/theme_mode_provider.dart';
import '../providers/training_provider.dart';
import 'training_common.dart';

/// The theme and the hold threshold, which every workout and warm-up share.
class SettingsTab extends ConsumerWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final thresholdKg = watchHoldThreshold(ref);
    return TrainingLogView(
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TitledCard(
            title: 'Theme',
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.system, label: Text('System')),
                ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
              ],
              selected: {ref.watch(themeModeProvider)},
              showSelectedIcon: false,
              onSelectionChanged: (selection) =>
                  ref.read(themeModeProvider.notifier).set(selection.single),
            ),
          ),
          const SizedBox(height: 16),
          TitledCard(
            title: 'Hold threshold: ${formatKg(thresholdKg)}',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'A workout or warm-up hold starts when you pull more, and '
                  'ends a second after the force drops to it. Lower it for '
                  'light targets.',
                  style: textTheme.bodySmall,
                ),
                Slider(
                  value: thresholdKg.clamp(0.5, 10),
                  min: 0.5,
                  max: 10,
                  divisions: 19,
                  label: formatKg(thresholdKg),
                  onChanged: ref.read(holdThresholdProvider.notifier).set,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
