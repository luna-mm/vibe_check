import 'package:flutter/material.dart';
import 'package:vibe_check/notification_service.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notification Settings"),
      ),
      body: ListView(
        children: [
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