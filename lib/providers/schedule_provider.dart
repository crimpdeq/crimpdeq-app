import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/training_models.dart';
import 'training_provider.dart';

/// The next [weekday] at [hour]:[minute] after [now], in its time zone.
tz.TZDateTime nextWeekdayTime(
  tz.TZDateTime now,
  int weekday,
  int hour,
  int minute,
) {
  var date = tz.TZDateTime(
    now.location,
    now.year,
    now.month,
    now.day,
    hour,
    minute,
  );
  while (date.weekday != weekday || !date.isAfter(now)) {
    date = tz.TZDateTime(
      now.location,
      date.year,
      date.month,
      date.day + 1,
      hour,
      minute,
    );
  }
  return date;
}

/// The training reminders and the end of the rest between grippers, as local
/// notifications. Only Android, iOS and macOS repeat them weekly.
class TrainingNotifications {
  bool get supported =>
      !kIsWeb &&
      const {
        TargetPlatform.android,
        TargetPlatform.iOS,
        TargetPlatform.macOS,
      }.contains(defaultTargetPlatform);

  /// The rest's end. Reminders follow it, 7 per reminder, one per weekday.
  static const _restOverId = 0;

  final _plugin = FlutterLocalNotificationsPlugin();
  Future<void>? _ready;

  /// Loads the time zones and the plugin once, without asking to notify.
  Future<void> _init() => _ready ??= () async {
    tz_data.initializeTimeZones();
    final zone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zone.identifier));
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: darwin,
        macOS: darwin,
      ),
    );
  }();

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  IOSFlutterLocalNotificationsPlugin? get _ios => _plugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >();

  MacOSFlutterLocalNotificationsPlugin? get _macos => _plugin
      .resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin
      >();

  /// Asks to notify, and on Android to notify on time instead of up to an
  /// hour late. Returns whether notifications are allowed.
  Future<bool> requestPermission() async {
    await _init();
    if (_android case final android?) {
      final allowed = await android.requestNotificationsPermission() ?? false;
      if (allowed &&
          !(await android.canScheduleExactNotifications() ?? false)) {
        await android.requestExactAlarmsPermission();
      }
      return allowed;
    }
    return await (_ios?.requestPermissions(alert: true, sound: true) ??
            _macos?.requestPermissions(alert: true, sound: true)) ??
        false;
  }

  /// Whether notifications are allowed, without asking: the system settings
  /// can turn them off at any time.
  Future<bool> areAllowed() async {
    await _init();
    if (_android case final android?) {
      return await android.areNotificationsEnabled() ?? false;
    }
    final options =
        await (_ios?.checkPermissions() ?? _macos?.checkPermissions());
    return options?.isEnabled ?? false;
  }

  /// Replaces the scheduled reminders with [reminders].
  Future<void> scheduleReminders(List<Reminder> reminders) async {
    await _init();
    for (final request in await _plugin.pendingNotificationRequests()) {
      if (request.id != _restOverId) await _plugin.cancel(id: request.id);
    }
    final now = tz.TZDateTime.now(tz.local);
    for (final (index, reminder) in reminders.indexed) {
      for (final weekday in reminder.weekdays) {
        await _plugin.zonedSchedule(
          id: 1 + index * 7 + weekday - DateTime.monday,
          title: '${reminder.tool} workout',
          body: 'Time for your ${reminder.tool} workout.',
          scheduledDate: nextWeekdayTime(
            now,
            weekday,
            reminder.hour,
            reminder.minute,
          ),
          notificationDetails: _details('reminders', 'Training reminders'),
          androidScheduleMode: await _scheduleMode(),
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    }
  }

  /// Notifies at [at] that the rest is over, replacing the previous notice.
  Future<void> scheduleRestOver(
    DateTime at, {
    required String title,
    required String body,
  }) async {
    await _init();
    await _plugin.zonedSchedule(
      id: _restOverId,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(at, tz.local),
      notificationDetails: _details('rest', 'Rest between grippers'),
      androidScheduleMode: await _scheduleMode(),
    );
  }

  Future<void> cancelRestOver() async {
    await _init();
    await _plugin.cancel(id: _restOverId);
  }

  /// On time when Android allows exact alarms, otherwise up to an hour late.
  Future<AndroidScheduleMode> _scheduleMode() async =>
      await _android?.canScheduleExactNotifications() ?? false
      ? AndroidScheduleMode.exactAllowWhileIdle
      : AndroidScheduleMode.inexactAllowWhileIdle;

  static NotificationDetails _details(String channelId, String channelName) =>
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
        macOS: const DarwinNotificationDetails(),
      );
}

