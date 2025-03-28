import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vibe_check/cards.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'database_helper.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelKey: 'test_channel',
      channelName: 'Test Notifications',
      channelDescription: 'Our first of many notifications!',
    ),
  ]);

  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseHelper.instance.initDb();
  await DatabaseHelper.instance
      .initializeSampleEntries(); // For presentation on Friday

  runApp(const MyApp());
}

// Vibe Check App - your personal mood tracker
// by stelubertu 2025!
// COMP 225 - Software Design and Development
// Professor Paul Cantrell, Macalester College
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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
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

  // Ask the user for permission to send notifications.
  @override
  void initState() {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    super.initState();
  }

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
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(
            icon: Icon(Icons.calendar_today),
            label: "Check In",
          ),
          NavigationDestination(icon: Icon(Icons.settings), label: "Settings"),
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

  triggerNotification() {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: "test_channel",
        title: "Vibe Check! (soon™)",
        body: "Check in with yourself, what vibes are you feeling right now?",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: triggerNotification,
          child: const Text('Notify me!'),
        ),
      ),
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
      LastDaysCard(emojis: List<String>.filled(1, "Incomplete")),
      WordCloudCard(),
    ];

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            tooltip: 'Show Calendar',
            onPressed: () {},
            icon: Icon(Icons.today),
          ),
          IconButton(
            tooltip: 'Edit Layout',
            onPressed: () {},
            icon: Icon(Icons.edit),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: 1 + cardList.length,
        itemBuilder: (context, index) {
          return index == 0
              ? ListTile(
                title: Text(
                  "Vibe Check",
                  style: GoogleFonts.delius(
                    textStyle: Theme.of(
                      context,
                    ).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                subtitle: Text("Here are your stats!"),
              )
              : index == 1
              ? cardList[0]
              : cardList[index - 1];
        },
        separatorBuilder:
            (BuildContext context, int index) => const SizedBox(height: 10),
      ),
    );
  }
}

/// The page where the user can check in their mood.
/// Prompts the user to pick one of 6 displayed emojis and log a sentence.
class CheckInPage extends StatefulWidget {
  const CheckInPage({super.key});

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  String? selectedEmoji;
  TextEditingController textController = TextEditingController();

  // The list of emojis that user can choose from
  final List<String> emojis = ['😊', '😔', '🫠', '😒', '😡', '🫢'];

  void resetCheckIn() {
    setState(() {
      selectedEmoji = null;
      textController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    var checkInState = context.watch<CheckInState>();
    var timestamp = checkInState.checkInTime;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Vibe Check!",
                    style: GoogleFonts.delius(
                      textStyle: Theme.of(
                        context,
                      ).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text.rich(
                    TextSpan(
                      style: TextStyle(fontSize: 17),
                      children: [
                        WidgetSpan(child: Icon(Icons.calendar_month)),
                        TextSpan(
                          text: DateFormat(" MMM d, y ").format(timestamp),
                        ),
                        WidgetSpan(child: Icon(Icons.schedule)),
                        TextSpan(
                          text: DateFormat(" h:mm a ").format(timestamp),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: emojis.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedEmoji = emojis[index];
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color:
                                selectedEmoji == emojis[index]
                                    ? const Color.fromARGB(255, 198, 180, 246)
                                    : const Color.fromARGB(255, 233, 228, 246),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            emojis[index],
                            style: TextStyle(fontSize: 40),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20),

                  TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      labelText: 'Describe your mood...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      if (selectedEmoji == null &&
                          textController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Please select an emoji and describe your mood!',
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Checked in!'),
                            duration: Duration(seconds: 2),
                          ),
                        );

                        // TODO: Save check-in data to the database.

                        resetCheckIn();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      }
                    },
                    child: Text('Check In'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
