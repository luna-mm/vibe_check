import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

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
        home: HomePage(),
      ),
    );
  }
}

class CheckInState extends ChangeNotifier {
  var checkInTime = DateTime.now();
  var checkInPending = false;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var currentIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    var checkInState = context.watch<CheckInState>();
    if (checkInState.checkInPending) {
      currentIndex = 1;
    }

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentIndex = index;
          });
        },
        indicatorColor: Theme.of(context).colorScheme.primary,
        selectedIndex: currentIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today),
            label: "Check In",
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
      body: IndexedStack(
        index: currentIndex,
        children: const <Widget>[
          PlaceholderPage(),
          CheckInPage(),
          PlaceholderPage(),
        ],
      ),
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Placeholder Page"),
    );
  }
}

class CheckInPage extends StatelessWidget {
  const CheckInPage({super.key});

  @override
  Widget build(BuildContext context) {
    var checkInState = context.watch<CheckInState>();
    var timestamp = checkInState.checkInTime;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Vibe Check!",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 40,
                fontStyle: FontStyle.italic,
              ),
            ),
            Text.rich(
              TextSpan(
                style: TextStyle(fontSize: 17),
                children: [
                  WidgetSpan(child: Icon(Icons.calendar_month)),
                  TextSpan(text: DateFormat(" MMM d, y ").format(timestamp)),
                  WidgetSpan(child: Icon(Icons.schedule)),
                  TextSpan(text: DateFormat(" h:mm a ").format(timestamp)),
                ],
              ),
            ),

            // TODO: Implement Emoji Picker
            // TODO: Implemenet Text Field
            // TODO: Implement Check In BUtton
          ],
        ),
      ),
    );
  }
}
