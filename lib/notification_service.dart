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
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
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
      "Test Notification",
      "Hopefully you're seeing this! :)",
      notificationDetails,
    );
  }

  Future<void> testScheduleNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      "Future notification",
      "Test!!",
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
}
