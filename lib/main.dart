import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CheckInState(),
      child: MaterialApp(
        title: "Vibe Check",
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: CheckInPage()
      )
    );
  }
}

class ActivePage extends StatefulWidget {
  const ActivePage({super.key});

  @override
  State<ActivePage> createState() => _ActivePageState();
}

class _ActivePageState extends State<ActivePage> {
  bool checkInPending = true;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (checkInPending) {
      case true:
        page = CheckInPage();
        break;
      case false:
        page = Placeholder();
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vibe Check'),
      ),
      body: page,
    );
  }
}

class CheckInState extends ChangeNotifier {
  var checkInTime = DateTime.now();
}

// TODO: Implement HomePage


class CheckInPage extends StatelessWidget {
  const CheckInPage({super.key});

  @override
  Widget build(BuildContext context) {
    var checkInState = context.watch<CheckInState>();
    var timestamp = checkInState.checkInTime;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Development Check In Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Vibe Check!",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 40,
                fontStyle: FontStyle.italic)
            ),
            Text.rich(
              TextSpan(
                style: TextStyle(
                  fontSize: 17,
                ),
                children: [
                  WidgetSpan(
                    child: Icon(Icons.calendar_month)
                  ),
                  TextSpan(
                    text: DateFormat(" MMM d, y ").format(timestamp)
                  ),
                  WidgetSpan(
                    child: Icon(Icons.schedule)
                  ),
                  TextSpan(
                    text: DateFormat(" h:mm a ").format(timestamp)
                  )
                ]
              )
            )

            // TODO: Implement Emoji Picker
            // TODO: Implemenet Text Field
            // TODO: Implement Check In BUtton
          ],
        ),
      ),
    );
  }
}