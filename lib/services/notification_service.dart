import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import '../models/meeting_schedule.dart';

class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _scheduleZoneName = 'Australia/Sydney';

  Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );
    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final iosImpl = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    final androidGranted =
        await androidImpl?.requestNotificationsPermission() ?? true;
    final iosGranted = await iosImpl?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        true;

    return androidGranted && iosGranted;
  }

  Future<void> scheduleMeetingAlert(MeetingSchedule meeting) async {
    if (!meeting.notifyBefore) return;

    final sydney = tz.getLocation(_scheduleZoneName);
    final now = tz.TZDateTime.now(sydney);

    for (final weekday in meeting.weekdays) {
      var scheduled = tz.TZDateTime(
        sydney,
        now.year,
        now.month,
        now.day,
        meeting.startHour,
        meeting.startMinute,
      ).subtract(Duration(minutes: meeting.notifyMinutesBefore));

      while (scheduled.weekday != weekday || scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      await _plugin.zonedSchedule(
        meeting.id.hashCode ^ weekday,
        'Upcoming: ${meeting.title}',
        meeting.silentMode
            ? 'Phone will switch to Silent in ${meeting.notifyMinutesBefore} min.'
            : 'Phone will switch to Vibrate in ${meeting.notifyMinutesBefore} min.',
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'meeting_alerts',
            'Meeting Alerts',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  Future<void> cancelAll() => _plugin.cancelAll();
}
