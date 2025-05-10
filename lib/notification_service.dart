import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    tz.initializeTimeZones();

    final DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, 
      iOS: initializationSettingsIOS, 
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings
    );
  }

  Future<void> requestNotificationPermission() async {
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.
    requestNotificationsPermission();
  }
  
  Future<void> pushTestNotification() async {
    final AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      "testChannel", 
      "Notification Tests",
      importance: Importance.max
    );

    final DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(
      presentAlert: true
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails
    );

    await FlutterLocalNotificationsPlugin().show(
      0,
      "Hey there!",
      "Glad to see your notifications are working. :)",
      notificationDetails,
    );
  }

  Future<void> testScheduleNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      "Vibe Check! (just kidding)",
      "This is what your daily vibe check reminders will look like.",
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 8)),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'testChannel',
          'Notification Tests',
          importance: Importance.max
        )
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle
    );
  }

  Future<bool> scheduleDailyReminder(TimeOfDay time) async {
    // Convert TimeOfDay to DateTime
    DateTime now = DateTime.now();
    DateTime selectedTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    if (selectedTime.isBefore(DateTime.now())) {
      selectedTime = selectedTime.add(const Duration(days: 1));
    }

    // Convert TimeOfDay to Notification ID
    int id = (time.hour * 60) + time.minute;

    final tz.TZDateTime scheduledTime = tz.TZDateTime.from(selectedTime, tz.local);

    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'checkInAlarm',
      'Check In Reminders',
      importance: Importance.max
    );

    final DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(
      presentAlert: true
    );

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        'Vibe Check!', 
        'It\'s time to check in. How are you doing?',
        scheduledTime, 
        NotificationDetails(
          android: androidNotificationDetails,
          iOS: darwinNotificationDetails
        ),
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        matchDateTimeComponents: DateTimeComponents.time
      );
      debugPrint('Notification scheduled successfully');
      return true;
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
      return false;
    }
  }

  Future<void> deleteScheduledReminder(TimeOfDay time) async {
    int id = (time.hour * 60).toInt() + time.minute;
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<List<TimeOfDay>> retrieveScheduledNotifications() async {
    final List<PendingNotificationRequest> pendingNotificationRequests = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    if (pendingNotificationRequests.isEmpty) return List.empty();

    List<TimeOfDay> scheduledTimes = [];
    for (PendingNotificationRequest rq in pendingNotificationRequests) {
      int hour = (rq.id / 60).floor();
      int minute = rq.id - (hour * 60);
      scheduledTimes.add(TimeOfDay(hour: hour, minute: minute));
    }

    return scheduledTimes;
  }
}
