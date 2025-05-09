import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibe_check/notification_service.dart';
import 'package:vibe_check/preferences.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notification Settings"),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text("Enable Notifications"),
            subtitle: Text("Try to enable notifications. If that doesn't work, configure in your system settings."),
            onTap: () => context.read<Preferences>().requestNotificationPermission()
          ),
          ListTile(
            leading: Icon(Icons.developer_mode),
            title: Text("Send a test notification"),
            onTap: () => NotificationService().pushTestNotification()
          ),
          ListTile(
            leading: Icon(Icons.timelapse),
            title: Text("Schedule notification in 8 seconds"),
            subtitle: Text("For testing purposes!"),
            onTap: () { 
              NotificationService().testScheduleNotification();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Scheduled! Here it comes...'),
                  duration: Duration(seconds: 2),
                )
              );
            }
          )
        ],
      )
    );
  }
}