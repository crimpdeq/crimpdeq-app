import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/training_models.dart';
import '../providers/schedule_provider.dart';
import 'training_common.dart';

const _howGripperRestWorks =
    'A grip day trains both grippers, both hands. HoG Academy sets at '
    'least an hour between gripper workouts for the first 30 sessions on '
    'each gripper.\n\n'
    'Once a workout is saved, the Workout page counts the rest down before '
    'a workout with the other gripper. A workout of the other hand on the '
    'same gripper needs no rest.\n\n'
    'Without time for the rest, train the other gripper the next day: both '
    'keep the same days per week.';

/// The rest between grippers and the weekly reminders.
class ScheduleTab extends StatelessWidget {
  const ScheduleTab({super.key});

  @override
  Widget build(BuildContext context) {
    return TrainingLogView(
      builder: (context, _) => const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [_RestSettings(), SizedBox(height: 16), _Reminders()],
      ),
    );
  }
}

/// Longest rest to choose, and its step.
const _maxRestMinutes = 120;
const _restStepMinutes = 15;

class _RestSettings extends ConsumerWidget {
  const _RestSettings();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final settings = ref.watch(gripperRestProvider).value;
    final notifier = ref.read(gripperRestProvider.notifier);
    if (settings == null) return const SizedBox.shrink();
    final minutes = settings.rest.inMinutes;
    return TitledCard(
      title: 'Rest between grippers',
      trailing: const InfoButton(
        title: 'Rest between grippers',
        content: _howGripperRestWorks,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(minutes == 0 ? 'Rest: off' : 'Rest: $minutes min'),
          Slider(
            value: minutes.clamp(0, _maxRestMinutes).toDouble(),
            max: _maxRestMinutes.toDouble(),
            divisions: _maxRestMinutes ~/ _restStepMinutes,
            label: minutes == 0 ? 'Off' : '$minutes min',
            onChanged: (value) =>
                notifier.setRest(Duration(minutes: value.round())),
          ),
          Text(
            'Before a workout with the other gripper. HoG Academy sets at '
            'least an hour for the first 30 sessions on each gripper.',
            style: textTheme.bodySmall,
          ),
          if (ref.read(trainingNotificationsProvider).supported)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Notify when the rest is over'),
              subtitle: const Text(
                'While the other gripper is left to train that day.',
              ),
              value: settings.notify,
              onChanged: minutes == 0
                  ? null
                  : (notify) async {
                      final messenger = ScaffoldMessenger.of(context);
                      if (!await notifier.setNotify(notify)) {
                        messenger.showSnackBar(_notificationsOff);
                      }
                    },
            ),
        ],
      ),
    );
  }
}

const _notificationsOff = SnackBar(
  content: Text(
    'Notifications are off for Crimpdeq. Allow them in the system settings.',
  ),
);

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// [DateTime.monday] to [DateTime.sunday].
final _days = [for (var day = 1; day <= 7; day++) day];

String _formatTime(int hour, int minute) =>
    '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

class _Reminders extends ConsumerWidget {
  const _Reminders();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final notifications = ref.read(trainingNotificationsProvider);
    if (!notifications.supported) {
      return const TitledCard(
        title: 'Reminders',
        child: Text('Reminders need the Android, iOS or macOS app.'),
      );
    }
    final reminders = ref.watch(remindersProvider).value;
    if (reminders == null) return const SizedBox.shrink();
    final notifier = ref.read(remindersProvider.notifier);

    Future<void> add() async {
      final messenger = ScaffoldMessenger.of(context);
      // A gripper without a reminder first, such as the second one.
      final tool = trainingTools.firstWhere(
        (tool) => reminders.every((reminder) => reminder.tool != tool),
        orElse: () => trainingTools.first,
      );
      final allowed = await notifications.requestPermission();
      await notifier.set([
        ...reminders,
        Reminder(
          tool: tool,
          weekdays: const [
            DateTime.monday,
            DateTime.wednesday,
            DateTime.friday,
          ],
          hour: 10,
          minute: 0,
        ),
      ]);
      if (!allowed) messenger.showSnackBar(_notificationsOff);
    }

