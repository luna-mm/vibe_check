import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vibe_check/cards.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:vibe_check/entry.dart';
import 'database_helper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_confetti/flutter_confetti.dart';

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
          DevSettingsPage(),
        ],
      ),
    );
  }
}

// The development settings page for the app.
// Not intended for production use!
class DevSettingsPage extends StatefulWidget {
  const DevSettingsPage({super.key});

  @override
  State<DevSettingsPage> createState() => _DevSettingsPageState();
}

class _DevSettingsPageState extends State<DevSettingsPage> {
  List<Entry> _entries = [];

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

  Future<void> _fetchEntries() async {
    final entryMap = await DatabaseHelper.instance.queryAllEntries();
    setState(() {
      _entries = entryMap.map((entryMap) => Entry.fromMap(entryMap)).toList();
    });

    // Debug
    for (var entry in _entries) {
      print(entry.id);
    }
  }

  @override
  void initState() {
    _fetchEntries();
    super.initState();
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: GoogleFonts.deliusSwashCaps(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _settingsOpt(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: GoogleFonts.deliusSwashCaps(),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: GoogleFonts.deliusSwashCaps(),
        ),
      ),
      body: ListView(
        children: [
          _sectionTitle("Customization"),
          _settingsOpt(Icons.palette, "Theme", onTap: () {
            // TODO
          }),
          _settingsOpt(Icons.font_download, "Font", onTap: () {
            // TODO
          }),
          _settingsOpt(Icons.language, "Language", onTap: () {
            // TODO
          }),
          _settingsOpt(Icons.wb_sunny_outlined, "Display Mode", onTap: () {
            // TODO
          }),
          _settingsOpt(Icons.calendar_today, "Start of the Week", onTap: () {
            // TODO
          }),

          _sectionTitle("System"),
          _settingsOpt(Icons.notifications, "Notifications", onTap: () {
            // TODO
          }),

          _sectionTitle("Data"),
          ElevatedButton(
            onPressed: () {
              // TODO
            },
            child: Text("Manage My Data"),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              triggerNotification();
            },
            child: Text("Trigger Notification"),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              DatabaseHelper.instance.initializeSampleEntries();
              _fetchEntries();
            },
            child: Text("Initialize Sample Entries"),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AllEntriesWidget(entries: _entries),
                ),
              );
            },
            child: Text("View All Entries"),
          ),
        ],
      ),
    );
  }
}

