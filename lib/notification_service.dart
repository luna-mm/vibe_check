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

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false
    );

    final InitializationSettings initializationSettings =InitializationSettings(
      android: initializationSettingsAndroid, 
      iOS: initializationSettingsIOS, 
      macOS: null
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings
    );
  }

  Future<void> pushTestNotification() async {
    final AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      "testChannelID", 
      "Test Channel 1",
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
          'your channel id',
          'your channel name',
          channelDescription: 'your channel description'
          ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle
    );
  }
}
