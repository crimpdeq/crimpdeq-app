import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

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

/// The rest between grippers and the weekly reminders, with a warning while
/// the system keeps their notifications off.
class ScheduleTab extends ConsumerStatefulWidget {
  const ScheduleTab({super.key});

  @override
  ConsumerState<ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends ConsumerState<ScheduleTab> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // The system settings, opened from the warning, can allow them meanwhile.
    _lifecycle = AppLifecycleListener(
      onResume: () => ref.invalidate(notificationsAllowedProvider),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifying =
        (ref.watch(remindersProvider).value?.isNotEmpty ?? false) ||
        (ref.watch(gripperRestProvider).value?.notify ?? false);
    final allowed = ref.watch(notificationsAllowedProvider).value ?? true;
    return TrainingLogView(
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (notifying && !allowed) ...[
            const _NotificationsOff(),
            const SizedBox(height: 16),
          ],
          const _RestSettings(),
          const SizedBox(height: 16),
          const _Reminders(),
        ],
      ),
    );
  }
}

class _NotificationsOff extends StatelessWidget {
  const _NotificationsOff();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notifications_off_outlined,
                  color: colorScheme.error,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Notifications are off for Crimpdeq, so the reminders and '
                    'the rest notice do not show.',
                  ),
                ),
              ],
            ),
            if (!kIsWeb) ...[
              const SizedBox(height: 12),
              const OutlinedButton(
                onPressed: openAppSettings,
                child: Text('Open App Settings'),
              ),
            ],
          ],
        ),
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
                      final allowed = await notifier.setNotify(notify);
                      ref.invalidate(notificationsAllowedProvider);
                      if (!allowed) messenger.showSnackBar(_notificationsOff);
                    },
            ),
        ],
      ),
    );
  }
}

final _notificationsOff = SnackBar(
  content: const Text(
    'Notifications are off for Crimpdeq. Allow them in the system settings.',
  ),
  action: kIsWeb
      ? null
      : const SnackBarAction(label: 'Settings', onPressed: openAppSettings),
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
      // A gripper without a reminder first, such as the second one.
      final tool = trainingTools.firstWhere(
        (tool) => reminders.every((reminder) => reminder.tool != tool),
        orElse: () => trainingTools.first,
      );
      // Denied, the warning above the cards stays until they are allowed.
      await notifications.requestPermission();
      ref.invalidate(notificationsAllowedProvider);
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
              onDelete: () {
                unawaited(notifier.set([...reminders]..removeAt(index)));
                ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text('${reminder.tool} reminder deleted.'),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () => notifier.set(
                          [
                            ...ref.read(remindersProvider).value ??
                                const <Reminder>[],
                          ]..insert(index, reminder),
                        ),
                      ),
                    ),
                  );
              },
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
    // Compact, so the workout's Start stays near the top.
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.hourglass_top, color: colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rest before ${widget.tool}',
                          style: textTheme.titleSmall,
                        ),
                        Text(
                          'After your ${widget.workouts.last.tool} workout '
                          'at ${_formatTime(saved.hour, saved.minute)}, or '
                          'train ${widget.tool} tomorrow.',
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    // The seconds round up, so the clock ends at 00:00.
                    formatClock((remaining.inMilliseconds / 1000).ceil()),
                    style: textTheme.headlineSmall?.copyWith(
                      color: colorScheme.primary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const InfoButton(
                    title: 'Rest between grippers',
                    content: _howGripperRestWorks,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: LinearProgressIndicator(
                  value: 1 - remaining.inSeconds / rest.inSeconds,
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