    return TitledCard(
      title: 'Reminders',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            reminders.isEmpty
                ? 'Get a notification on the days and at the time you train '
                      'a gripper, such as Spark at 10:00 and Photon at 15:00 '
                      'on Monday, Wednesday and Friday.'
                : 'Each gripper 2 to 4 days a week, usually on the same '
                      'days.',
            style: textTheme.bodySmall,
          ),
          for (final (index, reminder) in reminders.indexed) ...[
            const SizedBox(height: 12),
            _ReminderTile(
              reminder: reminder,
              onChanged: (changed) =>
                  notifier.set([...reminders]..[index] = changed),
              onDelete: () => notifier.set([...reminders]..removeAt(index)),
            ),
          ],
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: add,
            icon: const Icon(Icons.add_alarm),
            label: const Text('Add Reminder'),
          ),
        ],
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({
    required this.reminder,
    required this.onChanged,
    required this.onDelete,
  });

  final Reminder reminder;
  final ValueChanged<Reminder> onChanged;
  final VoidCallback onDelete;

  Future<void> _pickTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: reminder.hour, minute: reminder.minute),
    );
    if (time == null) return;
    onChanged(reminder.copyWith(hour: time.hour, minute: time.minute));
  }

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // The whole width, so each gripper's name fits on one line.
            ToolAndHand(
              tools: trainingTools,
              tool: reminder.tool,
              onToolChanged: (tool) => onChanged(reminder.copyWith(tool: tool)),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _pickTime(context),
                  icon: const Icon(Icons.schedule),
                  label: Text(_formatTime(reminder.hour, reminder.minute)),
                ),
                IconButton(
                  tooltip: 'Delete reminder',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                for (final day in _days)
                  FilterChip(
                    label: Text(_weekdays[day - 1]),
                    showCheckmark: false,
                    selected: reminder.weekdays.contains(day),
                    onSelected: (selected) => onChanged(
                      reminder.copyWith(
                        weekdays: [
                          for (final weekday in _days)
                            if (weekday == day
                                ? selected
                                : reminder.weekdays.contains(weekday))
                              weekday,
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            if (reminder.weekdays.isEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Choose the days to be reminded on.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The rest before a workout with [tool] after one with the other gripper,
/// counting down. Nothing without a rest or once it is over.
class GripperRestCard extends ConsumerStatefulWidget {
  const GripperRestCard({
    super.key,
    required this.workouts,
    required this.tool,
  });

  final List<WorkoutRecord> workouts;
  final String tool;

  @override
  ConsumerState<GripperRestCard> createState() => _GripperRestCardState();
}

class _GripperRestCardState extends ConsumerState<GripperRestCard> {
  // Counts the rest down, only while there is one.
  Timer? _tick;

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _tick?.cancel();
    final rest = ref.watch(gripperRestProvider).value?.rest;
    if (rest == null) return const SizedBox.shrink();
    final end = gripperRestEnd(widget.workouts, widget.tool, rest);
    final remaining = end?.difference(DateTime.now());
    if (remaining == null || remaining <= Duration.zero) {
      return const SizedBox.shrink();
    }
    // Once the clock, rounded up, shows the next second.
    final untilNextSecond = remaining.inMilliseconds % 1000;
    _tick = Timer(
      Duration(milliseconds: untilNextSecond == 0 ? 1000 : untilNextSecond),
      () => setState(() {}),
    );
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final saved = widget.workouts.last.date.toLocal();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TitledCard(
        title: 'Rest before ${widget.tool}',
        trailing: const InfoButton(
          title: 'Rest between grippers',
          content: _howGripperRestWorks,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              // The seconds round up, so the clock ends at 00:00.
              formatClock((remaining.inMilliseconds / 1000).ceil()),
              style: textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.primary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
              textAlign: TextAlign.center,
            ),
            LinearProgressIndicator(
              value: 1 - remaining.inSeconds / rest.inSeconds,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            const SizedBox(height: 8),
            Text(
              'Your ${widget.workouts.last.tool} workout was saved at '
              '${_formatTime(saved.hour, saved.minute)}. Rest '
              '${rest.inMinutes} min between gripper workouts, or train '
              '${widget.tool} tomorrow. Change the rest in Schedule, in the '
              'menu.',
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