/// The main page for the app, which displays the user's analysis in Cards.
class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  List<Entry> _entries = [];

  @override
  void initState() {
    _fetchEntries();
    super.initState();
  }

  Future<void> _fetchEntries() async {
    final entryMap = await DatabaseHelper.instance.queryAllEntries();
    setState(() {
      _entries = entryMap.map((entryMap) => Entry.fromMap(entryMap)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // The list of cards, which should be user editable.
    // TODO: Implement Edit page and allow user to add and remove cards, along with changing the order of the cards.
    var cardList = <Widget>[
      StreakCard(entries: _entries),
      RecapCard(entries: _entries),
      WordCloudCard(entries: _entries),
    ];

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            tooltip: 'Show Calendar',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CalendarView()),
              );
            },
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
                  style: GoogleFonts.deliusSwashCaps(
                    textStyle: Theme.of(
                      context,
                    ).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
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
                    style: GoogleFonts.deliusSwashCaps(
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
                                    ? const Color.fromARGB(255, 246, 180, 180)
                                    : const Color.fromARGB(255, 246, 228, 228),
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
                    onPressed: () async {
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
                        Confetti.launch(
                          context,
                          options: const ConfettiOptions(
                            particleCount: 100,
                            spread: 70,
                            y: 0.6,
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Checked in!'),
                            duration: Duration(seconds: 2),
                          ),
                        );

                        Entry newEntry = Entry(
                          id: DateTime.now(),
                          emoji: selectedEmoji!,
                          sentence: textController.text,
                        );

                        await DatabaseHelper.instance.insertEntry(newEntry);

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

/// Calendar view of mood check-ins for each day of the selected month.
class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  final DateTime _now = DateTime.now();
  late DateTime _firstDayOfMonth;
  late int _daysInMonth;
  DateTime? _selectedDate;

  List<Entry> _allEntries = [];
  Map<String, String> _emojiByDate = {};
  List<Entry> _selectedDateEntries = [];

  @override
  void initState() {
    super.initState();
    _firstDayOfMonth = DateTime(_now.year, _now.month, 1);
    _daysInMonth = DateTime(_now.year, _now.month + 1, 0).day;
    _selectedDate = _now;
    _fetchEntries();
  }

  Future<void> _fetchEntries() async {
    final entryMap = await DatabaseHelper.instance.queryAllEntries();
    _allEntries = entryMap.map((e) => Entry.fromMap(e)).toList();

    final Map<String, Entry> lastByDate = {};
    for (var entry in _allEntries) {
      final dateKey = DateFormat('yyyy-MM-dd').format(entry.id);
      if (!lastByDate.containsKey(dateKey) || entry.id.isAfter(lastByDate[dateKey]!.id)) {
        lastByDate[dateKey] = entry;
      }
    }

    _emojiByDate = {for (var entry in lastByDate.entries) entry.key: entry.value.emoji};
    _updateSelectedDateEntries();
  }

  void _updateSelectedDateEntries() {
    if (_selectedDate == null) return;

    final selectedKey = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    setState(() {
      _selectedDateEntries = _allEntries.where((entry) {
        return DateFormat('yyyy-MM-dd').format(entry.id) == selectedKey;
      }).toList();
    });
  }

  Future<void> _selectMonthYear() async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: _firstDayOfMonth,
      firstDate: DateTime(_now.year - 5, 1),
      lastDate: DateTime(_now.year + 5, 12),
      builder: (context, child) => Theme(
        data: _datePickerTheme(context),
        child: child!,
      ),
    );

    if (selected != null && selected != _firstDayOfMonth) {
      setState(() {
        _firstDayOfMonth = DateTime(selected.year, selected.month, 1);
        _daysInMonth = DateTime(selected.year, selected.month + 1, 0).day;
        _selectedDate = null;
      });
      _fetchEntries();
    }
  }

  ThemeData _datePickerTheme(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: colorScheme.primary,
        onPrimary: Colors.white,
        surface: colorScheme.surface,
        onSurface: colorScheme.onSurface,
        secondary: colorScheme.secondary,
        onSecondary: Colors.white,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
      ),
      dialogBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    int startWeekday = _firstDayOfMonth.weekday % 7;
    List<String> weekdayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Calendar',
          style: GoogleFonts.deliusSwashCaps(
            textStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _selectMonthYear,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat.yMMMM().format(_firstDayOfMonth),
                    style: GoogleFonts.deliusSwashCaps(
                      textStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),

            Row(
              children: weekdayNames.map((day) => Expanded(
                child: Center(
                  child: Text(day, style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.bold)),
                ),
              )).toList(),
            ),

            SizedBox(
              height: 300,
              child: GridView.builder(
                itemCount: _daysInMonth + startWeekday,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (context, index) {
                  if (index < startWeekday) return const SizedBox();

                  int day = index - startWeekday + 1;
                  DateTime date = DateTime(_firstDayOfMonth.year, _firstDayOfMonth.month, day);
                  bool isSelected = _selectedDate?.year == date.year &&
                                    _selectedDate?.month == date.month &&
                                    _selectedDate?.day == date.day;

                  String dateKey = DateFormat('yyyy-MM-dd').format(date);
                  String emoji = _emojiByDate[dateKey] ?? '🫥';

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = date;
                      });
                      _updateSelectedDateEntries();
                    },
                    child: Center(
                      child: Column(
                        children: [
                          Text(emoji, style: const TextStyle(fontSize: 24)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
                            decoration: isSelected
                                ? BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  )
                                : null,
                            child: Text(
                              day.toString(),
                              style: GoogleFonts.deliusSwashCaps(
                                textStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onBackground,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            Expanded(
              child: _selectedDateEntries.isNotEmpty
                ? ListView.builder(
                  itemCount: _selectedDateEntries.length,
                  itemBuilder: (context, index) {
                    final entry = _selectedDateEntries[index];
                    return ListTile(
                      leading: Text(entry.emoji, style: const TextStyle(fontSize: 24)),
                      title: Text(entry.sentence, style: GoogleFonts.lato()),
                      subtitle: Text(
                        DateFormat.jm().format(entry.id),
                        style: GoogleFonts.deliusSwashCaps(fontSize: 12),
                      ),
                    );
                  },
                )
                : _selectedDate != null
                  ? Center(
                    child: Text(
                      "No entries for this day.",
                      style: GoogleFonts.deliusSwashCaps(color: Colors.grey[600]),
                    ),
                  )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}