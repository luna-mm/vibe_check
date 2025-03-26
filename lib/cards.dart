import 'package:flutter/material.dart';

/// This file contains various "cards", widgets displayed on the Analysis page
/// that display the user's statistics in varying ways.

/// Card that displays the user's current and longest streaks
class StreakCard extends StatelessWidget {
  final int streak;
  final int longestStreak;

  const StreakCard({
    required this.streak,
    required this.longestStreak,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            /// TODO: Add text formatting (from theme)
            title: Text("Current Streak"),
            subtitle: Text("$streak days"),
          ),
          ListTile(
            title: Text("Longest Streak"),
            subtitle: Text("$longestStreak days"),
          ),
        ],
      ),
    );
  }
}

/// Card that displays the user's emojis in the last 7 days
class LastDaysCard extends StatelessWidget {
  const LastDaysCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text("Last 7 Days"),
            subtitle: Text("In progress"), /// TODO: Implement
          ),
        ],
      ),
    );
  }
}

/// Card that displays a wordcloud of the user's entries the last 7 days
class WordCloudCard extends StatelessWidget {
  const WordCloudCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card (
      child: Column (
        children: <Widget>[
          ListTile(
            title: Text("Wordcloud"),
            subtitle: Text("In progress") /// TODO: Implement
          )
        ]
      )
    );
  }
}
