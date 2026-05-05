import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:android_intent_plus/android_intent.dart';

class NotificationService {
  static final NotificationService _instance =
  NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  /// 🔥 INIT (call once in main.dart)
  Future<void> init() async {
    tz.initializeTimeZones();

    // ✅ Force correct timezone (VERY IMPORTANT)
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const androidSettings =
    AndroidInitializationSettings('@drawable/ic_notification');

    const settings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(settings);

    await _requestPermission();
  }

  /// 🔐 Notification permission
  Future<void> _requestPermission() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await android?.requestNotificationsPermission();
  }

  /// ⚠️ Exact alarm settings (for Vivo/iQOO)
  Future<void> openExactAlarmSettings() async {
    if (!Platform.isAndroid) return;

    const intent = AndroidIntent(
      action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
    );

    await intent.launch();
  }

  /// Check permission
  Future<bool> canScheduleExactAlarms() async {
    if (!Platform.isAndroid) return true;

    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    return await android?.canScheduleExactNotifications() ?? false;
  }

  /// 🔥 MAIN FUNCTION
  Future<void> scheduleDailyReminder(String time) async {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      await _notifications.cancelAll();

      final scheduled = _nextInstance(hour, minute);

      await _notifications.zonedSchedule(
        1,
        'Bag Reminder',
        'Pack your bag for tomorrow!',
        scheduled,
        const NotificationDetails(
          android: const AndroidNotificationDetails(
            'bag_reminder_channel',
            'Bag Reminder',
            channelDescription: 'Daily bag reminder',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@drawable/ic_notification',
          ),
        ),
        androidScheduleMode:
        AndroidScheduleMode.inexactAllowWhileIdle, // for real devices
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );

      print("✅ Scheduled at: $scheduled");
    } catch (e) {
      print("❌ Error: $e");
    }
  }

  /// ⏰ Next time calculation
  tz.TZDateTime _nextInstance(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);

    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}