import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibe_check/notification_service.dart';
import 'package:vibe_check/preferences.dart';
import 'package:vibe_check/settings_page.dart';
import 'calendar_page.dart';
import 'cards.dart';
import 'check_in_page.dart';
import 'database.dart';

/// Vibe Check App - your personal mood tracker
/// by stelubertu 2025!
/// COMP 225 - Software Design and Development
/// Professor Paul Cantrell, Macalester College

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Data()),
        ChangeNotifierProvider(create: (_) => Preferences()),
        ChangeNotifierProvider(create: (_) => CheckInState())
      ],
      child: const VibeCheckApp(),
    ),
  );
}

class VibeCheckApp extends StatelessWidget {
  const VibeCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = ColorScheme.fromSeed(seedColor: context.watch<Preferences>().accentColor);
    TextTheme textTheme = context.watch<Preferences>().textTheme;
    return MaterialApp(
      title: "Vibe Check",
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        textTheme: textTheme.copyWith(
          headlineLarge: GoogleFonts.deliusSwashCaps().copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
            fontSize: 40
          ),
          headlineMedium: GoogleFonts.deliusSwashCaps().copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary
          )
        )
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage()
    );
  }
}

/// The main navigation UI.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            selectedIndex = index;
          });
        },
        selectedIndex: selectedIndex,
        destinations: const <Widget>[
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(icon: Icon(Icons.calendar_month), label: "Calendar"),
          NavigationDestination(icon: Icon(Icons.settings), label: "Settings"),
        ]
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: const <Widget>[
          AnalysisPage(),
          CalendarPage(),
          SettingsPage(),
        ],
      ),
    );
  }
}

/// This widget displays "cards" that display the user's data in neat ways.
class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  bool _editMode = false;
  // The list of cards.
  late List<Widget> cardList = [
    StreakCard(),
    RecapCard(),
    WordCloudCard()
  ];

  // The list of deleted cards
  late List<Widget> deletedCards = [];

  String _getCardTitle(Widget card) {
    if (card is StreakCard) {
      return "Current Streak";
    } else if (card is RecapCard) {
      return "Recap - Last 5 days";
    } else if (card is WordCloudCard) {
      return "Wordcloud";
    } else {
      return "Unknown Card"; 
    }
  }

  void _showRestoreDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select a card to restore"),
          content: SizedBox(
            height: 200,
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: deletedCards.length,
              itemBuilder: (context, index) {
                final cardTitle = _getCardTitle(deletedCards[index]);
                return ListTile(
                  title: Text(cardTitle),
                  onTap: () {
                    setState(() {
                      cardList.add(deletedCards[index]);
                      deletedCards.removeAt(index);
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    List<int> order = context.watch<Preferences>().cardOrder;
    cardList = [];
    deletedCards = [];
    if (!order.contains(0)) deletedCards.add(StreakCard());
    if (!order.contains(1)) deletedCards.add(RecapCard());
    if (!order.contains(2)) deletedCards.add(WordCloudCard());

    for (int id in order) {
      if (id == 0) {
        cardList.add(StreakCard());
      } else if (id == 1) {
        cardList.add(RecapCard());
      } else if (id == 2) {
        cardList.add(WordCloudCard());
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        actions: <Widget>[
          if (_editMode) IconButton(
            icon: Text("Editing: Hold to drag, swipe left to delete"),
            onPressed: () {},
          ),
          IconButton(
            tooltip: _editMode ? 'Exit Edit Mode' : 'Edit Layout',
            onPressed: () {
              setState(() {
                _editMode = !_editMode;
              });
              // Save order to user preferences
              List<int> cardOrder = [];
              for (Widget card in cardList) {
                if (card is StreakCard) cardOrder.add(0);
                if (card is RecapCard) cardOrder.add(1);
                if (card is WordCloudCard) cardOrder.add(2);
              }
              context.read<Preferences>().setCardOrder(cardOrder);
            },
            icon: Icon(_editMode ? Icons.check : Icons.edit),
          ),
        ],
      ),
      floatingActionButton: Visibility(
        visible: !_editMode,
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const CheckInPage()));
          },
          icon: Icon(Icons.add),
          label: Text("Check In")
        ),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text(
              "Vibe Check",
              style: TextTheme.of(context).headlineLarge
            ),
            subtitle: Text("Here are your stats!"),
          ),
          Expanded(
            child: _editMode
                ? ReorderableListView(
                    buildDefaultDragHandles: false,
                    padding: const EdgeInsets.all(8),
                    onReorder: (int oldIndex, int newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) newIndex -= 1;
                        final item = cardList.removeAt(oldIndex);
                        cardList.insert(newIndex, item);
                      });
                    },
                    children: List.generate(cardList.length, (index) {
                      return Dismissible(
                        key: ValueKey(cardList[index]),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          setState(() {
                            deletedCards.add(cardList[index]);
                            cardList.removeAt(index);
                          });
                        },
                        background: Container(
                          color: const Color.fromARGB(238, 179, 31, 31),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: cardList[index]),
                            ReorderableDelayedDragStartListener(index: index, child: Container(
                                padding: EdgeInsets.all(10.0),
                                child: Icon(Icons.drag_handle),
                              )
                            )
                          ]
                        ),
                      );
                    }),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: cardList.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          cardList[index],
                        ],
                      );
                    },
                  ),
          ),
          if (_editMode && deletedCards.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _showRestoreDialog,
                child: Text("Restore Deleted Cards"),
              ),
            ),
        ],
      ),
    );
  }
}