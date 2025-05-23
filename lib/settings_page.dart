import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
// import 'package:vibe_check/cards.dart';
import 'package:vibe_check/database.dart';
import 'package:vibe_check/notification_settings_page.dart';
import 'package:vibe_check/preferences.dart';

/// Settings page is where user can customize UI, notifications and manage data
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(style: TextTheme.of(context).headlineMedium, "Settings"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(style: TextTheme.of(context).headlineSmall, "Theme"),
          ListTile(
            leading: Icon(Icons.palette),
            title: Text('Set Accent Color'),
            onTap: () => colorPickerDialog(context)
          ),
          ListTile(
            leading: Icon(Icons.phone_android),
            title: Text('Use System Colors'),
            subtitle: Text('Only available on certain devices.'),
            trailing: Switch(
              value: context.watch<Preferences>().usingSystemColor,
              onChanged: (context.read<Preferences>().isSystemColorAvailable)
              ? (bool value) => context.read<Preferences>().setUsingSystemColor(value)
              : null
            )
          ),
          ListTile(
            leading: Icon(Icons.font_download),
            title: Text('Set Font'),
            onTap: () => fontSelectorDialog(context)
          ),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text('Start of the Week'),
            onTap: () => startOfWeekDialog(context)
          ),
          Text(style: TextTheme.of(context).headlineSmall, "System"),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Manage Notifications'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => NotificationSettingsPage()))
          ),
          ListTile(
            leading: Icon(Icons.co_present),
            title: Text('Create sample data'),
            subtitle: Text('For use when demoing the app.'),
            onTap: () {
              context.read<Data>().addSampleEntries();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Added some sample entries!'),
                  duration: Duration(seconds: 2),
                )
              );
            }
          ),
          // ListTile(
          //   leading: Icon(Icons.developer_mode),
          //   title: Text('View Entries'),
          //   subtitle: Text('For developers :3 See all items in database.'),
          //   onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => AllEntriesWidget()))
          // )
        ]
      )
    );
  }
}

/// Function to show the color picker dialog for selecting accent color
void colorPickerDialog(BuildContext context) {
  // Get user preference for color
  Color pickedColor = context.read<Preferences>().accentColor;

  // Controllers for the color input fields
  var hexController = TextEditingController();
  var rController = TextEditingController();
  var gController = TextEditingController();
  var bController = TextEditingController();

  // Update text fields based on selected color
  void updateTextControllers(Color color) {
    final hex = color.toHexString();
    hexController.text = '#${hex.substring(2)}';
    rController.text = '${(color.r * 255).toInt()}';
    gController.text = '${(color.g * 255).toInt()}';
    bController.text = '${(color.b * 255).toInt()}';
  }

  // Update color on hex change
  void onHexChanged(String value) {
    final hex = value.replaceAll('#', '');
    if (hex.length == 6) {
      try {
        final color = Color(int.parse('FF$hex', radix: 16));
        pickedColor = color;
        updateTextControllers(color);
      } catch (_) {}
    }
  }

  // Update color on rgb change
  void onRGBChanged() {
    try {
      final r = int.parse(rController.text);
      final g = int.parse(gController.text);
      final b = int.parse(bController.text);
      if (r >= 0 && r <= 255 && g >= 0 && g <= 255 && b >= 0 && b <= 255) {
        final color = Color.fromARGB(255, r, g, b);
        pickedColor = color;
        updateTextControllers(color);
      }
    } catch (_) {}
  }

  // Initialize the text fields with current color values
  updateTextControllers(pickedColor);

  // Show the color picker dialog
  showDialog<void> (
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Color Scheme'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Color picker widget for selecting a color
              ColorPicker(
                pickerColor: pickedColor,
                onColorChanged: (color) {
                  pickedColor = color;
                  updateTextControllers(color);
                },
                enableAlpha: false,
                pickerAreaHeightPercent: 0.7,
                displayThumbColor: true,
                labelTypes: const [],
              ),
              const SizedBox(height: 16),
    
              // Hex input field
              TextField(
                controller: hexController,
                decoration: const InputDecoration(
                  labelText: 'Hex (#RRGGBB)',
                  border: OutlineInputBorder(),
                ),
                onChanged: onHexChanged,
              ),
              const SizedBox(height: 12),
    
              // RGB input field
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: rController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'R'),
                      onChanged: (_) => onRGBChanged(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: gController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'G'),
                      onChanged: (_) => onRGBChanged(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: bController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'B'),
                      onChanged: (_) => onRGBChanged(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          // Button to reset color to default pink
          TextButton(
            onPressed: () {
              context.read<Preferences>().setAccentColor(Colors.pink);
              Navigator.pop(context);
            },
            child: const Text('Reset')
          ),
          // Button to close dialog without changes
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          // Button to apply the selected color
          TextButton(
            onPressed: () {
              context.read<Preferences>().setAccentColor(pickedColor);
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      );
    }
  );
}

/// Function to show the font selector dialog
void fontSelectorDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'Text Theme',
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(title: Text('Lato'), onTap: () {
                context.read<Preferences>().setFont('Lato');
                Navigator.pop(context);
              }),
              ListTile(title: Text('Delius Swash Caps'), onTap: () {
                context.read<Preferences>().setFont('Delius Swash Caps');
                Navigator.pop(context);
              })
            ]
          )
        ),
        actions: [
          TextButton(child: Text('Cancel'), onPressed: () => Navigator.pop(context))
        ]
      );
    }
  );
}

/// Function to show the startWeek selector dialog
void startOfWeekDialog(BuildContext context) {
  final current = context.read<Preferences>().startOfWeek;
  final days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

  showDialog<void>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text("Start of the Week"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(7, (index) {
          return RadioListTile<int>(
            value: index,
            groupValue: current,
            title: Text(days[index]),
            onChanged: (value) {
              if (value != null) {
                context.read<Preferences>().setStartOfWeek(value);
                Navigator.pop(context);
              }
            },
          );
        }),
      ),
      actions: [
          TextButton(child: Text('Cancel'), onPressed: () => Navigator.pop(context))
        ]
    )
  );
}