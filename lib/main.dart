import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'calendar_page.dart';
import 'cards.dart';
import 'check_in_page.dart';
import 'database.dart';

/// Vibe Check App - your personal mood tracker
/// by stelubertu 2025!
/// COMP 225 - Software Design and Development
/// Professor Paul Cantrell, Macalester College

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Data()),
        ChangeNotifierProvider(create: (_) => CheckInState()),
        ChangeNotifierProvider(create: (_) => ThemeState())
      ],
      child: const VibeCheckApp(),
    ),
  );
}

class VibeCheckApp extends StatelessWidget {
  const VibeCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeState>();

    return MaterialApp(
      title: "Vibe Check",
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: themeState.themeSeedColor),
        textTheme: themeState.currentTextTheme,
      ),
      home: const HomePage(),
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
  var currentIndex = 0;

  @override
  Widget build(BuildContext context) {
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
          SettingsPage(),
        ],
      ),
    );
  }
}

/// This widget displays "cards" that display the user's data in neat ways.
class AnalysisPage extends StatelessWidget {
  const AnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    // The list of cards, which should be user editable.
    // TODO: Implement Edit page and allow user to add and remove cards, along with changing the order of the cards.
    var cardList = <Widget>[
      StreakCard(),
      RecapCard(),
      WordCloudCard(),
    ];

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            tooltip: 'Show Calendar',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CalendarPage()),
              );
            },
            icon: Icon(Icons.today),
          ),
          IconButton(
            tooltip: 'Edit Layout',
            onPressed: () {},
            icon: Icon(Icons.edit),
          )
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: 1 + cardList.length,
        itemBuilder: (context, index) {
          return (index == 0)
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
          : (index == 1)
          ? cardList[0]
          : cardList[index - 1];
        },
        separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 10)
      )
    );
  }
}

/// A settings widget where user can customize UI, notifications and manage data
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // Wasn't sure how to refactor this properly - if there's a better way to pass
  // BuildContext to these widgets, implement it pls
  Widget _sectionTitle(String title, BuildContext context) { 
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _settingsOpt(IconData icon, String title, BuildContext context, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
          fontSize: 15,
        ),
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
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 40,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      body: ListView(
        children: [
          _sectionTitle("Customization", context),
          _settingsOpt(Icons.palette, "Theme", context, onTap: () {
            showDialog(
              context: context,
              builder: (context) => const ThemeSelectorDialog(),
            );
          }),
          _settingsOpt(Icons.font_download, "Font", context, onTap: () {
            showDialog(
              context: context,
              builder: (context) => const FontSelectorDialog(),
            );
          }),

          _settingsOpt(Icons.language, "Language", context, onTap: () {
            // TODO
          }),
          _settingsOpt(Icons.wb_sunny_outlined, "Display Mode", context, onTap: () {
            // TODO
          }),
          _settingsOpt(Icons.calendar_today, "Start of the Week", context, onTap: () {
            // TODO
          }),
          _sectionTitle("System", context),
          _settingsOpt(Icons.notifications, "Notifications", context, onTap: () {
            // TODO
          }),
          _sectionTitle("Data", context),
          _settingsOpt(Icons.notifications, "Manage My Data", context, onTap: () {
            // TODO
          }),
          // Debugging button
          ElevatedButton(
            onPressed: () {
              // TODO: Implement proper notification system
            },
            child: Text("Trigger Notification"),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              context.read<Data>().addSampleEntries();
            },
            child: Text("Initialize Sample Entries"),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AllEntriesWidget(),
                ),
              );
            },
            child: Text("View All Entries")
          )
        ]
      )
    );
  }
}

class ThemeState extends ChangeNotifier {
  Color _themeSeedColor = Colors.pink;
  String _fontKey = 'Delius Swash Caps';

  final Map<String, TextTheme Function()> _fontMap = {
    'Delius Swash Caps': GoogleFonts.deliusSwashCapsTextTheme,
    'Lato': GoogleFonts.latoTextTheme,
  };

  Color get themeSeedColor => _themeSeedColor;
  String get fontKey => _fontKey;
  List<String> get availableFonts => _fontMap.keys.toList();
  TextTheme get currentTextTheme => _fontMap[_fontKey]!();

  void updateThemeSeedColor(Color color) {
    _themeSeedColor = color;
    notifyListeners();
  }

  void updateFontKey(String key) {
    if (_fontMap.containsKey(key)) {
      _fontKey = key;
      notifyListeners();
    }
  }

  TextStyle? previewFont(String key) {
    return _fontMap[key]?.call().bodyLarge;
  }
}

class ThemeSelectorDialog extends StatefulWidget {
  const ThemeSelectorDialog({super.key});

  @override
  State<ThemeSelectorDialog> createState() => _ThemeSelectorDialogState();
}

class _ThemeSelectorDialogState extends State<ThemeSelectorDialog> {
  late Color pickerColor;
  final _hexController = TextEditingController();
  final _rController = TextEditingController();
  final _gController = TextEditingController();
  final _bController = TextEditingController();

  @override
  void initState() {
    super.initState();
    pickerColor = context.read<ThemeState>().themeSeedColor;
    _updateTextControllers(pickerColor);
  }

  void _updateTextControllers(Color color) {
    final hex = color.value.toRadixString(16).padLeft(8, '0').toUpperCase();
    _hexController.text = '#${hex.substring(2)}';
    _rController.text = color.red.toString();
    _gController.text = color.green.toString();
    _bController.text = color.blue.toString();
  }

  void _onHexChanged(String value) {
    final hex = value.replaceAll('#', '');
    if (hex.length == 6) {
      try {
        final color = Color(int.parse('FF$hex', radix: 16));
        setState(() {
          pickerColor = color;
          _updateTextControllers(color);
        });
      } catch (_) {}
    }
  }

  void _onRGBChanged() {
    try {
      final r = int.parse(_rController.text);
      final g = int.parse(_gController.text);
      final b = int.parse(_bController.text);
      if (r >= 0 && r <= 255 && g >= 0 && g <= 255 && b >= 0 && b <= 255) {
        final color = Color.fromARGB(255, r, g, b);
        setState(() {
          pickerColor = color;
          _updateTextControllers(color);
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Color Scheme',
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (color) {
                setState(() {
                  pickerColor = color;
                  _updateTextControllers(color);
                });
              },
              enableAlpha: false,
              pickerAreaHeightPercent: 0.7,
              displayThumbColor: true,
              labelTypes: const [],
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _hexController,
              decoration: const InputDecoration(
                labelText: 'Hex (#RRGGBB)',
                border: OutlineInputBorder(),
              ),
              onChanged: _onHexChanged,
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _rController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'R'),
                    onChanged: (_) => _onRGBChanged(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _gController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'G'),
                    onChanged: (_) => _onRGBChanged(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _bController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'B'),
                    onChanged: (_) => _onRGBChanged(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            context.read<ThemeState>().updateThemeSeedColor(pickerColor);
            Navigator.pop(context);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

class FontSelectorDialog extends StatelessWidget {
  const FontSelectorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final themeState = context.read<ThemeState>();
    final currentFont = themeState.fontKey;

    return AlertDialog(
      title: Text(
        'Text Theme',
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: themeState.availableFonts.map((fontName) {
            return ListTile(
              title: Text(
                fontName,
                style: themeState.previewFont(fontName),
              ),
              trailing: fontName == currentFont ? const Icon(Icons.check) : null,
              onTap: () {
                themeState.updateFontKey(fontName);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
