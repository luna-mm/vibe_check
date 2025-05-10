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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(style: TextTheme.of(context).headlineSmall, "System"),
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
            ),
            Text(style: TextTheme.of(context).headlineSmall, "Check Ins"),
            NotificationsListView()
          ]
        )
      )
    );
  }
}

class NotificationsListView extends StatefulWidget {
  const NotificationsListView({super.key});

  @override
  State<StatefulWidget> createState() => _NotificiationListViewState();
}

class _NotificiationListViewState extends State<NotificationsListView> {
  late List<TimeOfDay> _timeList;
  late Future<void> _timeListData;

  Future<void> _initData() async {
    final timeList = await NotificationService().retrieveScheduledNotifications();
    _timeList = timeList;
  }

  Future<void> _refresh() async {
    final timeList = await NotificationService().retrieveScheduledNotifications();
    setState(() {
      _timeList = timeList;
    });
  }

  @override
  initState() {
    super.initState();
    _timeListData = _initData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _timeListData,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
          case ConnectionState.active: {
            return CircularProgressIndicator();
          }
          case ConnectionState.done: {
            if (_timeList.isEmpty) {
              return Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.add_alarm),
                    title: Text("Add a Check In Reminder"),
                    subtitle: Text("Reminds you to do your daily vibe check."),
                    onTap: () async {
                      TimeOfDay? selectedTime = await showDialog<TimeOfDay>(
                      context: context, 
                      builder: (BuildContext context) => TimePickerDialog(
                        initialTime: TimeOfDay.now(),
                        initialEntryMode: TimePickerEntryMode.input,
                        )
                      );
                      if (selectedTime != null) {
                        await NotificationService().scheduleDailyReminder(selectedTime);
                        _refresh();
                      }
                    }
                  ),
                  Card.filled(
                    child: Column(
                      children: [
                        ListTile(
                            leading: Icon(Icons.refresh),
                            title: Text("Refresh"),
                            onTap: () => _refresh()
                        ),
                        ListTile(title: Text("No Scheduled Notifications")),
                      ],
                    ),
                  )
                ],
              );
            } else {
              return Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.add_alarm),
                    title: Text("Add a Check In Reminder"),
                    subtitle: Text("Reminds you to do your daily vibe check."),
                    onTap: () async {
                      TimeOfDay? selectedTime = await showDialog<TimeOfDay>(
                      context: context, 
                      builder: (BuildContext context) => TimePickerDialog(
                        initialTime: TimeOfDay.now(),
                        initialEntryMode: TimePickerEntryMode.input,
                        )
                      );
                      if (selectedTime != null) {
                        await NotificationService().scheduleDailyReminder(selectedTime);
                        _refresh();
                      }
                    }
                  ),
                  Card.filled(
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.refresh),
                          title: Text("Refresh"),
                          onTap: () => _refresh()
                        ),
                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _timeList.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(_timeList[index].format(context)),
                              trailing: Icon(Icons.alarm_off),
                              onTap: () {
                                NotificationService().deleteScheduledReminder(_timeList[index]);
                                _refresh();
                              },
                            );
                          },
                        )
                      ],
                    ),
                  )
                ],
              );
            }
          }
        }
      }
    );
  }
}
