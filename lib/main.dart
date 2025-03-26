import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vibe_check/cards.dart';
import 'database_helper.dart';

void main() {
  runApp(const MyApp());
}

// Vibe Check App - your personal mood tracker
// by stelubertu 2025
// COMP 225 - Software Design and Development
// Professor Jedediah Carlson, Macalester College
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

/// State used to manage when to prompt the user to check in
class CheckInState extends ChangeNotifier {
  var checkInTime = DateTime.now();
  var checkInPending = false;
}

/// Main home page of the Vibe Check app
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// State for the HomePage widget
class _HomePageState extends State<HomePage> {
  var currentIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    // If a check in is pending, the check in page is displayed upon launch
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
          AnalysisPage(),
          CheckInPage(),
          PlaceholderPage(),
        ],
      ),
    );
  }
}

/// A placeholder page. TODO: Implement and remove this page
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Placeholder Page"),
    );
  }
}

/// The main page for the app, which displays the user's analysis in Cards.
class AnalysisPage extends StatelessWidget {
  const AnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    // The list of cards, which should be user editable.
    // TODO: Implement Edit page and allow user to add and remove cards, along with changing the order of the cards.
    var cardList = <Widget>[
      StreakCard(streak: 5, longestStreak: 10),
      LastDaysCard(),
      WordCloudCard()
    ];

    return Scaffold (
      appBar: AppBar (
        actions: <Widget>[
          IconButton(
            tooltip: 'Show Calendar',
            onPressed: () {},
            icon: Icon(Icons.today),
          ),
          IconButton(
            tooltip: 'Edit Layout',
            onPressed: () {},
            icon: Icon(Icons.edit)
          )
        ]
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: 1 + cardList.length,
        itemBuilder: (context, index) {
          return index == 0
            ? ListTile(
              title: Text(
                "Hello! :)",
                style: Theme.of(context).textTheme.headlineLarge),
              subtitle: Text("Welcome to Vibe Check, your personal mood tracker"),
            )
            : index == 1
              ? cardList[0]
              : cardList[index - 2];
        },
        separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 10),
      )
    );
  }
}

/// The page where the user can check in their mood.
/// Prompts the user to pick one of 6 displayed emojis and log a sentence.
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

            /// TODO: Implement Emoji Picker
            /// TODO: Implemenet Text Field
            /// TODO: Implement Check In BUtton
          ],
        ),
      ),
    );
  }
}
