import 'package:flutter/material.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'database.dart';
import 'entry.dart';

/// State to manage when a check in is pending or performed
class CheckInState extends ChangeNotifier {
  var checkInTime = DateTime.now();
  var checkInPending = false;
}

/// Check in page is where user can select an emoji and write a description representing their mood.
class CheckInPage extends StatefulWidget {
  const CheckInPage({super.key});

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

/// State for the check in page widget
class _CheckInPageState extends State<CheckInPage> {
  String? selectedEmoji;
  TextEditingController textController = TextEditingController();
  final List<String> emojis = ['😊', '😔', '🫠', '😒', '😡', '🫢']; // List of available emojis to choose from

  // Resets the check-in by clearing the selected emoji and text input.
  void resetCheckIn() {
    setState(() {
      selectedEmoji = null;
      textController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      resizeToAvoidBottomInset: true, // Prevent UI overflow when keyboard appears
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Vibe Check!",
              style: GoogleFonts.deliusSwashCaps(
                textStyle: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
                "How are you feeling?",
                style: GoogleFonts.deliusSwashCaps(
                  textStyle: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
            ),
            SizedBox(height: 20),

            // Grid of emojis to select from
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: emojis.length,
              padding: const EdgeInsets.all(8.0),
              itemBuilder: (context, index) {
                // Toggle selected emoji when tapped
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (selectedEmoji == emojis[index]) {
                        selectedEmoji = null;
                      } else {
                        selectedEmoji = emojis[index];
                      }
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    // Highlight selected emoji
                    decoration: BoxDecoration(
                      color: selectedEmoji == emojis[index]
                          ? Theme.of(context).colorScheme.surfaceContainerHighest
                          : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
            SizedBox(height: 5),

            // Text field to describe mood
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: textController,
                decoration: InputDecoration(
                  labelText: 'Describe your mood...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ),
            SizedBox(height: 5),

            // Check in button to submit the input
            ElevatedButton(
              onPressed: () {
                // If no input, show a warning. Otherwise, save the input.
                if (selectedEmoji == null && textController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please select an emoji or enter thoughts!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  Entry newEntry = Entry(
                    id: DateTime.now(),
                    emoji: selectedEmoji ?? '',
                    sentence: textController.text,
                  );
                  context.read<Data>().addEntry(newEntry);
            
                  resetCheckIn();
            
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Checked in!'),
                      duration: Duration(seconds: 2),
                    ),
                  );

                  Confetti.launch(
                    context,
                    options: const ConfettiOptions(
                      particleCount: 100,
                      spread: 70,
                      y: 0.6,
                    ),
                  );     
                }
              },
              child: Text('Check In'),
            ),
          ],
        ),
      ),
    );
  }
}