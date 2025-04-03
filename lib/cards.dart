import 'package:flutter/material.dart';
import 'package:vibe_check/entry.dart';

/// This file contains various "cards", widgets displayed on the Analysis page
/// that display the user's statistics in varying ways.

/// For development purposes only
/// Card that displays all entries in the database
class AllEntriesWidget extends StatelessWidget {
  final List<Entry> entries;
  
  const AllEntriesWidget({
    required this.entries,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Entries"),
      ),
      body: ListView.builder(
        itemCount: entries.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Entry ${index + 1}'),
            subtitle: Text(entries[index].toString())
          );
        },
      )
    );
  }
}

/// Card that displays the user's current and longest streaks
class StreakCard extends StatelessWidget {
  final List<Entry> entries;

  const StreakCard({
    required this.entries,
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
            subtitle: Text("${entries.length} days"),
          ),
          ListTile(
            title: Text("Longest Streak"),
            subtitle: Text("${entries.length} days"),
          ),
        ],
      ),
    );
  }
}

/// Card that displays the user's emojis in the last 7 days
class LastDaysCard extends StatelessWidget {
  final List<Entry> entries;

  const LastDaysCard({
    required this.entries,
    super.key
  });

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
  final List<Entry> entries;
  
  const WordCloudCard({
    required this.entries,
    super.key
  });

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
