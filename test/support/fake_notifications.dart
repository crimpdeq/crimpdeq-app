import 'package:crimpdeq/models/training_models.dart';
import 'package:crimpdeq/providers/schedule_provider.dart';

/// Records the notifications instead of scheduling them on the platform.
class FakeNotifications extends TrainingNotifications {
  FakeNotifications({this.allowed = true});

  /// Whether the user allows notifications.
  final bool allowed;
  final calls = <String>[];

  @override
  bool get supported => true;

  @override
  Future<bool> requestPermission() async {
    calls.add('request');
    return allowed;
  }

  @override
  Future<bool> areAllowed() async => allowed;

  @override
  Future<void> scheduleReminders(List<Reminder> reminders) async => calls.add(
    'reminders ${[for (final reminder in reminders) '${reminder.tool} ${reminder.weekdays} ${reminder.hour}:${reminder.minute}'].join(', ')}',
  );

  @override
  Future<void> scheduleRestOver(
    DateTime at, {
    required String title,
    required String body,
  }) async => calls.add('rest $at $body');

  @override
  Future<void> cancelRestOver() async => calls.add('cancel rest');
}
