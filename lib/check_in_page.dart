import 'package:flutter/material.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'database.dart';
import 'entry.dart';
import 'main.dart';

/// This file holds the Check-In page/prompt, its helper functions,
/// and the current Check in State of the app.

/// State to manage when to send notification
class CheckInState extends ChangeNotifier {
  var checkInTime = DateTime.now();
  var checkInPending = false;
}

/// The check in page where user can check in their mood.
class CheckInPage extends StatefulWidget {
  const CheckInPage({super.key});

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

/// State for the check in page widget
class _CheckInPageState extends State<CheckInPage> {
  String? selectedEmoji;
  TextEditingController textController = TextEditingController();
  final List<String> emojis = ['😊', '😔', '🫠', '😒', '😡', '🫢'];

  void resetCheckIn() {
    setState(() {
      selectedEmoji = null;
      textController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                            if (selectedEmoji == emojis[index]) {
                              selectedEmoji = null;
                            } else {
                              selectedEmoji = emojis[index];
                            }
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
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
                      if (selectedEmoji == null && textController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please select an emoji or describe your mood!'),
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

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );

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
          ),
        ),
      ),
    );
  }
}