final trainingNotificationsProvider = Provider<TrainingNotifications>(
  (ref) => TrainingNotifications(),
);

/// Whether notifications are allowed, read again on [Ref.invalidate], such
/// as when the app returns from the system settings.
final notificationsAllowedProvider = FutureProvider<bool>(
  (ref) => ref.watch(trainingNotificationsProvider).areAllowed(),
);

/// Weekly reminders to train a gripper, stored on this device.
final remindersProvider =
    AsyncNotifierProvider<RemindersNotifier, List<Reminder>>(
      RemindersNotifier.new,
    );

class RemindersNotifier extends AsyncNotifier<List<Reminder>> {
  static const _key = 'training.reminders';

  @override
  Future<List<Reminder>> build() async => [
    for (final json in jsonDecode(
      (await SharedPreferences.getInstance()).getString(_key) ?? '[]',
    ) as List)
      Reminder.fromJson(json as Map<String, Object?>),
  ];

  // The last schedule, so overlapping changes schedule in order.
  Future<void> _scheduled = Future.value();

  /// Stores [reminders] and schedules them in place of the previous ones.
  Future<void> set(List<Reminder> reminders) async {
    state = AsyncData(reminders);
    await (await SharedPreferences.getInstance()).setString(
      _key,
      jsonEncode(reminders),
    );
    final notifications = ref.read(trainingNotificationsProvider);
    final schedule = _scheduled.then(
      (_) => notifications.scheduleReminders(reminders),
    );
    // A failed schedule fails its caller, not the later ones.
    _scheduled = schedule.catchError((_) {});
    await schedule;
  }
}

/// The rest between workouts with different grippers, and whether to notify
/// when it is over.
typedef GripperRest = ({Duration rest, bool notify});

/// The rest HoG Academy sets for the first 30 sessions on each gripper.
const defaultGripperRest = Duration(hours: 1);

final gripperRestProvider =
    AsyncNotifierProvider<GripperRestNotifier, GripperRest>(
      GripperRestNotifier.new,
    );

class GripperRestNotifier extends AsyncNotifier<GripperRest> {
  static const _minutesKey = 'training.gripperRestMinutes';
  static const _notifyKey = 'training.gripperRestNotify';

  @override
  Future<GripperRest> build() async {
    final prefs = await SharedPreferences.getInstance();
    final minutes = prefs.getInt(_minutesKey);
    return (
      rest: minutes == null ? defaultGripperRest : Duration(minutes: minutes),
      notify: prefs.getBool(_notifyKey) ?? false,
    );
  }

  Future<void> setRest(Duration rest) async {
    state = AsyncData((rest: rest, notify: (await future).notify));
    await (await SharedPreferences.getInstance()).setInt(
      _minutesKey,
      rest.inMinutes,
    );
    await notifyRestOver();
  }

  /// Notifies once allowed to. Returns whether notifications are allowed.
  Future<bool> setNotify(bool notify) async {
    final allowed =
        !notify ||
        await ref.read(trainingNotificationsProvider).requestPermission();
    state = AsyncData((rest: (await future).rest, notify: notify && allowed));
    await (await SharedPreferences.getInstance()).setBool(
      _notifyKey,
      notify && allowed,
    );
    await notifyRestOver();
    return allowed;
  }

  /// Notifies when the rest after the latest workout ends, while a gripper
  /// with a benchmark is left to train that day, in place of the previous
  /// notice. Cancels it otherwise.
  Future<void> notifyRestOver() async {
    final notifications = ref.read(trainingNotificationsProvider);
    if (!notifications.supported) return;
    final (:rest, :notify) = await future;
    final log = await ref.read(trainingLogProvider.future);
    final latest = log.workouts.lastOrNull;
    final left = latest == null
        ? const <String>[]
        : toolsLeftToday(log.workouts, [
            for (final tool in trainingTools)
              if (log.benchmarks.any((benchmark) => benchmark.tool == tool))
                tool,
          ], latest.date);
    if (!notify ||
        latest == null ||
        left.isEmpty ||
        !latest.date.add(rest).isAfter(DateTime.now())) {
      await notifications.cancelRestOver();
      return;
    }
    await notifications.scheduleRestOver(
      latest.date.add(rest),
      title: 'Rest over',
      body:
          'Time for ${left.join(' and ')}: ${rest.inMinutes} min since your '
          '${latest.tool} workout.',
    );
  }
}
