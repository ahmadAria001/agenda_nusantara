import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../models/task.dart';

/// Service to handle local scheduled notifications.
class NotificationService {
  // Singleton pattern
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();
  factory NotificationService() => instance;

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initializes the notification service.
  Future<void> init() async {
    // Initialize timezones
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap if needed
      },
    );
  }

  /// Requests permissions for notifications (crucial for Android 13+ and iOS).
  Future<void> requestPermissions() async {
    // For Android 13+ (API 33+)
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
    }

    // For iOS
    final IOSFlutterLocalNotificationsPlugin? iosPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  /// Schedules notifications for a task.
  Future<void> scheduleTaskNotifications(Task task) async {
    if (task.dueDate == null || task.dueDate!.isEmpty) return;

    try {
      // Parse due date (Assuming format YYYY-MM-DD)
      final parts = task.dueDate!.split('-');
      if (parts.length != 3) return;

      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);

      final now = tz.TZDateTime.now(tz.local);
      final dueDay = tz.TZDateTime(tz.local, year, month, day);

      // Calculate target time based on slots
      tz.TZDateTime scheduledDate;

      if (dueDay.isAfter(now)) {
        // Future date: default to 9:00 AM
        scheduledDate = tz.TZDateTime(tz.local, year, month, day, 9, 0);
      } else if (dueDay.year == now.year &&
          dueDay.month == now.month &&
          dueDay.day == now.day) {
        // Today: find next available slot
        final slot9AM = tz.TZDateTime(tz.local, year, month, day, 9, 0);
        final slot1PM = tz.TZDateTime(tz.local, year, month, day, 13, 0);
        final slot5PM = tz.TZDateTime(tz.local, year, month, day, 17, 15);
        final slot8PM = tz.TZDateTime(tz.local, year, month, day, 20, 0);

        if (now.isBefore(slot9AM)) {
          scheduledDate = slot9AM;
        } else if (now.isBefore(slot1PM)) {
          scheduledDate = slot1PM;
        } else if (now.isBefore(slot5PM)) {
          scheduledDate = slot5PM;
        } else if (now.isBefore(slot8PM)) {
          scheduledDate = slot8PM;
        } else {
          // All slots passed, fire in 10 seconds as immediate alert
          scheduledDate = now.add(const Duration(seconds: 10));
        }
      } else {
        // Past date: don't schedule
        return;
      }

      await _notificationsPlugin.zonedSchedule(
        task.id! * 2, // Unique ID
        'Deadline Tugas',
        "Today is the deadline for '${task.title}'!",
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'agenda_nusantara_channel',
            'Agenda Nusantara Notifications',
            channelDescription: 'Notifications for task deadlines',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      // Reminder Notification (Only if due date is in the future)
      if (dueDay.isAfter(now.add(const Duration(days: 1)))) {
        final reminderTime = tz.TZDateTime(
          tz.local,
          year,
          month,
          day,
          9,
          0,
        ).subtract(const Duration(days: 1));

        if (reminderTime.isAfter(now)) {
          await _notificationsPlugin.zonedSchedule(
            task.id! * 2 + 1, // Unique ID
            'Pengingat Tugas',
            "Reminder: '${task.title}' is due tomorrow!",
            reminderTime,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'agenda_nusantara_channel',
                'Agenda Nusantara Notifications',
                channelDescription: 'Notifications for task deadlines',
                importance: Importance.max,
                priority: Priority.high,
              ),
              iOS: DarwinNotificationDetails(),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
        }
      }

      // Keep the test notification for now as requested earlier
      // await scheduleTestNotification(task.title);
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  /// Schedules a test notification 10 seconds from now.
  Future<void> scheduleTestNotification(String title) async {
    final now = tz.TZDateTime.now(tz.local);
    final testTime = now.add(const Duration(seconds: 10));

    await _notificationsPlugin.zonedSchedule(
      9999, // Static ID for test
      'Tes Notifikasi Berhasil! 🎉',
      "Ini adalah tes untuk tugas: '$title'",
      testTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'agenda_nusantara_test_channel',
          'Agenda Nusantara Test',
          channelDescription: 'Channel for testing notifications',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    debugPrint('Test notification scheduled for 10 seconds from now.');
  }

  /// Cancels notifications for a task (useful on delete or complete).
  Future<void> cancelTaskNotifications(int taskId) async {
    await _notificationsPlugin.cancel(taskId * 2);
    await _notificationsPlugin.cancel(taskId * 2 + 1);
  }
}
